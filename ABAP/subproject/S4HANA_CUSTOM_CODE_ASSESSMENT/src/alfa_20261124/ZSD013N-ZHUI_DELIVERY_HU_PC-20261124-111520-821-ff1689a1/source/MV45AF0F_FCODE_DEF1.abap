*---------------------------------------------------------------------*
*       FORM FCODE_DEF1                                               *
*---------------------------------------------------------------------*
*       Es wird die Default-Übersicht angesteuert                     *
*---------------------------------------------------------------------*
FORM FCODE_DEF1.

  IF TVAK-UEVOR NE SPACE.
    FCODE = TVAK-UEVOR.
  ELSE.
*   If no cust.entry was found, read last used F-code
    IMPORT ITEM_DETAIL_COUNTER HEADER_DETAIL_COUNTER UEBOR
      FROM memory ID INDXKEY.
    IF SY-SUBRC eq '0' AND NOT UEBOR IS INITIAL.
      FCODE = UEBOR.
    ELSE.
*     Set default screen Overview-Sales
      FCODE = FCODE_UEBERSICHT_EINZEILIG.
    ENDIF.
  ENDIF.
  PERFORM FCODE_BEARBEITEN.

ENDFORM.