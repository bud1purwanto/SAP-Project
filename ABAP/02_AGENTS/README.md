# 02_AGENTS — Agent ABAP per Peran (versi ECC 6.0 / ABAP 7.31)

Peta agent dari **ADT AGENTS** (`C:\Users\User\Downloads\ADT AGENTS\Agents\`) yang diadaptasi ke project ini.
Format file = Claude Code subagent (`---` frontmatter `name` + `description`), tetap bisa dibaca AI lain sebagai SOP biasa.

> Versi: 2026-11-05 · Aturan global tetap di [AGENTS.md](../AGENTS.md) dan [00_RULES/](../00_RULES/). Alur: [07_Workflow_Development.md](../00_RULES/07_Workflow_Development.md).

## 1. Jawaban singkat: harus pakai ADT?

**Tidak harus.** Agent bisa jalan dengan MCP SAP kita (RFC). Agent ADT asli memanggil tool `abap-adt-*` (ADT REST) yang **tidak terpasang** di project ini, jadi file aslinya tidak bisa dipakai apa adanya — di sini sudah ditulis ulang memakai tool MCP SAP.

Yang **tidak** ada padanannya tanpa ADT: ATC, ABAP Unit runner, debugger, syntax check resmi. Untuk itu dipakai alternatif (tabel di bawah) atau langkah manual Baginda via SAP GUI / Virtual VNC.

Catatan server (dicek 2026-11-05): node ICF `ADT` ada di TRD (`sandbox-new` / `dev`), SAP_BASIS 731 SP4. ADT MCP mungkin bisa tersambung, tapi fitur ADT di 7.31 terbatas dan **belum diuji**.

## 2. Daftar Agent

| Agent | Dari ADT AGENTS | Peran | Write ke SAP? |
|---|---|---|---|
| [abap-brainstormer](abap-brainstormer.md) | abap-brainstormer | Analisa FS, peta objek, opsi, rekomendasi, Design Brief | Tidak |
| [abap-developer](abap-developer.md) | abap-onprem-developer | Ubah/buat program, FM, Smart Form di `sandbox-new` | Ya, hanya `sandbox-new` |
| [abap-syntax-checker](abap-syntax-checker.md) | abap-syntax-checker | Cek sintaks 7.31 + kesiapan aktivasi, usulan fix (diff) | Tidak |
| [abap-test-engineer](abap-test-engineer.md) | abap-test-engineer | Skenario test, program/harness test di `sandbox-new` | Ya, hanya objek test |
| [abap-qa-engineer](abap-qa-engineer.md) | abap-qa-engineer | QA gate PASS/WARN/FAIL/NOT RUN → READY / NOT READY | Tidak |
| [abap-reviewer](abap-reviewer.md) | abap-reviewer | Code review Critical/Major/Minor | Tidak |

**Tidak diambil:** `abap-cloud-developer` (RAP / ABAP Cloud), `fiori-developer` (UI5) — sistem kita ECC 7.31, tidak ada RAP/Fiori. Bisa dibuat nanti khusus server `S4-HANA` (ADB, SAP_BASIS 754) bila dibutuhkan.

Batasan "read-only" pada agent di atas adalah **aturan prompt**, bukan penghalang teknis — MCP SAP kita tidak punya write guard per package seperti `abap-adt-mcp`.

## 3. Peta Tool ADT → MCP SAP Kita

| Tool ADT (`abap-adt-*`) | Padanan MCP SAP | Status |
|---|---|---|
| `abap_get_source` | `read_program`, `read_function_module`, `read_class` | Tersedia |
| `abap_search` | `search_programs` | Tersedia |
| `abap_where_used` | `get_where_used` | Tersedia |
| `abap_object_structure` (DDIC) | `read_table_structure` | Tersedia |
| `abap_table_contents` / `abap_run_sql` (SELECT) | `read_table` (RFC_READ_TABLE, filter + rowcount) | Tersedia |
| `abap_set_source` + `abap_activate` + lock | **Prioritas** `call_function` `Z_RFC_PROGRAM_UPDATE`; `write_program` hanya fallback bila FM error | Tersedia (lihat [03](../00_RULES/03_Push_Program_dan_SmartForm.md)) — wajib pull terbaru sebelum push |
| Smart Form | `write_smartform_xml`, `write_smartstyle_xml`, `import_smartform_artifact` | Tersedia |
| `abap_inactive_objects` | `read_table` `DWINACTIV` | **Terverifikasi** di sandbox-new |
| `abap_dumps` | `read_table` `SNAP` (header: DATUM, UZEIT, UNAME, AHOST) + ST22 via GUI untuk detail | Header **terverifikasi**; detail dump via GUI |
| `abap_transport_info` / `abap_user_transports` | `read_table` `E070` / `E071` | Tersedia (belum diuji) |
| Lock (SM12) | `check_system_locks` | Tersedia |
| `abap_syntax_check` | Temp program via `install_and_run_abap` dengan `SYNTAX-CHECK FOR itab` | **Perlu diuji** — sementara: push lalu cek hasil/pesan, atau SE38 Check via GUI |
| `abap_atc_run` | — | Tidak ada. Manual: SCI / ATC di SAP GUI |
| `abap_run_unit_tests` | — | Tidak ada. Manual: SE80 / SE38 Unit Test via GUI, atau program test biasa (`ZTEST_*`) |
| `abap_debug_*` | — | Tidak ada. Manual debugger |
| `abap_trace_*` | — | Manual ST05 / SAT |
| `abap_abap_docs` | RAG SAP (`rag_search`, `sap_support_research`) | Tersedia |
| `abap_create_transport` / release | `create_transport_request` / `release_transport_request` | Ada, **dilarang** dipakai agent tanpa perintah Baginda |

## 4. Cara Pakai

**A. Tanpa install** — sebut file di prompt:
```
Baca dan ikuti 02_AGENTS/abap-reviewer.md, lalu review subproject/GI_JR_CLOSING/src/ZPPR_GI_JR_CLOSING.abap.
```

**B. Install sebagai subagent Claude Code** (dipanggil otomatis per peran), dari folder project:
```powershell
New-Item -ItemType Directory -Force .claude\agents | Out-Null
Copy-Item 02_AGENTS\abap-*.md .claude\agents\ -Force
```
Frontmatter sengaja tanpa `tools:` → agent mewarisi semua tool sesi (nama MCP SAP berbeda per mesin: `mcp__sap-leader__*`, `SAP_MCP`, dll).

## 5. Urutan Pakai (sesuai workflow)

```
abap-brainstormer -> (Baginda AGREED) -> abap-developer -> abap-syntax-checker -> abap-test-engineer -> abap-qa-engineer -> abap-reviewer -> report
```
