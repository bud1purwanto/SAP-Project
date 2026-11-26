*---------------------------------------------------------------------*
*       MODULE TVAG_SELECT_LOOP                                       *
*---------------------------------------------------------------------*
*       In Loopzeilen muss unter PBO der Absagegrund gelesen werden   *
*---------------------------------------------------------------------*
MODULE TVAG_SELECT_LOOP OUTPUT.

  PERFORM TVAG_SELECT_LOOP USING VBAP-ABGRU.

ENDMODULE.