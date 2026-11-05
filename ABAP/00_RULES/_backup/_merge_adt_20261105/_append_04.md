
---

## Tambahan Review dari ADT AGENTS (2026-11-05)

### Urutan efek & posting
- **Semua aturan blocking dicek SEBELUM BAPI / COMMIT pertama.** Aturan yang baru dicek di step berikutnya meninggalkan data setengah jadi (contoh nyata: GR duplikat ZPP001 karena tiap step `COMMIT` sendiri).
- Proses multi-step dengan COMMIT per step: wajib ada guard idempotensi (cek dokumen sudah ada) atau kompensasi (cancel) bila step berikut gagal.
- BDC / batch input: hasil diverifikasi **di database** (bukan hanya `sy-subrc`), evaluasi TYPE setiap message (bukan hanya message pertama), `MODE 'N'` di kode final, setiap field rekaman ada di dynpro itu.
- Pesan setelah side effect sukses (dokumen dibuat / BAPI commit) = informasi, bukan warning/error.

### Konsistensi
- Komentar, dokumen FS/TS, dan konstanta harus cocok dengan kode. Ditemukan beda → laporkan sebagai temuan.
- Setiap baris aturan di FS diimplementasikan; nilai turunan FS (mis. order type per jenis) diambil dari satu tempat (mis. `ZMAP_TYPE`), bukan konstanta tersebar. Input yang tidak ter-mapping ditolak.
- Nilai org (plant, company code, purchasing org) di satu blok konstanta / mapping, tidak tersebar.

### Format hasil review & QA
- Temuan dikelompokkan **Critical / Major / Minor**: objek + baris, apa yang salah, kenapa penting, perbaikan konkret.
- Laporkan hanya temuan yang terverifikasi dari source; tebakan diberi label "dugaan". Akhiri dengan apa yang **tidak** dicek.
- QA gate memakai status **PASS / WARN / FAIL / NOT RUN**. Dilarang menulis PASS untuk cek yang tidak dijalankan. Vonis: **READY / READY WITH WARNINGS / NOT READY** + langkah berikutnya.
- Data hasil test di server (dokumen dibuat) dicatat key-nya agar bisa dibersihkan Baginda.
