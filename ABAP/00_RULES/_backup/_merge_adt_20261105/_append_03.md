
---

## Start gate wajib sebelum write apa pun

(merge dari ADT AGENTS, 2026-11-05 — alur lengkap: [07_Workflow_Development.md](07_Workflow_Development.md))

Sebelum push/update pertama, semua harus terpenuhi. Jika tidak, berhenti dan sebutkan yang kurang:
1. Ada Design Brief berstatus `AGREED` (atau, untuk bug fix kecil, instruksi Baginda yang eksplisit di chat).
2. Target server = `sandbox-new` (`set_active_server`), objek yang akan diubah ada di daftar objek brief.
3. Source lama sudah dibaca dan **backup** disimpan di `subproject/<NAMA>/outputs/`.
4. Bangun hanya yang ada di brief. Butuh objek lain / desain tidak cocok dengan kenyataan → berhenti, kembali ke brainstorm. Tidak ada penyimpangan diam-diam.
5. Objek di luar daftar brief (FM shared, include milik program lain, tabel Z, objek SAP standar): minta persetujuan Baginda **per objek** dengan info: jenis + nama, alasan, perubahan (diff), dampak (`get_where_used`). Persetujuan umum ("kerjakan saja semua") tidak berlaku.
6. Write ditolak / gagal (`EV_SUCCESS <> 'X'`) → laporkan pesan apa adanya. Jangan cari jalan pintas (server lain, mekanisme lain) tanpa izin.

## Delete rule: hapus hanya dengan perintah eksplisit

(diadaptasi dari "Delete guard" ADT AGENTS, 2026-11-05)

- **Default: agent tidak menghapus** objek (program, include, FM, tabel Z, Smart Form), data tabel, maupun file di project.
- Penghapusan **boleh** hanya jika Baginda memberi **perintah eksplisit** di chat yang menyebut objek/data yang dihapus (contoh: "hapus program ZTMP_PATCH01 di sandbox-new").
- Sebelum eksekusi hapus, wajib:
  1. Sebut ulang objek/data, server, dan dampak (`get_where_used` untuk objek; jumlah baris + WHERE untuk data).
  2. Simpan backup (source/XML/isi tabel) di `outputs/`.
  3. Konfirmasi sekali lagi jika dampaknya lebih luas dari yang disebut Baginda.
- Production (`prod`) dan tabel standar SAP: **tidak pernah** dihapus, walau ada perintah. Arahkan ke proses standar / tim Basis.
- Tanpa perintah eksplisit: berikan **saran penghapusan** (objek, alasan, bukti where-used, urutan, langkah manual) dan biarkan Baginda yang memutuskan.
