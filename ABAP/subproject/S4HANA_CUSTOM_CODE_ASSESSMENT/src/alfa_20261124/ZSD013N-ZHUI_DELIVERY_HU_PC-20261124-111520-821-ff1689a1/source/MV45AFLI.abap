
************************************************************************
*                                                                      *
* Unterroutinen fuer die Kundenauftragsabwicklung                      *
*     Routinen für Listprozessing                                      *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       AT LINE-SELEKTION                                             *
*---------------------------------------------------------------------*
*       Bei Zeilenselektion                                           *
*---------------------------------------------------------------------*
AT USER-COMMAND.
  DATA: DA_LILLI LIKE SY-LILLI.
  DA_LILLI = SY-LILLI.
  FCODE = SY-UCOMM.
  CASE FCODE.                          "FCODE.
    WHEN 'BACK'.
      FEHLEREXIT = 'X'.
      FEHLER = ' '.
* Unvollständigkeit Partner-Subscreen - Fehlerflags zurücksetzen
      CLEAR: FEHLER_KPAR_SUB,
             FEHLER_PPAR_SUB.
      LEAVE."SCREEN.                    "QQH 21.02.91
    WHEN 'P+  '.
    WHEN 'P++ '.
    WHEN 'P-  '.
    WHEN 'P-- '.
    WHEN 'FEAL'.
      YVBUV_LINES = 6.
      DO.
        YVBUV_LINES = YVBUV_LINES + 1.
        READ LINE YVBUV_LINES.
        IF SY-SUBRC = 0 AND
           SY-LISEL(1) <> CHAR-.
          SY-LISEL(1) = 'X'.
        ELSE.
          EXIT.
        ENDIF.
        MODIFY CURRENT LINE.
      ENDDO.
    WHEN 'FENO'.
      YVBUV_LINES = 6.
      DO.
        YVBUV_LINES = YVBUV_LINES + 1.
        READ LINE YVBUV_LINES.
        IF SY-SUBRC = 0 AND
           SY-LISEL(1) <> CHAR-.
          SY-LISEL(1) = ' '.
        ELSE.
          EXIT.
        ENDIF.
        MODIFY CURRENT LINE.
      ENDDO.
    WHEN 'FEMA'.
      READ LINE SY-CUROW OF CURRENT PAGE.
      IF SY-LISEL(1) = 'X' OR
         SY-LISEL(1) = '_'.
        IF SY-LISEL(1) = 'X'.
          SY-LISEL(1) = '_'.
          DETAIL.
        ELSE.
          SY-LISEL(1) = 'X'.
          SUMMARY.
        ENDIF.
        MODIFY CURRENT LINE.
      ELSE.
        MESSAGE S410(VR).
      ENDIF.

    WHEN 'FEBE'.
      FEHLER = 'X'.
* Partner-Subscreen-Fehlerflag setzen
      IF XVBUV-TBNAM CP 'VBPA'.
        IF XVBUV-POSNR IS INITIAL.
          FEHLER_KPAR_SUB = CHARX.
        ELSE.
          FEHLER_PPAR_SUB = CHARX.
        ENDIF.
      ENDIF.
      REFRESH YVBUV.
      YVBUV_LINES = 6.
      DO.
        YVBUV_LINES = YVBUV_LINES + 1.
        READ LINE YVBUV_LINES.
        IF SY-SUBRC = 0.
          IF SY-LISEL(1) = 'x' OR SY-LISEL(1) = 'X'.
            YVBUV = XVBUV. APPEND YVBUV.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.

      DESCRIBE TABLE YVBUV LINES YVBUV_LINES.
      IF YVBUV_LINES = 0.
        READ LINE DA_LILLI OF CURRENT PAGE.
        YVBUV = XVBUV.
        APPEND YVBUV.
      ENDIF.
      PERFORM FCODE_FEWE.
    WHEN OTHERS.
ENHANCEMENT-SECTION     MV45AFLI_01 SPOTS ES_SAPMV45A.
      FEHLER = ' '.
* Unvollständigkeit Partner-Subscreen - Fehlerflags zurücksetzen
      CLEAR: FEHLER_KPAR_SUB,
             FEHLER_PPAR_SUB.
      FCODE = SY-UCOMM.
      FEHLEREXIT = 'X'.
      LEAVE.
END-ENHANCEMENT-SECTION.
  ENDCASE.


*---------------------------------------------------------------------*
*       TOP-OF-PAGE                                                   *
*---------------------------------------------------------------------*
*       Bei Seitenanfang                                              *
*---------------------------------------------------------------------*
TOP-OF-PAGE.

  DETAIL.
  WRITE: /(20) TEXT-002,
    22 KUAGV-KUNNR,
    KUAGV-NAME1,
         /(20) RV45A-TXT_VBELN,
           22 VBAK-VBELN,
         / TEXT-004.

  NEW-LINE.
ENHANCEMENT-SECTION     MV45AFLI_02 SPOTS ES_SAPMV45A.
  ULINE (59).
  SKIP TO LINE 5.
  WRITE: /2(58) TEXT-003 COLOR COL_HEADING.
  NEW-LINE.
  ULINE (59).
END-ENHANCEMENT-SECTION.
* SKIP TO LINE 6.
* WRITE: 9(1) ' ', 36(1) ' '.

  DETAIL.
  SET CURSOR 1 8.

AT LINE-SELECTION.
  READ LINE SY-CUROW OF CURRENT PAGE.
  IF SY-LISEL(1) = 'X' OR SY-LISEL(1) = 'x'.
    SY-LISEL(1) = '_'.
    DETAIL.
  ELSE.
    SY-LISEL(1) = 'X'.
    SUMMARY.
  ENDIF.
  MODIFY CURRENT LINE.

TOP-OF-PAGE DURING LINE-SELECTION.


*---------------------------------------------------------------------*
*       FORM FEHLERBEHANDLUNG                                         *
*---------------------------------------------------------------------*
FORM FEHLERBEHANDLUNG.

* Fehler-Window Partner
  IF XVBUV-PARVW CN ' '.
    MOVE-CORRESPONDING XVBUV TO XVBPAKEY.

    IF XVBPAKEY-PARVW = 'AA'
    OR XVBPAKEY-PARVW = 'AW'.
*     Sonderfall Mehrfachrollen AA/AW
      LOOP AT XVBPA WHERE VBELN = XVBPAKEY-VBELN
                    AND   POSNR = XVBPAKEY-POSNR
                    AND   PARVW = XVBPAKEY-PARVW
                    AND ( KUNNR IS INITIAL OR ADRDA IS INITIAL ).
        EXIT.
      ENDLOOP.
    ELSE.
      READ TABLE XVBPA WITH KEY XVBPAKEY.
    ENDIF.
    IF SY-SUBRC = 0.
      IF XVBPA-POSNR > 0.
        IF XVBUV-FCODE = 'KPAR' OR
           XVBUV-FCODE = 'KPAR_SUB'.
          IF XVBUV-FCODE = 'KPAR'.
            XVBUV-FCODE = 'PPAR'.
          ENDIF.
          IF XVBUV-FCODE = 'KPAR_SUB'.
            XVBUV-FCODE = 'PPAR_SUB'.
          ENDIF.
          LOOP AT IVBAP.
            IF IVBAP-SELKZ = 'X'.
              IVBAP-SELKZ = ' '.
              MODIFY IVBAP.
            ENDIF.
            IF IVBAP-POSNR = XVBPA-POSNR.
              IVBAP-SELKZ = 'X'.
              MODIFY IVBAP.
            ENDIF.
          ENDLOOP.
          READ TABLE IVBAP WITH KEY XVBPA-POSNR BINARY SEARCH.
          IF SY-SUBRC NE 0.
            IVBAP-POSNR = XVBPA-POSNR.
            IVBAP-SELKZ = 'X'.
            APPEND IVBAP.
          ENDIF.
          PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING XVBUV-POSNR
                                                     SVBAP-TABIX.
          PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
        ENDIF.
      ENDIF.

      MOVE XVBUV-FCODE TO FCODE.
      FEHLEREXIT = 'X'.

      IF SY-CALLD = ' ' OR SY-UCOMM = 'FEBE'.               "K11K046789
        SET SCREEN 700.
        LEAVE SCREEN.
      ENDIF.
      CHECK 1 = 2.
    ENDIF.
  ENDIF.                               "Ende PARVW nicht initial

* Fehler-Window Texte
  IF XVBUV-TDID CN ' '.
    MOVE XVBUV-FCODE TO FCODE.
    MOVE-CORRESPONDING XVBUV TO FTEXT.
    CASE FTEXT-POSNR.
      WHEN '000000'. FTEXT-TDOBJECT = 'VBBK'.
      WHEN OTHERS  . FTEXT-TDOBJECT = 'VBBP'.
    ENDCASE.
    FEHLEREXIT = 'X'.
    SET SCREEN 700.
    LEAVE SCREEN.
    CHECK 1 = 2.
  ENDIF.                               "Ende PARVW nicht initial

* Fehler-Window zum Kopf
  IF XVBUV-POSNR EQ SPACE AND
     XVBUV-ETENR EQ SPACE.

     IF XVBUV-FCODE EQ FCODE_KONDITION_KOPF.
       XVBUV-FCODE = FCODE_KONDITION_KOPF_SUBSC.
     ENDIF.

    MOVE XVBUV-FCODE TO FCODE.
    FEHLEREXIT = 'X'.

    IF SY-CALLD = ' ' OR SY-UCOMM = 'FEBE'.                 "K11K046789
      SET SCREEN 700.
      LEAVE SCREEN.
    ENDIF.
    CHECK 1 = 2.

  ENDIF.

* Fehler-Window zur Positionen
  IF XVBUV-POSNR CN '0 ' AND
     XVBUV-ETENR CO '0 '.
    PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING XVBUV-POSNR
                                               SVBAP-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
ENHANCEMENT-POINT FEHLERBEHANDLUNG_10 SPOTS ES_SAPMV45A.
* Wegen Umstellung auf neues Konditionsbild ist der folgende MOVE
* erforderlich
    IF XVBUV-FCODE EQ FCODE_KONDITION_POSITION.
      XVBUV-FCODE = FCODE_KONDITION_POSITION_SUBSC.
    ENDIF.

    MOVE XVBUV-FCODE TO FCODE.
    FEHLEREXIT = 'X'.

    IF SY-CALLD = ' ' OR SY-UCOMM = 'FEBE'.                 "K11K046789
      SET SCREEN 700.
      LEAVE SCREEN.
    ENDIF.
    CHECK 1 = 2.
    EXIT.

  ENDIF.

* Fehler-Window zur Einteilung
  IF XVBUV-POSNR NE SPACE AND
     XVBUV-ETENR NE SPACE.
    PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING XVBUV-POSNR
                                               SVBAP-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    PERFORM XVBEP_LESEN_DIREKT(SAPFV45E) USING XVBUV-POSNR
                                               XVBUV-ETENR
                                               SVBEP-TABIX.
    PERFORM VBEP_BEARBEITEN_VORBEREITEN(SAPFV45E).
    MOVE XVBUV-FCODE TO FCODE.
    FEHLEREXIT = 'X'.

    IF SY-CALLD = ' ' OR SY-UCOMM = 'FEBE'.                 "K11K046789
      SET SCREEN 700.
      LEAVE SCREEN.
    ENDIF.
    CHECK 1 = 2.

  ENDIF.
  MOVE 'FEBA' TO FCODE.
  FEHLEREXIT = 'X'.
  LEAVE.
  CHECK 1 = 2.

ENDFORM.