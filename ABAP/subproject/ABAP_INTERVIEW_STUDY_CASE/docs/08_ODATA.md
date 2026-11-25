# 08 — OData (SAP Gateway)

> Kondisi sistem (dicek 25 Nov 2026):
> - **ECC DEV dan sandbox-new tidak punya SAP Gateway.** Komponen `IW_BEP`, `IW_FND`, `GW_CORE`, `SAP_GWFND` tidak ada di `CVERS`, jadi SEGW dan OData **tidak bisa** dibuat di ECC kita.
> - **S/4HANA ADB 130 (1909, BASIS 754) punya Gateway.** Service sudah terdaftar di `/IWFND/I_MED_SRH`, CDS standar `I_PURCHASEORDER` / `I_PURCHASEORDERITEM` tersedia, ada 10 PO (4500000001–4500000010, vendor 100000, EUR), dan logical system-nya `ADBCLNT130`.
> - Proyek BTP Baginda (subproject `BTP_HYBRID_INTEGRATION`) sudah memakai OData PO standar `MM_PUR_POITEMS_MONI_SRV` dari S/4 ke Fiori di BTP. Studi kasus ini adalah versi **buatan sendiri** dari service seperti itu.
>
> Kode latihan: [../src/ZCL_ZTRN_PO_DPC_EXT.abap](../src/ZCL_ZTRN_PO_DPC_EXT.abap) (method DPC_EXT) dan [../src/ZTRN_I_PO.ddls](../src/ZTRN_I_PO.ddls) (pembanding CDS). Nama interface/method Gateway yang dipakai (`GET_FILTER`, `GET_FILTER_SELECT_OPTIONS`, `CONVERT_SELECT_OPTION`, `GET_KEYS`, `GET_SOURCE_KEYS`, `/IWBEP/CL_MGW_DATA_UTIL=>PAGING`, `/IWBEP/CX_MGW_BUSI_EXCEPTION=>BUSINESS_ERROR`) sudah dicek ada di S/4 (`SEOCOMPO`). Kode **belum** dijalankan, karena perlu project SEGW dibuat dulu.

## 1. Konsep dasar

### 1.1 OData itu apa
OData = protokol **REST di atas HTTP** untuk membaca/mengubah data dalam bentuk entity. Dipakai oleh Fiori/UI5, aplikasi mobile, BTP, dan integrasi modern. Bedanya dengan IDoc dan BAPI:

| | BAPI / RFC | IDoc | OData |
|---|---|---|---|
| Protokol | RFC (biner SAP) | ALE/EDI, asinkron | HTTP(S), JSON/XML |
| Pola | Panggil fungsi | Kirim dokumen, diproses kemudian | Request–response sinkron, CRUD per entity |
| Pemakai khas | Program ABAP lain, middleware | Sistem SAP lain, EDI partner | Fiori, web, mobile, BTP |
| Contoh | `BAPI_SALESORDER_CREATEFROMDAT2` | `ORDERS05` | `GET /sap/opu/odata/sap/ZTRN_PO_SRV/PurchaseOrderSet` |

### 1.2 Istilah yang pasti ditanya

| Istilah | Arti | Di studi kasus |
|---|---|---|
| **Entity type** | Struktur satu objek (mirip struktur ABAP) dengan key | `PurchaseOrder` (key `Ebeln`), `POItem` (key `Ebeln`, `Ebelp`) |
| **Entity set** | Kumpulan entity (mirip tabel) — yang dipanggil di URL | `PurchaseOrderSet`, `POItemSet` |
| **Association / navigation property** | Hubungan antar entity, bisa dinavigasi | `PurchaseOrder` 1:n `POItem`, navigasi `ToItems` |
| **$metadata** | Dokumen XML yang menjelaskan semua entity — "kontrak" service | `.../ZTRN_PO_SRV/$metadata` |
| **Query option** | Parameter URL standar | `$filter`, `$top`, `$skip`, `$orderby`, `$expand`, `$select`, `$format=json`, `$count` |
| **MPC** (Model Provider Class) | Class berisi definisi model (entity, property, association), di-generate SEGW | `ZCL_ZTRN_PO_MPC` / `_MPC_EXT` |
| **DPC** (Data Provider Class) | Class berisi logika ambil/simpan data | `ZCL_ZTRN_PO_DPC` / **`_DPC_EXT`** |
| **Service registration** | Mengaktifkan service di hub Gateway | `/IWFND/MAINT_SERVICE` |
| **Deployment** | *Embedded* (Gateway di sistem yang sama, seperti ADB) atau *Hub* (Gateway terpisah) | ADB = embedded |

### 1.3 Operasi CRUD → method DPC

| HTTP | URL | Method DPC_EXT yang di-redefine |
|---|---|---|
| GET daftar | `/PurchaseOrderSet` | `PURCHASEORDERSET_GET_ENTITYSET` |
| GET satu | `/PurchaseOrderSet('4500000001')` | `PURCHASEORDERSET_GET_ENTITY` |
| GET navigasi | `/PurchaseOrderSet('4500000001')/ToItems` | `POITEMSET_GET_ENTITYSET` (dengan source key) |
| POST | `/PurchaseOrderSet` + body | `..._CREATE_ENTITY` |
| PUT / MERGE | `/PurchaseOrderSet('...')` + body | `..._UPDATE_ENTITY` |
| DELETE | `/PurchaseOrderSet('...')` | `..._DELETE_ENTITY` |
| GET dengan `$expand` | `/PurchaseOrderSet?$expand=ToItems` | Default: framework memanggil GET_ENTITYSET per navigasi; untuk performa bisa redefine `/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET` |

Aturan emas: **jangan ubah `_DPC` / `_MPC`** (di-generate ulang setiap *Generate Runtime Objects*); tulis kode hanya di `_DPC_EXT` / `_MPC_EXT`.

Nama method dibatasi 30 karakter. Itu sebabnya entity set item dinamai `POItemSet`: dengan nama `PurchaseOrderItemSet`, SEGW akan memotong nama method menjadi `PURCHASEORDERITE_GET_ENTITYSET`.

## 2. Study case

**Skenario:** aplikasi Fiori/gudang perlu membaca daftar PO, detail satu PO, dan item-itemnya lewat HTTP. Kita buat service `ZTRN_PO_SRV` dengan dua cara:
- **A. SEGW + kode DPC_EXT** (cara klasik, paling sering ditanya, juga berlaku di ECC yang punya Gateway).
- **B. CDS + `@OData.publish`** (cara S/4, tanpa kode ABAP).

**Tempat:** S/4HANA ADB 130, package `$TMP`, user TRSTABAP. Read-only terhadap data (hanya GET).

> Risiko alat: SEGW dan `/IWFND/GW_CLIENT` memakai control GUI yang mungkin tidak didukung SAP GUI Java di server (editor SE38 sudah terbukti dump di sana). Jika macet, pakai **SAP GUI Windows** atau **ADT (Eclipse)**; service bisa diuji langsung lewat browser / Postman ke `http://192.168.1.199:8080/sap/opu/odata/sap/...`.

### Bagian A — SEGW

#### A1. Buat project dan model
1. **SEGW** → *Create Project*: `ZTRN_PO`, *Service with SAP Annotations*, package `$TMP`.
2. **Data Model → Import → DDIC Structure**:
   - Dari `EKKO`: entity `PurchaseOrder`, entity set `PurchaseOrderSet`; property `EBELN` (key), `BSART`, `LIFNR`, `BEDAT`, `WAERS`.
   - Dari `EKPO`: entity `POItem`, entity set `POItemSet`; property `EBELN` (key), `EBELP` (key), `MATNR`, `TXZ01`, `MENGE`, `MEINS`, `NETWR`.
3. **Association** `PO_Items`: principal `PurchaseOrder` (cardinality 1) → dependent `POItem` (cardinality M), referential constraint `Ebeln` = `Ebeln`, navigation property **`ToItems`**.
4. **Generate Runtime Objects** (ikon roda merah). Terbentuk: `ZCL_ZTRN_PO_MPC`, `ZCL_ZTRN_PO_MPC_EXT`, `ZCL_ZTRN_PO_DPC`, `ZCL_ZTRN_PO_DPC_EXT`, model `ZTRN_PO_MDL`, service `ZTRN_PO_SRV`.

#### A2. Daftarkan service
`/IWFND/MAINT_SERVICE` → *Add Service* → system alias `LOCAL` → cari `ZTRN_PO_SRV` → package `$TMP`. Pastikan node ICF `/sap/opu/odata/sap/ZTRN_PO_SRV` aktif (SICF).

Uji pertama tanpa coding: `GET .../ZTRN_PO_SRV/$metadata` → XML berisi `EntityType Name="PurchaseOrder"`, `NavigationProperty Name="ToItems"`.

#### A3. Tulis kode di DPC_EXT
SE24 / SEGW → *Service Implementation* → `ZCL_ZTRN_PO_DPC_EXT` → redefine tiga method, isi dari [../src/ZCL_ZTRN_PO_DPC_EXT.abap](../src/ZCL_ZTRN_PO_DPC_EXT.abap).

Inti `$filter` (cara yang aman, tanpa parsing string sendiri):
```abap
lo_filter = io_tech_request_context->get_filter( ).
lt_so = lo_filter->get_filter_select_options( ).
LOOP AT lt_so INTO ls_so.
  CASE ls_so-property.                     "nama ABAP, huruf besar
    WHEN 'LIFNR'.
      lo_filter->convert_select_option(
        EXPORTING is_select_option = ls_so
        IMPORTING et_select_option = lr_lifnr ).   "jadi RANGE biasa
  ENDCASE.
ENDLOOP.
SELECT ... FROM ekko ... WHERE lifnr IN lr_lifnr AND bstyp = 'F'.
/iwbep/cl_mgw_data_util=>paging( EXPORTING is_paging = is_paging
                                 CHANGING  ct_data   = et_entityset ).  "$top/$skip
```

Inti navigasi (`/PurchaseOrderSet('...')/ToItems` dan `$expand`):
```abap
lt_keys = io_tech_request_context->get_source_keys( ).   "kunci PO dari entity sumber
READ TABLE lt_keys INTO ls_key WITH KEY name = 'EBELN'.
```

Error bisnis (muncul sebagai HTTP 400 dengan pesan JSON/XML):
```abap
RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
  EXPORTING textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = 'PO tidak ditemukan'.
```

Catatan: filter `BSTYP = 'F'` dipakai lagi. Pelajaran dari uji ALV: EKKO juga berisi RFQ dan kontrak ([01_ALV.md](01_ALV.md)).

#### A4. Uji di `/IWFND/GW_CLIENT` (atau browser)

| # | Request | Hasil yang diharapkan |
|---|---|---|
| 1 | `GET /sap/opu/odata/sap/ZTRN_PO_SRV/$metadata` | XML model, HTTP 200 |
| 2 | `GET .../PurchaseOrderSet?$format=json` | 10 PO, HTTP 200 |
| 3 | `GET .../PurchaseOrderSet?$filter=Lifnr eq '0000100000'&$top=3&$format=json` | 3 PO |
| 4 | `GET .../PurchaseOrderSet('4500000001')?$format=json` | 1 PO (EUR) |
| 5 | `GET .../PurchaseOrderSet('9999999999')` | HTTP 400, pesan "PO tidak ditemukan" |
| 6 | `GET .../PurchaseOrderSet('4500000001')/ToItems?$format=json` | Item 10, material SRAJII, 50 ROL, 22.500,00 |
| 7 | `GET .../PurchaseOrderSet?$expand=ToItems&$top=2&$format=json` | 2 PO, masing-masing dengan array `ToItems` |
| 8 | `GET .../POItemSet?$format=json` (tanpa filter) | HTTP 400 "Isi filter Ebeln…" (melindungi dari baca seluruh EKPO) |
| 9 | `GET .../PurchaseOrderSet/$count` | `10` (framework, tanpa kode tambahan bila GET_ENTITYSET mengisi `es_response_context-inlinecount`/count; jika 0, jadikan latihan tambahan) |

Debugging: pasang *external breakpoint* (bukan session breakpoint) di method DPC_EXT, lalu kirim request dari GW_CLIENT/browser. Error log: `/IWFND/ERROR_LOG` (hub) dan `/IWBEP/ERROR_LOG` (backend).

### Bagian B — CDS + `@OData.publish` (pembanding)
1. ADT (Eclipse) → *New Data Definition* `ZTRN_I_POITEM`, lalu `ZTRN_I_PO` (isi dari [../src/ZTRN_I_PO.ddls](../src/ZTRN_I_PO.ddls)). Aktifkan.
2. Karena `@OData.publish: true`, sistem membuat service **`ZTRN_I_PO_CDS`** otomatis.
3. `/IWFND/MAINT_SERVICE` → Add Service `ZTRN_I_PO_CDS`.
4. Uji: `.../ZTRN_I_PO_CDS/ZTRN_I_PO?$expand=to_Item&$format=json`. Nama navigasi dibuat otomatis dari association (`_Item` → `to_Item`); cek di `$metadata`.

| | SEGW + DPC_EXT | CDS `@OData.publish` | RAP (service definition + binding) |
|---|---|---|---|
| Kode ABAP | Banyak (per method) | Tidak ada untuk read | Behavior definition/implementation untuk transaksi |
| Filter, paging, $count | Ditulis/dipanggil sendiri | Otomatis (SADL) | Otomatis |
| Create/update | Method CREATE/UPDATE_ENTITY | Butuh BOPF/annotation | Managed/unmanaged behavior |
| Tersedia di | ECC dengan Gateway, S/4 | S/4 / NW 7.50+ | S/4 1909+ (paling direkomendasikan untuk pengembangan baru) |
| Kapan dipakai | Logika kompleks, sumber non-DB (BAPI, FM) | Read-only cepat dari tabel/CDS | Aplikasi Fiori baru di S/4 |

### Bersih-bersih
`/IWFND/MAINT_SERVICE` → hapus service `ZTRN_PO_SRV` dan `ZTRN_I_PO_CDS`; SEGW project dan class tetap di `$TMP` untuk latihan berikutnya.

## 3. Pertanyaan interview yang mungkin muncul

1. **Apa itu OData dan bedanya dengan RFC/BAPI?** → REST/HTTP, entity-based, dipakai Fiori; BAPI = RFC biner dipanggil fungsi.
2. **Apa itu MPC dan DPC? Kenapa kode di `_EXT`?** → MPC = model, DPC = data; class dasar di-generate ulang, `_EXT` aman dari regenerate.
3. **Method apa untuk GET list, GET satu, create, update, delete?** → `GET_ENTITYSET`, `GET_ENTITY`, `CREATE_ENTITY`, `UPDATE_ENTITY`, `DELETE_ENTITY`.
4. **Bagaimana membaca `$filter`?** → `io_tech_request_context->get_filter( )->get_filter_select_options( )` + `convert_select_option`, atau `it_filter_select_options` (nama property eksternal).
5. **Bagaimana `$expand` bekerja? Kapan redefine `GET_EXPANDED_ENTITYSET`?** → Default memanggil GET_ENTITYSET per navigasi (N+1 query); redefine untuk mengambil header+item sekali jalan bila datanya besar.
6. **Bagaimana `$top`/`$skip`?** → `is_paging`, helper `/IWBEP/CL_MGW_DATA_UTIL=>PAGING` (atau lebih baik: `UP TO n ROWS` / `OFFSET` di SELECT supaya DB yang membatasi).
7. **Bagaimana mengirim error ke UI?** → `RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION` (error bisnis, HTTP 400) atau `/IWBEP/CX_MGW_TECH_EXCEPTION` (teknis, HTTP 500); message container untuk banyak pesan.
8. **Embedded vs hub deployment?** → Embedded: Gateway di backend yang sama (ADB). Hub: Gateway di sistem terpisah, backend lewat system alias/RFC.
9. **Service tidak ditemukan (HTTP 403/404)?** → Belum didaftarkan di `/IWFND/MAINT_SERVICE`, node ICF tidak aktif (SICF), system alias salah, atau otorisasi `S_SERVICE`.
10. **Bagaimana debug?** → External breakpoint di DPC_EXT; `/IWFND/ERROR_LOG`, `/IWBEP/ERROR_LOG`; `/IWFND/TRACES` untuk payload.
11. **Bagaimana menghubungkan ke BTP?** → Cloud Connector memetakan host internal → destination BTP → aplikasi Fiori memanggil `/sap/opu/odata/...` (pola yang sudah dipakai di proyek BTP_HYBRID_INTEGRATION).
