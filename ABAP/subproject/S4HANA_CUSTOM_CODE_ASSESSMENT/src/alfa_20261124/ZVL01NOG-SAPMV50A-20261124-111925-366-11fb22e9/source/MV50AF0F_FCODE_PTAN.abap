***INCLUDE MV50AF0F_FCODE_PTAN .
*---------------------------------------------------------------------*
*       FORM FCODE_PTAN                                               *
*---------------------------------------------------------------------*
*       Analyse Positionstextbild                                     *
*---------------------------------------------------------------------*
FORM FCODE_PTAN.
* to analyse the textprocessing the communication-WA has to be filled
  PERFORM LIPS_FUELLEN_TEXTE_SIMUL.
  PERFORM RV_TEXT_COPY_SIMUL.
ENDFORM.