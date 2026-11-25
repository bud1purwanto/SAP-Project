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
  GV_R1 = 'Upload file .abap dari PC (baseline Alfa: program utama + include)'.
  GV_R2 = 'Baca dari ECC lewat RFC (isi RFC destination dan nama program)'.
  GV_R3 = 'Baca dari program yang sudah ada di ADB (boleh pola Z*)'.
  GV_L1 = 'Nama program'.
  GV_T2 = 'Perbandingan dengan ECC'.
  GV_L2 = 'RFC destination ECC'.
  GV_T3 = 'Lapis deteksi'.
  GV_L3 = 'L1  Diff DDIC (S/4; dibanding ECC bila RFC destination diisi)'.
  GV_L4 = 'L2  Syntax check dengan compiler S/4'.

AT SELECTION-SCREEN OUTPUT.
  " nama program hanya relevan untuk mode RFC dan ADB
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'PRG' AND RB_FILE = ABAP_TRUE.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'ONLI' OR SY-UCOMM = 'PRIN' OR SY-UCOMM = 'SJOB'.
    IF RB_RFC = ABAP_TRUE AND P_DEST IS INITIAL.
      MESSAGE 'Mode RFC: isi RFC destination ECC' TYPE 'E'.
    ENDIF.
    IF ( RB_RFC = ABAP_TRUE OR RB_ADB = ABAP_TRUE ) AND S_PROG[] IS INITIAL.
      MESSAGE 'Isi nama program' TYPE 'E'.
    ENDIF.
    IF P_L1 = ABAP_FALSE AND P_L2 = ABAP_FALSE.
      MESSAGE 'Pilih minimal satu lapis deteksi (L1 atau L2)' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  DATA(GO_RUN) = NEW LCL_RUNNER( ).
  GO_RUN->RUN( ).
  GO_RUN->DISPLAY( ).