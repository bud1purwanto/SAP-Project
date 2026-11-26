*---------------------------------------------------------------------*
*       MODULE TVLVT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Verwendungskennzeichentext                              *
*---------------------------------------------------------------------*
MODULE TVLVT_SELECT OUTPUT.
*  for case header
  IF SY-DYNGR = 'KOPF'.
    PERFORM TVLVT_SELECT(SAPFV45L) USING VBAK-ABRVW
                                         SPACE
                                         SY-SUBRC.
* for case item
  ELSEIF SY-DYNGR = 'POSI'.
    PERFORM TVLVT_SELECT(SAPFV45L) USING VBAP-VKAUS
                                         SPACE
                                         SY-SUBRC.
  ENDIF.
ENDMODULE.