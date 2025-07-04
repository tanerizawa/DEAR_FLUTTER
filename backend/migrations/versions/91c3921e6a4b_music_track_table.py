"""add music track table

Revision ID: 91c3921e6a4b
Revises: 5fd8dcb3eb33
Create Date: 2025-07-02 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "91c3921e6a4b"
down_revision: Union[str, Sequence[str], None] = "5fd8dcb3eb33"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "musictracks",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("title", sa.String(), nullable=True),
        sa.Column("youtube_id", sa.String(), nullable=True),
        sa.Column("artist", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_musictracks_id"), "musictracks", ["id"], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f("ix_musictracks_id"), table_name="musictracks")
    op.drop_table("musictracks")
