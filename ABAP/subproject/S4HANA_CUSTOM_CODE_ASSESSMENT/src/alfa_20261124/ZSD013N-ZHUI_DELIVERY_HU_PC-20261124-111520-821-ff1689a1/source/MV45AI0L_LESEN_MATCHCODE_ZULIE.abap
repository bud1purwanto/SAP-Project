*&---------------------------------------------------------------------*
*&      Module  LESEN_MATCHCODE_ZULIEFERER  INPUT
*&---------------------------------------------------------------------*
*       prüft, ob bereits identischer Lieferplan bezüglich Matchcode
*       vorhanden ist.                                             *
*----------------------------------------------------------------------*
MODULE LESEN_MATCHCODE_ZULIEFERER INPUT.

  IF NOT VBAK-ABDIS IS INITIAL.
    IF VBAK-ABRVW NE *VBAK-ABRVW OR
       VBAK-KTEXT NE *VBAK-KTEXT OR
       VBAK-KUNNR NE *VBAK-KUNNR.
      PERFORM LESEN_MATCHCODE_ZULIEFERER(SAPFV45P) USING SPACE.
    ENDIF.
  ENDIF.

ENDMODULE.                 " LESEN_MATCHCODE_ZULIEFERER  INPUT