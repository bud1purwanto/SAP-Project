***INCLUDE MV50AF0F_FCODE_PTE1 .
*---------------------------------------------------------------------*
*       FORM FCODE_PTE1                                               *
*---------------------------------------------------------------------*
*       Übergang zum Positionstextbild aus Positionsbild              *
*---------------------------------------------------------------------*
FORM FCODE_PTE1.

  PERFORM XTHEAD_UEBERSICHT_P_ANSTEUERN(SAPFV45T)
                  USING TVLP-TXTGR
                        CHARL
                        LIKP-VBELN
                        XLIPS-POSNR.

ENDFORM.