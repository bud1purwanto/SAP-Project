*&---------------------------------------------------------------------*
*&      Form  FCODE_TRAC
*&---------------------------------------------------------------------*
*       Anzeige des Transportnetzes zum Auftrag als Liste
*----------------------------------------------------------------------*
FORM FCODE_TRAC USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.

  CALL FUNCTION 'XSI_ALV_TREE'
       EXPORTING
            I_VBTYP = VBAK-VBTYP
            I_VBELN = VBAK-VBELN.

ENDFORM.                               "FCODE_TRAC







