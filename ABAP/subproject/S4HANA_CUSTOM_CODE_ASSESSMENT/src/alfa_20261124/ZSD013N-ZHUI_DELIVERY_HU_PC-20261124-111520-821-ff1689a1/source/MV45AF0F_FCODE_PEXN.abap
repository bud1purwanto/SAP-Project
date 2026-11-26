*eject
*---------------------------------------------------------------------*
*       FORM FCODE_PEXN                                               *
*---------------------------------------------------------------------*
*       Ablauf der Ausfuhrkontrolle im Normalfall und Fortschreibung  *
*       --> 'Neuermittlung'                                           *
*---------------------------------------------------------------------*
FORM FCODE_PEXN USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

*-------Aufruf nur im Verändern-Modus
  IF T180-TRTYP EQ CHARV.
    IF NOT ( TVAK-EXCOK IS INITIAL ).
      AUSFUHR_NEU    = CHARX.
      R185D-DATALOSS = CHARX.
      MESSAGE S654.
    ELSE.
      MESSAGE S653.
    ENDIF.
  ELSE.
    MESSAGE S651.
  ENDIF.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.