***INCLUDE MV50AF0F_FCODE_VL05 .
*---------------------------------------------------------------------*
*       FORM FCODE_VL05                                               *
*---------------------------------------------------------------------*
FORM FCODE_VL05.

  DATA: DA_TCODE LIKE SY-TCODE.
  SET PARAMETER ID 'VAG' FIELD KUWEV-KUNNR.
  SET PARAMETER ID 'VKO' FIELD LIKP-VKORG.
  SET PARAMETER ID 'VST' FIELD LIKP-VSTEL.
  SET PARAMETER ID 'LAV' FIELD 'WE'.

ENDFORM.