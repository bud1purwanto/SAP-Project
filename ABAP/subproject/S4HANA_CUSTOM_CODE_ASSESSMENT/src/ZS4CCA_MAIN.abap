*&---------------------------------------------------------------------*
*& Report ZS4CCA_MAIN
*& Tool deteksi kode ECC 6.0 yang tidak valid di S/4HANA (tanpa AI)
*& F1: L1 diff DDIC (ADB vs ECC opsional) + L2 syntax check S/4.
*& Hanya membaca; hasil ke ALV (export Excel lewat menu ALV).
*& Brief: subproject/S4HANA_CUSTOM_CODE_ASSESSMENT/docs/
*&        BRIEF_TOOL_DETEKSI_PERBAIKAN_S4.md
*&---------------------------------------------------------------------*
REPORT zs4cca_main.

INCLUDE zs4cca_top.
INCLUDE zs4cca_core.

INITIALIZATION.
  gv_t1 = 'Sumber source'.
  gv_r1 = 'Upload file .abap dari PC (baseline Alfa: program utama + include)'.
  gv_r2 = 'Baca dari ECC lewat RFC (isi RFC destination dan nama program)'.
  gv_r3 = 'Baca dari program yang sudah ada di ADB (boleh pola Z*)'.
  gv_l1 = 'Nama program'.
  gv_t2 = 'Perbandingan dengan ECC'.
  gv_l2 = 'RFC destination ECC'.
  gv_t3 = 'Lapis deteksi'.
  gv_l3 = 'L1  Diff DDIC (S/4; dibanding ECC bila RFC destination diisi)'.
  gv_l4 = 'L2  Syntax check dengan compiler S/4'.
  gv_l5 = 'Konversi otomatis ke S/4 (hint Oracle, tabel lama ke view pengganti SAP)'.
  gv_l6 = '    Simulasi saja (salinan _ECC6 tidak ditulis ke ADB)'.

AT SELECTION-SCREEN OUTPUT.
  " nama program hanya relevan untuk mode RFC dan ADB
  LOOP AT SCREEN.
    IF screen-group1 = 'PRG' AND rb_file = abap_true.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN.
  IF sy-ucomm = 'ONLI' OR sy-ucomm = 'PRIN' OR sy-ucomm = 'SJOB'.
    IF rb_rfc = abap_true AND p_dest IS INITIAL.
      MESSAGE 'Mode RFC: isi RFC destination ECC' TYPE 'E'.
    ENDIF.
    IF ( rb_rfc = abap_true OR rb_adb = abap_true ) AND s_prog[] IS INITIAL.
      MESSAGE 'Isi nama program' TYPE 'E'.
    ENDIF.
    IF p_l1 = abap_false AND p_l2 = abap_false.
      MESSAGE 'Pilih minimal satu lapis deteksi (L1 atau L2)' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  DATA(go_run) = NEW lcl_runner( ).
  go_run->run( ).
  IF p_fix = abap_true.
    go_run->convert( ).
  ELSE.
    go_run->display( ).
  ENDIF.
