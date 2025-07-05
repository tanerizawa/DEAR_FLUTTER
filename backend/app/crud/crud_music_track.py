from sqlalchemy.orm import Session
from sqlalchemy import desc

from .base import CRUDBase
from app.models.music_track import MusicTrack
from app.schemas.audio import AudioTrackCreate, AudioTrackUpdate


class CRUDMusicTrack(CRUDBase[MusicTrack, AudioTrackCreate, AudioTrackUpdate]):
    def create(self, db: Session, *, obj_in: AudioTrackCreate) -> MusicTrack:
        data = obj_in.model_dump(exclude={"cover_url"})
        db_obj = MusicTrack(**data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_latest(self, db: Session) -> MusicTrack | None:
        return db.query(self.model).order_by(desc(self.model.created_at)).first()

    def get_latest_done(self, db: Session) -> MusicTrack | None:
        """Get the latest music track with status 'done' and valid fields."""
        return (
            db.query(self.model)
            .filter(self.model.status == 'done')
            .filter(self.model.title.isnot(None))
            .filter(self.model.youtube_id.isnot(None))
            .filter(self.model.stream_url.isnot(None))
            .order_by(desc(self.model.created_at))
            .first()
        )


music_track = CRUDMusicTrack(MusicTrack)
