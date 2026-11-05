# Design Brief — <nama development>

Simpan di `subproject/<NAMA>/docs/BRIEF_<topik>.md`. Alur: [07_Workflow_Development.md](../00_RULES/07_Workflow_Development.md).

| Atribut | Isi |
|---|---|
| Status | DRAFT / AGREED / REOPENED (AGREED hanya setelah Baginda setuju; kutip di bagian 10) |
| Tanggal | |
| FS / sumber | path / versi |
| Sub-project | `subproject/<NAMA>/` |
| Server analisa | dev-aix / prod (read-only) |
| Server write | `sandbox-new` |

## 1. Tujuan
2–3 kalimat, dengan kata-kata Baginda.

## 2. Analisa FS
Tujuan, user, kriteria seleksi, aturan bisnis, sumber data, non-fungsional (volume, background/online, email/file). Sebut bagian/halaman FS per poin.

## 3. Pertanyaan Terbuka
| # | Pertanyaan | Ditanya ke | Jawaban | Tanggal |
|---|---|---|---|---|

## 4. Peta Objek & Sumber Data
| Ref FS | Kebutuhan | Sumber (tabel/FM/BAPI) | Sudah ada di sistem? (program/FM/ZMAP_TYPE) | Keputusan (pakai / ubah / baru) |
|---|---|---|---|---|

## 5. Opsi
| Opsi | Ringkasan | Plus | Minus | Effort (S/M/L) | Dipilih? |
|---|---|---|---|---|---|

## 6. Desain yang Disepakati
Objek dan hubungannya, FORM/include yang berubah, urutan cek sebelum BAPI/COMMIT pertama, error handling (RETURN, ROLLBACK, log), authority check, yang **di luar scope**.

## 7. Daftar Objek
| Jenis | Nama | Baru / ubah | Server | Backup di `outputs/` |
|---|---|---|---|---|

## 8. Urutan Build & Strategi Test
1. Backup → 2. Ubah → 3. Syntax check → 4. Test (normal, data kosong, error, reversal/status) → 5. QA gate → 6. Review.

## 9. Log Keputusan
| Putaran | Keputusan | Oleh | Tanggal |
|---|---|---|---|

## 10. Persetujuan
> Kutipan persetujuan Baginda: "..." (tanggal)

## 10b. Perubahan di Luar Daftar Objek (opsional)
Hanya jika desain butuh. Masing-masing disetujui Baginda per objek; ditulis di sini bukan berarti disetujui.
| Objek | Alasan | Perubahan | Disetujui Baginda (tanggal) |
|---|---|---|---|

## 11. Target (diisi setelah AGREED)
| Server write | Package | Objek yang boleh diubah | Catatan |
|---|---|---|---|
| `sandbox-new` | `$TMP` | | |
