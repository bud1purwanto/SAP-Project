***INCLUDE MV50AF0F_FCODE_KTAN .
*---------------------------------------------------------------------*
*       FORM FCODE_KTAN                                               *
*---------------------------------------------------------------------*
*       Analyse Kopftextbild                                          *
*---------------------------------------------------------------------*
FORM FCODE_KTAN.
* to analyse the textprocessing the communication-WA has to be filled
  PERFORM LIKP_FUELLEN_TEXTE_SIMUL.
  PERFORM RV_TEXT_COPY_SIMUL.
ENDFORM.