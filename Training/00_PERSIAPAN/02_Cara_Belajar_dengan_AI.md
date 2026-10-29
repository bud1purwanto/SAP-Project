# 02 — Cara Belajar SAP dengan AI

## 1. Alat yang Dipakai

| Alat | Fungsi | Contoh |
|---|---|---|
| **Claude Code** (VS Code / terminal) | Asisten utama: bertanya, membaca file project, menulis kode | "Jelaskan program ini baris per baris" |
| **MCP SAP** (`sap-leader`) | AI membaca langsung data/program dari sistem SAP | `read_table`, `read_program`, `read_table_structure` |
| **MCP RAG SAP** (`rag-sap`) | AI mencari dokumen blueprint, SOP, knowledge SAP | `rag_search`, `rag_find_similar_issues` |
| **SAP GUI** | Verifikasi visual: SE11, SE16N, SE38, SE93, ST22 | Mencocokkan jawaban AI dengan layar asli |
| **Skill** (folder `01_SKILLS/`) | "SOP" yang membuat AI bekerja dengan aturan yang benar | `/abap-dev-sandbox-new` |

---

## 2. Pola Belajar Harian (5 Langkah)

```
 1. BACA case     -> pahami cerita bisnis & tujuan hari ini
 2. TANYA AI      -> pakai contoh prompt di file case
 3. VERIFIKASI    -> cocokkan jawaban AI dengan sistem (SE11/SE16N/SE38 atau MCP)
 4. KERJAKAN      -> tugas hari itu (analisa / coding)
 5. REFLEKSI      -> jawab kuis, isi Progress Tracker
```

---

## 3. Pola Prompt yang Efektif

Format umum:

```
[Konteks]   Saya sedang belajar Day 06. Server: prod (read-only).
[Tugas]     Jelaskan arti status order I0045 dan cara membacanya dari JEST.
[Batasan]   Hanya baca. Maksimal 50 baris data. Pakai ABAP 7.31.
[Format]    Jelaskan dengan bahasa awam dulu, lalu detail teknis + TCODE.
```

Contoh prompt yang baik:

- *"Pakai skill pp-analisa-production. Baca tabel AUFK di server prod untuk order 100007232823, lalu jelaskan arti setiap field penting dalam bahasa awam."*
- *"Saya tidak paham FOR ALL ENTRIES. Jelaskan dengan analogi sehari-hari, lalu beri contoh ABAP 7.31 yang benar dan satu contoh yang salah."*
- *"Cek jawabanmu tadi: apakah ada sintaks 7.40 di kodenya? Kalau ada, tulis ulang."*

Contoh prompt yang kurang baik:

- *"Buatkan program PP."* → terlalu umum, tidak ada konteks/server/batasan.
- *"Perbaiki data di production."* → melanggar aturan read-only.

---

## 4. Teknik Belajar dengan AI

| Teknik | Prompt |
|---|---|
| **Jelaskan seperti ke orang awam** | "Jelaskan ini seperti ke manager non-IT, maksimal 5 kalimat." |
| **Minta analogi** | "Beri analogi untuk konsep LUW / COMMIT." |
| **Kuis balik** | "Beri saya 5 soal pilihan ganda tentang materi hari ini, jangan beri jawaban dulu." |
| **Socratic** | "Jangan beri jawabannya. Beri petunjuk bertahap sampai saya menemukan root cause sendiri." |
| **Bandingkan** | "Bandingkan REUSE_ALV_GRID_DISPLAY vs CL_SALV_TABLE dalam tabel." |
| **Review kode saya** | "Review kode saya: cek sintaks 7.31, performa, dan error handling." |

---

## 5. Cara Memverifikasi Jawaban AI

AI bisa salah (halusinasi nama tabel/field). Biasakan:

1. Nama tabel/field → cek dengan `read_table_structure` atau SE11.
2. Nama FM/BAPI → cek dengan SE37 atau `read_function_module`.
3. Angka/data → cek dengan `read_table` atau SE16N.
4. Logika program → baca source asli (`read_program` / SE38), jangan hanya ringkasan AI.
5. Jika ragu, minta AI: *"Tunjukkan bukti dari sistem untuk klaim ini."*

---

## 6. Etika

- Jangan menempelkan password, data pribadi, atau data rahasia perusahaan ke AI di luar lingkungan resmi.
- AI tidak boleh diminta mem-bypass authorization atau mengubah data Production.
