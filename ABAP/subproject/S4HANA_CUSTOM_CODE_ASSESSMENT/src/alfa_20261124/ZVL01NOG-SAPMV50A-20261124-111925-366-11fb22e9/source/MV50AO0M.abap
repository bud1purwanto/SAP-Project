************************************************************************
*                                                                      *
* PBO Module Lieferabwicklung                                          *
*     Module alphabetisch geordnet; hier mit "M" beginnend             *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*       MODULE MSEG_LESEN                                             *
*---------------------------------------------------------------------*
*       Für VL07 wird ausser der Lieferposition die parallele         *
*       Tabelle MSEG gelesen                                          *
*---------------------------------------------------------------------*
MODULE MSEG_LESEN OUTPUT.

  READ TABLE SLIPS INDEX SY-STEPL.
  IF SY-SUBRC NE 0.
     CLEAR MSEG.
     EXIT FROM STEP-LOOP.
  ELSE.
     READ TABLE XMSEG INDEX SLIPS-TABIX.
     IF SY-SUBRC NE 0.
       MESSAGE A322 WITH 'XMSEG'.
     ENDIF.

     MSEG = XMSEG.
  ENDIF.

ENDMODULE.
*eject