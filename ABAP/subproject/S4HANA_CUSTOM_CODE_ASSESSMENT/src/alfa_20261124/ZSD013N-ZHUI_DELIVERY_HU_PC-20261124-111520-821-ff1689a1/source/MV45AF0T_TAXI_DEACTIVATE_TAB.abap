*&---------------------------------------------------------------------*
*&      Form  TAXI_DEACTIVATE_TAB
*&---------------------------------------------------------------------*
*       Eintrag des übergebenen Funktionscodes in die Tabelle          *
*       auszublendender Tabstrip-Reiter                                *
*----------------------------------------------------------------------*
*       -->US_FCODE  semantischer Funktionscode des auszublendenden    *
*                    Reiters                                           *
*----------------------------------------------------------------------*
FORM TAXI_DEACTIVATE_TAB USING US_FCODE LIKE TAXI_PARAMS-FCODE.
  TAXI_INACTIVE_FCODES-FCODE = US_FCODE.
  APPEND TAXI_INACTIVE_FCODES.
ENDFORM.                               " TAXI_DEACTIVATE_TAB