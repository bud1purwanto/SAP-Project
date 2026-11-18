# Aturan project COA (ZQMI_COA)

## Cara testing COA: SAP GUI di server
Testing COA dilakukan lewat **SAP GUI di server (SSH, display `:99`)**, bukan laptop user. Cara kerja dan login: lihat `/data/Projects/SAP/CLAUDE.md`.

- Sistem uji: Development AIX, **client 130** (client 100 = configuration). Pengembangan tetap sandbox-new dulu; DEV hanya diubah user (deploy).
- **ZQM002**: field Nomor ODO (DO) di (335,285), F8; screenshot layar Print COA.
- **ZQM005** (Properties Report for Production): wajib isi **Date** dan **Plant** (ambil dari `QALS-ENSTEHDAT` dan `QALS-WERK` inspection lot), lalu Material dan Batch, pilih Jumbo Roll. Mean Value per karakteristik dibandingkan dengan Value di ZQM002.
- Laporan hasil: Excel dengan **satu sheet per skenario, nama sheet = nomor DO**. Isi sheet: screenshot ZQM002, tabel value MIC (rumus selisih dan status), screenshot ZQM005 tiap inspection lot, dan peta panah yang menghubungkan MIC ZQM002 dengan karakteristik ZQM005. Bila ada 2 inspection lot dengan MIC sama, nilainya **dirata-rata** (rumus AVERAGE). Plus file markdown per skenario berisi value MIC.
- Contoh hasil: `outputs/gui_test_20261118/` (generator ada di sesi 18 Nov; panah digambar dengan PIL di atas screenshot).
- Regresi massal tetap lewat harness (`scripts/mt_*.mjs`, lihat `docs/STANDAR_SKENARIO_TESTING_COA.md` §0.4); uji GUI dipakai bila user minta testing langsung di layar.
