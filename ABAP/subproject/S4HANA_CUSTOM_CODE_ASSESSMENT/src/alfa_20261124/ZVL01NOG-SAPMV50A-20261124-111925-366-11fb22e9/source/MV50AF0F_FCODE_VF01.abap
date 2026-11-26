***INCLUDE MV50AF0F_FCODE_VF01 .
*---------------------------------------------------------------------*
*       FORM FCODE_VF01                                               *
*---------------------------------------------------------------------*
*       Beleg sichern und Fakturierung aufrufen                       *
*---------------------------------------------------------------------*
FORM FCODE_VF01.

  IF R185D-DATALOSS NE SPACE.
    PERFORM BELEG_SICHERN USING CHARX.
  ENDIF.

*APO: safety first
  PERFORM NMODUL_FOR_TCODE_APO.

ENDFORM.