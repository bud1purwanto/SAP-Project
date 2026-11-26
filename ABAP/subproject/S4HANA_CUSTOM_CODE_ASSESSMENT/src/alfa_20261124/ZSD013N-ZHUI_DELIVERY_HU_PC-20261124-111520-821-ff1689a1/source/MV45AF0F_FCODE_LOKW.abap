*&---------------------------------------------------------------------*
*&      Form  FCODE_LOKW
*&---------------------------------------------------------------------*
*       Anzeige des Transportweges zum Auftrag                        *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FCODE_LOKW
                USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.
  CALL FUNCTION 'SD_GTIS_TRANSNET'
       EXPORTING
            ORDERID     = VBAK-VBELN
            MODE        = 'R'
            RETURN_MODE = 'N'
            OUTPUT_MODE = 'G'.
ENDFORM.