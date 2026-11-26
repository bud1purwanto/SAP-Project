*---------------------------------------------------------------------*
*       PAI - Module zur Textverarbeitung                             *
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE CURSOR_MERKEN                                          *
*---------------------------------------------------------------------*
*       Bei PAI wird die fuer die Form FCODE_TELO die Position des    *
*       Cursors gemerkt.                                              *
*---------------------------------------------------------------------*
MODULE CURSOR_MERKEN INPUT.

  PERFORM CURSOR_MERKEN(SAPFV45T).

ENDMODULE.
*eject

*---------------------------------------------------------------------*
*       MODULE TEXT_SPRACHE_PRUEFEN                                   *
*---------------------------------------------------------------------*
*       prueft die eingegebene Sprache und modifiziert den Textkopf   *
*---------------------------------------------------------------------*
MODULE TEXT_SPRACHE_PRUEFEN INPUT.

  PERFORM TEXT_SPRACHE_PRUEFEN(SAPFV45T).

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE THEAD_UNTERLEGEN                                       *
*---------------------------------------------------------------------*
*       Bei PAI wird zunächst der alte Text gelesen.                  *
*---------------------------------------------------------------------*
MODULE THEAD_UNTERLEGEN INPUT.

  PERFORM THEAD_UNTERLEGEN(SAPFV45T).

ENDMODULE.
*eject

*---------------------------------------------------------------------*
*       MODULE THEAD_BEARBEITEN                                       *
*---------------------------------------------------------------------*
*       Verarbeitung der Inline-Texte                                 *
*---------------------------------------------------------------------*
MODULE THEAD_BEARBEITEN INPUT.

  PERFORM THEAD_BEARBEITEN(SAPFV45T).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_MARKED_ROWS  INPUT
*&---------------------------------------------------------------------*
MODULE GET_MARKED_ROWS INPUT.
  PERFORM GET_MARKED_ROWS.
ENDMODULE.                             " GET_MARKED_ROWS  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_HEAD_GET_DATA  INPUT
*&---------------------------------------------------------------------*
MODULE TEXT_HEAD_GET_DATA INPUT.

  PERFORM TEXT_HEAD_GET_DATA.

ENDMODULE.                             " TEXT_HEAD_GET_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_ITEM_GET_DATA  INPUT
*&---------------------------------------------------------------------*
MODULE TEXT_ITEM_GET_DATA INPUT.

  PERFORM TEXT_ITEM_GET_DATA.

ENDMODULE.                 " TEXT_ITEM_GET_DATA  INPUT