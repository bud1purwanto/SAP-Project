# Solusi: Create Process Order (COR1) dari Luar SAP via RFC

**Kasus:** Process order Jumbo Roll harus terbentuk dengan bentuk seperti di COR1, yaitu **Total Qty 1 ROL** dan **Base Quantity dalam KG** (contoh: 318,230 KG). Proses dijalankan dari aplikasi di luar SAP, lewat RFC saja, **tanpa transport (zero transport)**, dan berjalan di background.

**Sistem yang dicek:** TRD (Development AIX) dan PRT (Production AIX), ECC 731.

---

## 1. Ringkasan

| Pertanyaan | Jawaban |
|---|---|
| Bisa dengan BAPI standar (`BAPI_PROCORD_CREATE`)? | **Tidak**, untuk bentuk 1 ROL + base quantity KG. |
| Bisa full RFC tanpa objek Z? | **Bisa**, lewat FM standar `ABAP4_CALL_TRANSACTION` yang menjalankan COR1. |
| Berjalan di background, tidak mengganggu user? | **Ya**, dengan `MODE_VAL = 'N'`. Tidak ada SAP GUI yang terbuka. |
| Alternatif clean core murni? | `BAPI_PROCORD_CREATE` dengan `QUANTITY_UOM` kosong menghasilkan order dalam **KG**, bukan ROL. |

---

## 2. Kenapa BAPI Standar Tidak Bisa

### 2.1 Tidak ada field base quantity

`BAPI_PROCORD_CREATE` menerima struktur `BAPI_PI_ORDER_CREATE` (36 field). Tidak satu pun field itu adalah base quantity. `BAPI_PROCORD_CHANGE` (`BAPI_PI_ORDER_CHANGE`) juga tidak punya.

### 2.2 Satuan order dipaksa ke Production Unit

`BAPI_PROCORD_CREATE` hanyalah pembungkus untuk `COXT_BAPI_ORDER_CREATE`. Di dalamnya ada blok berikut:

```abap
* UoM conversion
IF NOT LS_ORDPAR-GMEIN IS INITIAL AND
   NOT LS_MSFCV-FRTME  IS INITIAL AND
   LS_ORDPAR-GMEIN <> LS_MSFCV-FRTME.
  PERFORM BASEUOM_CONVERT_TO_ALTUOM USING LS_MSFCV-FRTME
                                 CHANGING LS_ORDPAR.
ENDIF.
```

Jika `QUANTITY_UOM` diisi dan berbeda dari `MARC-FRTME` (Production Unit), SAP mengonversinya ke FRTME.

Data PRD plant 2000: `SRXK4I`, `SRXEMI`, dan `SRXK6I` semuanya memiliki `FRTME = ROL`, sedangkan `MARA-MEINS = KG`.

### 2.3 Base quantity hanya bisa diisi lewat layar COR1

Base quantity (`CAUFVD-BMENGE`) hanya tersedia di **dynpro `SAPLCOKO` 0133** ("Popup zur Eingabe der neuen Auftragsmenge"). Flow logic PAI-nya:

```abap
CHAIN.
  FIELD: CAUFVD-GMEIN MODULE CHECK_ORDER_UNIT ON REQUEST.
  FIELD: CAUFVD-GASMG, CAUFVD-GAMNG, CAUFVD-BMENGE, MSFCV-AUSSS.
  MODULE SET_KZWS_UMR2.          " flag konversi ON
  MODULE CHECK_ACT_AMOUNT_0133.  " hitung ulang faktor konversi
  MODULE CLEAR_KZWS_UMR.
ENDCHAIN.
```

Modul-modul inilah yang menghitung faktor konversi order (`AFPO-UMREZ/UMREN`). Contohnya, 1 ROL = 3.444 KG tercatat sebagai `UMREZ = 3444`, `UMREN = 1`. Karena logika ini hanya hidup di layar, tidak ada BAPI atau FM standar yang bisa mengisinya secara langsung.

### 2.4 Apa yang terjadi kalau tetap pakai BAPI

Order akan terbentuk **1 ROL dengan konversi 1:1** (diambil dari MARM, yang nilainya ROL:KG = 1:1). Saat GR 318,23 KG, SAP membacanya sebagai 318,23 ROL terhadap order 1 ROL, sehingga GR ditolak sebagai over-delivery.

---

## 3. Solusi: `ABAP4_CALL_TRANSACTION` (Standar, RFC, Zero Transport)

### 3.1 Profil FM

FM standar SAP, **RFC-enabled** (`FMODE = R`, sudah dicek di PRT).

```
IMPORT : TCODE        (SY-TCODE)
         SKIP_SCREEN  (default SPACE)
         MODE_VAL     (default 'A')   -> isi 'N'
         UPDATE_VAL   (default 'A')   -> isi 'S'
TABLES : USING_TAB    (BDCDATA)
         SPAGPA_TAB   (RFC_SPAGPA)
         MESS_TAB     (BDCMSGCOLL)
EXPORT : SUBRC
EXCEPTIONS: CALL_TRANSACTION_DENIED, TCODE_INVALID
```

### 3.2 Urutan layar (`USING_TAB`)

Diambil dari program existing **ZPP002** (`ZPPI_UP_REV_PR_JR_F01`, FORM `UPLOAD_PO`), yang sudah terbukti menghasilkan order 1 ROL dengan base quantity KG.

| # | Program / Dynpro | Field | Nilai |
|---|---|---|---|
| 1 | `SAPLCOKO` / `5100` | `BDC_OKCODE` | `=ENTK` |
|   |  | `CAUFVD-MATNR` | material |
|   |  | `CAUFVD-WERKS` | plant |
|   |  | `AUFPAR-PI_AUFART` | order type (mis. `ZRR2`) |
| 2 | `SAPLCOKO` / `5115` | `BDC_OKCODE` | `=SLAP` |
|   |  | `CAUFVD-GAMNG` | `1` |
|   |  | `CAUFVD-GMEIN` | `ROL` |
|   |  | `CAUFVD-GSTRS` / `CAUFVD-GSUZS` | tanggal / jam mulai |
|   |  | `CAUFVD-GLTRS` / `CAUFVD-GLUZS` | tanggal / jam selesai |
| 3 | `SAPLCOSD` / `5132` | `BDC_CURSOR` | `MDFQ-VERID(01)` |
|   |  | `BDC_OKCODE` | `=AUSW` |
| 4 | `SAPLCOKO` / `5115` | `BDC_OKCODE` | `=STAK` |
| 5 | `SAPLCOKO` / `5131` | `BDC_OKCODE` | `=ENT1` |
|   |  | `RC62F-VER_SEL` | `X` |
|   |  | `RC62F-PROD_VERS` | production version (4 digit, leading zero) |
|   |  | `RC62F-NEW_ROUT` | `X` |
|   |  | `RC62F-NEW_BOM` | `X` |
| 6 | `SAPLCOKO` / `5115` | `BDC_OKCODE` | `=+COI` |
| 7 | `SAPLCOKO` / `5115` | `BDC_OKCODE` | `=FREI` (release) |
|   |  | `ZFILM-ZCODE` | type film |
|   |  | `ZFILM-ZWIDTH` | width |
|   |  | `ZFILM-ZLENGTH` | length |
|   |  | `ZFILM-ZTREAT` | treatment |
|   |  | `ZFILM-ZLINE` | production line |
|   |  | `ZFILM-ZMONTH` | bulan produksi |
|   |  | `ZFILM-ZCUSTM` | customer |
|   |  | `ZFILM-ZNOSHEET` | no sheet |
| 8 | `SAPLCOKO` / `5115` | `BDC_OKCODE` | `=KOSD` |
| 9 | `SAPLCOKO` / `5115` | `BDC_CURSOR` | `CAUFVD-AUTERM` |
|   |  | `CAUFVD-AUTERM` | *(kosong)* |
| 10 | `SAPLCOKO` / `5115` | `BDC_OKCODE` | `=KOMG` |
| 11 | **`SAPLCOKO` / `0133`** | `BDC_CURSOR` | `CAUFVD-BMENGE` |
|   |  | `BDC_OKCODE` | `=ENT1` |
|   |  | **`CAUFVD-BMENGE`** | **base quantity KG (mis. `318,23`)** |
| 12 | `SAPLCOKO` / `5115` | `BDC_OKCODE` | `=BU` (save) |

Format baris `BDCDATA`:

- Baris layar: `PROGRAM`, `DYNPRO`, `DYNBEGIN = 'X'`
- Baris field: `FNAM`, `FVAL`

### 3.3 Cara memanggil dari aplikasi luar

1. Bangun `USING_TAB` sesuai tabel di atas.
2. Panggil `ABAP4_CALL_TRANSACTION`:
   - `TCODE = 'COR1'`
   - `MODE_VAL = 'N'` (tanpa layar)
   - `UPDATE_VAL = 'S'` (synchronous, order sudah tersimpan saat RFC kembali)
3. Ambil nomor order dari `MESS_TAB`: baris dengan `MSGID = '40'`, `MSGNR = '582'`, `MSGTYP = 'S'`. Nomor order ada di `MSGV1`.
4. Jika `SUBRC <> 0` atau ada `MSGTYP = 'E'/'A'`, anggap gagal dan simpan seluruh `MESS_TAB` sebagai log.
5. Verifikasi lewat `RFC_READ_TABLE` pada `AFPO` (field `AUFNR`, `AMEIN`, `PSMNG`, `UMREZ`, `UMREN`). Pastikan `AMEIN = ROL` dan perbandingan `UMREZ/UMREN` sesuai base quantity.

Contoh pseudocode (PyRFC):

```python
using_tab = [
    {"PROGRAM": "SAPLCOKO", "DYNPRO": "5100", "DYNBEGIN": "X"},
    {"FNAM": "BDC_OKCODE",       "FVAL": "=ENTK"},
    {"FNAM": "CAUFVD-MATNR",     "FVAL": "JRGARI"},
    {"FNAM": "CAUFVD-WERKS",     "FVAL": "2000"},
    {"FNAM": "AUFPAR-PI_AUFART", "FVAL": "ZRR2"},
    # ... layar 5115, 5132, 5131, 5115 (+COI, FREI, KOSD, KOMG) ...
    {"PROGRAM": "SAPLCOKO", "DYNPRO": "0133", "DYNBEGIN": "X"},
    {"FNAM": "BDC_CURSOR",       "FVAL": "CAUFVD-BMENGE"},
    {"FNAM": "BDC_OKCODE",       "FVAL": "=ENT1"},
    {"FNAM": "CAUFVD-BMENGE",    "FVAL": "318,23"},
    {"PROGRAM": "SAPLCOKO", "DYNPRO": "5115", "DYNBEGIN": "X"},
    {"FNAM": "BDC_OKCODE",       "FVAL": "=BU"},
]

result = conn.call(
    "ABAP4_CALL_TRANSACTION",
    TCODE="COR1",
    MODE_VAL="N",
    UPDATE_VAL="S",
    USING_TAB=using_tab,
)

order_no = next(
    (m["MSGV1"] for m in result["MESS_TAB"]
     if m["MSGID"] == "40" and m["MSGNR"] == "582" and m["MSGTYP"] == "S"),
    None,
)
```

---

## 4. Running di Background

**Ya, sepenuhnya di background.**

- `MODE_VAL = 'N'`: layar COR1 diproses tanpa ditampilkan.
- Eksekusi terjadi di work process server SAP, dalam sesi RFC aplikasi, bukan di sesi GUI user.
- Mesin aplikasi luar tidak memerlukan SAP GUI. Cukup library RFC (PyRFC, node-rfc, JCo, atau NCo).
- User yang sedang bekerja di SAP tidak melihat apa pun.

---

## 5. Hal yang Wajib Diperhatikan

1. **Jangan pakai `MODE_VAL = 'A'` atau `'E'`.** Keduanya butuh GUI dan akan gagal di sesi RFC.
2. **User RFC bertipe System/Communication**, bukan user dialog milik orang. Otorisasi yang dibutuhkan: `S_RFC` untuk FM ini, `S_TCODE = COR1`, dan otorisasi PP process order (`C_AFKO_*`). Sebagian perusahaan memblokir `ABAP4_CALL_TRANSACTION`, jadi konfirmasi ke Basis.
3. **Format angka dan tanggal mengikuti profil user RFC.** Nilai BDC dikirim dalam format eksternal. Cek `USR01-DCPFM` (pemisah desimal) dan `USR01-DATFM` (format tanggal) milik user RFC, lalu sesuaikan format `318,23` atau `318.23` dan format tanggalnya.
4. **Tidak ada `OPTIONS`.** ZPP002 memakai `DEFSIZE = 'X'`, sedangkan FM ini tidak menyediakannya. Uji terutama di layar daftar production version (`SAPLCOSD 5132`).
5. **Popup tak terduga tidak membuat proses menggantung.** Di mode N, transaksi langsung berhenti dan pesannya masuk ke `MESS_TAB`. Aplikasi wajib membaca `SUBRC` dan `MESS_TAB`.
6. **Risiko GUI control.** ZPP002 berjalan mode N di dalam sesi GUI, sedangkan RFC dari luar tidak punya GUI sama sekali. Jika ada layar yang memakai GUI control, layar itu bisa error. **Wajib diuji dari aplikasi luar di DEV**, bukan dari SAP GUI.
7. **Proses satu per satu.** Satu order per panggilan RFC. Jangan jalankan paralel untuk material/plant yang sama karena bisa terkena lock.
8. **Bergantung pada layar.** Cara ini zero transport, tapi bukan clean core murni karena masih mengikuti urutan layar COR1. Jika SAP mengubah layar (upgrade/support package), `USING_TAB` perlu disesuaikan.
9. **Hindari `RFC_ABAP_INSTALL_AND_RUN`.** Memang zero transport, tapi itu injeksi kode dinamis dan bertentangan dengan clean core.

---

## 6. Alternatif Clean Core Murni (Satuan KG)

Jika bisnis bisa menerima order dalam **KG** (bukan ROL), cukup pakai API yang di-release:

1. `BAPI_PROCORD_CREATE` dengan **`QUANTITY_UOM` dikosongkan** dan `QUANTITY` dalam KG.
2. `BAPI_TRANSACTION_COMMIT` (`WAIT = 'X'`).
3. `BAPI_PROCORD_RELEASE`, lalu `BAPI_TRANSACTION_COMMIT`.

Saat `QUANTITY_UOM` kosong, blok konversi FRTME tidak aktif, sehingga satuan order jatuh ke base UoM (KG). Base quantity juga otomatis sama dengan qty.

**Bukti di PRD:** order `100007251718` (material `SRXEMI`, `FRTME = ROL`) terbentuk dengan `GMEIN = KG`, `GAMNG = 39,310`, dan `BMENGE = 39,310`.

**Keterbatasan:** field custom `ZFILM-*` (append di `CI_AUFK`, tersimpan di `AUFK`) tidak bisa diisi lewat BAPI standar.

---

## 7. Perbandingan

| Kriteria | `ABAP4_CALL_TRANSACTION` | `BAPI_PROCORD_CREATE` (UoM kosong) |
|---|---|---|
| Bentuk 1 ROL + base qty KG | Ya | Tidak (order dalam KG) |
| Field custom ZFILM | Ya | Tidak |
| Zero transport | Ya | Ya |
| Clean core (API released) | Tidak (screen-based) | Ya |
| Tahan upgrade | Sedang | Tinggi |
| Background / tanpa GUI | Ya (`MODE_VAL = 'N'`) | Ya |

---

## 8. Langkah Berikutnya

1. Konfirmasi ke Basis bahwa user RFC boleh memanggil `ABAP4_CALL_TRANSACTION` dan `COR1`.
2. Cek format desimal dan tanggal user RFC (`USR01`).
3. Uji di **DEV** dari aplikasi luar dengan 1 order (material Jumbo Roll, order type `ZRR2`).
4. Verifikasi hasil di `AFPO` (`AMEIN`, `UMREZ`, `UMREN`) dan `AFKO` (`GMEIN`, `BMENGE`).
5. Setelah lolos, lanjut ke QA lalu PRD.
