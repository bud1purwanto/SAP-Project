*----------------------------------------------------------------------*
*   INCLUDE MV45AO0R_RV45A_TEXT_BESCHAFFU                              *
*----------------------------------------------------------------------*
MODULE RV45A-TEXT_BESCHAFFUNG_AUSGABE OUTPUT.

  PERFORM BUTTON_BESCHAFFUNG_TEXT(SAPFV45E)
                                  CHANGING RV45A-BTN_FCODE
                                           RV45A-TEXT_BESCHAFFUNG.

ENDMODULE.