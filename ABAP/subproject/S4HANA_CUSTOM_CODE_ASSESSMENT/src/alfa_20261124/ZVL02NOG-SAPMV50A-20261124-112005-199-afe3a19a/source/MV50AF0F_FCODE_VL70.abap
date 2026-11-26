***INCLUDE MV50AF0F_FCODE_VL70 .
*---------------------------------------------------------------------*
*       FORM FCODE_VL70                                               *
*---------------------------------------------------------------------*
*       Beleg sichern und Kommiliste drucken                          *
*---------------------------------------------------------------------*
FORM FCODE_VL70.

  IF R185D-DATALOSS NE SPACE.
*   Soll beim bzw. nach dem Sichern der Lieferung die Kommiliste
*   gedruckt werden, so muß die Verbuchung synchronisiert werden:
*   Andernfalls ist der NaSt-Satz noch nicht vorhanden und die vl70
*   findet keine Nachricht zum Druck der Kommiliste. Dieses Warten
*   wird durch das nachfolgende Flag angezeigt.
    V50AGL-SYNCHRON = 'X'.
    PERFORM SYNCHRON.
    SET PARAMETER ID 'NAC' FIELD SPACE.
    PERFORM BELEG_SICHERN USING CHARX.
  ENDIF.

*APO: safety first
  PERFORM NMODUL_FOR_TCODE_APO.

ENDFORM.