*-------------------------------------------------------------------
***INCLUDE MV45AF0S_SET_FCODE_TO_PAEN .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  SET_FCODE_TO_PAEN
*&---------------------------------------------------------------------*
* Zur Benutzung als CModul in der Folgebildsteuerung
*----------------------------------------------------------------------*

FORM SET_FCODE_TO_PAEN USING H185F STRUCTURE T185F
                             H185  STRUCTURE T185
                             H185V STRUCTURE T185V.
  H185F-FCODE = 'PAEN' .

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

ENDFORM.                    " SET_FCODE_TO_PAEN