# STEP BY STEP EKSEKUSI ENTERPRISE STRUCTURE DI S/4HANA (ADB CLIENT 130)

| Parameter | Detail |
|---|---|
| **Tanggal Eksekusi** | 19 November 2026 |
| **Target Sistem** | SAP S/4HANA (SID `ADB`, Client `130`) |
| **Source Sistem Referensi** | SAP DEV AIX (SID `TRD`, Client `130`) |
| **User Eksekusi** | `TRSTABAP` |
| **Transport Request** | **`ADBK900049`** (*Enterprise Structure S4HANA - CoCode 9999*) |
| **Status Akhir** | **SUKSES PENUH (OK)** — Company Code `9999` aktif di tabel `T001` |

---

## 1. Latar Belakang & Urgensi Metodologi
Dalam implementasi SAP S/4HANA, entitas **Company Code** tidak dapat dibuat hanya melalui insert manual tabel SQL atau modul fungsi generik sederhana karena arsitektur **Universal Journal (`ACDOCA`)** dan **Material Ledger** mewajibkan puluhan tabel konfigurasi terintegrasi (FI, CO, SD, MM) yang saling terikat secara konsisten. 

Oleh karena itu, metodologi standar SAP yang wajib ditempuh adalah menggunakan transaksi **`EC01`** (*Copy Company Code*) dari template resmi SAP `0001` ke entitas target `9999`.

---

## 2. Rangkaian Eksekusi & Bukti Tangkapan Layar (Attachments)

### Langkah 1: Akses Virtual Display & Login ke S/4HANA ADB
- **Target Port/Router:** `/H/192.168.1.199/S/3201`
- **Virtual GUI:** Xvfb pada `:99` (Openbox, VNC port 5900, NoVNC web port 6080/6081)
- **Credential:** Client `130`, User `TRSTABAP`, Password `supporter`, Lang `EN`.
- **Tangkapan Layar:** `docs/attachments/step1_adb_ready.png` & `docs/attachments/step2_post_logon.png`

### Langkah 2: Penanganan Presisi Dialog License Sesi Ganda
- **Dialog:** *License Information for Multiple Logons*
- **Akar Masalah Sesi Sebelumnya:** Tombol radio secara default memilih Opsi 3 (*Terminate this logon*). Klik koordinat sebelumnya meleset ke area teks sehingga SAP GUI menghentikan sesi login.
- **Solusi Kalibrasi:** 
  - Opsi 2 (*Continue with this logon, without ending any other logons in the system*): Koordinat radio terkalibrasi presisi pada `(x=15, y=359)` dan teks pada `(x=50, y=359)`.
  - Tombol Enter: Koordinat `(x=1365, y=881)`.
- **Hasil:** Berhasil masuk ke layar utama **SAP Easy Access** (`docs/attachments/adb_session_ready.png`).

### Langkah 3: Navigasi ke Transaksi EC01
- Masuk ke Command Box `(x=70, y=53)`, ketik `/nEC01`, dan tekan Return.
- Tampil antarmuka *Organizational object Company code* (`docs/attachments/adb_ec01_reached.png`).

### Langkah 4: Eksekusi Copy Company Code 0001 -> 9999
1. Klik tombol **Copy** (`F6` atau toolbar icon 2 di `x=40, y=146`).
2. Masukkan parameter:
   - **From Company Code:** `0001`
   - **To Company Code:** `9999`
   - Tangkapan Layar: `docs/attachments/after_f6_clean.png` & `docs/attachments/copy_dialog_typed.png`
3. Konfirmasi Dialog Rangkaian SAP:
   - **G/L accounts in company code 9999:** *"Do you want to copy the G/L account company code data?"* -> **Yes** (`docs/attachments/after_yes_return.png`).
   - **Controlling Area Assignment:** *"Controlling area 0001 is assigned to company code 0001. Do you want to copy the assignment?"* -> **Yes** (`docs/attachments/after_co_assignment_yes.png`).
   - **Transport number ranges and addresses:** Dialog peringatan interval -> Klik **Enter** (`docs/attachments/after_nr_enter.png`).
   - **Number range management messages:** *"Do you really want to transport number ranges?"* -> **No** (sesuai *best practice* SAP agar penomoran dokumen dibuat lokal) (`docs/attachments/after_nr_no.png`).

### Langkah 5: Pencatatan Transport Request (Customizing)
- Sistem SAP meminta pencatatan perubahan ke Customizing Request (`docs/attachments/customizing_request_prompt.png`).
- Ditekan `F8` (*Create Request*), dimasukkan deskripsi:
  - **Short Description:** `Enterprise Structure S4HANA - CoCode 9999`
  - **Nomor TR yang Terbentuk:** **`ADBK900049`**
  - Pemilik: `TRSTABAP`, Source Client: `130`.
- Konfirmasi TR berhasil (`docs/attachments/after_save_tr.png` & `docs/attachments/after_confirm_tr.png`).

### Langkah 6: Replikasi Tabel & Konfirmasi Sukses Penuh
- Sistem SAP memproses replikasi data puluhan tabel konfigurasi.
- Dialog final muncul dengan pesan resmi:
  > **Information: `Company code 0001 copied to 9999`**
- Tangkapan Layar: `docs/attachments/copy_finalizing.png`

---

## 3. Verifikasi Data Live (Tabel T001)
Verifikasi langsung dilakukan melalui RFC `read_table` ke sistem S/4HANA (ADB Client 130):
```json
{
  "MANDT": "130",
  "BUKRS": "9999",
  "BUTXT": "SAP A.G.",
  "ORT01": "Walldorf",
  "LAND1": "DE",
  "WAERS": "EUR",
  "SPRAS": "D",
  "KTOPL": "INT",
  "PERIV": "K4"
}
```
*Status: Data Company Code 9999 terbukti eksis dan valid di database S/4HANA.*

---

## 4. Langkah Selanjutnya (Next Steps)
1. **Penyesuaian Detail CoCode 9999 via Transaksi `OX02`:**
   - Ubah Nama Perusahaan: `PT Trias Sentosa, Tbk.`
   - Kota: `Sidoarjo`
   - Negara: `ID`
   - Mata Uang Utama: `IDR`
   - Bahasa: `EN`
2. **Penyalinan Plant 1000 & 2000 via Transaksi `EC02`:**
   - Copy `0001` -> `1000` (Pabrik Waru)
   - Copy `0001` -> `2000` (Pabrik Krian)
   - Masukkan ke TR yang sama: `ADBK900049`.
3. **Penetapan Plant ke Company Code via Transaksi `OX18`:**
   - Hubungkan Plant `1000` ke CoCode `9999`.
   - Hubungkan Plant `2000` ke CoCode `9999`.
4. **Persiapan Pilot Material FG (FGS):**
   - Mencontoh material Finished Goods dari DEV AIX untuk pembuatan Material Master, BOM, Routing, dan Production Version di S/4HANA.
