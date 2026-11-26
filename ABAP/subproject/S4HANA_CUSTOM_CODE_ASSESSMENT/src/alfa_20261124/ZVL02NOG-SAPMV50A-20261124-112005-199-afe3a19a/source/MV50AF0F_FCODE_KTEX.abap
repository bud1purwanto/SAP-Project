***INCLUDE MV50AF0F_FCODE_KTEX .
*---------------------------------------------------------------------*
*       FORM FCODE_KTEX                                               *
*---------------------------------------------------------------------*
*       Übergang zum Kopftextbild                                     *
*---------------------------------------------------------------------*
FORM FCODE_KTEX.

  PERFORM XTHEAD_UEBERSICHT_K_ANSTEUERN(SAPFV45T)
                              USING TVLK-TXTGR
                                    CHARL
                                    LIKP-VBELN.

ENDFORM.