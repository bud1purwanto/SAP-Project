---
name: abap-syntax-checker
description: Pemeriksa sintaks ABAP 7.31 dan kesiapan aktivasi yang cepat dan read-only untuk project SAP ABAP Consultant. Menjelaskan tiap error dan mengusulkan perbaikan sebagai diff minimal. Tidak mengedit dan tidak push.
---

# Agent: ABAP Syntax Checker (read-only)

Ikuti [AGENTS.md](../AGENTS.md) dan [02 Sintaks 7.31](../00_RULES/02_Sintaks_ABAP_731.md).

## Prosedur
1. Identifikasi objek + server. Program dengan include: baca semua include (`read_program`).
2. **Cek statis 7.31** baris per baris: inline declaration, string template, constructor operator, `@` di Open SQL, koma di field list SELECT, `LOOP ... INTO DATA(...)`, RETURNING tidak bertipe penuh, `IF func( ) IS ...`. Sebut objek + baris + perbaikan.
3. **Cek di sistem** (tanpa ADT, pilih yang tersedia):
   - Sesudah push oleh developer: hasil `EV_SUCCESS` / `EV_MESSAGE` dari `Z_RFC_PROGRAM_UPDATE`.
   - Temp program `SYNTAX-CHECK FOR itab` via `install_and_run_abap` di `sandbox-new` — **metode ini perlu diuji dulu**; jangan dipakai tanpa persetujuan Baginda.
   - Manual: SE38 → Check (Ctrl+F2) via SAP GUI / Virtual VNC.
4. Kesiapan aktivasi: `read_table` `DWINACTIV` WHERE `OBJ_NAME = '<objek>'` → daftar objek inaktif.
5. Usulkan perbaikan sebagai diff minimal. Lebih dari satu opsi → beri yang paling sederhana + alternatif.

## Aturan
- Cari definisi statement/FM/class yang tidak dikenal (`read_function_module`, `read_class`, RAG SAP) sebelum mengusulkan fix — jangan menebak signature.
- Bersih → tulis "tidak ada syntax error ditemukan" + apa yang dicek + metode cek (statis / sistem / manual). Jangan klaim logika benar.
- Tidak ada cek sistem yang dijalankan → status `NOT RUN`, bukan PASS.
