*---------------------------------------------------------------------*
*       FORM FCODE_ILIF                                               *
*---------------------------------------------------------------------*
*       Anzeige Liefersituation auf Positionsebene                    *
*---------------------------------------------------------------------*
FORM FCODE_ILIF USING US_T185F
                      US_T185
                      US_T185V.


* bei Lieferplänen mit Abrufen Anzeige der Lieferungen über
* Funktionsbaustein 'SD_HELP_DELIVERIES'.
  IF NOT VBAK-ABDIS IS INITIAL.
    IF VBAK-VBKLT EQ VBKLT_LP_AUSL_AUFT.           " MAIS-Lieferplan
      CALL FUNCTION 'SD_HELP_DELIVERIES_MAIS'
           EXPORTING
                I_VBELV     = VBLB-VBELN
                I_POSNV     = VBLB-POSNR
                I_TRTYP     = 'A'
                I_UMVKN     = VBAP-UMVKN
                I_UMVKZ     = VBAP-UMVKZ
                I_VRKME     = VBAP-VRKME
                I_SET_TITLE = JA
                I_KUWEV     = KUWEV
           TABLES
                FXVBFA      = XVBFA
           EXCEPTIONS
                OTHERS      = 0.
    ELSE.
* bei diesem Aufruf muß das Pop-Up in 'SD_HELP_DELIVERIES' einen
* anderen Titel erhalten (I_SET_TITLE = JA)
      CALL FUNCTION 'SD_HELP_DELIVERIES'
           EXPORTING
                I_ABRFZ       = VBLB-ABEFZ
                I_LIFFZ       = RV45Z-LIFFZ
                I_POSNV       = VBLB-POSNR
                I_TRTYP       = 'A'
*               I_VBELN       = ' '
                I_VBELV       = VBLB-VBELN
                I_KORMNG      = VBAPD-KORMNG
                I_KORDT       = VBAPD-KORDT
                I_KORLI       = TVAK-KORLI
                I_SET_TITLE   = JA
                I_VRKME       = VBAP-VRKME
                I_KUWEV       = KUWEV
                I_VBLB        = VBLB
                I_UMVKN       = VBAP-UMVKN
                I_UMVKZ       = VBAP-UMVKZ
                I_EDLUE       = RV45Z-EDLUE
*          IMPORTING
*               E_LIFFZ  =
*               E_VBELN  =
           TABLES
                FXVBFA   = XVBFA
           EXCEPTIONS
                OTHERS   = 1.
    ENDIF.
  ELSE.
    CLEAR VBCO6.
    MOVE-CORRESPONDING VBAP TO VBCO6.
    CALL DIALOG 'RV_ORDER_DELIVERY_SITUATION'
         EXPORTING
              MAKT-MATKX FROM VBAP-ARKTX
              KNA1-NAME1 FROM KUAGV-NAME1
              VBCO6      FROM VBCO6
              IVKORG     FROM VBAK-VKORG
              IVTWEG     FROM VBAK-VTWEG
              MAKT-MATNR FROM VBAP-MATNR
              IVBUP      FROM VBUP
              KNA1-KUNNR FROM KUAGV-KUNNR.
  ENDIF.

ENDFORM.