*eject
*---------------------------------------------------------------------*
*       FORM UNGUELTIGE_ZEILE                                         *
*---------------------------------------------------------------------*
*       Der Cursor steht auf einer ungueltigen Zeile.                 *
*---------------------------------------------------------------------*
FORM ungueltige_zeile.
  fcode_next = fcode.
  CLEAR: t063o, t063t, t063c, index_l, ccode, xpf02.
  MESSAGE i550.
ENDFORM.