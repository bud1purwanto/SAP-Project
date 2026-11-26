***INCLUDE MV50AF0F_FCODE_VL71 .
*---------------------------------------------------------------------*
*       FORM FCODE_VL71                                               *
*---------------------------------------------------------------------*
*       Beleg sichern und Bearbeiten Versandnachrichten aufrufen      *
*---------------------------------------------------------------------*
FORM FCODE_VL71.

  IF R185D-DATALOSS NE SPACE.
*   siehe oben vl70
    V50AGL-SYNCHRON = 'X'.
    PERFORM SYNCHRON.
    SET PARAMETER ID 'NAC' FIELD SPACE.
    PERFORM BELEG_SICHERN USING CHARX.
  ENDIF.

*APO: safety first
  PERFORM NMODUL_FOR_TCODE_APO.

ENDFORM.