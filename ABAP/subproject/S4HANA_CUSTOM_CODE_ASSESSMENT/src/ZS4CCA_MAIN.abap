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
  gv_c1 = 'RB_FILE: upload file .abap dari PC (baseline Alfa, utama + include)'.
  gv_c2 = 'RB_RFC : baca dari ECC via P_DEST (S_PROG = nama program, EQ)'.
  gv_c3 = 'RB_ADB : program yang sudah ada di ADB (S_PROG boleh pola Z*)'.
  gv_t2 = 'Lapis deteksi'.
  gv_c4 = 'P_L1 = diff DDIC (isi P_DEST untuk banding ECC) | P_L2 = syntax S/4'.

AT SELECTION-SCREEN.
  IF sy-ucomm = 'ONLI' OR sy-ucomm = 'PRIN' OR sy-ucomm = 'SJOB'.
    IF rb_rfc = abap_true AND p_dest IS INITIAL.
      MESSAGE 'Mode RFC: isi P_DEST (RFC destination ke ECC)' TYPE 'E'.
    ENDIF.
    IF ( rb_rfc = abap_true OR rb_adb = abap_true ) AND s_prog[] IS INITIAL.
      MESSAGE 'Isi S_PROG (nama program)' TYPE 'E'.
    ENDIF.
    IF p_l1 = abap_false AND p_l2 = abap_false.
      MESSAGE 'Pilih minimal satu lapis (P_L1/P_L2)' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  DATA(go_run) = NEW lcl_runner( ).
  go_run->run( ).
  go_run->display( ).
