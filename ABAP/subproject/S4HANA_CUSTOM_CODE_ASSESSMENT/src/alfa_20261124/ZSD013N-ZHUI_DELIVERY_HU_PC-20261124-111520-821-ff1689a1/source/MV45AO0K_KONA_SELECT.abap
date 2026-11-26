*---------------------------------------------------------------------*
*       MODULE KONA_SELECT                                            *
*---------------------------------------------------------------------*
*       Lesen Bonusabsprache                                          *
*---------------------------------------------------------------------*
MODULE KONA_SELECT OUTPUT.

  PERFORM KONA_SELECT(SAPFV45K) USING VBAK-KNUMA
                                      SY-SUBRC.

ENDMODULE.