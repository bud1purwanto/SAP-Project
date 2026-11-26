***INCLUDE MV50AF0F_FCODE_VA05 .
*---------------------------------------------------------------------*
*       FORM FCODE_VA05                                               *
*---------------------------------------------------------------------*
*       Umsetzen des FCodes VA05 in den jeweiligen Transaktionscode   *
*---------------------------------------------------------------------*
FORM FCODE_VA05.

  DATA: DA_TCODE LIKE SY-TCODE.
  SET PARAMETER ID 'VAG' FIELD KUWEV-KUNNR.
  SET PARAMETER ID 'PAR' FIELD 'AG'.
  SET PARAMETER ID 'VKO' FIELD LIKP-VKORG.

ENDFORM.