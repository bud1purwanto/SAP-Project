*eject
*&---------------------------------------------------------------------*
*&      Form  FCODE_LOKN
*&---------------------------------------------------------------------*
*       Anzeige des Transportnetzes zum Auftrag
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FCODE_LOKN
                USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.
  CALL FUNCTION 'SD_GTIS_TRANSNET'
       EXPORTING
            ORDERID     = VBAK-VBELN
            MODE        = 'N'
            RETURN_MODE = 'N'
            OUTPUT_MODE = 'G'.
ENDFORM.