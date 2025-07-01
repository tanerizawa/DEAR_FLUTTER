#!/bin/bash
# Install backend test requirements for Dear Diary
set -e
pip install -r backend/requirements.txt
pip install pytest pytest-asyncio
