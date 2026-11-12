# 08 — Checkpoint Wajib Setelah Setiap Pekerjaan

> Tujuan: saat sesi baru atau ganti device, langsung tahu status pekerjaan terakhir tanpa bertanya ke Baginda.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Dua Level Checkpoint

| File | Isi | Kapan Diupdate |
|---|---|---|
| [`CHECKPOINT.md`](../CHECKPOINT.md) (root) | Blok **Terakhir Dikerjakan** + **Log** 1 baris per pekerjaan (terbaru di atas) | Setiap selesai pekerjaan apa pun |
| `subproject/<NAMA>/CHECKPOINT.md` | Status detail sub-project: temuan data, keputusan, next step | Setiap ada update pada sub-project itu |

---

## Format Baris Log Root

| Kolom | Isi |
|---|---|
| Waktu | `YYYY-MM-DD HH:MM` (WIB) |
| AI / device | misal: `Claude / desktop`, `Gemini / laptop` |
| Sub-project | Nama sub-project terkait atau `—` (jika lintas subproject/global) |
| Pekerjaan | 1 kalimat padat |
| Status | `Selesai` / `Menunggu Baginda` / `Terputus` |
| Next step | 1 kalimat langkah berikutnya |
