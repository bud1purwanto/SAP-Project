*eject
*---------------------------------------------------------------------*
*       FORM FCODE_IFDP                                               *
*---------------------------------------------------------------------*
*       Aufruf des Protokolls der Zuordnung der Finanzdokumente       *
*       * Ausgabe der Protokolliste                                   *
*       oder                                                          *
*       * Nachricht, wenn kein Protokoll vorhanden                    *
*---------------------------------------------------------------------*
FORM FCODE_IFDP USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

*------- Aufruf des Funktionsbausteins zur Protokollausgabe
  CALL FUNCTION 'RV_FOR_TRADE_PROTOCOL_DISPLAY'
       EXPORTING
            I_PROT  = 'D'.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.