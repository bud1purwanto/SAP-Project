# 02 — Master Data, Tabel Kunci & TCODE BASIS

> Peta master data, tabel utama, dan transaksi standar untuk modul BASIS.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Ruang Lingkup Modul BASIS
System Administration & Health Monitoring, Work Process Overview (SM50/SM66), Background Job Scheduling (SM37), System Dumps & Logs (ST22/SM21), Transport Management (STMS/SE09/SE10), User & Authorization (SU01/PFCG/SU53).

---

## Tabel Kunci

| Tabel | Deskripsi | Field Kunci |
|---|---|---|
| `USR02` | Logon Data (User Master, Lock Status, Expiry) | BNAME, GLTGV, GLTGB, UFLAG, BCODE, PASSCODE |
| `USR21` / `ADR6` | User Address Assignment / Email Address | BNAME, PERSNUMBER, ADDRNUMBER, SMTP_ADDR |
| `AGR_USERS` | Assignment of Roles to Users | AGR_NAME, UNAME, FROM_DAT, TO_DAT |
| `AGR_1251` | Authorization Data for Activity Groups | AGR_NAME, OBJECT, AUTH, FIELD, LOW, HIGH |
| `TBTCO` / `TBTCP` | Background Job Header / Step Details | JOBNAME, JOBCOUNT, STATUS, SDLSTRTDT, SDLSTRTTM, PROGNAME |
| `TSP01` | Spool Requests | RQIDENT, RQCLIENT, RQ0NAME, RQ1NAME, RQOWNER, RQCREATTIME |
| `SNAP` | ABAP Short Dumps (System Error Logs) | DATUM, UZEIT, AHOST, UNAME, MANDT, MODNO, SEQNO |
| `E070` / `E071` | Change & Transport System: Header / Objects | TRKORR, TRFUNCTION, TRSTATUS, AS4USER, PGMID, OBJECT, OBJ_NAME |
| `RFCDES` | RFC Destination Descriptions | RFCDEST, RFCTYPE, RFCDOC1 |

---

## TCODE Standar BASIS

| Kategori | TCODE | Keterangan |
|---|---|---|
| Monitoring | `SM50` / `SM51` / `SM66` | Work Process Overview / Server Overview / Global Work Process |
| Monitoring | `SM04` / `AL08` | User List (Instance / Global) |
| Troubleshooting | `ST22` | ABAP Dump Analysis |
| Troubleshooting | `SM21` | System Log |
| Performance | `ST03N` / `ST04` / `ST06` | Workload Monitor / DB Performance / OS Monitor |
| Traces | `ST05` / `ST12` | SQL / RFC / Enqueue Performance Trace |
| Background | `SM37` / `SM36` | Background Job Overview / Define Job |
| Security | `SU01` / `PFCG` | User Maintenance / Role Maintenance |
| Security | `SU53` | Evaluate Authorization Check (Cek Gagal Otorisasi) |
| Transport | `STMS` / `SE09` / `SE10` | Transport Management System / Transport Organizer |
