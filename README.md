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

## Notifications

Local notifications are powered by `flutter_local_notifications`. The
`NotificationService` is initialized in `main.dart` and automatically polls the
`/quotes/latest` endpoint every 15 minutes. When a new quote is found a
notification is shown and tapping it opens the quote detail screen.
The app also polls `/music/latest` every 15 minutes to update the home screen
with the newest song recommendation.

On Android the default app icon is used for the notification. No additional
configuration is required other than granting notification permissions on first
launch.

## Backend Setup

1. Create and activate a Python virtual environment:

```bash
python -m venv venv
source venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Provide Spotify API credentials in a `.env` file inside `backend/`:

```bash
SPOTIFY_CLIENT_ID=<your-client-id>
SPOTIFY_CLIENT_SECRET=<your-client-secret>
```

4. Start the development server **from inside** the `backend/` directory to avoid
   `ModuleNotFoundError`:

```bash
cd backend && uvicorn app.main:app --reload
```
> **Note**: If you run `uvicorn` from outside `backend/`, export `PYTHONPATH=backend` or run `python -m uvicorn app.main:app --reload`.

Once running you can try the music search endpoint or request a recommendation.
The `/music/recommend` route analyzes your latest five journal entries with
OpenRouter to produce a song keyword and then searches Spotify:

```bash
# search by mood
curl "http://localhost:8000/api/v1/music?mood=happy" -H "Authorization: Bearer <token>"

# get a song based on your last five journals
    curl http://localhost:8000/api/v1/music/recommend \
     -H "Authorization: Bearer <token>"

# fetch the most recently scheduled recommendation
curl http://localhost:8000/api/v1/music/latest
```

### Spotify Web API

Music search now relies on the [Spotify Web API](https://developer.spotify.com/documentation/web-api/).
Create a developer application on the Spotify dashboard and provide its
client credentials in your `.env` file as shown above.

### YouTube Audio Service

Recommended tracks returned by the backend include a `youtube_id` field. The
Flutter client resolves this ID to a playable stream using
`lib/services/youtube_audio_service.dart`. The service fetches the available
audio streams with `youtube_explode_dart`, sorts them by bitrate and returns the
highest quality URL. No additional YouTube API key is required.

Audio suggestions come from the `/music/recommend` endpoint which analyses the
latest journal entries through OpenRouter to generate a search keyword. That
keyword is used to query Spotify and the resulting track IDs are then passed to
`YoutubeAudioService` for playback.

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
python backend/app/db/seed.py
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
- `SPOTIFY_CLIENT_ID` – Spotify Web API client ID.
- `SPOTIFY_CLIENT_SECRET` – Spotify Web API client secret.


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
SPOTIFY_CLIENT_ID=
SPOTIFY_CLIENT_SECRET=
```

After creating `.env` you can verify the setup with:

```bash
python backend/check_env.py
```

This script ensures `OPENROUTER_API_KEY` and the Spotify credentials are defined.

## Usage


Start the backend and then run the Flutter app. By default the client expects the
API to be available at `http://localhost:8000/api/v1/`. When running on an Android
emulator the app automatically switches to `http://10.0.2.2:8000/api/v1/` so the
backend can still be reached from the virtual device.

### App Usage

Long‑press any message in the conversation to enter selection mode. A delete icon will appear in the top bar so you can remove the selected messages, similar to how WhatsApp handles chat message deletion. The home screen now automatically shows a recommended song based on your latest journals.

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

- Use the commit message style `<type>(<scope>): <description>` as outlined in `AGENTS.md`. For example: `fix(ui): resolve newline issues`.

## License

This project is licensed under the [MIT License](LICENSE).


