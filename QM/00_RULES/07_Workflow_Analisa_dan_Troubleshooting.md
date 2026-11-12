# 07 — Workflow Analisa & Troubleshooting QM

> Urutan langkah baku menangani case atau request pada modul QM.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Alur Kerja Baku

```
Cek Email (bila ada) -> Cek Checkpoint & Subproject -> RAG / Knowledge -> MCP SAP Live Data -> Analisa & Rekomendasi -> Update Checkpoint
```

### 1. Step 1 — Validasi Case & Email
- Jika case berasal dari email atau Baginda menyebutkan email:
  - Buka email via `read_email` & `get_email_image`.
  - Pahami pengirim, kronologi, screenshot SAP yang dilampirkan.
  - Laporkan pemahaman isi email kepada Baginda terlebih dahulu.

### 2. Step 2 — Routing Subproject
- Baca [SUBPROJECTS.md](../SUBPROJECTS.md) untuk mencocokkan topik.
- Bekerja di subfolder yang tepat, baca `README.md` dan `CHECKPOINT.md` subproject tersebut.

### 3. Step 3 — RAG SAP & Pengetahuan Bisnis
- Cari dokumentasi bisnis atau best practice via tool RAG jika tersedia.

### 4. Step 4 — Grounding Data Live via MCP SAP
- Query tabel SAP terkait via `read_table` (server `prod` atau `dev-aix`).
- Cek dokumen terkait, status open/cleared, status reversal, dan log error.

### 5. Step 5 — Formulasi Solusi & Rekomendasi
- Buat laporan analisa menggunakan format standar di [01_TEMPLATE/](../01_TEMPLATE/Template_Laporan_Analisa.md).
- Rekomendasikan solusi yang aman (Clean Core, konfigurasi standar vs custom Z).

### 6. Step 6 — Update Checkpoint Wajib
- Catat aktivitas pada `CHECKPOINT.md` root modul dan `CHECKPOINT.md` subproject sebelum mengakhiri sesi.
