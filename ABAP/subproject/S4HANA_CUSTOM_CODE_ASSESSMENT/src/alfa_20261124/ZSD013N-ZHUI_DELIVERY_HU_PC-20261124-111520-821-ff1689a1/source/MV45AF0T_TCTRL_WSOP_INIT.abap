*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TCTRL_WSOP_INIT                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TCTRL_WSOP_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls.
*       Es werden die Anzahl der Zeilen gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_WSOP_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE XWSOP LINES DA_TFILL.
  TCTRL_WSOP-LINES    = DA_TFILL.
  TCTRL_NAME = 'TCTRL_WSOP'.

ENDFORM.                    " TCTRL_WSOP_INIT