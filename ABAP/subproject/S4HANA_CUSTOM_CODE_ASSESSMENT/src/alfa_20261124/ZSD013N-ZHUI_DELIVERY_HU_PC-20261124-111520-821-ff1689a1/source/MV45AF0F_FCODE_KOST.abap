*eject
*---------------------------------------------------------------------*
*       FORM FCODE_KOST                                               *
*---------------------------------------------------------------------*
*       Abbrechen auf dem Kopierauswahlbild                           *
*---------------------------------------------------------------------*
FORM FCODE_KOST USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: DA_KOKRS LIKE VBAK-KOKRS.
  DATA: DA_OBJNR LIKE VBAP-OBJNR.
  DATA: BEGIN OF DA_KIS1 OCCURS 1.
          INCLUDE STRUCTURE KIS1.
  DATA: END OF DA_KIS1,
        BEGIN OF DA_CKI64A.
          INCLUDE STRUCTURE CKI64A.
  DATA: END OF DA_CKI64A.
  DATA BEGIN OF DA_CKIT OCCURS 1.
          INCLUDE STRUCTURE CKIT.
  DATA END OF DA_CKIT.


  PERFORM T459A_SELECT(SAPMV45A) USING VBAP-BEDAE
                                       CHARX
                                       SY-SUBRC.
  PERFORM T459K_SELECT(SAPFV45V) USING T459A-BEDAR
                                       CHARX
                                       SY-SUBRC.

  PERFORM T001W_SELECT USING VBAP-WERKS
                             SPACE
                             SY-SUBRC.

  IF SY-SUBRC = 0 AND
     VBAK-BUKRS_VF NE T001K-BUKRS.
* Kostenrechnungskreis bei abweichendem Buchungskreis ermitteln
    CALL FUNCTION 'RK_KOKRS_FIND'
         EXPORTING
              BUKRS  = T001K-BUKRS
              GSBER  = VBAP-GSBER
         IMPORTING
              KOKRS  = DA_KOKRS
         EXCEPTIONS
              OTHERS = 08.
    IF SY-SUBRC > 0.
      DA_KOKRS = VBAK-KOKRS.
    ENDIF.
  ELSE.
    DA_KOKRS = VBAK-KOKRS.
  ENDIF.

* Ist die Position kalkulationspflichtig gekennzeichnet bzw.
* existiert bereits eine Kalkulationsnummer und liegt kein Einzel-
* verbrauchskennzeichen vor --> Kalkulations-Kostenbericht

  IF VBAP-KALNR <> SPACE      AND
     VBAP-KZVBR <> KZVBR_E    OR
     T459K-KALKU <> SPACE     AND
     VBAP-KZVBR <> KZVBR_E.

    IF XVBAP-UPDKZ_KALK = CHARI.
      MESSAGE I566.
      EXIT.
    ELSEIF XVBAP-UPDKZ_KALK = CHARU.
      MESSAGE I567.
    ENDIF.

    CALL FUNCTION 'K_UNITCOSTING_KEY_TO_OBJ_GET'
         EXPORTING
              KUK_KOKRS = DA_KOKRS
              KUK_SPRAS = SY-LANGU
              KUK_VBELN = VBAP-VBELN
              KUK_POSNR = VBAP-POSNR
         IMPORTING
              KUK_BWVAR = DA_CKIT-BWVAR
              KUK_BZOBJ = DA_CKIT-BZOBJ
              KUK_KADKY = DA_CKIT-KADKY
              KUK_KALKA = DA_CKIT-KALKA
              KUK_KALNR = DA_CKIT-KALNR
              KUK_KKZMA = DA_CKIT-KKZMA
              KUK_LEDNR = DA_CKIT-LEDNR
              KUK_TVERS = DA_CKIT-TVERS
         EXCEPTIONS
              OTHERS    = 14.

    CALL FUNCTION 'K_UNITCOSTING_READ' " Lesen Kalk.daten
         EXPORTING
            FEL_BWVAR = DA_CKIT-BWVAR
            FEL_BZOBJ = DA_CKIT-BZOBJ
            FEL_KADKY = DA_CKIT-KADKY
            FEL_KALKA = DA_CKIT-KALKA
            FEL_KALNR = DA_CKIT-KALNR
            FEL_KKZMA = DA_CKIT-KKZMA
            FEL_TVERS = DA_CKIT-TVERS
            FEL_LEDNR = DA_CKIT-LEDNR
            FEL_SPRAS = DA_CKIT-SPRAS
         TABLES
            FEL_TAB_CKIT = DA_CKIT     " Texte
            FEL_TAB_KIS1 = DA_KIS1     " Alle Daten
         EXCEPTIONS
            FEL_NOT_FOUND = 1.

    CALL FUNCTION 'K_KKB_KALK_REPORT_CALL'
         EXPORTING
              KOKRS                = DA_KOKRS
              KOPF                 = DA_CKI64A
         TABLES
              T_KIS1               = DA_KIS1
         EXCEPTIONS
              INTERNAL_ERROR       = 1
              JOB_DOES_NOT_EXIST   = 2
              JOB_IS_NOT_GENERATED = 3
              NO_AUTHORITY         = 4
              OTHERS               = 5.

  ELSE.

*   Wurde eine Kalkulation durchgeführt, muss auf mögliche
*   Inkonsistenzen hingewiessen werden
    IF XVBAP-UPDKZ_KALK <> SPACE.
      MESSAGE I567.
    ENDIF.

*   Kostenbericht nur im Falle der Einzelfertigung aufrufen
    IF VBAP-KZVBR NE KZVBR_E.
      MESSAGE I543 WITH VBAP-POSNR.
      EXIT.
    ENDIF.

    IF VBAP-VBELV NE VBAP-VBELN OR
       VBAP-POSNV NE VBAP-POSNR.
*   Objektnummer des Referenzbelegs ermitteln
      CONCATENATE 'VB' VBAP-VBELV VBAP-POSNV INTO DA_OBJNR.
    ELSE.
      DA_OBJNR = VBAP-OBJNR.
    ENDIF.

    CALL FUNCTION 'CK_F_CO_OBJECT_DISPLAY'
         EXPORTING
              KOKRS_IMP          = DA_KOKRS
              OBJNR_IMP          = DA_OBJNR
         EXCEPTIONS
              DATA_NOT_FOUND     = 01
              JOB_DOES_NOT_EXIST = 02
              NOT_GENERATED      = 03
              NO_AUTHORITY       = 04.

    IF SY-SUBRC = 1.
      MESSAGE S545 WITH VBAP-POSNR.
    ENDIF.
  ENDIF.

ENDFORM.