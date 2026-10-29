# 01_SKILLS — Skill AI untuk Training

Skill = file instruksi (SOP) yang membuat AI bekerja dengan aturan yang benar secara konsisten.
Format mengikuti standar Claude Code skill (`SKILL.md` dengan frontmatter `name` + `description`).

## Daftar Skill

| Skill | Dipakai untuk | Server | Mode |
|---|---|---|---|
| [abap-dev-sandbox-new](abap-dev-sandbox-new/SKILL.md) | Menulis, mengubah, push, dan test program ABAP | `sandbox-new` | WRITE |
| [pp-analisa-production](pp-analisa-production/SKILL.md) | Analisa Production/Process Order, confirmation, TECO, BOM | `prod` | READ-ONLY |
| [mm-analisa-production](mm-analisa-production/SKILL.md) | Analisa movement stok, batch, PO, reversal | `prod` | READ-ONLY |
| [qm-analisa-production](qm-analisa-production/SKILL.md) | Analisa inspection lot, hasil uji, UD, COA | `prod` | READ-ONLY |
| [sd-analisa-production](sd-analisa-production/SKILL.md) | Analisa Sales Order, delivery, billing | `prod` | READ-ONLY |
| [fico-analisa-production](fico-analisa-production/SKILL.md) | Analisa dokumen FI, faktur pajak, change document | `prod` | READ-ONLY |

## Cara Install

Skill dapat dipakai dengan dua cara:

> Semua perintah di bawah memakai **path relatif**. Folder `Training` boleh diletakkan di mana saja.
> Jalankan perintah dari **dalam folder `Training`** (folder yang berisi `README.md` utama training ini).

**A. Langsung dari folder ini (paling mudah, tanpa install)** — buka Claude Code di folder `Training`, lalu sebut path skill di prompt:

```
Baca dan ikuti 01_SKILLS/pp-analisa-production/SKILL.md, lalu analisa order 100007232823.
```

**B. Install sebagai skill Claude Code** (bisa dipanggil `/nama-skill`) — salin setiap folder skill ke `.claude/skills/`.

Pilihan B1 — hanya untuk folder `Training` (disarankan). Buka Claude Code di folder `Training` setelahnya.

Linux / macOS (bash):

```bash
mkdir -p .claude/skills
cp -r 01_SKILLS/*/ .claude/skills/
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force .claude\skills | Out-Null
Get-ChildItem 01_SKILLS -Directory | Copy-Item -Destination .claude\skills -Recurse -Force
```

Pilihan B2 — untuk semua project di komputer ini (skill personal, di folder home user):

Linux / macOS (bash):

```bash
mkdir -p ~/.claude/skills
cp -r 01_SKILLS/*/ ~/.claude/skills/
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null
Get-ChildItem 01_SKILLS -Directory | Copy-Item -Destination "$HOME\.claude\skills" -Recurse -Force
```

Cek hasil: folder `.claude/skills/` harus berisi 6 folder (`abap-dev-sandbox-new`, `pp-analisa-production`, `mm-analisa-production`, `qm-analisa-production`, `sd-analisa-production`, `fico-analisa-production`), masing-masing berisi `SKILL.md`.

Lalu di Claude Code ketik `/pp-analisa-production`, atau cukup bertanya; AI akan memilih skill yang cocok.

## Struktur Setiap Skill Modul

Semua skill analisa modul memakai urutan yang sama, sehingga mudah dipelajari:

1. **Guardrail** — aturan read-only Production.
2. **Peta proses** — alur bisnis modul di Trias.
3. **Tabel kunci** — tabel standar + tabel Z yang sering dipakai.
4. **TCODE** — transaksi standar & Z.
5. **Resep analisa** — langkah investigasi untuk kasus umum.
6. **Format laporan** — bentuk jawaban.
