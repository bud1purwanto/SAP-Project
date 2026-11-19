# Uji guard NCR approval — ZQMI_BARRIER_PASS_FAIL (TRS / sandbox-new)

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-19 |
| Server | sandbox-new (TRS) |
| Versi program | source dev terbaru + guard NCR v8 (push 19 Nov, GENERATE_OK) |
| Metode | `RFC_ABAP_INSTALL_AND_RUN`, panggil `PERFORM ... IN PROGRAM ZQMI_BARRIER_PASS_FAIL` pada batch dummy |
| Batch dummy | MATNR `ZTEST_NCR`, CHARG `ZTNCR00001` (dihapus di akhir uji) |
| Hasil | **LULUS semua skenario** |

## Hasil per skenario

| # | Skenario | Harapan | Hasil | Status |
|---|---|---|---|---|
| S1 | `INSERT_JUDGEMENT` NCR, belum Approved | V1 di-soft-delete, V2 baru aktif | V1 `DEL=X`, V2 aktif | LULUS |
| S2 | Set `NCRAPPROVAL = Approved` (seperti form `APPROVAL`) | V2 Approved, CANBESHIP O | sesuai | (setup) |
| S3 | `INSERT_JUDGEMENT` NCR setelah Approved | Tidak ada perubahan / versi baru | tetap 2 baris, V2 Approved aktif | LULUS |
| S4 | `INSERT_JUDGEMENT` PASS setelah Approved | Tidak ada perubahan (judgement beku) | tetap 2 baris, V2 NCR Approved | LULUS |
| S5 | `GET_SHIPMENT` pada baris Approved | Hanya CANBESHIP berubah, NCRAPPROVAL tetap | CANBESHIP `O`→kosong, NCRAPPROVAL tetap `Approved` | LULUS |

Catatan S5: CANBESHIP jadi kosong karena tabel konfigurasi `IT_SHIPMENT`/`IT_RANK` tidak dimuat saat uji
(form dipanggil langsung). Yang diuji adalah bahwa `UPDATE` tidak menyentuh `NCRAPPROVAL`.

## Data asli

- 8 baris Approved asli (SRRFBI batch 410737/410758/410762/410764) identik sebelum dan sesudah uji.
- Pola V1 Approved `DEL=X` + V2 Approved aktif pada keempat batch itu = jejak kode lama
  (`MODIFY` tanpa guard) yang membuat versi baru untuk batch yang sudah Approved.
- Baris dummy setelah cleanup: 0.

## Belum dicakup

- Race condition nyata (job dan approval berjalan bersamaan) tidak disimulasikan; dicakup secara desain oleh `UPDATE` per-kolom.
- Uji GUI end-to-end ZQM004 (layar NCR Approval) belum dilakukan.
- Guard belum ada di DEV.

## File
- Program uji: `ZTNCR_test_program.abap`
- Output mentah: `hasil_run_TRS.txt`
