# Dockerfile

# 1. Gunakan image Python resmi sebagai dasar
# Pilih versi yang sesuai dengan pengembangan Anda, 3.11 adalah pilihan yang baik dan modern
FROM python:3.11-slim

# 2. Tetapkan direktori kerja di dalam kontainer
WORKDIR /app

# 3. Tetapkan variabel lingkungan
# Mencegah Python menulis file .pyc untuk menjaga image tetap bersih
ENV PYTHONDONTWRITEBYTECODE=1
# Memastikan output dari Python tidak di-buffer, sehingga log langsung terlihat
ENV PYTHONUNBUFFERED=1

# 4. Instal dependensi sistem jika ada (saat ini tidak ada, tapi ini tempatnya)
# RUN apt-get update && apt-get install -y ...

# 5. Instal dependensi Python
# Salin file requirements.txt terlebih dahulu untuk memanfaatkan caching Docker
COPY requirements.txt .
COPY alembic.ini .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 6. Salin semua kode aplikasi Anda ke dalam direktori kerja
COPY . .

# 7. Beri tahu Docker port mana yang akan diekspos oleh kontainer
# Gunicorn akan berjalan di port 8000
EXPOSE 8000

# 8. Copy gunicorn configuration
COPY gunicorn.conf.py .

# 9. Jalankan aplikasi saat kontainer dimulai
# Use gunicorn configuration file for better worker management
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app.main:app"]
