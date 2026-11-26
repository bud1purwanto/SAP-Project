*&---------------------------------------------------------------------*
*&      Module  XMERKMAL_PRUEFEN     INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE xmerkmal_pruefen    INPUT.

  PERFORM merkmal_pruefen using char_va_sel-atnam
                                charx
                                sy-subrc.

ENDMODULE.                             " XMERKMAL_pruefen     INPUT
