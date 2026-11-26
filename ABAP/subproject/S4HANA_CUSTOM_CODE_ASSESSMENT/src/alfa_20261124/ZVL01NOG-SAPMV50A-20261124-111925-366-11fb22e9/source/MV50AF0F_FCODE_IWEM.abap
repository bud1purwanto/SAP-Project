***INCLUDE MV50AF0F_FCODE_IWEM .
*---------------------------------------------------------------------*
*       FORM FCODE_IWEM                                               *
*---------------------------------------------------------------------*
*       Anzeige Warenempfänger                                        *
*---------------------------------------------------------------------*
FORM FCODE_IWEM.

  DATA: AUSWAHL(80) VALUE '110120315330340'.

  SET PARAMETER ID 'KUN' FIELD KUWEV-KUNNR.
  SET PARAMETER ID 'VKO' FIELD LIKP-VKORG.
  SET PARAMETER ID 'VTW' FIELD RV50A-VTWEG.
  SET PARAMETER ID 'SPA' FIELD RV50A-SPART.
  SET PARAMETER ID 'DDY' FIELD AUSWAHL.

ENDFORM.