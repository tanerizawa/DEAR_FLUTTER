from sqlalchemy.orm import Session
from sqlalchemy import desc
from .base import CRUDBase
from app.models.motivational_quote import MotivationalQuote
from app.schemas.motivational_quote import MotivationalQuoteCreate, MotivationalQuoteUpdate

class CRUDMotivationalQuote(CRUDBase[MotivationalQuote, MotivationalQuoteCreate, MotivationalQuoteUpdate]):
    def get_latest(self, db: Session) -> MotivationalQuote | None:
        return db.query(self.model).order_by(desc(self.model.id)).first()

motivational_quote = CRUDMotivationalQuote(MotivationalQuote)
