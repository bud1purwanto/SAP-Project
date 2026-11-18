# Blueprint Konfigurasi Enterprise Structure SAP S/4HANA
**Referensi: Sistem DEV AIX (TRD Client 130) -> Target: S/4HANA (ADB Client 130)**

---

## 1. Ringkasan Eksekutif
Sebelum master data manufaktur (Material, Work Center, BOM, Routing, Production Version) dapat dibuat di SAP S/4HANA, struktur organisasi (*Enterprise Structure*) dan konfigurasi dasar modul MM/PP/CO/FI harus didefinisikan dan dihubungkan terlebih dahulu.

Dokumen ini menyajikan parameter konfigurasi riil yang diekstrak langsung dari SAP DEV AIX (TRD) sebagai blueprint resmi untuk implementasi di SAP S/4HANA (ADB).

---

## 2. Struktur Finansial & Pengendalian (FI & CO)

### 2.1 Company Code (FI)
- **Tabel:** \T001\
- **T-Code Definisi:** \OX02\ (atau \EC01\ copy template)

| Parameter | Nilai DEV AIX | Rekomendasi S/4HANA | Keterangan |
|---|---|---|---|
| Company Code (\BUKRS\) | \9999\ | \9999\ | Kode Perusahaan |
| Company Name (\BUTXT\) | \PT Trias Sentosa, Tbk.\ | \PT Trias Sentosa, Tbk.\ | Nama Resmi Perusahaan |
| City (\ORT01\) | \Sidoarjo\ | \Sidoarjo\ | Lokasi Kantor Pusat |
| Country (\LAND1\) | \ID\ | \ID\ | Indonesia |
| Currency (\WAERS\) | \IDR\ | \IDR\ | Rupiah |
| Language (\SPRAS\) | \E\ | \E\ | English |
| Chart of Accounts (\KTOPL\) | \TSCA\ | \TSCA\ | Bagan Akun Standar Trias |
| Fiscal Year Variant (\PERIV\) | \K4\ | \K4\ | Calendar Year, 4 Special Periods |
| Credit Control Area (\KKBER\) | \TSCC\ | \TSCC\ | Credit Control Area Trias |

### 2.2 Controlling Area (CO)
- **Tabel:** \TKA01\ (Definisi) & \TKA02\ (Assignment)
- **T-Code Definisi:** \OX06\ | **T-Code Assignment:** \OX19\

| Parameter | Nilai DEV AIX | Rekomendasi S/4HANA | Keterangan |
|---|---|---|---|
| Controlling Area (\KOKRS\) | \TSCO\ | \TSCO\ | Controlling Area Trias |
| CoAr Name | Trias Controlling Area | Trias Controlling Area | Deskripsi |
| Currency Type | \20\ | \20\ | Controlling Area Currency |
| Currency (\WAERS\) | \USD\ | \USD\ | Mata Uang Operasional CO |
| Chart of Accounts (\KTOPL\) | \TSCA\ | \TSCA\ | Harus sinkron dengan FI |
| Assignment (\BUKRS\ -> \KOKRS\) | \9999\ -> \TSCO\ | \9999\ -> \TSCO\ | Relasi 1:N / Cross-Company |

---

## 3. Struktur Logistik & Pabrik (MM & PP)

### 3.1 Plants (Pabrik / Werk)
- **Tabel:** \T001W\ (Definisi) & \T001K\ (Assignment ke Company Code)
- **T-Code Definisi:** \OX10\ (atau \EC02\ copy) | **T-Code Assignment:** \OX18\

| Plant (\WERKS\) | Nama Pabrik (\NAME1\) | Valuation Area (\BWKEY\) | Assigned Company Code (\BUKRS\) | Factory Calendar (\FABKL\) | Valuation Grouping Code (\BWMOD\) |
|---|---|---|---|---|---|
| \1000\ | Waru | \1000\ | \9999\ | \ZT\ (Trias Calendar) | "
