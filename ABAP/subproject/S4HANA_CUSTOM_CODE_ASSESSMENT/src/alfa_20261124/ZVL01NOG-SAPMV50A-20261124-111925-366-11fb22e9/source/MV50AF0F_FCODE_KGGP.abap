***INCLUDE MV50AF0F_FCODE_KGGP .
*---------------------------------------------------------------------*
*       FORM FCODE_KGGP                                              *
*---------------------------------------------------------------------*
*       Gefahrgutprüfungen manuell ausführen
*---------------------------------------------------------------------*
FORM FCODE_KGGP USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  PERFORM GG_MANUAL_CHECK.

ENDFORM.