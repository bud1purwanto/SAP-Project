# 07 — Workflow Development (Brief → Agreement → Development → Verifikasi → Report)

> Alur kerja untuk development/enhancement program. Diadaptasi dari ADT AGENTS (`Rules/WORKFLOW.md`) untuk ECC 6.0 / ABAP 7.31 / `sandbox-new`, tanpa tier dan tanpa transport.
> Kembali ke [AGENTS.md](../AGENTS.md).

```
0 Intake -> 1 Brainstorm (putaran) -> 2 Agreement -> 3 Target -> 4 Development -> 5 Verifikasi -> 6 Report
```

| Fase | Yang terjadi | Siapa | Output |
|---|---|---|---|
| 0 Intake | Baginda memberi FS/permintaan + sub-project. Agent routing via `SUBPROJECTS.md`. | Baginda | Input |
| 1 Brainstorm | Baca FS, source existing (`read_program`), tabel (`read_table_structure`), where-used. Susun peta objek, opsi, rekomendasi. Tiap putaran diakhiri "Keputusan yang dibutuhkan dari Baginda" + `Status: DRAFT - putaran n`. **Tanpa kode, tanpa push.** | agent brainstormer + Baginda | Design Brief DRAFT |
| 2 Agreement | Baginda bilang setuju. Brief disimpan di `subproject/<NAMA>/docs/BRIEF_<topik>.md` status `AGREED` + kutipan persetujuan. | Baginda + sesi utama | Brief AGREED |
| 3 Target | Konfirmasi server write (`sandbox-new`), daftar objek yang boleh diubah, lokasi backup. | sesi utama | Bagian "Target" di brief |
| 4 Development | Agent developer menjalankan **Start gate** ([03](03_Push_Program_dan_SmartForm.md#start-gate-wajib-sebelum-write-apa-pun)). Bangun hanya objek di brief. Menyimpang dari brief = berhenti, kembali ke fase 1. | agent developer | Objek aktif di `sandbox-new` |
| 5 Verifikasi | Syntax check, test, QA gate, review. Format hasil: PASS / WARN / FAIL / NOT RUN. | agent syntax-checker, test, qa, reviewer | Vonis READY / NOT READY |
| 6 Report | Objek yang diubah, backup, hasil QA, yang masih manual. Update `CHECKPOINT.md` / `README.md` sub-project. | sesi utama | Report + checkpoint |

## Kapan workflow ini wajib

| Jenis permintaan | Fase yang dipakai |
|---|---|
| Program/enhancement baru, perubahan logika > 1 FORM, atau menyentuh posting (BAPI/BDC/COMMIT) | Semua fase (0–6) |
| Bug fix kecil yang jelas (1 lokasi, tanpa posting) | 0 → 4 → 5 → 6 (brief boleh 3–5 baris di chat) |
| Analisa/RCA saja (read-only) | Pakai `Template_Laporan_Analisa` / `Template_Laporan_RCA`, tanpa workflow ini |

## Aturan tetap

- Brainstormer tidak pernah menyatakan setuju sendiri. `AGREED` hanya dari kalimat Baginda.
- Perubahan scope setelah AGREED → status `REOPENED`, putaran baru.
- Semua write hanya ke `sandbox-new`, package `$TMP` kecuali Baginda menyebut lain. Transport ke DEV/QAS/PRD dikerjakan Baginda / tim Basis.
- Objek SAP standar tidak diubah kecuali Baginda menyetujui objek itu secara eksplisit.
- Penghapusan objek / data: lihat [Delete rule](03_Push_Program_dan_SmartForm.md#delete-rule-hapus-hanya-dengan-perintah-eksplisit).

Template brief: [Template_Design_Brief.md](../01_TEMPLATE/Template_Design_Brief.md). Agent per peran: [02_AGENTS/](../02_AGENTS/README.md).
