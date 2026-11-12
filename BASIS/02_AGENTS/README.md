# 02_AGENTS — Persona Agent Modul BASIS

Daftar spesialisasi agent yang dapat dipanggil untuk menangani analisa, QA, dan perancangan solusi pada modul BASIS.

> Aturan global di [AGENTS.md](../AGENTS.md) dan [00_RULES/](../00_RULES/).

## Daftar Agent

| Agent | Deskripsi Peran | Mode Akses |
|---|---|---|
| [basis-consultant](basis-consultant.md) | Lead konsultan Basis: manajemen landscape SAP, TMS transport management, kernel patch, backup & recovery. | Read-Only |
| [basis-analyst](basis-analyst.md) | Spesialis monitoring work process (SM50/SM66), short dumps (ST22), system log (SM21), background job (SM37). | Read-Only |
| [basis-reviewer](basis-reviewer.md) | Review user licensing, role PFCG, authorization object (SU53/SU24), dan security compliance. | Read-Only |

## Cara Pakai
Sebut nama agent atau file di awal perintah:
```
Ikuti 02_AGENTS/basis-consultant.md, lalu analisa kasus di subproject/<NAMA>/
```
