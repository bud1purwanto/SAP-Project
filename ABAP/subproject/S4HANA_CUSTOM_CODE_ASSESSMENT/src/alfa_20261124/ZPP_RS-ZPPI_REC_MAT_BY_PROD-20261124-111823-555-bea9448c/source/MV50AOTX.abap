*---------------------------------------------------------------------*
*       PBO - Module zur Textverarbeitung                             *
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE FELDAUSWAHL_TEXTE                                      *
*---------------------------------------------------------------------*
MODULE FELDAUSWAHL_TEXTE OUTPUT.

  PERFORM FELDAUSWAHL_TEXTE(SAPFV45T).

ENDMODULE.
*eject

*---------------------------------------------------------------------*
*       MODULE INIT                                                   *
*---------------------------------------------------------------------*
MODULE INIT OUTPUT.

  PERFORM TEXT_PARA_INIT(SAPFV45T) USING CHARL.

ENDMODULE.
*eject

*---------------------------------------------------------------------*
*       MODULE LTEXT_KZ_SETZEN                                        *
*---------------------------------------------------------------------*
*       setzen des Langtextkennzeichens                               *
*---------------------------------------------------------------------*
MODULE LTEXT_KZ_SETZEN OUTPUT.

  PERFORM LTEXT_KZ_SETZEN(SAPFV45T).

ENDMODULE.
*eject

*---------------------------------------------------------------------*
*       MODULE TEXT_SPRACHE_FEHLT                                     *
*---------------------------------------------------------------------*
*       positioniert Cursor auf RV45A-SPRAS, falls die Eingabe        *
*       einer Sprache notwendig ist.                                  *
*---------------------------------------------------------------------*
MODULE TEXT_SPRACHE_FEHLT OUTPUT.

  PERFORM TEXT_SPRACHE_FEHLT(SAPFV45T).

ENDMODULE.
*eject
*---------------------------------------------------------------------*
*       MODULE XTHEAD_AUFSETZEN                                       *
*---------------------------------------------------------------------*
*       Tabelle XTHEAD zur Bildschirmanzeige aufsetzen                *
*---------------------------------------------------------------------*
MODULE XTHEAD_AUFSETZEN OUTPUT.

  PERFORM XTHEAD_AUFSETZEN(SAPFV45T).

ENDMODULE.
*eject

*---------------------------------------------------------------------*
*       MODULE XTHEAD_LESEN                                           *
*---------------------------------------------------------------------*
*       Tabelle XTHEAD zur Bildschirmanzeige lesen                    *
*---------------------------------------------------------------------*
MODULE XTHEAD_LESEN OUTPUT.

  PERFORM XTHEAD_LESEN(SAPFV45T).

ENDMODULE.
*eject
*&---------------------------------------------------------------------*
*&      Module  STATUS_0621  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0621 OUTPUT.

ENDMODULE.                             " STATUS_0621  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_HEAD_SET_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE TEXT_HEAD_SET_DATA OUTPUT.

  PERFORM TEXT_HEAD_SET_DATA.

ENDMODULE.                             " TEXT_HEAD_SET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_ITEM_SET_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE TEXT_ITEM_SET_DATA OUTPUT.

  PERFORM TEXT_ITEM_SET_DATA.

ENDMODULE.                 " TEXT_ITEM_SET_DATA  OUTPUT