*&---------------------------------------------------------------------*
*&      Form  MESSAGE_IDOC_DISPLAY
*&---------------------------------------------------------------------*
*       Message wenn zum Abruf kein IDOC vorhanden ist                 *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MESSAGE_IDOC_DISPLAY.
  IF VBLB-ABART EQ ABART_LAB.
    MESSAGE I120(V4) WITH TEXT-224.
*    Zum aktuellen & gibt es keinen Zwischenbeleg
  ELSEIF VBLB-ABART EQ ABART_FAB.
    MESSAGE I120(V4) WITH TEXT-225.
*    Zum aktuellen & gibt es keinen Zwischenbeleg
  ELSE.
    MESSAGE I120(V4) WITH TEXT-226.
*    Zum aktuellen & gibt es keinen Zwischenbeleg
  ENDIF.
ENDFORM.                               " MESSAGE_IDOC_DISPLAY