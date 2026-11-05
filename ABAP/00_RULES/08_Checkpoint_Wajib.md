# 08 — Checkpoint Wajib Setelah Setiap Pekerjaan

> Tujuan: pindah device / ganti AI / sesi baru, folder sama → langsung tahu **terakhir mengerjakan apa** dan **lanjut dari mana**, tanpa bertanya ke Baginda.
> Kembali ke [AGENTS.md](../AGENTS.md).

## 1. Dua level checkpoint

| File | Isi | Kapan diupdate |
|---|---|---|
| [`CHECKPOINT.md`](../CHECKPOINT.md) (root) | Blok **Terakhir Dikerjakan** (ditimpa) + **Log** 1 baris per pekerjaan (terbaru di atas), lintas sub-project | Setiap selesai pekerjaan apa pun |
| `subproject/<NAMA>/CHECKPOINT.md` | Status detail sub-project: perubahan, keputusan, next step, backup terakhir | Setiap pekerjaan di sub-project itu |

Pekerjaan non-sub-project (struktur folder, aturan, template, tooling) cukup di root `CHECKPOINT.md`.

## 2. Aturan wajib

1. **Awal sesi:** baca root `CHECKPOINT.md` lebih dulu (blok Terakhir Dikerjakan + 5 log teratas), lalu `CHECKPOINT.md` sub-project yang relevan.
2. **Akhir setiap pekerjaan** (analisa, perubahan kode, push, test, dokumen, perubahan struktur), sebelum jawaban akhir ke Baginda. **Dikecualikan:** tanya-jawab konsep / penjelasan singkat tanpa membaca sistem dan tanpa mengubah file — tidak perlu checkpoint.
   - Timpa blok **Terakhir Dikerjakan** di root `CHECKPOINT.md`.
   - Tambah **1 baris** di tabel **Log** root (paling atas).
   - Update `CHECKPOINT.md` sub-project: tambah 1 baris di **Log Sesi** + perbarui status/next step. Belum ada → buat dari [Template_Checkpoint.md](../01_TEMPLATE/Template_Checkpoint.md).
3. **Pekerjaan terputus / belum selesai:** tetap tulis checkpoint dengan status `Terputus` dan langkah persis untuk melanjutkan (file, FORM/baris, server, perintah terakhir).
4. Isi harus bisa dipakai tanpa konteks chat: sebut path file, nama objek SAP, server, backup, hasil (`EV_SUCCESS`, jumlah baris), dan keputusan Baginda.
5. Dilarang mencatat password, token, atau data pribadi.
6. **Sesi paralel (2 AI / 2 device):** baca ulang `CHECKPOINT.md` tepat sebelum menulis. Jangan hapus/timpa baris log milik sesi lain. Blok Terakhir Dikerjakan diisi pekerjaan yang selesai paling akhir; jika sesi lain masih jalan, sebut di kolom Next step.
7. **Rotasi log root:** jika tabel Log root lebih dari 30 baris, pindahkan baris tertua (sisakan 30 teratas) ke `00_RULES/_backup/checkpoint_arsip/YYYY-MM.md` (bulan dari kolom Waktu, terbaru di atas). Log sub-project tidak dirotasi kecuali Baginda minta.
8. Checkpoint sub-project format lama (mis. `AUTO_TECO/CHECKPOINT.md`, `ZPP090/CHECKPOINT.md`) **tidak dirombak**; cukup tambahkan bagian `## Log Sesi` di akhir saat update pertama. `DAILY_ABAP_BRIEFING` tetap memakai `docs/checkpoint-YYYY-MM-DD.md`.

## 3. Format baris log

| Kolom | Isi |
|---|---|
| Waktu | `YYYY-MM-DD HH:MM` (WIB) — ambil dari `date '+%F %H:%M'` (TZ WIB), jangan dikira-kira |
| AI / device | mis. `Claude / desktop kantor`, `Codex / laptop` |
| Sub-project | `AUTO_TECO`, `—` (global) |
| Pekerjaan | 1 kalimat |
| Status | `Selesai` / `Terputus` / `Menunggu Baginda` |
| Next step | 1 kalimat, atau `—` |
