*---------------------------------------------------------------------*
*       FORM FCODE_DEF0                                               *
*---------------------------------------------------------------------*
*       Es wird die Default-Übersicht angesteuert                     *
*---------------------------------------------------------------------*
FORM FCODE_DEF0.

  IF TVAK-UEVOR NE SPACE.
    FCODE = TVAK-UEVOR.
  ELSE.
    FCODE = FCODE_UEBERSICHT_EINZEILIG.
  ENDIF.
  PERFORM FUNKTION_AUSFUEHREN.

ENDFORM.