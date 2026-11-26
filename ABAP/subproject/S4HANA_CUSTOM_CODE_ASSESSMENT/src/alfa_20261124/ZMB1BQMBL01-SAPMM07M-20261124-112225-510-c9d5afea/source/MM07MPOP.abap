*---------------------------------------------------------------------*
*        Form - Routinen im Zusammenhang mit POP-UP-Verarbeitung      *
*---------------------------------------------------------------------*
*       FORM MEINS_SETZEN                                             *
*---------------------------------------------------------------------*
*       Die Mengeneinheit fuer die Verfuegbarkeitsanzeige wird gesetzt*
*---------------------------------------------------------------------*
FORM MEINS_SETZEN.

  T157T-MEINS = MSEG-MEINS.
  CHECK MSEG-ERFME NE SPACE.
  T157T-MEINS = MSEG-ERFME.

ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM VERFUEGBARKEIT_ANZEIGEN                                  *
*---------------------------------------------------------------------*
*       Die Anzeigeregel fuer das Verfuegbarkeitswindow wird ermittelt*
*---------------------------------------------------------------------*
FORM VERFUEGBARKEIT_ANZEIGEN
         USING IS_ENHANCEMENT TYPE ISU_VERFUEGBARKEIT_ANZEIGEN."IS2ERP

  DATA: LS_ISU_UMRECHNEN_ME TYPE ISU_UMRECHNEN_ME.          "IS2ERP
  DATA: LS_ISU_LMKOL        TYPE ISU_LMKOL.                 "n1607379

ENHANCEMENT-POINT VERFUEGBARKEIT_ANZEIGEN_01 SPOTS ES_SAPMM07M.

  REFRESH VTEXT.
  CLEAR VTEXT.
  CLEAR INDEX_V.
  SELECT SINGLE * FROM T157R WHERE ANZRE = DM07M-ANZRE AND
                                   XCHAR = MBEFU-XCHAR.
  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE E001 WITH '157R' DM07M-ANZRE MBEFU-XCHAR.
  ENDIF.
  SELECT * FROM T157N WHERE ANZRE = T157R-REGEL.
    CHECK T157N-FELDV NE SPACE.
    TEXTA-SEGMN = T157N-SEGMV.
    TEXTA-FELDN = T157N-FELDV.
    SELECT SINGLE * FROM T157T WHERE SPRAS   = SY-LANGU
                               AND   FELDN   = TEXTA.
    CHECK SY-SUBRC IS INITIAL.
    VTEXT-SEGMN = T157N-SEGMV.
    VTEXT-FELDN = T157N-FELDV.
    VTEXT-TEXTA = T157T-TEXT20.
    APPEND VTEXT.
  ENDSELECT.
  LOOP AT VTEXT.
    AT NEW SEGMN.
      RNAME-NAME = VTEXT-SEGMN.
      RNAME-KENN = L.
*     Due to an IS-U Enhancement we need to call LMKOL static "n1607379
      IF RNAME-NAME <> 'MKOL'.                                "n1607379
        PERFORM (RNAME) IN PROGRAM SAPFM07M USING MSEG-MATNR
                                                MSEG-WERKS
                                                MSEG-LGORT
                                                MSEG-CHARG
                                                MSEG-SOBKZ
                                                MSEG-KDAUF
                                                MSEG-KDPOS
                                                MSEG-KUNNR
                                                MSEG-LIFNR
                                                MSEG-EMLIF
                                                MSEG-PLPLA
                                                MSEG-EBELN
                                                MSEG-EBELP
                                                MSEG-LFBJA
                                                MSEG-LFBNR
                                                MSEG-LFPOS
                                                MSEG-KZZUG
                                                MSEG-AUFNR
                                                MSEG-AUFPS
                                                MSEG-RSNUM
                                                MSEG-RSPOS
                                                MSEG-RSART
                                                MSEG-PS_PSP_PNR
                                                SPACE
                                                SPACE
                                                SPACE.
      ELSE.                                                   "n1607379
        PERFORM LMKOL IN PROGRAM SAPFM07M USING   MSEG-MATNR  "n1607379
                                                  MSEG-WERKS
                                                  MSEG-LGORT
                                                  MSEG-CHARG
                                                  MSEG-SOBKZ
                                                  MSEG-KDAUF
                                                  MSEG-KDPOS
                                                  MSEG-KUNNR
                                                  MSEG-LIFNR
                                                  MSEG-EMLIF
                                                  MSEG-PLPLA
                                                  MSEG-EBELN
                                                  MSEG-EBELP
                                                  MSEG-LFBJA
                                                  MSEG-LFBNR
                                                  MSEG-LFPOS
                                                  MSEG-KZZUG
                                                  MSEG-AUFNR
                                                  MSEG-AUFPS
                                                  MSEG-RSNUM
                                                  MSEG-RSPOS
                                                  MSEG-RSART
                                                  MSEG-PS_PSP_PNR
                                                  SPACE
                                                  SPACE
                                                  SPACE
                                                  LS_ISU_LMKOL. "IS-U
      ENDIF.                                                  "n1607379
      CLEAR RC.
      LOOP AT  VTEXT WHERE SEGMN = RNAME-NAME.
        ASSIGN VTEXT-FELDN TO <FELD1>.
        IF NOT SY-SUBRC IS INITIAL.
          RC = SY-SUBRC.
          EXIT.
        ENDIF.
        READ TABLE VTEXT WITH KEY <FELD1>.
        FELDN-SEGMN = RNAME-NAME.
        FELDN-FELDN = <FELD1>.
        ASSIGN (FELDN) TO <FELD1>.
        IF NOT SY-SUBRC IS INITIAL.
          RC = SY-SUBRC.
          EXIT.
        ENDIF.
        DATA: MENGE1 LIKE MSEG-MENGE,
              MENGE2 LIKE MSEG-MENGE.
        MENGE1 = <FELD1>.
        CLEAR MENGE2.

ENHANCEMENT-SECTION     VERFUEGBARKEIT_ANZEIGEN_02 SPOTS ES_SAPMM07M.
        PERFORM UMRECHNEN_ME(SAPFM07M) USING MSEG-MATNR
                                             MSEG-CHARG     "ALR014884
                                             MSEG-WERKS     "ALR014884
*                                             mseg-cuobj     "ALR014884
                                             MSEG-MEINS
                                             MSEG-ERFME
                                                 MENGE1
                                                 MENGE2
                                            DM07M-UMREZ
                                            DM07M-UMREN
                                            LS_ISU_UMRECHNEN_ME."IS2ERP
END-ENHANCEMENT-SECTION.

        VTEXT-MENGE = MENGE2.
        MODIFY VTEXT.
      ENDLOOP.
    ENDAT.
    IF NOT RC IS INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF NOT RC IS INITIAL.
    MESSAGE W147.
    PERFORM POPUP_VERLASSEN.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM VERFUEGBARKEIT_UEBERNEHMEN                               *
*---------------------------------------------------------------------*
*       Die Daten fuer die Verfuegbarkeitspruefung werden aus         *
*       der entsprechenden Sperrtabelle gelesen.                      *
*---------------------------------------------------------------------*
FORM VERFUEGBARKEIT_UEBERNEHMEN.
  INDEX_V = INDEX_V + 1.
  READ TABLE VTEXT INDEX INDEX_V.
  IF SY-SUBRC = 0.
    T157T-TEXT20 = VTEXT-TEXTA.
    T157T-MENGE  = VTEXT-MENGE.
    RM07M-MENGM  = VTEXT-MENGE.                          "note388567
  ELSE.
    EXIT FROM STEP-LOOP.
  ENDIF.
ENDFORM.
*eject