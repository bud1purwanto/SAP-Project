*eject
*&---------------------------------------------------------------------*
*&      Form  BELEG_KOPF_KOPIEREN_AUS_LISTE
*&---------------------------------------------------------------------*
*       Beleg kopieren auf Positionsebene                              *
*----------------------------------------------------------------------*
FORM BELEG_KOPF_KOPIEREN_AUS_LISTE USING US_VBELN
                                         US_TRVOG.

  SET PARAMETER ID 'VRA' FIELD US_VBELN.

  IF US_TRVOG = '2'.
*   Angebot ist zu kopieren
    FCODE = 'RANG'.
  ELSE.
*   Kontrakt ist zu kopieren
    FCODE = 'RKON'.
  ENDIF.

  PERFORM FCODE_BEARBEITEN.

  IF SVBAK-TABIX NE 0.
     if call_bapi is initial.
        FLAG_LEAVE_SCREEN = CHARX.
     endif.
  ENDIF.

ENDFORM.