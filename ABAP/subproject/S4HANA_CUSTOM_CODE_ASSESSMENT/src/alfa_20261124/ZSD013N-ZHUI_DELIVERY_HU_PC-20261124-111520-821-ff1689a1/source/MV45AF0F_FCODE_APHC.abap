*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_APHC                                        *
*----------------------------------------------------------------------*
FORM FCODE_APHC USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.

  LOCAL: TVCPA.

* Hat der Beleg bereits einen Vorgängerbeleg?
  IF NOT VBAK-VGBEL IS INITIAL.
    FCODE = FCODE_ABBRECHEN.
    MESSAGE S805 WITH VBAK-VGBEL.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
  ENDIF.

* Wurde der Beleg bereits fakturiert?
  IF VBUK-FKSTK CA 'BC' OR
     VBUK-FKSAK CA 'BC'.
    FCODE = FCODE_ABBRECHEN.
    MESSAGE S886.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
  ENDIF.

* Auftraggeber in Partnerstruktur füllen
  READ TABLE XVBPA INTO VBPA
                   WITH KEY VBELN = VBAK-VBELN
                            POSNR = POSNR_LOW
                            PARVW = PARVW_AG
                            KUNNR = VBAK-KUNNR.

* Damit auf keinen Fall ein Positionsbezug hergestellt wird:
  CLEAR VBAP.

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
            FXVBSN = CVBSN.

ENDFORM.