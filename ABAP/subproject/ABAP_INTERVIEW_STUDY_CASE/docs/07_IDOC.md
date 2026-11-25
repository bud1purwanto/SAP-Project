# 07 — IDoc (Intermediate Document)

> Kondisi sistem (dicek 25 Nov 2026): di DEV dan sandbox-new **belum ada pemakaian IDoc**. Partner profile (EDP13/EDP21) kosong, dan tidak ada IDoc yang terbentuk sejak 2024. Yang sudah tersedia: logical system per client (mis. `TRDCLNT130`, dicatat di T000) dan basic type standar (`MATMAS05`, `ORDERS05`, `INVOIC02`, `DEBMAS07`).
> Karena itu studi kasus ini **dibangun dari nol**, dengan tema yang sama dengan modul lain: **PO**.
> Kode latihan: [../src/ZTRN_IDOC_PO_OUT.abap](../src/ZTRN_IDOC_PO_OUT.abap) (outbound) dan [../src/Z_IDOC_INPUT_ZTRN_PO.abap](../src/Z_IDOC_INPUT_ZTRN_PO.abap) (inbound). Keduanya lolos syntax check di sandbox-new memakai versi mock (`ZTRAIN_IDOC_OUT_MOCK`, `ZTRAIN_IDOC_IN_MOCK`; tipe segmen ditiru sebagai `TYPES` lokal karena segmen belum dibuat). Nama parameter `MASTER_IDOC_DISTRIBUTE` dan interface FM inbound sudah dicocokkan dengan `FUPARAREF` (interface `IDOC_INPUT_ORDERS`).

## 1. Konsep dasar (mulai dari nol)

### 1.1 IDoc itu apa
IDoc adalah **format amplop data standar SAP** untuk bertukar dokumen bisnis antar sistem: SAP ke SAP, atau SAP ke sistem luar lewat middleware (PI/PO, CPI, EDI converter). Ibaratnya surat:

| Bagian surat | Bagian IDoc | Tabel | Isi |
|---|---|---|---|
| Amplop (pengirim, penerima, jenis surat) | **Control record** | `EDIDC` | Nomor IDoc (`DOCNUM`), message type, basic type, partner pengirim/penerima, port, status terakhir |
| Isi surat (paragraf) | **Data record** | `EDID4` (struktur `EDIDD`) | Baris-baris **segmen**; tiap segmen = 1 struktur data (header, item, ...) disimpan di field `SDATA` (1000 karakter) |
| Cap pos / riwayat pengiriman | **Status record** | `EDIDS` | Riwayat status: dibuat, dikirim, diterima, error, sukses |

### 1.2 Istilah yang pasti ditanya

| Istilah | Arti | Transaksi | Contoh |
|---|---|---|---|
| **Segment** | Satu blok data (struktur) dalam IDoc | WE31 | `E1EDK01` (header order), `ZTRN_E1POHDR` (latihan) |
| **Basic type** (IDoc type) | Susunan segmen: urutan, wajib/tidak, berapa kali boleh berulang | WE30 | `ORDERS05`, `MATMAS05`, `ZTRN_PO01` |
| **Extension** | Tambahan segmen custom pada basic type standar | WE30 | `ZORDERS05_EXT` di atas `ORDERS05` |
| **Message type** | Arti bisnis dokumen ("ini order", "ini master material") | WE81, hubungan ke basic type di WE82 | `ORDERS`, `MATMAS`, `ZTRN_PO` |
| **Logical system** | Nama sistem dalam dunia ALE | BD54, dikaitkan ke client di SCC4 | `TRDCLNT130` |
| **Partner profile** | Aturan per partner: message type apa, lewat port mana, diproses langsung atau dikumpulkan, process code apa | WE20 | Partner `ZTRNLS` tipe LS |
| **Port** | Jalur fisik kirim: tRFC, file, XML-HTTP | WE21 | Port file `ZTRNFILE` |
| **Process code** | Penghubung inbound: message type → function module pemroses | WE42 | `ZTRN_PO` → `Z_IDOC_INPUT_ZTRN_PO` |
| **ALE** | Application Link Enabling: IDoc antar sistem SAP (sering untuk master data) | BD64 distribution model | Kirim material dari ECC ke sistem lain |
| **EDI** | IDoc dengan partner bisnis luar (customer/vendor) lewat converter | Partner tipe KU/LI | PO ke vendor (`ORDERS`), invoice dari vendor (`INVOIC`) |

### 1.3 Arah dan status

```
OUTBOUND (SAP mengirim)                         INBOUND (SAP menerima)
program / output (NAST) / change pointer        port menerima IDoc
   -> MASTER_IDOC_DISTRIBUTE                       -> status 50 (diterima)
   -> status 01 (dibuat)                           -> status 64 (siap diproses)
   -> status 30 (siap dikirim, belum dikirim)      -> FM inbound (process code)
   -> status 03 (sudah diserahkan ke port)         -> status 53 (sukses diposting)
   -> status 02 / 29 (error kirim)                 -> status 51 (error aplikasi)
                                                   -> status 56 (partner profile salah)
```

Hafalkan minimal: **03** (outbound terkirim), **30** (outbound menunggu), **51** (inbound error), **53** (inbound sukses), **64** (inbound menunggu).

### 1.4 Cara IDoc outbound terbentuk (3 cara)
1. **Program sendiri** memanggil `MASTER_IDOC_DISTRIBUTE` (studi kasus ini).
2. **Output determination (NACE)**: output type dengan medium 6 (EDI), mis. PO ke vendor lewat `ORDERS`. Mekanismenya sama dengan cetak SmartForms di [05_SMARTFORMS.md](05_SMARTFORMS.md), hanya medium-nya EDI.
3. **Change pointer** (BD52/BD50 + BD21): perubahan master data otomatis dikirim (`MATMAS`, `DEBMAS`).

## 2. Study case

**Skenario:** sistem gudang (WMS) perlu menerima daftar PO dari SAP. SAP mengirim PO sebagai IDoc custom `ZTRN_PO01`. Untuk latihan, "sistem lain"-nya adalah **SAP itu sendiri** (loop-back), jadi cukup satu client:
- Outbound menulis IDoc ke **port file** (bisa dibuka isinya).
- Inbound diuji dengan **WE19** (test tool), yang mengambil IDoc outbound tadi lalu memprosesnya sebagai inbound.

**Tempat:** sandbox-new (TRS 130, kategori client *Customizing*). Semua objek berawalan `ZTRN`. Langkah 1 hanya membaca; langkah 2 dan seterusnya membuat konfigurasi.

> Peringatan: WE20, WE21, BD54, WE42, WE57 adalah **konfigurasi tingkat client**. Semua user sandbox client 130 ikut melihatnya. Hapus atau nonaktifkan setelah latihan.

### Langkah 1 — Kenali IDoc standar (tanpa membuat apa pun)
1. **WE60** (dokumentasi IDoc) → basic type `ORDERS05` → lihat segmen `E1EDK01` (header), `E1EDP01` (item), dan aturan min/max kemunculan.
2. **WE30** (display) `MATMAS05`: pohon segmen.
3. **WE82**: message type `ORDERS` ↔ basic type `ORDERS05`.
4. Catat jawaban: apa beda message type `ORDERS` dan basic type `ORDERS05`? (Satu message type bisa punya beberapa versi basic type: `ORDERS01`…`ORDERS05`.)

### Langkah 2 — Buat struktur IDoc custom

| # | Transaksi | Buat | Isi |
|---|---|---|---|
| 2.1 | WE31 | Segmen `ZTRN_E1POHDR` | `EBELN` CHAR10, `BSART` CHAR4, `LIFNR` CHAR10, `BEDAT` CHAR8, `WAERS` CHAR5 → **Release** |
| 2.2 | WE31 | Segmen `ZTRN_E1POITM` | `EBELP` CHAR5, `MATNR` CHAR18, `TXZ01` CHAR40, `MENGE` CHAR17, `MEINS` CHAR3, `NETWR` CHAR17 → Release |
| 2.3 | WE30 | Basic type `ZTRN_PO01` | `ZTRN_E1POHDR` wajib, min 1 max 1; di bawahnya `ZTRN_E1POITM` opsional, max 9999 → Release |
| 2.4 | WE81 | Message type `ZTRN_PO` | "Latihan PO ke WMS" |
| 2.5 | WE82 | Hubungan | `ZTRN_PO` ↔ `ZTRN_PO01`, release 700 |

Kenapa semua field segmen bertipe CHAR? Karena `SDATA` adalah teks 1000 karakter. Angka dan tanggal ditulis sebagai teks, dan penerima yang mengubahnya kembali.

### Langkah 3 — Partner dan port (outbound)

| # | Transaksi | Buat | Isi |
|---|---|---|---|
| 3.1 | BD54 | Logical system `ZTRNLS` | "Partner latihan WMS" |
| 3.2 | WE21 | Port file `ZTRNFILE` | Direktori di server aplikasi (cek AL11, mis. `DIR_TEMP`), function module nama file `EDI_PATH_CREATE_MESTYP_DOCNUM` |
| 3.3 | WE20 | Partner `ZTRNLS`, tipe LS → **Outbound parameters** | Message type `ZTRN_PO`, port `ZTRNFILE`, *Transfer IDoc immediately*, basic type `ZTRN_PO01` |

### Langkah 4 — Program outbound
Buat `ZTRN_IDOC_PO_OUT` dari [../src/ZTRN_IDOC_PO_OUT.abap](../src/ZTRN_IDOC_PO_OUT.abap). Inti programnya:

```abap
gs_control-mestyp = 'ZTRN_PO'.
gs_control-idoctp = 'ZTRN_PO01'.
gs_control-rcvprt = 'LS'.
gs_control-rcvprn = 'ZTRNLS'.

gs_data-segnam = 'ZTRN_E1POHDR'.
gs_data-sdata  = gs_hdr.            "struktur segmen -> teks SDATA
APPEND gs_data TO gt_data.
" ... 1 segmen ZTRN_E1POITM per item EKPO ...

CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
  EXPORTING  master_idoc_control        = gs_control
  TABLES     communication_idoc_control = gt_comm     "IDoc yang terbentuk
             master_idoc_data           = gt_data.
COMMIT WORK.                        "tanpa commit IDoc tidak diproses
```

Jalankan dengan PO sandbox, mis. `4503000351`.

Checklist:
- [ ] Program menulis "IDoc dibuat: <nomor> status 01/03".
- [ ] **WE02/WE05** → IDoc baru: control record (`ZTRN_PO`, partner `ZTRNLS`), data record (1 header + item), status **03**.
- [ ] **AL11** → direktori port → file IDoc ada, isinya terbaca (format fixed-length).
- [ ] Jalankan dengan partner yang belum ada di WE20 → tidak ada IDoc terbentuk (`gt_comm` kosong). Cari penyebabnya → partner profile.

### Langkah 5 — Inbound: function module + process code

| # | Transaksi | Buat | Isi |
|---|---|---|---|
| 5.1 | SE11 | Tabel `ZTRN_PO_LOG` | `MANDT`, `DOCNUM` (key), `EBELN` (key), `EBELP` (key), `MATNR`, `MENGE` CHAR17, `ERDAT`, `ERZET` |
| 5.2 | SE37 | FM `Z_IDOC_INPUT_ZTRN_PO` di function group `ZTRN_IDOC` | Salin dari [../src/Z_IDOC_INPUT_ZTRN_PO.abap](../src/Z_IDOC_INPUT_ZTRN_PO.abap). Interface **harus persis** seperti FM inbound standar (salin dari `IDOC_INPUT_ORDERS`) |
| 5.3 | WE57 | Hubungkan FM ↔ basic type ↔ message type | FM `Z_IDOC_INPUT_ZTRN_PO`, tipe F, `ZTRN_PO01`, `ZTRN_PO`, direction 2 (inbound) |
| 5.4 | BD51 | Karakteristik FM inbound | FM `Z_IDOC_INPUT_ZTRN_PO`, input type 0 (mass processing) |
| 5.5 | WE42 | Process code `ZTRN_PO` | Processing by function module → `Z_IDOC_INPUT_ZTRN_PO` |
| 5.6 | WE20 | Partner `ZTRNLS` → **Inbound parameters** | Message type `ZTRN_PO`, process code `ZTRN_PO`, *Trigger immediately* |

Pola wajib di FM inbound (lihat kode lengkap):

```abap
LOOP AT idoc_contrl.                         "bisa lebih dari 1 IDoc sekaligus
  LOOP AT idoc_data WHERE docnum = idoc_contrl-docnum.
    CASE idoc_data-segnam.
      WHEN 'ZTRN_E1POHDR'. ls_hdr = idoc_data-sdata.   "teks -> struktur segmen
      WHEN 'ZTRN_E1POITM'. ls_itm = idoc_data-sdata.   "... simpan ke ZTRN_PO_LOG
    ENDCASE.
  ENDLOOP.
  idoc_status-docnum = idoc_contrl-docnum.
  idoc_status-status = '53'.                 "atau '51' bila error
  APPEND idoc_status.                        "framework yang menulis EDIDS
ENDLOOP.
```

Catatan: FM inbound **tidak** melakukan `COMMIT WORK`; commit diatur framework ALE.

### Langkah 6 — Uji inbound dengan WE19
1. **WE19** → *Existing IDoc*: nomor IDoc outbound dari langkah 4.
2. Ubah control record: **sender** = partner `ZTRNLS`/LS, **receiver** = logical system sendiri (`TRDCLNT130`)/LS, port penerima = SAP + SID.
3. Klik **Standard inbound** → IDoc baru terbentuk sebagai inbound.

Checklist:
- [ ] WE02 → IDoc inbound status **53**, teks "PO 4503000351 tercatat di ZTRN_PO_LOG".
- [ ] SE16N `ZTRN_PO_LOG` → baris per item PO.
- [ ] Di WE19 kosongkan `EBELN` pada segmen header → status **51** "Nomor PO kosong di segmen header".
- [ ] **BD87** → IDoc status 51 → perbaiki datanya (WE19 / edit segmen WE02, status berubah 69 → 51) → *Process* → status 53.
- [ ] Hapus process code di partner profile inbound, kirim lagi → status **56** (partner profile tidak ditemukan).

### Langkah 7 (opsional) — Extension IDoc standar
Tambah segmen `ZTRN_E1EDP01X` (mis. `ZLINE` production line) sebagai *extension* `ZTRN_ORDERS05X` di atas `ORDERS05` (WE30 → Extension, WE82 isi kolom Extension). Pengisian dilakukan di **customer exit** outbound ORDERS (SMOD `MM06E001`, `EXIT_SAPLEINM_002`). Ini menyambung ke [04_USER_EXIT.md](04_USER_EXIT.md): customer exit = FM `EXIT_...` + include `ZX...` lewat CMOD.

### Bersih-bersih setelah latihan
Hapus partner profile `ZTRNLS` (WE20), port `ZTRNFILE` (WE21), process code (WE42), dan isi `ZTRN_PO_LOG`. Segmen/basic type boleh tetap ada untuk latihan berikutnya.

## 3. Pertanyaan interview yang mungkin muncul

1. **Apa itu IDoc dan strukturnya?** → Control (EDIDC), data (EDID4/EDIDD, segmen), status (EDIDS).
2. **Beda message type dan basic type?** → Message type = arti bisnis (`ORDERS`); basic type = struktur teknis dan versinya (`ORDERS05`). Hubungan di WE82.
3. **Beda ALE dan EDI?** → ALE untuk antar sistem SAP/internal (partner LS), EDI untuk partner bisnis luar (KU/LI) lewat converter. Keduanya memakai IDoc.
4. **IDoc error 51, apa yang Anda lakukan?** → WE02 lihat status record dan pesan error → perbaiki data master/konfigurasi atau isi segmen → BD87 proses ulang. Kalau error di FM custom → debug FM inbound (WE19 dengan *inbound function module* in foreground/debug).
5. **Outbound status 30 terus, kenapa?** → Partner profile diset *Collect IDocs*; jalankan program `RSEOUT00` (atau ubah ke *Transfer immediately*).
6. **Status 56?** → Partner profile (inbound) tidak ditemukan/tidak cocok untuk kombinasi partner + message type.
7. **Bagaimana menambah field ke IDoc standar?** → Extension (segmen Z, WE30, WE82), isi lewat user exit/BAdI outbound, baca lewat user exit inbound.
8. **Bagaimana IDoc outbound dibuat dari PO?** → Output type NACE medium 6 → program `RSNASTED` → FM outbound standar `IDOC_OUTPUT_ORDERS`.
9. **Transaksi penting?** → WE02/WE05 (monitor), WE19 (test), WE20 (partner), WE21 (port), WE30/WE31 (struktur), WE60 (dokumentasi), WE81/WE82, WE57/WE42/BD51 (inbound), BD87 (reprocess), BD64 (distribution model), BD10/BD12 (kirim master), BD52/BD21 (change pointer).
10. **Bagaimana debug IDoc inbound?** → WE19 → *Inbound function module* → centang *call in debugging mode* / foreground.
