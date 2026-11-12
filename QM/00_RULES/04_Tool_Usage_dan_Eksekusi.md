# 04 — Penggunaan Tool & Panduan Eksekusi

> Panduan memilih antara SAP GUI, MCP SAP (RFC), dan MCP SQL.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Pilihan Tool Sesuai Kebutuhan

| Tool | Fungsi Utama | Kelebihan | Batasan |
|---|---|---|---|
| **MCP SAP (`read_table`, `call_function`)** | Pembacaan tabel & eksekusi FM | Cepat, headless, presisi | Hanya untuk data tabular / RFC terdaftar |
| **MCP SQL (`run_query`, `explain_query`)** | Analisa query analitik / database eksternal | Ekstraksi volume besar, profiling query | Tergantung koneksi server SQL aktif |
| **SAP GUI Klasik (TCODE)** | Eksekusi manual, verifikasi visual tampilan screen | Otentik sesuai pengalaman user | Lambat, butuh interaksi screen |

---

## Aturan Posting & Testing

1. **Target Uji Posting:** HANYA boleh dilakukan di server **`sandbox-new` (TRS)**.
2. **Izin Eksplisit:** Sebelum melakukan posting atau eksekusi yang mengubah status data di server mana pun, mintalah konfirmasi dari **Baginda**.
3. **Penyimpanan Kode / Script:**
   - Semua script otomasi, query, atau harness test disimpan di dalam folder sub-project terkait: `subproject/<NAMA_SUBPROJECT>/scripts/`.
