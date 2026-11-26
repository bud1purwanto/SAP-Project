***INCLUDE MV50AF0F_FCODE_WEUE .
*---------------------------------------------------------------------*
*       FORM FCODE_WEUE                                               *
*---------------------------------------------------------------------*
*       CAll der ME23 zur Anzeige der Bestellung                      *
*---------------------------------------------------------------------*
FORM FCODE_WEUE.
  DATA: FW_POSNR(5).

  PERFORM XLIPS_DETAIL(SAPFV50P).
* Wenn keine Position selektiert wurde, sitzt Fcode_gleiche_Seite
  IF FCODE NE FCODE_GLEICHE_SEITE.
    IF LIPS-VGBEL IS INITIAL OR
       LIPS-VGTYP NE CHARV.
      MESSAGE S614.
      FCODE = FCODE_GLEICHE_SEITE.
      PERFORM FCODE_BEARBEITEN.
    ELSE.
      SET PARAMETER ID 'BES' FIELD LIPS-VGBEL.
      FW_POSNR = LIPS-VGPOS+1(5).
      SET PARAMETER ID 'BSP' FIELD FW_POSNR.
    ENDIF.
  ENDIF.


ENDFORM.