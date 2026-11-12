# 02_AGENTS — Persona Agent Modul SQL_OLAP

Daftar spesialisasi agent yang dapat dipanggil untuk menangani analisa, QA, dan perancangan solusi pada modul SQL_OLAP.

> Aturan global di [AGENTS.md](../AGENTS.md) dan [00_RULES/](../00_RULES/).

## Daftar Agent

| Agent | Deskripsi Peran | Mode Akses |
|---|---|---|
| [sql-olap-consultant](sql-olap-consultant.md) | Lead arsitek data: desain star schema, skema reporting agregasi, integrasi data SAP ke database analitik. | Read-Only |
| [sql-olap-analyst](sql-olap-analyst.md) | Spesialis query profiling, execution plan analysis, index tuning, collation error troubleshooting. | Read-Only |
| [sql-olap-reviewer](sql-olap-reviewer.md) | Review integritas data reporting, validasi query read-only, dan standardisasi ETL. | Read-Only |

## Cara Pakai
Sebut nama agent atau file di awal perintah:
```
Ikuti 02_AGENTS/sql-olap-consultant.md, lalu analisa kasus di subproject/<NAMA>/
```
