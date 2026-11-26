*----------------------------------------------------------------------*
*       FORM   TEXT_PARAMETER                                          *
*----------------------------------------------------------------------*
*       Die Parameter für die Verarbeitung mit MB03 bzw. ME23          *
*       werden gefüllt.                                                *
*       Routine wird in den Nachrichtenarten MLGR/MLMD/MLFH gesetzt.   *
*----------------------------------------------------------------------*
FORM TEXT_PARAMETER USING FELDNAME FELDWERT
                          PNAST STRUCTURE NAST.
  CASE FELDNAME.
* für MB03
    WHEN 'RM07M-MBLNR'.
      MOVE XMSEG-MBLNR TO FELDWERT.
    WHEN 'RM07M-MJAHR'.
      MOVE XMSEG-MJAHR TO FELDWERT.
* für ME23
    WHEN 'RM06E-BSTNR'.
      MOVE XMSEG-EBELN TO FELDWERT.
* für CO06
    WHEN 'CAUFVD-MATNR'.
      GET PARAMETER ID 'MAT' FIELD FELDWERT.
    WHEN 'CAUFVD-WERKS'.
      GET PARAMETER ID 'WRK' FIELD FELDWERT.
    WHEN 'CAUFVD-PRREG'.
      GET PARAMETER ID 'PRR' FIELD FELDWERT.
  ENDCASE.
ENDFORM.