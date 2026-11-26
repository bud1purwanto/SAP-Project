*---------------------------------------------------------------------*
*       FORM FCODE_MONT                                               *
*---------------------------------------------------------------------*
*       Aus der Unvollständigkeitsliste wird für die VBEP-Felder      *
*       AUFNR und PLNUM eine Infomeldung ausgegeben, da keine         *
*       eindeutige Verarbeitung möglich ist.                          *
*---------------------------------------------------------------------*
FORM FCODE_MONT USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  MESSAGE I558.

  T185F-FCODE = FCODE_ZURUECK9.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.