# 02 — BAPI (dan bedanya dengan BDC)

> Basis kasus: **ZSD113 — Upload create SO** (`ZSD_UPLOAD_SO`, dibuat 2016) di DEV (TRD 130).
> Source referensi: [../outputs/dev_src/ZSD_UPLOAD_SO.abap](../outputs/dev_src/ZSD_UPLOAD_SO.abap).

## 1. Konsep singkat (untuk interview)

**BAPI** (Business Application Programming Interface) = function module standar SAP yang di-*release* untuk membuat/mengubah/membaca objek bisnis (Sales Order, PO, Material, dll.) **tanpa lewat layar**. Terdaftar di Business Object Repository (transaksi **BAPI**, SWO1).

Ciri BAPI:
- Nama `BAPI_<objek>_<aksi>`, mis. `BAPI_SALESORDER_CREATEFROMDAT2`, `BAPI_SALESORDER_CHANGE`.
- Bisa dipanggil via RFC (remote-enabled).
- **Tidak commit sendiri** → wajib `BAPI_TRANSACTION_COMMIT` (sukses) atau `BAPI_TRANSACTION_ROLLBACK` (gagal).
- Error tidak raise exception, tapi dikembalikan di tabel **RETURN** (tipe `BAPIRET2`: TYPE, ID, NUMBER, MESSAGE). TYPE `E`/`A` = gagal.
- Struktur `...X` (mis. `BAPISDITMX`) = *flag* field mana yang diisi/diubah, dengan `UPDATEFLAG` `I`/`U`/`D`.
- Field custom (append di VBAP) dibawa lewat parameter **EXTENSIONIN** (struktur `BAPE_VBAP` / `BAPE_VBAPX`).

**BDC** (Batch Data Communication) = merekam lalu memutar ulang layar transaksi (SHDB recording → `CALL TRANSACTION ... USING bdcdata` atau session SM35).

## 2. BAPI vs BDC (hafalkan tabel ini)

| Aspek | BAPI | BDC |
|---|---|---|
| Cara kerja | Panggil function module, langsung ke logika bisnis | Simulasi ketik di layar (dynpro + field + OK-code) |
| Ketergantungan layar | Tidak ada | Sangat tergantung: layar/field berubah (upgrade, config, screen variant, user parameter) → BDC rusak |
| Performa | Cepat | Lambat (proses PBO/PAI setiap layar) |
| Pesan error | Tabel RETURN terstruktur | `MESSAGES INTO bdcmsgcoll`, harus diterjemahkan |
| Commit | Manual: `BAPI_TRANSACTION_COMMIT` | Transaksi commit sendiri (`UPDATE` mode A/S/L) |
| Field custom | Lewat EXTENSIONIN + append BAPE_* | Isi langsung field layar (kalau ada di layar) |
| Kapan dipilih | Selalu utamakan jika BAPI tersedia & lengkap | BAPI tidak ada/kurang, atau perlu meniru persis perilaku layar (contoh di tim: COR1 via `ABAP4_CALL_TRANSACTION`, subproject PROCESS_ORDER_RFC) |
| Mode debug | Debug FM | Mode `A` (tampil semua layar) membantu lihat langkah |

## 3. Analisa ZSD113 (program nyata)

Alur:

```
Selection screen: P_SOURCE (file teks tab-delimited, F4 pakai WS_FILENAME_GET)
START-OF-SELECTION
  UPLOAD_DATA  -> GUI_UPLOAD ke ITAB
  CHECK_DATA   -> validasi isi file (PI No hanya untuk ZEOR, SKU wajib untuk ZDSS, ...); FLAG = 'X' kalau ada error
  CREATE_SO    -> (jika tidak ada error)
    LOOP per PO customer (ZPO) = 1 Sales Order
      Header   : SALES_ORG, DISTR_CHAN, DIVISION, DOC_TYPE, PURCH_NO_C, REQ_DATE_H, ...
      Partner  : AG (sold-to) dan WE (ship-to)
      LOOP item:
        tentukan material (SR + karakteristik), item category (T184), procedure (TVAK/T683V)
        Item      : ITM_NUMBER, MATERIAL, PLANT, ITEM_CATEG, TARGET_QTY ...
        Schedule  : REQ_DATE, REQ_QTY (+ SCHEDULES_INX)
        Condition : ZDD0 / ZED0 / dari T683V-KARTV
        Config    : SALES_CFGS_REF/INST/VALUE (variant configuration, karakteristik ZZTYPE, ZZPACKING, ...)
        Extension : BAPE_VBAP-ZDATE, ZLINE  (+ BAPE_VBAPX flag 'X')
      CALL FUNCTION 'SD_SALESDOCUMENT_CREATE'
      PERFORM COMMIT  (BAPI_TRANSACTION_COMMIT WAIT = 'X')
      CHANGE_SO -> BAPI_SALESORDER_CHANGE (update schedule line dari hasil konfigurasi) + COMMIT
      INSERT_PI_NO -> CREATE_TEXT (PI Number ke header text) kalau tidak ada error
      ALV_ERROR -> kumpulkan RETURN ke IT_ERROR (icon merah/hijau/kuning)
  WRITE_ERROR -> REUSE_ALV_GRID_DISPLAY log hasil
```

Hal penting untuk diceritakan saat interview:

1. **`SD_SALESDOCUMENT_CREATE` vs `BAPI_SALESORDER_CREATEFROMDAT2`.** ZSD113 memanggil `SD_SALESDOCUMENT_CREATE` langsung. Ini FM yang dipanggil *di dalam* `BAPI_SALESORDER_CREATEFROMDAT2`; parameternya hampir sama tetapi FM ini **bukan BAPI released** (tidak dijamin stabil antar release). Untuk latihan, pakai BAPI resminya.
2. **Field custom lewat EXTENSIONIN.** Di DEV sudah ada append `ZBAPE_VBAP`/`ZBAPE_VBAPX` (field ZDATE, ZLINE) di `BAPE_VBAP`/`BAPE_VBAPX`, dan `ZVBAPKOZ`/`ZVBAPKOZX` di `VBAPKOZ`/`VBAPKOZX`. Ini syarat agar SD BAPI bisa memindahkan field custom ke VBAP. Field yang sama tampil di tab "Additional Screen" VA01 (lihat [03_BADI.md](03_BADI.md)) — jadi satu field bisa diisi dari layar (BAdI) **dan** dari upload (BAPI).
3. **Kelemahan yang layak dikritisi** (pertanyaan "apa yang akan Anda perbaiki?"):
   - `PERFORM COMMIT` dipanggil **tanpa cek RETURN**. Seharusnya: kalau ada TYPE `E`/`A` → `BAPI_TRANSACTION_ROLLBACK`, kalau tidak → COMMIT.
   - `SELECT ... ENDSELECT` dan `SELECT SINGLE` di dalam loop item → bisa dioptimasi dengan baca sekali di awal (performa).
   - Tidak ada mode *test run* (BAPI SD punya parameter `TESTRUN`).

## 4. Study case hands-on

**Tujuan:** buat program kecil `ZTRAIN_BAPI_SO` yang membuat 1 Sales Order dari selection screen dengan BAPI resmi, lalu bandingkan dengan BDC VA01 untuk data yang sama.
**Tempat:** `sandbox-new` (TRS 130), package `$TMP`. Pakai customer, material, sales area yang valid di sandbox (cek dulu di VA01 manual).

### 4.1 Langkah 1 — buat SO manual di VA01 (baseline)
Catat: order type, sales org/dist channel/division, sold-to, ship-to, material, qty, plant, harga. Ini nilai input untuk BAPI dan BDC.

### 4.2 Langkah 2 — versi BAPI

```abap
REPORT ztrain_bapi_so.

PARAMETERS: p_auart TYPE vbak-auart OBLIGATORY,
            p_vkorg TYPE vbak-vkorg OBLIGATORY,
            p_vtweg TYPE vbak-vtweg OBLIGATORY,
            p_spart TYPE vbak-spart OBLIGATORY,
            p_kunag TYPE kunnr      OBLIGATORY,
            p_kunwe TYPE kunnr,
            p_bstkd TYPE vbkd-bstkd,
            p_matnr TYPE matnr      OBLIGATORY,
            p_werks TYPE werks_d,
            p_menge TYPE kwmeng     OBLIGATORY,
            p_zdate TYPE vbap-zdate,
            p_zline TYPE vbap-zline,
            p_test  AS CHECKBOX DEFAULT 'X'.

DATA: gs_head   TYPE bapisdhd1,
      gs_headx  TYPE bapisdhd1x,
      gt_item   TYPE STANDARD TABLE OF bapisditm,
      gs_item   TYPE bapisditm,
      gt_itemx  TYPE STANDARD TABLE OF bapisditmx,
      gs_itemx  TYPE bapisditmx,
      gt_part   TYPE STANDARD TABLE OF bapiparnr,
      gs_part   TYPE bapiparnr,
      gt_sch    TYPE STANDARD TABLE OF bapischdl,
      gs_sch    TYPE bapischdl,
      gt_schx   TYPE STANDARD TABLE OF bapischdlx,
      gs_schx   TYPE bapischdlx,
      gt_ext    TYPE STANDARD TABLE OF bapiparex,
      gs_ext    TYPE bapiparex,
      gs_bape   TYPE bape_vbap,
      gs_bapex  TYPE bape_vbapx,
      gt_return TYPE STANDARD TABLE OF bapiret2,
      gs_return TYPE bapiret2,
      gv_vbeln  TYPE vbak-vbeln,
      gv_error  TYPE c.

START-OF-SELECTION.
* Header
  gs_head-doc_type   = p_auart.
  gs_head-sales_org  = p_vkorg.
  gs_head-distr_chan = p_vtweg.
  gs_head-division   = p_spart.
  gs_head-purch_no_c = p_bstkd.
  gs_headx-updateflag = 'I'.
  gs_headx-doc_type   = 'X'.
  gs_headx-sales_org  = 'X'.
  gs_headx-distr_chan = 'X'.
  gs_headx-division   = 'X'.
  gs_headx-purch_no_c = 'X'.

* Partner
  gs_part-partn_role = 'AG'.
  gs_part-partn_numb = p_kunag.
  APPEND gs_part TO gt_part.
  IF p_kunwe IS NOT INITIAL.
    gs_part-partn_role = 'WE'.
    gs_part-partn_numb = p_kunwe.
    APPEND gs_part TO gt_part.
  ENDIF.

* Item
  gs_item-itm_number = '000010'.
  gs_item-material   = p_matnr.
  gs_item-plant      = p_werks.
  APPEND gs_item TO gt_item.
  gs_itemx-itm_number = '000010'.
  gs_itemx-updateflag = 'I'.
  gs_itemx-material   = 'X'.
  gs_itemx-plant      = 'X'.
  APPEND gs_itemx TO gt_itemx.

* Schedule line (qty)
  gs_sch-itm_number = '000010'.
  gs_sch-sched_line = '0001'.
  gs_sch-req_qty    = p_menge.
  APPEND gs_sch TO gt_sch.
  gs_schx-itm_number = '000010'.
  gs_schx-sched_line = '0001'.
  gs_schx-updateflag = 'I'.
  gs_schx-req_qty    = 'X'.
  APPEND gs_schx TO gt_schx.

* Field custom VBAP-ZDATE / ZLINE lewat EXTENSIONIN
  gs_bape-posnr = '000010'.
  gs_bape-zdate = p_zdate.
  gs_bape-zline = p_zline.
  gs_ext-structure  = 'BAPE_VBAP'.
  gs_ext-valuepart1 = gs_bape.
  APPEND gs_ext TO gt_ext.
  gs_bapex-posnr = '000010'.
  gs_bapex-zdate = 'X'.
  gs_bapex-zline = 'X'.
  CLEAR gs_ext.
  gs_ext-structure  = 'BAPE_VBAPX'.
  gs_ext-valuepart1 = gs_bapex.
  APPEND gs_ext TO gt_ext.

  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
      order_header_in      = gs_head
      order_header_inx     = gs_headx
      testrun              = p_test
    IMPORTING
      salesdocument        = gv_vbeln
    TABLES
      return               = gt_return
      order_items_in       = gt_item
      order_items_inx      = gt_itemx
      order_partners       = gt_part
      order_schedules_in   = gt_sch
      order_schedules_inx  = gt_schx
      extensionin          = gt_ext.

  LOOP AT gt_return INTO gs_return WHERE type = 'E' OR type = 'A'.
    gv_error = 'X'.
    EXIT.
  ENDLOOP.

  IF gv_error = 'X' OR p_test = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.

  LOOP AT gt_return INTO gs_return.
    WRITE: / gs_return-type, gs_return-id, gs_return-number, gs_return-message.
  ENDLOOP.
  IF gv_error IS INITIAL AND p_test IS INITIAL.
    WRITE: / 'Sales Order dibuat:', gv_vbeln.
  ENDIF.
```

Catatan: assign struktur ke `VALUEPART1` hanya aman kalau struktur `BAPE_VBAP` seluruhnya karakter (ZDATE tipe DATS = char 8, ZLINE char) — benar untuk kasus ini. Kalau struktur > 240 karakter, isi dipecah ke `VALUEPART1..4`.

Checklist uji:
- [ ] Jalankan dengan `P_TEST = 'X'` → RETURN berisi pesan sukses simulasi, **tidak ada** SO baru di VA03.
- [ ] Jalankan tanpa test → SO terbentuk; buka VA03 → item → tab **Additional Screen** → Production Date & Line terisi (bukti EXTENSIONIN jalan). **Pakai material grup 3*** (mis. `SRAABI` di sandbox): untuk material lain kedua field sengaja dibersihkan oleh user exit `ZSDE_MV45AFZZ_03` (lihat hasil uji di bawah dan [04_USER_EXIT.md](04_USER_EXIT.md)).
- [ ] Isi material salah → RETURN TYPE `E`, ROLLBACK, tidak ada nomor SO terpakai.
- [ ] Hapus `BAPI_TRANSACTION_COMMIT` → SO tidak tersimpan (bukti BAPI tidak commit sendiri).

### 4.3 Langkah 3 — versi BDC (pembanding)
1. **SHDB** → New recording `ZTRAIN_VA01`, transaksi `VA01`. Isi order type, sales area, sold-to, PO number, material, qty → Save.
2. Dari recording klik **Program** → generate `ZTRAIN_BDC_SO` (source ikut dibuat).
3. Ubah nilai hardcode menjadi parameter; panggil `CALL TRANSACTION 'VA01' USING bdcdata MODE 'N' UPDATE 'S' MESSAGES INTO messtab.`
4. Jalankan dengan MODE `'A'` untuk melihat setiap layar.

Eksperimen pembanding (catat hasilnya):

| Eksperimen | BAPI | BDC |
|---|---|---|
| Waktu eksekusi 1 SO (SE30/ST12 atau `GET RUN TIME`) | | |
| Isi field ZDATE/ZLINE (tab Additional Screen) | EXTENSIONIN | Harus navigasi ke tab item custom (layar BAdI) — rumit |
| User punya default value/screen variant berbeda | Tidak berpengaruh | Bisa gagal |
| Baca error | RETURN jelas | `MESSTAB` perlu `FORMAT_MESSAGE` |

## 5. Hasil uji (25 Nov 2026)

Program lengkap: [../src/ZTRAIN_BAPI_SO.abap](../src/ZTRAIN_BAPI_SO.abap). Detail: [06_HASIL_UJI.md](06_HASIL_UJI.md).

| Uji di sandbox-new | Input | Hasil |
|---|---|---|
| Syntax check 7.31 | — | OK |
| TESTRUN, data valid | ZDOR / 1000 / 01 / 00, customer 1141000100, material RPP-MZ, plant 2000, 1000 KG | `V4 233` header & item processed, `V1 555` incomplete (warning). **0 SO tersimpan** |
| TESTRUN, material salah | material NOTEXIST-XX | `V1 382` material not defined, `V4 248` error item, `V4 219` not changed → ROLLBACK, 0 SO |
| Create sungguhan (izin Baginda, 1 SO) | sama dengan baris 2, PO `ZTRAIN-EXT` | **SO 5683** tersimpan (`V1 311`) |
| Cek VBAP SO 5683 | ZDATE = hari ini, ZLINE = 2 via EXTENSIONIN | **ZDATE/ZLINE kosong** |
| `BAPI_SALESORDER_CHANGE` SO 5683 | EXTENSIONIN yang sama | Tersimpan, ZDATE/ZLINE tetap kosong |

Penyebab (ditelusuri sampai source standar):
1. `SD_SALESDOCUMENT_CREATE` → `MS_MOVE_EXTENSIONIN` (include `LVBAKF0C`) memindahkan `BAPE_VBAP` ke `EX_VBAPKOM` dengan benar.
2. `FV45PFAP_VBAP_FUELLEN_VBAPKOM` memindahkan field `VBAPKOZ` ke `VBAP` secara generik (`ASSIGN COMPONENT`), sesuai flag `VBAPKOZX`.
3. Lalu user exit `USEREXIT_SAVE_DOCUMENT_PREPARE` (implicit enhancement `ZSDE_MV45AFZZ_03`, "Validasi Tab Prod Line") **mengosongkan** ZDATE/ZLINE karena material RPP-MZ bergrup B00501 (bukan grup 3*).

Pelajaran: EXTENSIONIN berfungsi; data dibersihkan oleh aturan bisnis di user exit. Ini jawaban bagus untuk pertanyaan "field Z sudah dikirim lewat BAPI tapi tidak tersimpan, apa yang Anda cek?" → (a) append di BAPE_VBAP/X dan VBAPKOZ/X, (b) flag X, (c) POSNR cocok, (d) **user exit / enhancement yang mengubah field saat save**.

Catatan: dengan `TESTRUN = 'X'`, `USEREXIT_SAVE_DOCUMENT_PREPARE` tidak dipanggil, jadi validasi saat save tidak terlihat di test run (ZLINE `QQ` yang tidak valid pun lolos test run).

**S/4HANA ADB:** program tersimpan di `$TMP`, tetapi VBAP di S/4 tidak punya field ZDATE/ZLINE (append custom hanya ada di ECC) dan S/4 belum punya data SD (VBAK kosong, sales org hanya template 0001/0003). Jadi di S/4 program ini harus disesuaikan (hapus bagian EXTENSIONIN/ZDATE/ZLINE) dan butuh setup SD dulu.

## 6. Pertanyaan interview yang mungkin muncul

1. Apa itu BAPI dan di mana mencarinya? → FM released di BOR; transaksi `BAPI`, SE37 `BAPI*`.
2. Kenapa perlu `BAPI_TRANSACTION_COMMIT`? → BAPI hanya menyiapkan update (update task), tidak commit; supaya beberapa BAPI bisa digabung dalam satu LUW.
3. Fungsi parameter `WAIT = 'X'`? → tunggu update task selesai sebelum lanjut (penting kalau langsung baca/ubah dokumen yang baru dibuat, seperti ZSD113 yang lanjut `BAPI_SALESORDER_CHANGE`).
4. Bagaimana mengisi field Z di BAPI SD? → append field ke `VBAP` + `BAPE_VBAP`/`BAPE_VBAPX` + `VBAPKOZ`/`VBAPKOZX`, isi `EXTENSIONIN`.
5. Kapan tetap pakai BDC? → BAPI tidak tersedia/kurang field, atau perilaku layar (user exit/validasi dialog) wajib ikut jalan.
6. Bisakah BAPI dipanggil dari luar SAP? → ya, RFC (contoh: .NET/Java/Node RFC, PI/PO).
