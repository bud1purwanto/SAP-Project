*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
MODULE FREIGABE_AKTUELL_ERM OUTPUT.
  PERFORM FREIGABE_AKTUELL_ERMITTELN(SAPFV45L).
  PERFORM VBLB_SELECT_MAX(SAPFV45L).
ENDMODULE.