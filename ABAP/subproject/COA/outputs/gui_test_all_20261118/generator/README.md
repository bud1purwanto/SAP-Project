# Generator uji GUI semua skenario (18 Nov 2026)
Urutan: run2.sh (ZQM002 21 DO) -> harness debug (F01_dbg.abap + runner_dbg.abap lewat mt_pool_build2, TAG=dev_after_543) -> derive.py (lot sumber + QAMR) -> run5c.sh (ZQM005 per lot) -> extract.py + decode.py (baca angka per piksel) -> build2.py (Excel) -> recalc LibreOffice -> drawing_inject.py (gambar + panah shape).
Path scratchpad di skrip bersifat sesi; sesuaikan. Password tidak disimpan.
