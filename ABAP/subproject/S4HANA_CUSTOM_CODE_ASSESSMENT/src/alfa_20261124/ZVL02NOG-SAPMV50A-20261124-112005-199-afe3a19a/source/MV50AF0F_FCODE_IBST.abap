***INCLUDE MV50AF0F_FCODE_IBST .
*---------------------------------------------------------------------*
*       FORM FCODE_IBST                                               *
*---------------------------------------------------------------------*
*       Anzeige Bestände zum Material                                 *
*---------------------------------------------------------------------*
FORM FCODE_IBST.

*  IF LIPS-MATNR IS INITIAL.
*    MESSAGE S043.
*    FCODE = FCODE_GLEICHE_SEITE.
*    PERFORM FCODE_BEARBEITEN.
*  ELSE.
    PERFORM XLIPS_DETAIL(SAPFV50P).
    GET PARAMETER ID 'BST' FIELD MMBEVER.
    SET PARAMETER ID 'VNR' FIELD MMBEVER.
    SET PARAMETER ID 'MAT' FIELD LIPS-MATNR.
    SET PARAMETER ID 'WRK' FIELD LIPS-WERKS.
    IF NOT LIPS-LGORT IS INITIAL.
      SET PARAMETER ID 'LAG' FIELD LIPS-LGORT.
    ENDIF.
    IF NOT LIPS-CHARG IS INITIAL.
      SET PARAMETER ID 'CHA' FIELD LIPS-CHARG.
    ENDIF.
*  ENDIF.

ENDFORM.


