# Design Brief — Tool Deteksi & Perbaikan Custom Code ECC ke S/4HANA (tanpa AI)

| Atribut | Isi |
|---|---|
| Status | **AGREED** (2026-11-24, lihat bagian 10) |
| Tanggal | 2026-11-24 |
| Sumber | Email manager (assessment custom ABAP), percakapan 24 Nov (tanpa S-user, Opsi A, source dari ECC DEV) |
| Sub-project | `subproject/S4HANA_CUSTOM_CODE_ASSESSMENT/` |
| Server analisa | ECC Development AIX (TRD, 192.168.2.8, inst 00, client 130), read-only via RFC |
| Server write | S/4 ADB (192.168.1.199, client 130), **salinan** program saja, ECC tidak pernah ditulis |

## 1. Tujuan
Tool di dalam SAP (Z-report di ADB) yang mengambil program custom dari ECC, **mendeteksi** apa yang tidak valid di S/4HANA 1909, lalu **mengusulkan dan menerapkan perbaikan** ke salinan program di ADB. Tool tidak memakai AI sama sekali dan hasilnya terukur dan bisa diulang. Tool ini juga mengisi celah karena tidak ada S-user (tanpa Simplification DB dan tanpa note SAP).

## 2. Hasil Riset (ringkas)

### 2.1 Fakta dari sumber eksternal
| Temuan | Sumber |
|---|---|
| SAP punya **Quick Fix** di ADT (Eclipse) untuk temuan ATC S/4 readiness: ORDER BY, MATNR, akses `VBFA`/`VBUK`/`VBUP`/`KONV`/`BSEG`, dan elemen `VBTYPE`. Ada juga mode **massal** (per package). Quick Fix hanya bisa diterapkan pada hasil **ATC lokal** di sistem S/4 | [SAP blog semi-automatic adaptation](https://blogs.sap.com/2018/10/02/semi-automatic-custom-code-adaptation-after-sap-s4hana-system-conversion/comment-page-1/), [CustomCodeMigration End-to-End (help.sap.com)](https://help.sap.com/doc/9dcbc5e47ba54a5cbb509afaa49dd5a1/2022.001/en-US/CustomCodeMigration_EndtoEnd.pdf), [Komentar ADT quick fix](https://groups.community.sap.com/t5/application-development-blog-posts/comments-for-the-adt-quick-fixes/bc-p/13457836) |
| Tidak ada quick fix untuk pemanggilan FM/BAPI yang di-simplify. Komentar quick fix (menyimpan kode lama) hanya untuk objek **transportable**, bukan `$TMP` | Sumber yang sama |
| ATC hanya memeriksa kode yang lolos syntax check. Urutan kerjanya: perbaiki syntax error dulu, lalu jalankan ATC lagi (biasanya muncul temuan baru) | [abapconf 2024 – Successful Custom Code Adaptation](https://abapconf.org/abapconfeurope2024/assets/documents/Successful%20Custom%20Code%20Adaptation.pdf) |
| Check "usages of simplified objects" **butuh Simplification DB** (SYCM). Tanpa itu, temuan KONV/VBUK/dst. **tidak muncul**, sehingga quick fix-nya juga tidak muncul | [Custom code adaptation FAQ](https://blogs.sap.com/t5/enterprise-resource-planning-blogs-by-sap/custom-code-adaptation-for-sap-s-4hana-faq/ba-p/13418880) |
| Pola penggantian: `KONV` ke `PRCD_ELEMENTS` (note 2220005), status `VBUK`/`VBUP` pindah ke tabel header/item (`VBAK`, `LIKP`, `VBAP`, …), `MKPF`/`MSEG` ke `MATDOC` | [DZone – S/4 conversion issues](https://dzone.com/articles/large-scale-s4hana-conversion-issues-prevention), [SAP KBA 3563944](https://userapps.support.sap.com/sap/support/knowledge/en/3563944) |
| ADT bisa dipasang gratis dari update site `tools.hana.ondemand.com` (SAP Developer License), tanpa S-user | [SAP tutorial install ADT](https://developers.sap.com/tutorials/abap-install-adt.html) |
| abaplint (open source) adalah linter ABAP dengan 150+ aturan, tapi **tidak** fokus ke S/4 readiness | [abaplint GitHub](https://github.com/abaplint/abaplint), [rules.abaplint.org](https://rules.abaplint.org) |

### 2.2 Fakta dari sistem kita (RFC read-only, 24 Nov)
| Cek di ADB | Hasil | Arti untuk desain |
|---|---|---|
| `CL_S4H_QUICKFIX_PROVIDER`, `CL_SATC_CI_QUICKFIX_APPLY`, dll. | **Ada** | Quick fix standar SAP tersedia di ADB |
| ICF service `ADT` | Ada, flag aktif **kosong** | Perlu aktivasi SICF `/sap/bc/adt` supaya Eclipse ADT bisa dipakai |
| `CL_CI_TEST_NO_ORDER_BY`, `CL_CI_TEST_S4H_FIELD_EXT`, `CL_ABAP_COMPILER` | Ada | Check ORDER BY dan field length jalan **tanpa** SYCM. Compiler bisa dipakai untuk referensi pasti |
| `MKPF`→`NSDM_V_MKPF`, `MSEG`→`NSDM_V_MSEG`, `COEP`→`V_COEP`, `FAGLFLEXA`→`FGLV_FAGLFLEXA` (DD02L-`VIEWREF`) | Ada *replacement object* | **Terdeteksi otomatis** lewat diff DDIC: baca tetap jalan, tulis tidak boleh |
| `BSIS` | Berubah jadi `VIEW` | Terdeteksi otomatis lewat diff `TABCLASS` |
| `KONV`, `VBUK`, `VBUP` | Masih `TRANSP` | **Tidak** terdeteksi lewat diff (tabel masih ada, tapi tidak diisi lagi), jadi wajib masuk katalog aturan |
| `RPY_PROGRAM_INSERT` (RFC) | Ada | Bisa menulis salinan program ke ADB |

### 2.3 Aturan internal
SOP-ABAP-06 *ABAP Change Program* (RAG internal): setiap perubahan butuh nomor CR, **remark** di kode yang ditambah, diganti, atau dinonaktifkan, dan kode lama dikomentari, bukan dihapus. Tool wajib mengikuti format ini.

## 3. Pertanyaan Terbuka
| # | Pertanyaan | Ditanya ke | Jawaban | Tanggal |
|---|---|---|---|---|
| 1 | Target release (versi S/4HANA tujuan conversion: 1909 / 2020 / 2021 / 2022 / 2023 / 2025)? ADB = 1909. Ini menentukan check variant, daftar simplification, dan masa maintenance (1909 sudah lewat mainstream) | Manager | | |
| 2 | Boleh membuat package transportable + transport layer di ADB (syarat komentar quick fix)? | Basis | Tidak perlu: semua objek **lokal `$TMP`**, temporary, tidak di-transport. Komentar kode lama ditulis oleh tool sendiri (format SOP), bukan fitur komentar quick fix SAP | 2026-11-24 |
| 3 | Aktivasi SICF `/sap/bc/adt` di ADB: bisa dilakukan sendiri (otorisasi SICF) atau harus Basis? | Baginda | Dicoba lewat MCP 24 Nov: node ADT **belum aktif**, dan gateway menolak `HTTP_ACTIVATE_NODE` (di luar katalog). Diaktifkan **manual via SICF** oleh Baginda, **terverifikasi aktif** (ICFACTIVE=X, `/sap/bc/adt/discovery` = 401). URL ADT: `http://192.168.1.199:8080` / `https://192.168.1.199:4433`, client 130 | 2026-11-24 |
| 4 | Jenis migrasi nanti: system conversion (kode ikut terbawa) atau new implementation? Ini menentukan cara memasang fix pack | Manager | **System conversion.** Kode custom ikut terbawa ke S/4, jadi fix pack dipasang di S/4 DEV hasil conversion (bagian 6.4) | 2026-11-24 |
| 5 | Kode tool di ADB boleh pakai sintaks 7.54, atau tetap konvensi 7.31? | Baginda | Ikuti server as-is: ADB = SAP_BASIS **754** (terverifikasi), jadi tool ditulis dengan sintaks 7.54. Source salinan ECC tetap 7.31 apa adanya | 2026-11-24 |
| 6 | **DDIC Z ikut dibawa ke ADB?** Tanpa tabel/struktur/data element Z, salinan program tidak bisa dikompilasi, sehingga L2, L4, dan verifikasi fix penuh error palsu. Pilihan: transport of copies DDIC Z dari ECC (Basis), atau buat lewat tool | Baginda + Basis | **Dibawa, temporary** (`$TMP`, tanpa transport), dibuat oleh tool | 2026-11-24 |
| 7 | Nama salinan di ADB: sama dengan ECC (memudahkan fix pack) atau diberi prefix? Perlu cek bentrok dengan objek Z yang sudah ada di ADB (proyek data migration) | Baginda | **Akhiran `_ECC6`**; kalau melebihi batas panjang, nama asli dipotong (aturan 6.7) | 2026-11-24 |
| 8 | ADB boleh dipakai sebagai sandbox remediation? Gateway MCP melabeli ADB "production", padahal host-nya `hana-demo` | Baginda / Basis | **Sandbox** | 2026-11-24 |
| 9 | Baseline source: file Alfa atau ECC DEV? Kalau berbeda, mana yang dipakai? Tool akan membandingkan hash keduanya dan melaporkan selisihnya | Manager | **File Alfa.** ECC DEV hanya untuk metadata DDIC dan untuk mengambil objek yang hilang dari file Alfa (dilaporkan terpisah) | 2026-11-24 |
| 10 | Manager meminta "standard SAP tools". Tool Z ini posisinya pelengkap ATC lokal; perlu persetujuan manager | Manager | Belum disetujui. Tool ini dicari sebagai alternatif karena Basis masih sibuk, jadi desain diusahakan **tanpa ketergantungan Basis** | 2026-11-24 |

## 4. Peta Objek & Sumber Data
| Kebutuhan | Sumber | Sudah ada? | Keputusan |
|---|---|---|---|
| Baca source ECC | `RPY_PROGRAM_READ` / `RFC_READ_REPORT` via RFC `ECC_TRD_130` | Ada di ECC (mode R) | pakai |
| DDIC & repository ECC | `RFC_READ_TABLE` (DD02L, DD03L, DD04L, TFDIR, TSTC, SEOCLASS, TADIR) | Ada | pakai |
| DDIC & repository ADB | SELECT lokal | Ada | pakai |
| Parsing kode | `SCAN ABAP-SOURCE … TOKENS … STATEMENTS` (scanner resmi ABAP, lebih akurat dari regex) | Ada | pakai |
| Syntax check S/4 | `SYNTAX-CHECK FOR itab` pada salinan source | Ada | pakai |
| Referensi pasti (method, tipe) | `CL_ABAP_COMPILER` pada salinan di ADB | Ada | pakai (fase 2) |
| Quick fix SAP | ATC lokal + ADT Quick Fix | Ada (ADT perlu diaktifkan) | pakai untuk temuan yang dideteksi SAP |
| Ambil source baseline | Upload file `.abap` dari Alfa | — | pakai (utama) |
| Buat salinan DDIC Z | `DDIF_TABL_PUT`, `DDIF_DTEL_PUT`, `DDIF_DOMA_PUT`, `DDIF_TTYP_PUT` + `DDIF_*_ACTIVATE`, definisi dibaca dari ECC lewat `RFC_READ_TABLE` pada DD01L/DD07L (domain), DD04L (data element), DD02L/DD03L (tabel/struktur), DD40L (table type), lalu dirakit ulang di ADB. `DDIF_*_GET` di ECC **tidak** remote-enabled (cek 24 Nov) | `RFC_READ_TABLE` ada (R). `DDIF_*_PUT` di ADB belum dicek | pakai |
| Tulis salinan | `INSERT REPORT` / `RPY_PROGRAM_INSERT` ke `$TMP` | Ada | pakai |
| Katalog aturan | Z table baru | Belum | baru |

## 5. Opsi
| Opsi | Ringkasan | Plus | Minus | Effort | Dipilih? |
|---|---|---|---|---|---|
| A | Z-report + Z-class di ADB, source ditarik dari ECC lewat RFC | Murni di dalam SAP, memakai scanner/compiler resmi, quick fix SAP bisa langsung dipakai di sistem yang sama | Butuh RFC ADB ke ECC dan package di ADB | L | **Ya** (pilihan Baginda) |
| B | Script Node.js (lanjutan tool rekan) | Parser sudah ada | Regex, di luar SAP, tidak bisa memakai quick fix SAP | M | Tidak |

### 5.1 Opsi editor untuk Quick Fix standar SAP (pelengkap Opsi A)
Z-program `ZS4CCA` tetap jadi alat utama (scan, deteksi, approve, fix dari katalog, laporan). Editor hanya dipakai untuk menjalankan Quick Fix SAP pada temuan ATC lokal. Keputusan: **dua-duanya boleh**, dipilih setelah uji di ADB.

| Opsi | Ringkasan | Plus | Minus | Status |
|---|---|---|---|---|
| E1 – Eclipse ADT | Install dari `tools.hana.ondemand.com`, ATC → Quick Fix (`Ctrl+1`), termasuk mass quick fix | Jalur resmi SAP, mass quick fix per package | Perlu instal Eclipse di laptop | Opsi |
| E2 – VS Code + ABAP FS (`murbani.vscode-abap-remote-fs`) | Panel ATC Findings, fix lewat ikon lampu / `Ctrl+.` | Tim sudah memakai (subproject `ADT_VSCODE`), memakai REST API ADT yang sama | Extension komunitas, quick fix di 1909 **belum diuji**. **Jangan pakai** opsi "Fix with Copilot" (AI) | Opsi, uji dulu |
| E3 – ADT for VS Code resmi SAP | ATC + *deterministic quickfixes* via ADT MCP Server | Resmi SAP | Dukungan untuk backend 1909 belum pasti | Cek kompatibilitas |
| E0 – tanpa editor | Pola ORDER BY / MATNR dibuat sendiri di katalog `ZS4CCA` | Semua di SAP GUI | Tambah sekitar 2–3 hari, tidak memakai mesin resmi SAP | Cadangan |

Prasyarat E1/E2/E3: aktifkan SICF `/sap/bc/adt` di ADB dan buka port HTTP ICM (SMICM). Proxy `X-Requested-With` (khusus BASIS 731) kemungkinan tidak perlu di ADB (BASIS 754).

## 6. Desain

### 6.1 Alur besar
```
[1 Ambil]   ECC DEV --RFC--> source + include + DDIC ECC
[2 Deteksi] L1 diff DDIC ECC vs ADB | L2 syntax check S/4 | L3 katalog aturan | L4 ATC lokal SAP (S4HANA_READINESS_1909)
[3 Usul]    temuan -> kelas fix A/B/C -> source baru + diff + remark SOP
[4 Review]  developer approve/tolak per fix (ALV)
[5 Terap]   tulis salinan bernama *_ECC6 ke ADB $TMP (bukan ECC)
[6 Verif]   ulang L2 + L4 -> temuan harus hilang, tidak boleh muncul error baru
[7 Laporan] Excel: inventory, temuan, klasifikasi 4 kategori, status fix
```

### 6.2 Empat lapis deteksi
| Lapis | Mendeteksi | Contoh |
|---|---|---|
| L1 diff DDIC | Tabel/view hilang, `TABCLASS` berubah, `VIEWREF` (replacement object), field hilang/panjang berubah, FM/T-code/class hilang | `MKPF`/`MSEG` (VIEWREF), `BSIS` (VIEW), `MATNR` 40, T-code lama yang hilang |
| L2 syntax S/4 | Semua error kompilasi di S/4 | Tipe tidak cocok, objek tidak ditemukan. Error karena objek **Z** yang belum ada dipisahkan jadi daftar *missing dependencies* |
| L3 katalog aturan | Hal yang tidak terlihat dari DDIC | `KONV`, `VBUK`/`VBUP`, customer/vendor ke BP, credit management, Native SQL / hint Oracle, BDC ke T-code yang berubah |
| L4 ATC lokal SAP | Check resmi yang jalan tanpa SYCM | SELECT tanpa ORDER BY, field extension, syntax |

### 6.3 Tiga kelas perbaikan
| Kelas | Perlakuan | Contoh pola | Mesin |
|---|---|---|---|
| **A – otomatis** (mekanis, aman) | Tool membuat kode baru, developer cukup approve | ORDER BY PRIMARY KEY pada SELECT yang hasilnya diasumsikan urut, `TYPE c LENGTH 18` untuk material ke `TYPE matnr`, hapus `%_HINTS ORACLE`. (`KONV` ke `PRCD_ELEMENTS` sementara di kelas B, lihat R2) | Quick Fix SAP (untuk temuan L4) + rewrite template tool (untuk temuan L1/L3) |
| **B – semi otomatis** (template + isian) | Tool menyiapkan kerangka dan menandai bagian yang wajib diisi developer | `VBUK`/`VBUP` ke field status di `VBAK`/`LIKP`/`VBAP` (perlu tahu jenis dokumen), tulis `MSEG`/`MKPF` ke BAPI goods movement | Template di katalog aturan |
| **C – manual / redesign** | Hanya diberi penjelasan dan referensi | Customer/vendor ke Business Partner, credit management, output management | Tidak ada rewrite |

Prinsip keamanan: tidak ada fix yang diterapkan tanpa approve. Kode lama selalu dikomentari dengan format SOP:
```abap
*{ S4MIG <CR> <tgl> <user> rule KONV_01 - ganti KONV ke PRCD_ELEMENTS
*  SELECT * FROM konv INTO TABLE lt_konv WHERE knumv = lv_knumv.
   SELECT * FROM prcd_elements INTO TABLE lt_konv WHERE knumv = lv_knumv.
*} S4MIG
```

### 6.4 Penerapan ke migrasi nyata
- ADB adalah **sandbox remediation**, bukan sistem tujuan akhir. Setiap fix disimpan sebagai **fix pack** (source asli, source baru, diff, aturan) di `outputs/` dan git.
- Saat migrasi nyata, fix pack dipasang ulang di S/4 DEV hasil migrasi. Tool memeriksa *hash* source dulu: kalau program sudah berubah sejak di-scan, fix pack ditolak dan harus di-scan ulang.

### 6.5 Klasifikasi ke 4 kategori manager
| Kondisi | Kategori |
|---|---|
| Tidak ada temuan | Compatible |
| Semua temuan kelas A/B | Requires Modification |
| Ada temuan kelas C | Requires Redesign |
| Tidak ada di ST03N/TBTCP (usage) | Obsolete / Not Used (konfirmasi functional) |

### 6.6 Risiko & celah yang belum tertutup (review 2026-11-24)
| # | Celah | Dampak | Usulan |
|---|---|---|---|
| R1 | **Lolos syntax ≠ benar secara bisnis.** ADB tidak punya data transaksi yang representatif | Fix kelas A bisa lolos compile tapi hasilnya berbeda | Status fix maksimal "verified-syntax". Uji fungsional dilakukan di S/4 hasil migrasi (di luar tool) |
| R2 | KONV ke PRCD_ELEMENTS sebagai kelas A perlu dicek ulang: field tidak 100% identik, dan SAP juga menyarankan API/CDS `V_KONV` | Salah klasifikasi | Turunkan ke kelas B sampai diverifikasi di pilot |
| R3 | Writer awal hanya mendukung **program dan include** (`RPY_PROGRAM_INSERT`). Function group, class, enhancement, dan Smart Form belum | Sebagian objek hanya terdeteksi, tidak bisa di-fix | Fase F1–F3 dibatasi ke program dan include. Objek lain di fase lanjutan |
| R4 | Include yang dipakai bersama oleh beberapa program | Fix dobel atau saling timpa | Fix dicatat per include (sekali), bukan per program pemanggil |
| R5 | Usage (poin 3) belum ada cara masuk ke tool | Kategori "Obsolete" tidak terisi otomatis | Upload export ST03N/TBTCP (Excel/CSV) ke tool |
| R6 | Simplification List 1909 sebagai bahan katalog **diasumsikan** publik di help.sap.com, belum dicek | Katalog L3 bisa kurang lengkap | Cek ketersediaan PDF sebelum F2 |
| R7 | Belum ada otorisasi siapa yang boleh approve atau apply fix | Kontrol lemah | Authority check + catat approver dan CR di `ZS4CCA_FIX` |
| R8 | Jumlah objek di file Alfa belum diketahui | Run online bisa time-out | Mode background job untuk volume besar |

### 6.7 Aturan nama salinan `_ECC6`
| Jenis | Batas panjang | Aturan |
|---|---|---|
| Program / include | 40 | `<asli>_ECC6`, potong nama asli ke 35 karakter |
| Tabel / view DDIC | 16 | Potong ke 11 karakter + `_ECC6` |
| Struktur, data element, domain, table type | 30 | Potong ke 25 karakter + `_ECC6` |
| Function module | 30 | Potong ke 25 karakter + `_ECC6`. Function group-nya juga disalin (fase lanjutan, R3) |

- **Bentrok setelah dipotong** (dua nama asli jadi sama): karakter terakhir sebelum `_ECC6` diganti nomor urut 1–9/A–Z, dan dicatat di `ZS4CCA_NAMEMAP`.
- Sebelum dibuat, tool cek dulu apakah nama sudah ada di ADB (TADIR). Kalau sudah ada, pakai aturan bentrok.
- Semua referensi di source salinan diarahkan ke nama `_ECC6`. **Fix pack disimpan dengan nama asli**: saat diekspor, tool membalik pemetaan supaya fix bisa dipasang di S/4 nyata.
- Nama yang dirujuk lewat variabel (dinamis) tidak bisa di-rename, sehingga dilaporkan.

### 6.8 F3a — Fixer (dirancang 2026-11-25, berdasar survei korpus 292 file / 421 ribu baris)

| Pola di korpus | Baris | Aturan | Kelas |
|---|---|---|---|
| `%_HINTS ORACLE '...'` | ±100, belasan program | **R01_HINT** hapus klausa hint | A (otomatis, perlu pilih/approve) |
| `FROM KONV` / `TYPE KONV` | 18 baris, 3 program | **R02_KONV** KONV ke PRCD_ELEMENTS | A dengan tanda risiko (lihat bawah) |
| `EXEC SQL` (CONNECT TO / SET CONNECTION / INSERT) | 227 | Tidak diganti. Koneksi DB sekunder, cukup cek `DBCON` ada di S/4 | Info |
| `VBUK` / `VBUP` | 111 | Butuh pemetaan field per dokumen | B/C (F4) |
| `MKPF`/`MSEG` | 2214, hanya baca | Tidak perlu fix (replacement view); tulis = C | Info |

**Fakta DDIC R02 (ADB vs ECC, 25 Nov):** `PRCD_ELEMENTS` tidak identik dengan `KONV`. Field `MANDT`, `STUFE`, `WEGXX` hilang; 12–15 field berubah tipe/panjang (KBETR CURR 11 ke DEC 24, KDATU DATS ke CHAR 14, ZAEHK NUMC 2 ke 3, KRECH CHAR 1 ke 3). Karena itu: perbandingan field dihitung **saat berjalan dari DDIC ADB**; field hilang atau tulis ke tabel = risiko **E** (tidak diterapkan); field berubah tipe = risiko **W** (diterapkan, ditandai).

**Alur:** deteksi (ALV) lalu *Usulkan perbaikan* (centang P_FIX) lalu ALV usulan (pilih baris, E tidak terpilih) lalu Back lalu konfirmasi lalu tulis salinan `*_ECC6` ke `$TMP` (RPY_PROGRAM_INSERT, include ikut diganti nama) lalu verifikasi ulang L1+L2 pada salinan. Program asli dan ECC tidak pernah ditulis. Kode lama dikomentari dengan format SOP (`*{ S4MIG <aturan> <tanggal> <user>` ... `*} S4MIG`).

**Batas F3a:** hanya program dan include (function pool dilewati), 2 aturan, tanpa katalog tabel Z, DDIC Z belum disalin (F0b) sehingga verifikasi akan menampilkan `L1_MISSING_Z`/`L2_MISSING_Z`.

### 6.8b Arah diperjelas (25 Nov): tool = **auto conversion Z program ECC6 ke S/4HANA**

Roadmap: (1) konversi massal otomatis, (2) bawa dependensi Z ke ADB, (3) perluas katalog aturan, (4) kompilasi ulang + laporan per program (4 kategori manager).

**Langkah 1 (dikirim ke ADB 25 Nov, belum diuji jalan):**
- Pengganti diganti ke **view baca resmi SAP** di ADB (lebih cocok daripada `PRCD_ELEMENTS`): `KONV`→`V_KONV_CDS` (0 field hilang, 3 beda panjang), `VBUK`→`V_VBUK_CDS` (1 hilang: PODVWK; VBTYP 1→4), `VBUP`→`V_VBUP_CDS` (3 hilang: BUMP, LTSPS, MILL_VS_VSSTA). Tulis ke tabel-tabel itu = risiko E.
- Mode massal: banyak program sekaligus (file Alfa, daftar, atau pola nama seperti `ZPP*` lewat RFC). Semua perubahan risiko ' '/W diterapkan otomatis, E dilaporkan manual. Tidak ada popup per baris.
- Opsi **Simulasi** (default aktif): tidak menulis apa pun, hanya laporan.
- Kompilasi S/4 **sebelum vs sesudah** konversi dilakukan in-memory per program.
- Output: ALV ringkasan per program (Status: TIDAK PERLU UBAH / SIAP / PERLU MANUAL / GAGAL TULIS; jumlah otomatis, W, E, error S/4 sebelum/sesudah, objek Z belum ada), lalu ALV rincian per baris (Sebelum/Sesudah). Keduanya bisa diekspor ke Excel.

**Pengganti tabel dinamis (25 Nov):** daftar tetap KONV/VBUK/VBUP dihapus. Aturan `R02_<tabel>` ditemukan otomatis dari ADB saat berjalan: view `V_<T>_CDS` yang tabel dasarnya (DD26S) **tidak** memuat T, T masih TRANSP tanpa `VIEWREF`, dan T dipakai di source. Diuji ke 49 view `V_*_CDS` di ADB: hanya KONV (`PRCD_ELEMENTS`), VBUK (`VBAK`/`LIKP`/`VBRK`), VBUP (`VBAP`/`LIPS`) yang lolos; 5 view IS-U (TE069, TE115, TE221, TECDE, EPRESCL) membaca tabelnya sendiri sehingga tidak dianggap pengganti. 179 tabel ber-`VIEWREF` (MARC, MARD, MCHB, MSEG, dll.) tidak perlu diubah untuk baca (SAP mengalihkan otomatis); tulis ditandai L1.

Katalog aturan Z (`ZS4CCA_RULE`, untuk FM/T-code/pemetaan khusus) **dibuat sendiri oleh Baginda** nanti; tool akan membacanya bila tabel sudah ada.

### 6.9 Di luar scope
Menulis ke ECC, panggilan dinamis (`CALL FUNCTION lv_fm`, `SELECT FROM (lv_tab)`) yang hanya dilaporkan, perubahan proses bisnis, Smart Form/SAPscript (fase berikutnya), dan performa.

## 7. Daftar Objek (rencana, semua baru di ADB)
| Jenis | Nama | Fungsi |
|---|---|---|
| Package | `$TMP` (lokal) untuk tool dan salinan | Temporary, tidak di-transport. Konsekuensinya, objek hilang kalau ADB di-refresh; fix pack tetap aman di git |
| Tabel | `ZS4CCA_RULE` | Katalog aturan: id, lapis, pola (TABLE/FIELD/FM/TCODE/STATEMENT), kelas A/B/C, template, referensi note, aktif |
| Tabel | `ZS4CCA_RUN`, `ZS4CCA_FIND`, `ZS4CCA_FIX` | Header run, temuan per objek/baris/aturan, usulan fix + status (proposed/approved/applied/verified) + approver + CR |
| Class | `ZCL_S4CCA_SOURCE` | Ambil source + include dari ECC (RFC) atau upload file Alfa |
| Class | `ZCL_S4CCA_DDIC_DIFF` | L1 |
| Class | `ZCL_S4CCA_SYNTAX` | L2 + pemisahan error objek Z |
| Class | `ZCL_S4CCA_RULES` | L3 (berbasis token `SCAN ABAP-SOURCE`) |
| Class | `ZCL_S4CCA_FIXER` | Bangun source baru + remark SOP |
| Class | `ZCL_S4CCA_WRITER` | Tulis salinan program/include `*_ECC6` ke `$TMP` |
| Class | `ZCL_S4CCA_DDIC_COPY` | Salin DDIC Z (domain, data element, struktur, tabel, table type) dari ECC ke ADB dengan nama `*_ECC6` |
| Class | `ZCL_S4CCA_RENAME` | Peta nama asli ke `*_ECC6` + ganti referensi di source salinan (INCLUDE, TABLES, TYPE, SELECT FROM, CALL FUNCTION Z) |
| Tabel | `ZS4CCA_NAMEMAP` | Nama asli, jenis objek, nama salinan |
| Report | `ZS4CCA_MAIN` (T-code `ZS4CCA`) | Layar seleksi (RFC, program/package/file), ALV temuan + approve, export Excel |
| RFC dest | `ECC_TRD_130` | SM59 di ADB (dicoba dibuat sendiri; Basis hanya kalau otorisasi kurang) |

## 8. Urutan Build & Strategi Test
| Fase | Isi | Effort kasar |
|---|---|---|
| F0 | RFC `ECC_TRD_130`, aktivasi ADT, editor (Eclipse/VS Code). Dicoba tanpa Basis | 1 hari |
| F0b | Salin DDIC Z + rename `_ECC6` + rewrite referensi (bisa dipakai juga untuk deteksi) | 3–4 hari |
| F1 | Ambil source + L1 + L2 + ALV/Excel (deteksi saja) | 4–6 hari |
| F2 | Katalog awal 20–30 aturan (dari Simplification List 1909 publik + temuan pilot) + L3 | 3–5 hari |
| F3 | Fixer kelas A + writer + verifikasi ulang + uji Quick Fix SAP di ADT | 5–7 hari |
| F4 | Template kelas B | 3–5 hari |

Test: 5–10 program pilot dari file Alfa.
- Ukur jumlah temuan per lapis, persentase fix A/B/C, dan **0 error baru** setelah fix.
- Bandingkan dengan pengecekan manual developer pada 2 program, untuk menghitung false positive dan false negative.

## 9. Log Keputusan
| Putaran | Keputusan | Oleh | Tanggal |
|---|---|---|---|
| 1 | Tanpa S-user, jadi remote ATC tidak bisa; pakai ATC lokal di ADB | Baginda | 2026-11-24 |
| 2 | Opsi A (Z-report di ADB); source baseline kemudian diganti ke file Alfa (putaran 5), ECC DEV untuk DDIC | Baginda | 2026-11-24 |
| 3 | Tool harus bisa perbaikan, bukan hanya deteksi | Baginda | 2026-11-24 |
| 4 | Editor quick fix SAP: Eclipse ADT dan VS Code (ABAP FS) dua-duanya jadi opsi, dipilih setelah uji di ADB | Baginda | 2026-11-24 |
| 6 | F1 disederhanakan: 1 report + include berisi local class, tanpa tabel Z (hasil ke ALV + export bawaan). Class global + tabel Z di F2/F3 | Baginda | 2026-11-24 |
| 7 | Push: Baginda memilih `install_and_run_abap`; diuji dan **ditolak SAP (FL 046)**. `write_program` juga tidak bisa (FM `Z_RFC_PROGRAM_UPDATE` tidak ada di ADB). Mekanisme push perlu diputuskan ulang | Claude (hasil uji) | 2026-11-24 |
| 8 | 25 Nov: `Z_RFC_PROGRAM_UPDATE` sudah ada di ADB (function group `SAPLZTOOLS`, remote), tapi dipanggil menghasilkan *Syntax error in program SAPLZTOOLS* (tidak ada yang tertulis). Function group perlu diperbaiki dulu (SE80, Check). FM memakai `INSERT REPORT` saja (tidak membuat entri TADIR), jadi program baru mungkin perlu dibuat dulu lewat SE38. `Z_RFC_ACTIVATE_OBJECT` juga ada di group yang sama | Claude (hasil uji) | 2026-11-25 |
| 5 | DDIC Z dibawa temporary ($TMP, tanpa transport); akhiran `_ECC6` (potong nama asli kalau terlalu panjang); ADB = sandbox; baseline = file Alfa; manager belum setuju, cari jalur tanpa Basis | Baginda | 2026-11-24 |

## 10. Persetujuan
> Kutipan persetujuan Baginda: "sudah bisa, lanjut implementasi" (2026-11-24, setelah VS Code tersambung ke ADB). Target release dan persetujuan manager masih terbuka; implementasi berjalan di sandbox ADB.

## 11. Target (diisi setelah AGREED)
| Server write | Package | Objek yang boleh diubah | Catatan |
|---|---|---|---|
| ADB (S4-HANA) client 130, sandbox | `$TMP` | Objek di bagian 7 + salinan `*_ECC6` | ECC tidak pernah ditulis |
