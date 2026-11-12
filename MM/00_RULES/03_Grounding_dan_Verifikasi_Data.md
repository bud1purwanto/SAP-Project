# 03 — Grounding & Verifikasi Data (Evidence-Based)

> Aturan pembacaan data nyata, pencegahan asumsi, dan batas baris.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Prinsip Utama: No Evidence = Dilarang Menyimpulkan

1. **Dilarang berasumsi atau menebak data.** Jangan pernah mengasumsikan nilai master data, saldo stok, status order, atau posting tanpa verifikasi data nyata dari SAP.
2. **Gunakan MCP SAP / SQL:** Baca tabel live melalui `read_table` atau `run_query` sebelum membuat kesimpulan analisa.
3. **Pemeriksaan Dokumen Batal / Reversal:**
   - Cek selalu pasangan reversal (misal pada material doc: `MSEG-SMBLN`, order: status `CLSD`/`TECO`, akuntansi: `BKPF-STBLG`/`XBLNR`).
   - Jangan menghitung kuantitas atau nominal dari dokumen yang sudah dibatalkan tanpa memperhitungkan dokumen pembatalnya.

---

## Filter Wajib pada Query Data

Untuk mencegah kelebihan beban pada server SAP (terutama server Production):
- **Wajib batasi baris:** Gunakan row count maksimal 200–500 baris.
- **Filter sempit (WHERE clause):**
  - Sertakan Company Code (`BUKRS`), Plant (`WERKS`), atau fiscal year (`GJAHR`).
  - Gunakan range tanggal (`BUDAT` / `CPUDT` / `ERDAT`) yang spesifik.
  - Untuk dokumen spesifik, cari langsung berdasarkan nomor dokumen (`BELNR`, `MBLNR`, `AUFNR`, `VBELN`, `EBELN`).

---

## Etika Server Production

- Server Production (`PRT` / `TRP`) **HANYA READ-ONLY**.
- Dilarang keras mengeksekusi BAPI posting, update tabel, atau modifikasi data di Production.
- **Wajib logout setelah transaksi di Production:** Setiap kali membuka sesi SAP GUI di server Production, setelah selesai **WAJIB logout SAP** sebelum menutup sesi.
