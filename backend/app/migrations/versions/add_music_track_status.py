"""
Revision ID: add_music_track_status
Revises: 
Create Date: 2025-07-05
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    op.add_column('musictrack', sa.Column('status', sa.String(), nullable=True, server_default='done'))

def downgrade():
    op.drop_column('musictrack', 'status')
