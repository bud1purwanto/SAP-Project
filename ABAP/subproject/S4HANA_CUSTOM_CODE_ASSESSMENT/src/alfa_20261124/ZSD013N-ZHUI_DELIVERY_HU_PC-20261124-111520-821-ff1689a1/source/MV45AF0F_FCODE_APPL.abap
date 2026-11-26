*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_APPL                                        *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   FORM FCODE_APPL
*----------------------------------------------------------------------*
*   Nachträgliche Zuordnung einer Auftragsposition zu einem Kontrakt   *
*----------------------------------------------------------------------*
FORM FCODE_APPL USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.

  LOCAL: TVCPA.

* Wurde leere Zeile markiert?
  IF VBAP-POSNR IS INITIAL.
    FCODE = FCODE_ABBRECHEN.
    MESSAGE S735.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
  ENDIF.

* Hat die Position bereits einen Vorgängerbeleg?
  IF NOT VBAP-VGBEL IS INITIAL.
    FCODE = FCODE_ABBRECHEN.
    MESSAGE S698 WITH VBAP-POSNR.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
  ENDIF.

* Wurde Position bereits fakturiert?
  IF VBAP-FKREL CA CON_FKREL_LIEFER.
    READ TABLE XVBAPF WITH KEY VBELN = VBAP-VBELN
                               POSNR = VBAP-POSNR BINARY SEARCH.
    IF SY-SUBRC EQ 0 AND
       ( XVBAPF-FAKLMENG NE 0 OR XVBAPF-ERLMENGE_F NE 0 ).
      FCODE = FCODE_ABBRECHEN.
      MESSAGE S712 WITH VBAP-POSNR.
      PERFORM FCODE_BEARBEITEN(SAPMV45A).
      EXIT.
    ENDIF.
  ELSEIF VBAP-FKREL CA CON_FKREL_AUFTRAG.
    READ TABLE XVBUP WITH KEY VBELN = VBAP-VBELN
                              POSNR = VBAP-POSNR.
    IF SY-SUBRC = 0.
      IF XVBUP-FKSTA CA 'BC' OR
         XVBUP-FKSAA CA 'BC'.
        FCODE = FCODE_ABBRECHEN.
        MESSAGE S712 WITH VBAP-POSNR.
        PERFORM FCODE_BEARBEITEN(SAPMV45A).
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

* Auftraggeber in Partnerstruktur füllen
  READ TABLE XVBPA INTO VBPA
                   WITH KEY VBELN = VBAK-VBELN
                            POSNR = POSNR_LOW
                            PARVW = PARVW_AG
                            KUNNR = VBAK-KUNNR.

* Sicherheitshalber die Kopiertabelle CVBAP löschen
  REFRESH CVBAP.

  CALL FUNCTION 'RV_SALES_DOCUMENT_APPLY'
       EXPORTING
            F185F  = US_T185F
            F185   = US_T185
            F185V  = US_T185V
            FVAK   = TVAK
            FVBAK  = VBAK
            FVBPA  = VBPA
            FVBAP  = VBAP
            FVBKD  = VBKD
       IMPORTING
            FVBAK  = CVBAK
            FVCPA  = TVCPA
            FVBUK  = CVBUK
            F185F  = US_T185F
            F185   = US_T185
            F185V  = US_T185V
       TABLES
            FXVBAP = CVBAP
            FXVBEP = CVBEP
            FXVBFA = CVBFA
            FXVBKD = CVBKD
            FXVBPA = CVBPA
            FXVBUP = CVBUP
            FXVBUK = XVBUK
            FXVBUV = XVBUV
            FXFPLA = CFPLA
            FXFPLT = CFPLT
            FXVBSN = CVBSN
            FXVBAPF = XVBAPF.

ENDFORM.