*----------------------------------------------------------------------*
*   INCLUDE MV45AF_ABC_FUNKTIONEN                                      *
*----------------------------------------------------------------------*

*-----------------------------------------------------------------------
*        Form  TP_VBAK_SELECT
*----------------------------------------------------------------------*
*       Struktur VBAK fuer CO-ABC holen                                *
*----------------------------------------------------------------------*
FORM TP_VBAK_SELECT USING TD_VBAK STRUCTURE VBAK.

 TD_VBAK = VBAK.

ENDFORM.                    " TP_VBAK_SELECT

*----------------------------------------------------------------------*
*        Form  TP_XVBAP_SELECT                                         *
*----------------------------------------------------------------------*
*       Struktur XVBAP(aktuelle Position) fuer CO-ABC holen            *
*----------------------------------------------------------------------*
FORM TP_XVBAP_SELECT USING TD_XVBAP STRUCTURE VBAPVB.

     TD_XVBAP = XVBAP.

ENDFORM.                    " TP_XVBAP_SELECT

*----------------------------------------------------------------------*
*       Form  TP_TABLE_XVBAP_SELECT                                    *
*----------------------------------------------------------------------*
*      Tabelle XVBAP fuer CO-ABC holen                                 *
*----------------------------------------------------------------------*
FORM TP_TABLE_XVBAP_SELECT TABLES TD_XVBAP STRUCTURE VBAPVB
                            USING TD_SUBRC LIKE SY-SUBRC.

  CLEAR TD_XVBAP.
  REFRESH TD_XVBAP.
  CLEAR SY-TABIX.
  APPEND LINES OF XVBAP TO TD_XVBAP.
  IF SY-TABIX > 0.
    TD_SUBRC = 0.
  ELSE.
    TD_SUBRC = 1.
  ENDIF.

ENDFORM.                    " TP_TABLE_XVBAP_SELECT