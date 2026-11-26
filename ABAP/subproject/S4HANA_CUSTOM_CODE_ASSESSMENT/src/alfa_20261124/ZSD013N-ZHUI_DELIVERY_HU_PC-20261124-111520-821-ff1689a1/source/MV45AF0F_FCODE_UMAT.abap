*---------------------------------------------------------------------*
*       FORM FCODE_UMAT                                               *
*---------------------------------------------------------------------*
*       Positionsvorschlag aus Geschäft.                              *
*---------------------------------------------------------------------*
FORM FCODE_UMAT USING US_T185F US_T185 US_T185V.

* KUAGV mit Kopfsparte lesen, damit Sortimentsvorschlag auch bei
* Positionen mit abweichender Sparte erfolgt.
  PERFORM KUAGV_SELECT_XVBPA.
  SET PARAMETER ID 'VTV' FIELD SPACE.

ENHANCEMENT-POINT FCODE_UMAT_01 SPOTS ES_SAPMV45A.

  CALL FUNCTION 'RV_ITEMS_PROPOSE'
       EXPORTING
            F185F   = US_T185F
            F185    = US_T185
            F185V   = US_T185V
            F_VSORT = KUAGV-VSORT
       IMPORTING
            FVBAK   = CVBAK
            F185F   = US_T185F
            F185    = US_T185
            F185V   = US_T185V
       TABLES
            FXVBAP  = CVBAP
            FXVBPA  = CVBPA.

ENDFORM.