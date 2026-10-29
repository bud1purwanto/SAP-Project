# Day 05 — PO Exception Email (Konfigurasi `ZMAP_TYPE` + Email HTML & Excel)

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★ | MM / ABAP | `sandbox-new` (write) + `prod` (read-only) | 4 jam | abap-dev-sandbox-new, mm-analisa-production |

## Tujuan

1. Memahami pola **rule bisnis di tabel konfigurasi** (`ZMAP_TYPE`), bukan hardcode.
2. Membandingkan harga PO dengan **harga terakhir** (last price) material + vendor.
3. Mengirim hasil sebagai **email HTML + lampiran Excel** dengan `CL_BCS`, dan memantau di `SOST`.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D05` — cek exception PO (vendor baru, material baru, harga naik > X%), tampil ALV, opsional kirim email |
| 2 | Flow A (PO dibuat → dicek exception → approver menerima email) + Flow B (loader rule → hitung → keputusan exception → email) |
| 3 | Bukti: 1 email di `SOST` Sandbox + daftar rule `ZMAP_TYPE` yang dipakai |

## Cerita Kasus (dari project `ZMMI_PO_EMAIL`)

Approver PO ingin diberi tahu **hanya** untuk PO yang perlu perhatian:

| Exception | Arti |
|---|---|
| Vendor baru | Vendor belum pernah dipakai (tidak ada histori) atau histori terakhir lebih lama dari N hari |
| Material baru | Material belum pernah dibeli atau histori terakhir lebih lama dari N hari |
| Harga naik | Harga PO > harga terakhir × (1 + X%) |

Awalnya nilai N dan X ditulis sebagai konstanta di program. Setiap perubahan butuh developer + transport.
Project `ZMMI_PO_EMAIL` memindahkannya ke **`ZMAP_TYPE`** dengan `PROG = 'ZMMI_PO_EMAIL'`, `TYPE = 'EXC_RULE'` — rule aktif jika barisnya ada (`DELETION` kosong).

## Konsep Kunci

- **Tabel konfigurasi** `ZMAP_TYPE`: field utama `TCODE`, `PROG`, `TYPE`, `OPT`, `VALUE` (+ `DELETION`). Struktur pasti **wajib dicek** di SE11.
- **Loader sekali jalan**: baca semua rule di awal program, simpan di internal table, lalu dipakai berulang.
- **Last price**: harga PO terakhir untuk material + vendor sebelum PO ini (`EKPO` lebih lama, item tidak terhapus).
- **Faktor toleransi**: `harga_baru > harga_lama * ( 1 + persen / 100 )`.
- Email `CL_BCS`: `CL_BCS=>CREATE_PERSISTENT` → `CL_DOCUMENT_BCS=>CREATE_DOCUMENT( I_TYPE = 'HTM' )` → `ADD_ATTACHMENT` (`XLS`) → `CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS` → `SEND` → `COMMIT WORK`. Status kirim dilihat di `SOST`.
- Di training, program **hanya membaca** `ZMAP_TYPE` (tidak menulis konfigurasi).

## Spesifikasi Program `ZTRN_<INISIAL>_D05`

| Bagian | Isi |
|---|---|
| Input | `S_BEDAT` (wajib), `S_EBELN`, `S_EKORG`; checkbox `P_SEND`; `P_EMAIL` (penerima, muncul jika `P_SEND`) |
| Loader rule | Baca `ZMAP_TYPE` `PROG = 'ZMMI_PO_EMAIL'`, `TYPE = 'EXC_RULE'`, `DELETION` kosong. Rule tidak ada → exception tsb nonaktif (tampilkan peringatan) |
| Data | PO dari `EKKO`/`EKPO` (pakai logika Day 01/02). Histori: PO sebelumnya untuk vendor (`EKKO-LIFNR`) dan material (`EKPO-MATNR`) |
| Hitung | Flag `VENDOR_NEW`, `MATERIAL_NEW`, `PRICE_INCREASE` + harga terakhir, % kenaikan |
| Output | ALV hanya PO dengan minimal 1 exception; kolom alasan exception |
| Email | Jika `P_SEND`: email HTML (ringkasan + tabel) + lampiran Excel (tab-delimited `.XLS`) ke `P_EMAIL` |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | Buyer membuat PO → program cek exception → ada exception? → email ke approver → approver review/release |
| B — Program | Load rule → rule kosong? → ambil PO → ambil histori → per item: 3 keputusan exception → ALV → kirim email? → `SOST` |

## Langkah dengan AI

**Langkah 1 — baca rule nyata (read-only).**
```
Server prod (read-only), lalu sandbox-new. read_table_structure ZMAP_TYPE, lalu baca baris
PROG = 'ZMMI_PO_EMAIL' AND TYPE = 'EXC_RULE'. Jelaskan arti setiap baris (OPT/VALUE) dalam bahasa awam.
Bandingkan isi Production vs Sandbox.
```

**Langkah 2 — pahami project.**
```
Baca 05_REFERENSI/PO_EMAIL/2026-07-30-zmmi-po-email-dynamic-exception-rules.md
dan 05_REFERENSI/PO_EMAIL/2026-07-29-po-email-excel-attachment.md. Ringkas aturan rule & cara lampiran Excel dibuat.
```

**Langkah 3 — desain query histori.**
```
Bagaimana cara efisien mencari harga PO terakhir per material+vendor untuk banyak PO sekaligus di ABAP 7.31,
tanpa SELECT di dalam LOOP? Jelaskan pilihan dan risikonya, lalu pilih satu.
```

**Langkah 4 — kode, review, push.** Mulai tanpa email (ALV dulu). Setelah benar, tambahkan email.

**Langkah 5 — uji.**

| # | Skenario | Hasil diharapkan |
|---|---|---|
| T1 | PO vendor yang belum pernah ada histori | Flag Vendor baru |
| T2 | PO dengan harga naik di atas persen rule | Flag Harga naik + % kenaikan |
| T3 | PO normal | Tidak tampil |
| T4 | `P_SEND = X` ke email Anda | Email tercatat di `SOST` (status kirim tergantung konfigurasi SMTP Sandbox) |

**Langkah 6 — flow** (Flow A & B).

## Tugas

1. Tabel rule `ZMAP_TYPE` beserta artinya.
2. Empat skenario uji terdokumentasi.
3. Jawab: jika Purchasing ingin batas kenaikan harga dari 10% menjadi 15%, apa yang harus dilakukan? Perlu ubah program?
4. Flow A & B selesai.

## Checklist Selesai

- [ ] Rule dibaca dari `ZMAP_TYPE`, tidak ada angka rule hardcode.
- [ ] Tidak ada `SELECT` di dalam `LOOP`.
- [ ] Email muncul di `SOST`.
- [ ] Flow A & B selesai.

## Kuis

1. Harga terakhir 1.000, rule kenaikan 10%. PO baru 1.090 dan 1.120 — mana yang exception?
2. Apa keuntungan rule di `ZMAP_TYPE` dibanding konstanta di program?
3. Di TCODE mana memantau email yang dikirim SAP?

<details>
<summary>Kunci jawaban</summary>

1. Batas = 1.000 × 1,10 = 1.100. **1.120** exception, 1.090 tidak.
2. Perubahan nilai cukup di konfigurasi (dengan kontrol perubahan), tanpa ubah kode & transport program; rule bisa dinonaktifkan per baris.
3. `SOST` (dan `SCOT` untuk konfigurasi SMTP).

Tugas 3: ubah nilai baris rule `PRICE_INCREASE/PERCENT` di `ZMAP_TYPE` (di development, lalu transport/sesuai prosedur). Program tidak perlu diubah.

Potongan kode acuan — email HTML + lampiran:

```abap
DATA: lo_send  TYPE REF TO cl_bcs,
      lo_doc   TYPE REF TO cl_document_bcs,
      lo_rcpt  TYPE REF TO if_recipient_bcs,
      lo_bcsx  TYPE REF TO cx_bcs,
      lt_html  TYPE soli_tab,
      ls_html  TYPE soli,
      lv_xls   TYPE string,
      lt_solix TYPE solix_tab,
      lv_size  TYPE so_obj_len,
      lv_subj  TYPE so_obj_des,
      lv_msg   TYPE string.

TRY.
    lo_send = cl_bcs=>create_persistent( ).
    ls_html-line = '<p>Daftar PO dengan exception:</p>'.
    APPEND ls_html TO lt_html.
    " ... tambahkan baris tabel HTML per PO ...
    lv_subj = 'PO Exception'.
    lo_doc = cl_document_bcs=>create_document( i_type    = 'HTM'
                                               i_text    = lt_html
                                               i_subject = lv_subj ).

    " lv_xls: kolom dipisah TAB (cl_abap_char_utilities=>horizontal_tab),
    "         baris dipisah cl_abap_char_utilities=>cr_lf
    cl_bcs_convert=>string_to_solix( EXPORTING iv_string   = lv_xls
                                               iv_codepage = '4103'
                                               iv_add_bom  = 'X'
                                     IMPORTING et_solix    = lt_solix
                                               ev_size     = lv_size ).
    lo_doc->add_attachment( i_attachment_type    = 'XLS'
                            i_attachment_subject = 'PO_Exception'
                            i_attachment_size    = lv_size
                            i_att_content_hex    = lt_solix ).
    lo_send->set_document( lo_doc ).
    lo_rcpt = cl_cam_address_bcs=>create_internet_address( p_email ).
    lo_send->add_recipient( lo_rcpt ).
    lo_send->send( ).
    COMMIT WORK.
  CATCH cx_bcs INTO lo_bcsx.
    lv_msg = lo_bcsx->get_text( ).
    MESSAGE lv_msg TYPE 'I'.
ENDTRY.
```

Catatan: tipe `P_EMAIL` gunakan `AD_SMTPADR`. Pastikan Sandbox memang boleh mengirim email keluar; jika tidak, cukup bukti di `SOST`.
</details>

## Referensi

- [2026-07-30-zmmi-po-email-dynamic-exception-rules.md](../05_REFERENSI/PO_EMAIL/2026-07-30-zmmi-po-email-dynamic-exception-rules.md)
- [2026-07-29-po-email-excel-attachment.md](../05_REFERENSI/PO_EMAIL/2026-07-29-po-email-excel-attachment.md)
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
