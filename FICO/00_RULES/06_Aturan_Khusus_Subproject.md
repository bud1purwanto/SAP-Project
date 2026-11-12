# 06 — Aturan Khusus Subproject

> Struktur folder subproject, auto-mapping, dan larangan file acak.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Struktur Wajib Subproject

Semua pekerjaan operasional harus berada di dalam folder sub-project di bawah `subproject/<NAMA>/`:

```
subproject/<NAMA>/
├── src/        <- File konfigurasi, mapping query, template
├── scripts/    <- Script ekstraksi, audit, atau otomasi MCP
├── docs/       <- Dokumen FS, SOP bisnis, memo analisa, diagram
├── tests/      <- Skenario uji, case simulasi
├── outputs/    <- Hasil dump data, snapshot tabel, export file
├── README.md   <- Ringkasan sub-project (gunakan Template_README_Subproject.md)
└── CHECKPOINT.md <- Status & log progress (gunakan Template_Checkpoint.md)
```

---

## Larangan Keras

- **DILARANG menaruh file kerja baru langsung di root modul `FICO/`.**
- Setiap topik, issue, atau analisa baru wajib dibuatkan subfolder di `subproject/` dan didaftarkan pada tabel peta di [SUBPROJECTS.md](../SUBPROJECTS.md).
