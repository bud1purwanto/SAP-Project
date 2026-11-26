*----------------------------------------------------------------------*
*   INCLUDE MV45AO0R_RV45A_MABNR_AUSGABE                               *
*----------------------------------------------------------------------*
*   RV45A-MABNR wird gefüllt, abhängig von der Customizingeinstellung  *
*----------------------------------------------------------------------*

MODULE RV45A_MABNR_AUSGABE OUTPUT.

  PERFORM RV45A_MABNR_FUELLEN(SAPFV45P).

ENDMODULE.




















