# Dear Diary

## Overview

**Dear Diary** is a personal journaling application consisting of:

- **Flutter frontend**: A cross-platform client written in Dart. The source lives under `lib/`.
- **FastAPI backend**: Provides RESTful endpoints for authentication and journal management. The source is in `backend/app/`.

### Architecture

The Flutter app follows the BLoC pattern and communicates with the backend using Dio. Drift is used for local persistence and dependency injection is handled via `get_it` and `injectable`. The backend is a FastAPI project using SQLAlchemy ORM and JWT based authentication.

## Flutter Setup

Install Flutter from the [official instructions](https://docs.flutter.dev/get-started/install) and fetch the project dependencies:

```bash
flutter pub get
```
If packages appear outdated, run `flutter pub upgrade` to refresh cached
dependencies, especially for `flutter_local_notifications`.

Generate the dependency injection configuration so `configureDependencies()` can resolve providers at runtime:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
If Flutter is not available you can also run `dart run build_runner build`.

Hive is used to store playback history. The box is opened automatically when
`main()` runs, so no manual setup is required beyond ensuring the generated
code is built.

Run the application on an attached device or emulator:

```bash
flutter run
```

### Android build issues

If the build fails with an error such as:

```
Dependency ':flutter_local_notifications' requires desugar_jdk_libs version to be 2.1.4 or above
```

Edit `android/app/build.gradle` and ensure desugaring is enabled:

```gradle
android {
    compileOptions {
        coreLibraryDesugaringEnabled true
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```
Then run `flutter clean` followed by `flutter run`.

Recent versions of `just_audio` have removed the ExoPlayer "hidden method"
warnings during builds. If you still encounter them, upgrade `just_audio` to at
least version `0.10.4` and run `flutter pub upgrade`.

## Notifications

Local notifications are powered by `flutter_local_notifications`. The
`NotificationService` is initialized in `main.dart` and automatically polls the
`/quotes/latest` endpoint every 15 minutes. When a new quote is found a
notification is shown and tapping it opens the quote detail screen.

The backend runs a Celery task named `generate_music_recommendation_task`
every 15 minutes. It stores its result in `/music/latest`, and the Flutter app
polls this endpoint on the same schedule to update the home screen with the
newest track.

On Android the default app icon is used for the notification. No additional
configuration is required other than granting notification permissions on first
launch.

## Backend Setup

1. Change to the `backend/` directory and create a Python virtual environment:

```bash
cd backend
python -m venv venv
source venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Start the development server **from inside** the `backend/` directory to avoid
   `ModuleNotFoundError`:

```bash
uvicorn app.main:app --reload
```
> **Note**: If you run `uvicorn` from outside `backend/`, export `PYTHONPATH=backend` or run `python -m uvicorn app.main:app --reload`.

Start the Celery worker and beat alongside Uvicorn so background tasks such as
`generate_music_recommendation_task` can store new quotes and tracks:

```bash
celery -A app.celery_app.celery_app worker --loglevel=info
celery -A app.celery_app.celery_app beat --loglevel=info
```

### YouTube Audio Service

Recommended tracks returned by the backend include a `youtube_id` field. The
Flutter client resolves this ID to a playable audio stream using
`lib/services/youtube_audio_service.dart`. The service keeps a single
`YoutubeExplode` client around and queries the manifest for audio-only streams.
Only streams up to 160 kbps are considered and the highest quality URL within
that range is returned. No
YouTube API key is required.

The latest track is fetched from the `/music/latest` endpoint which already
includes a `youtube_id`. That ID is resolved by `YoutubeAudioService` into a
playable URL for the audio player.

To play the resolved URL using `just_audio` through `audio_service`:

```dart
final handler = getIt<AudioPlayerHandler>();
await handler.playFromYoutubeId(track.youtubeId);
```

Below is a minimal snippet that mirrors the quick-start example from the
`just_audio` documentation:

```dart
final player = AudioPlayer();
await player.setUrl('https://example.com/foo.mp3');
await player.play();
```

The `AudioPlayerScreen` widget obtains an `AudioPlayerHandler` instance and
triggers playback as above. Background audio is enabled in `main.dart` by
initializing `AudioService` with an `AudioServiceConfig` that defines the
Android notification channel. Ensure `just_audio` and `audio_service` are listed
as dependencies in `pubspec.yaml`.

### Database Migrations

Alembic handles schema migrations. Common commands:

```bash
# create a new revision after editing models
alembic revision --autogenerate -m "<description>"

# apply migrations
alembic upgrade head
```
Ensure the `DATABASE_URL` environment variable is set before running
`alembic upgrade head`; the migration script reads this value to connect
to your database.
### Loading Sample Data

After applying migrations you can populate some example articles, audio tracks and motivational quotes. Run the seeding script:

```bash
python app/db/seed.py
```


### Environment Variables

The backend reads several variables from the environment. Provide a
`.env` file with these values:

- `DATABASE_URL` – SQLAlchemy database URL (defaults to SQLite `sqlite:///./test.db`).
- `SECRET_KEY` – secret key used for JWT creation (defaults to `supersecretkey`).
- `OPENROUTER_API_KEY` – API key for the OpenRouter chat and music recommendation service (required for `/music/recommend`).
- `PLANNER_MODEL_NAME` – model name used by the conversation planner.
- `GENERATOR_MODEL_NAME` – model name used by the response generator.
- `APP_SITE_URL` – site URL sent in OpenRouter requests for identification.
- `APP_NAME` – application name reported to OpenRouter when making requests.


To use the AI features you need an OpenRouter account. Sign up at
[OpenRouter](https://openrouter.ai) and generate an API key from the dashboard.
Example models that work well are `mistralai/mistral-7b-instruct` for the planner
and `google/gemma-7b-it` for the generator.

Create a `.env` file inside the `backend/` directory and define these variables:

```bash
OPENROUTER_API_KEY=<your-key>
PLANNER_MODEL_NAME=mistralai/mistral-7b-instruct
GENERATOR_MODEL_NAME=google/gemma-7b-it
APP_SITE_URL=https://yourdomain.com
APP_NAME=Dear Diary
```

After creating `.env` you can verify the setup with:

```bash
python check_env.py
```

This script ensures `OPENROUTER_API_KEY` is defined.

## Usage


Start the backend and then run the Flutter app. By default the client expects the
API to be available at `http://localhost:8000/api/v1/`. When running on an Android
emulator the app automatically switches to `http://10.0.2.2:8000/api/v1/` so the
backend can still be reached from the virtual device.

### App Usage

Long‑press any message in the conversation to enter selection mode. A delete icon will appear in the top bar so you can remove the selected messages, similar to how WhatsApp handles chat message deletion. The home screen now automatically shows the latest track provided by the backend.

### Authentication workflow

Before using the chat endpoint you must create an account and obtain an access token:

1. Register:
   ```bash
   curl -X POST http://localhost:8000/api/v1/auth/register \
        -H "Content-Type: application/json" \
        -d '{"username": "test", "email": "test@example.com", "password": "secret"}'
   ```
2. Login and store the returned `access_token`:
   ```bash
   curl -X POST http://localhost:8000/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"email": "test@example.com", "password": "secret"}'
   ```
3. Optionally verify the token by fetching the current user:
   ```bash
   curl http://localhost:8000/api/v1/users/me \
        -H "Authorization: Bearer <token>"
   ```
4. Use the token when calling `/chat/`:
   ```bash
   curl -X POST http://localhost:8000/api/v1/chat/ \
        -H "Authorization: Bearer <token>" \
        -H "Content-Type: application/json" \
        -d '{"message": "Halo"}'
   ```

The chat endpoint performs a basic emotion analysis on each message. The detected label is saved with the chat history and influences the AI planner and generator prompts.

## Running Tests

Before running the tests you must install the backend requirements:

```bash
pip install -r backend/requirements.txt
pip install pytest pytest-asyncio
```

You can also use the helper script:

```bash
./scripts/install-test-deps.sh
```

Run the suite with:

```bash
pytest backend/tests
```

Alternatively you can simply run `make test` which installs the requirements and executes `pytest` for you.

## Contributing

Contributions are welcome! Please open issues or pull requests on GitHub. Make sure to format code and provide tests where relevant.

- See [docs/CONFIG_NOTES.md](docs/CONFIG_NOTES.md) for how to document any configuration changes.

- Use the commit message style `<type>(<scope>): <description>` as outlined in `AGENTS.md`. For example: `fix(ui): resolve newline issues`.

## Profiling

See [docs/PROFILING.md](docs/PROFILING.md) for details on API and audio performance.
For information on Android buffering logs and tuning ExoPlayer, see
[docs/AUDIO_BUFFERING.md](docs/AUDIO_BUFFERING.md).

## License

This project is licensed under the [MIT License](LICENSE).


