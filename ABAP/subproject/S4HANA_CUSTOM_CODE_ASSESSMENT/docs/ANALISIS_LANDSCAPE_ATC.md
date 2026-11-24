# Analisis Landscape untuk ATC S/4HANA Readiness

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-24 |
| Sistem sumber (as-is) | ECC Production AIX (192.168.1.151, client 999) |
| Sistem tujuan | S/4HANA ADB (192.168.1.199, client 130) |
| Bukti | RFC read-only ke Development AIX (CVERS, TSTC, TRDIR, TFDIR). PRD belum disentuh. ADB belum terverifikasi lewat RFC (tidak terdaftar di MCP SAP) |

## 1. Versi ECC (DEV AIX, diasumsikan sama dengan PRD, perlu konfirmasi Basis)

| Komponen | Release | SP |
|---|---|---|
| SAP_BASIS / SAP_ABA / SAP_BW | 731 | 0004 / 0003 / 0003 |
| SAP_APPL / EA-APPL | 606 (EHP6) | 0003 |
| ST-PI | 2008_1_700 | 0017 |
| ST-A/PI | 01V_731 | 0002 |

## 2. Ketersediaan tool di ECC

| Tool | Status |
|---|---|
| SCI, framework ATC lokal (`SATC*`), SE95, SAPRSEUB | Ada |
| SCMON / SUSG | Tidak ada |
| SYCM / `/SDF/RC_START_CHECK` (Readiness Check) | Tidak ada |
| Stub remote ATC | Tidak ada |
| `ZRFC_READ_REPORT` (dipakai tool ekstrak) | Ada di DEV (`SAPLZFRFC`) |

## 2a. Status S/4 ADB (cek RFC read-only via gateway MCP SAP target `S4-HANA`, 2026-11-24)

| Item | Hasil |
|---|---|
| Release | **S/4HANA 1909 FPS03** (S4CORE 104 SP03), SAP_BASIS 754 SP03, ST-PI 740 SP13, HANA, kernel 777 |
| T-code ATC, SCI, SYCM, SCMON, SUSG, SNOTE, SM59 | Ada |
| Check S/4 readiness (`CL_CI_TEST_S4H_*`, 8 class) | Ada |
| Remote stub di ADB sendiri (`SCA_REMOTE_DATA_ACCESS`) | Ada (sebagai pembanding, ECC belum punya) |
| **Simplification DB** (`SYCM_SAP_SIMPL`, `SYCM_SITEM`) | **Kosong, belum di-load** |
| **Konfigurasi ATC central** (`SATC_AC_CONFIG`, `SATC_AC_STATE`) | **Kosong, belum di-setup** |
| RFC ke ECC (RFCDES type 3) | **Belum ada.** Yang ada hanya RFC internal ADB (TMSADM, FINBTR, MDGTR, CIF) |
| Check variant (`SCICHKV_HD`) | 0 baris terbaca lewat RFC. Perlu dicek langsung di SCI karena bisa jadi terbatas otorisasi |

Kesimpulan: ADB **layak** dipakai sebagai central check system (release dan check-nya sudah ada), tapi **belum dikonfigurasi**.

## 2b. Kendala utama: tidak ada kontrak support SAP / S-user (dikonfirmasi 2026-11-24)

Yang terblokir: Simplification DB (SYCM), note 2270689 (remote ATC), note SCMON/SUSG untuk 7.31, dan SAP Readiness Check.

Jalur pengganti (tetap memakai tool standar):

| Poin | Pengganti |
|---|---|
| 1–2 Inventory & dependency | Tidak terdampak (TADIR, SE80, Where-Used, SAPRSEUB, SE19/SE20/CMOD) |
| 3 Usage | ST03N/STAD (job `SAP_COLLECTOR_FOR_PERFMONITOR` di PRD) + TBTCP. Tanpa SCMON, level transaksi/report saja |
| 4 ATC | Kode pilot dibawa ke ADB (transport STMS atau copy), lalu **ATC lokal** di ADB dengan `S4HANA_READINESS_1909` (variant ada, check RFC-based dan S/4HANA Readiness aktif). Yang efektif: syntax check di S/4, field length extension, operasi DB/HANA. Tidak ada daftar simplification item resmi |

Variant `S4HANA_READINESS_1909` di ADB terverifikasi lewat screenshot SCI (changed 29.06.2020 by SAP).

## 3. Arsitektur yang diusulkan (standar SAP, butuh S-user)

```
S/4HANA ADB (central check system)  --RFC read-->  ECC Production AIX (checked system)
  - ATC variant S4HANA_READINESS_<rilis>            - stub remote ATC (note 2270689)
  - Simplification DB (note 2241080)                - SCMON aktif (usage)
  - Custom Code Migration app (Fiori, opsional)
```

## 4. Kendala dan keputusan

1. **Target release.** Menurut dokumen, ADB adalah S/4HANA 1909, yang sudah lewat mainstream maintenance (akhir 2024). Perlu dipastikan target migrasinya. Central check system idealnya berada di release yang sama atau lebih tinggi dari target.
2. **Basis di ECC:** pasang note stub remote ATC, naikkan ST-PI, siapkan SCMON untuk 7.31, dan periksa note prasyarat karena SP04 tergolong rendah.
3. **Basis di ADB:** buat RFC destination read-only ke ECC, load Simplification DB, dan aktifkan Fiori Custom Code Migration (opsional).
4. **Usage:** SCMON harus jalan di PRD minimal 1 siklus closing, idealnya 3 bulan atau lebih. Alternatif sementara: ST03N.
5. **Izin RFC ADB ke PRD**, atau pakai QA (192.168.2.7, client 320) kalau source-nya sinkron dengan PRD.

## 5. Yang bisa jalan sekarang (tanpa menunggu Basis)

- Inventory: TADIR, SMOD/CMOD, SE19, SE20, SE95.
- Dependency: SAPRSEUB (background), Where-Used, `WBCROSSGT`/`D010INC`, ditambah tool ekstrak untuk drill-down pilot.
- SCI lokal (hanya check klasik, bukan readiness S/4).
