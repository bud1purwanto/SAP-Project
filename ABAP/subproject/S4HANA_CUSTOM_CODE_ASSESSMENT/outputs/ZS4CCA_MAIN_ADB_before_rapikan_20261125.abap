*&---------------------------------------------------------------------*
*& Report ZS4CCA_MAIN
*& Tool deteksi kode ECC 6.0 yang tidak valid di S/4HANA (tanpa AI)
*& F1: L1 diff DDIC (ADB vs ECC opsional) + L2 syntax check S/4.
*& Hanya membaca; hasil ke ALV (export Excel lewat menu ALV).
*& Brief: subproject/S4HANA_CUSTOM_CODE_ASSESSMENT/docs/
*&        BRIEF_TOOL_DETEKSI_PERBAIKAN_S4.md
*&---------------------------------------------------------------------*
REPORT ZS4CCA_MAIN.

INCLUDE ZS4CCA_TOP.
INCLUDE ZS4CCA_CORE.

INITIALIZATION.
  GV_T1 = 'Sumber source'.
  GV_C1 = 'RB_FILE: upload file .abap dari PC (baseline Alfa, utama + include)'.
  GV_C2 = 'RB_RFC : baca dari ECC via P_DEST (S_PROG = nama program, EQ)'.
  GV_C3 = 'RB_ADB : program yang sudah ada di ADB (S_PROG boleh pola Z*)'.
  GV_T2 = 'Lapis deteksi'.
  GV_C4 = 'P_L1 = diff DDIC (isi P_DEST untuk banding ECC) | P_L2 = syntax S/4'.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'ONLI' OR SY-UCOMM = 'PRIN' OR SY-UCOMM = 'SJOB'.
    IF RB_RFC = ABAP_TRUE AND P_DEST IS INITIAL.
      MESSAGE 'Mode RFC: isi P_DEST (RFC destination ke ECC)' TYPE 'E'.
    ENDIF.
    IF ( RB_RFC = ABAP_TRUE OR RB_ADB = ABAP_TRUE ) AND S_PROG[] IS INITIAL.
      MESSAGE 'Isi S_PROG (nama program)' TYPE 'E'.
    ENDIF.
    IF P_L1 = ABAP_FALSE AND P_L2 = ABAP_FALSE.
      MESSAGE 'Pilih minimal satu lapis (P_L1/P_L2)' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  DATA(GO_RUN) = NEW LCL_RUNNER( ).
  GO_RUN->RUN( ).
  GO_RUN->DISPLAY( ).