***INCLUDE MV50AF0F_FCODE_LOKN .
*---------------------------------------------------------------------*
*       FORM FCODE_LOKN                                               *
*---------------------------------------------------------------------*
*       Transportkette - Transportnetz anzeigen                    *
*---------------------------------------------------------------------*
*  -->  US_T185F                                                      *
*  -->  US_T185                                                       *
*  -->  US_T185V                                                      *
*---------------------------------------------------------------------*
FORM FCODE_LOKN
                USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.
  CALL FUNCTION 'SD_GTIS_TRANSNET'
       EXPORTING
            DELIVID     = LIKP-VBELN
            MODE        = 'N'
            RETURN_MODE = 'N'
            OUTPUT_MODE = 'G'.
ENDFORM.