*---------------------------------------------------------------------*
*       FORM FCODE_IAEN                                               *
*---------------------------------------------------------------------*
*       Anzeige Belegänderungen                                       *
*---------------------------------------------------------------------*
FORM FCODE_IAEN.

  SET PARAMETER ID 'CDO' FIELD 'VERKBELEG'.
  SET PARAMETER ID 'CDI' FIELD VBAK-VBELN.
  SET PARAMETER ID 'VBELN4CD' FIELD VBAK-VBELN.

ENDFORM.