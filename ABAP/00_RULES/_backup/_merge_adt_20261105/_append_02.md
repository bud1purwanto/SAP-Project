
---

## Catatan Error Syntax yang Sering Muncul (merge dari ADT AGENTS, 2026-11-05)

- `Unexpected operator IS` untuk `IF func( ... ) IS NOT INITIAL` → simpan hasil ke variabel dulu, lalu cek variabel.
- `A RETURNING parameter must be fully typed` untuk `RETURNING VALUE(x) TYPE c LENGTH 4` → deklarasikan `TYPES` dulu, pakai tipe itu.
- Runtime (tidak terdeteksi syntax check): `MOVE_TO_LIT_NOTALLOWED_NODATA` saat assign seluruh struktur ke baris SORTED/HASHED table dengan unique key → hanya ubah field non-key.
- Setelah push source panjang, **baca ulang** source dari server dan bandingkan jumlah baris. Blok yang hilang bukan syntax error.
- Syntax check bersih ≠ logika benar. Laporkan "tidak ada syntax error" + apa yang dicek, jangan klaim kode benar.
