*&---------------------------------------------------------------------*
*&      Form  FCODE_TILN
*&---------------------------------------------------------------------*
*       Anzeige des Transportnetzes zum Auftrag als Liste
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FCODE_TILN
                USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.
  CALL FUNCTION 'SD_GTIS_TRANSNET'
       EXPORTING
            ORDERID     = VBAK-VBELN
            MODE        = 'N'
            RETURN_MODE = 'N'
            OUTPUT_MODE = 'L'.
ENDFORM.