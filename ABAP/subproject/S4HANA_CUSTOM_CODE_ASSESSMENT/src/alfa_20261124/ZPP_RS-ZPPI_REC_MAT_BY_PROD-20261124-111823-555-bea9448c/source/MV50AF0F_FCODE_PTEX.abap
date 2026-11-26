***INCLUDE MV50AF0F_FCODE_PTEX .
*---------------------------------------------------------------------*
*       FORM FCODE_PTEX                                               *
*---------------------------------------------------------------------*
*       Übergang zum Positionstextbild                                *
*---------------------------------------------------------------------*
FORM FCODE_PTEX.
  PERFORM XLIPS_DETAIL(SAPFV50P).
  PERFORM XTHEAD_UEBERSICHT_P_ANSTEUERN(SAPFV45T)
                  USING TVLP-TXTGR
                        CHARL
                        LIKP-VBELN
                        XLIPS-POSNR.
ENDFORM.