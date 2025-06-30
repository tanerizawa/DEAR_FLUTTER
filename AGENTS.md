# AGENTS.md

## Lingkup

`AGENTS.md` ini berlaku untuk semua kode dan dokumentasi di dalam direktori ini beserta subfoldernya. Instruksi yang tercantum di sini bersifat **wajib** bagi semua kontributor yang mengerjakan *frontend* Flutter dan *backend* FastAPI proyek ini.

---

## 1. Alur Kerja Umum & Kebijakan Git

-   **Jangan membuat *branch* baru** kecuali diinstruksikan oleh pengelola repositori.
-   Semua pekerjaan harus di-*commit* ke *branch* yang sedang aktif.
-   Anda harus menunggu semua perintah terminal selesai atau menghentikannya sebelum menyelesaikan pekerjaan Anda.
-   Gunakan pesan *commit* yang deskriptif dan konvensional. Contoh:
    -   `fix(api): handle empty user input gracefully`
    -   `feat(ui): add mood analytics chart`
-   Setelah melakukan perubahan kode atau dokumentasi, periksa `git status` untuk memastikan *worktree* Anda bersih dan semua perubahan telah di-*commit*.
-   Jika *pre-commit hooks* gagal, perbaiki masalah yang dilaporkan dan coba lagi *commit* tersebut. Tidak ada kode atau dokumen yang boleh di-*commit* jika *pre-commit* tidak lolos.
-   Jangan mengubah atau memodifikasi *commit* yang sudah ada.

---

## 2. Konvensi Penulisan Kode

### 2.1 Flutter

-   **Struktur Proyek:**
    Organisasikan kode berdasarkan fitur, bukan berdasarkan tipe. Contoh yang diutamakan:
    ```
    /lib
    ├── /features
    │   ├── /journal
    │   │   ├── journal_screen.dart
    │   │   └── journal_viewmodel.dart
    │   └── /auth
    │       └── ...
    └── /core
        └── ...
    ```

-   **Manajemen State:**
    Gunakan `provider`, `bloc`, atau `riverpod` sesuai arahan dalam basis kode. Jangan mencampur pola dalam fitur yang sama.

-   **Gaya Kode:**
    -   Ikuti panduan [Effective Dart](https://dart.dev/guides/language/effective-dart/style).
    -   Utamakan penggunaan *stateless widget* jika memungkinkan.
    -   Semua *widget*, model, dan layanan publik harus didokumentasikan dengan komentar DartDoc.
    -   Jalankan `dart format .` dan `dart analyze` sebelum setiap *commit*.

-   **Pengujian:**
    -   Tempatkan semua tes di direktori `/test`.
    -   Pastikan semua logika baru dicakup oleh *unit test* atau *widget test*.

### 2.2 FastAPI (Python Backend)

-   **Struktur Proyek:**
    -   Ikuti struktur modular: `/app/api`, `/app/services`, `/app/schemas`, `/app/core`, dll.
    -   File konfigurasi (`.env`, `settings.py`) tidak boleh diisi dengan nilai produksi secara *hardcode*.

-   **Gaya Kode:**
    -   Ikuti [PEP8](https://peps.python.org/pep-0008/) untuk semua kode Python.
    -   Gunakan *type hints* dan *docstrings* untuk semua kelas dan fungsi publik.
    -   Jalankan `black .` dan `ruff .` (atau `flake8`) sebelum melakukan *commit*.

-   **Manajemen Dependensi:**
    -   Daftar semua dependensi di `requirements.txt`.
    -   Gunakan `pip freeze > requirements.txt` setelah menginstal paket baru.

-   **Pengujian:**
    -   Tempatkan semua tes di direktori `/tests`.
    -   Semua logika bisnis harus dicakup oleh pengujian otomatis (`pytest`).

---

## 3. Kepatuhan `AGENTS.md`

-   Untuk setiap file yang Anda ubah, pastikan perubahan Anda mengikuti semua aturan di `AGENTS.md` terdekat yang ditemukan di pohon direktori.
-   Jika ada instruksi yang bertentangan, `AGENTS.md` yang paling dalam (paling spesifik) yang akan diutamakan.
-   Instruksi langsung dari pimpinan proyek atau pengelola selalu lebih diutamakan daripada dokumen ini.

---

## 4. Pesan *Pull Request*

-   Semua PR harus berisi:
    -   Ringkasan perubahan yang singkat dan jelas.
    -   Referensi ke *issue*/*ticket* yang ditangani.
    -   Daftar file yang terpengaruh.
    -   Instruksi untuk pengujian manual atau otomatis.
-   Jika `AGENTS.md` mana pun berisi format pesan PR khusus, Anda **wajib** mengikutinya.

---

## 5. Pemeriksaan Terprogram

-   Jika `AGENTS.md` dalam lingkup Anda menentukan pemeriksaan terprogram atau *CI jobs*, **Anda harus menjalankan semua pemeriksaan dan memperbaiki semua kesalahan atau peringatan sebelum mengirimkan atau menyelesaikan perubahan Anda**—bahkan untuk dokumentasi.
-   Jika tidak yakin, tanyakan kepada pengelola atau peninjau untuk klarifikasi.

---

## 6. Kebijakan Sitasi

-   Jika Anda menelusuri atau memeriksa file/output terminal sebagai bagian dari alur kerja atau PR Anda, tambahkan sitasi di pesan PR Anda sesuai dengan format berikut:
    -   Untuk referensi file:
        `【F:<file_path>†L<line_start>(-L<line_end>)?】`
    -   Untuk output terminal:
        `【<chunk_id>†L<line_start>(-L<line_end>)?】`
-   **Jangan** mengutip *diff* PR sebelumnya, komentar, atau *hash git* sebagai ID *chunk*.
-   Selalu utamakan sitasi file untuk perubahan kode/dokumentasi.

---

## 7. Panduan Tambahan

-   Jangan pernah menyimpan rahasia atau kredensial sensitif secara *hardcode* di dalam file sumber.
-   Untuk setiap integrasi AI atau alat otomatis, dokumentasikan input/output yang diharapkan dan contoh *prompt*/perintah utama di `README` atau dokumentasi fitur yang relevan.
-   Selalu perbarui semua `README`, `AGENTS.md`, dan dokumentasi yang ditujukan untuk pengembang dengan setiap perubahan struktural atau proses.

---

_*`AGENTS.md` ini dirancang untuk menjaga alur kerja yang konsisten, kolaboratif, dan aman bagi semua kontributor di seluruh basis kode Flutter dan FastAPI. Jika ada ketidakpastian atau konflik, selalu konsultasikan dengan pengelola proyek._