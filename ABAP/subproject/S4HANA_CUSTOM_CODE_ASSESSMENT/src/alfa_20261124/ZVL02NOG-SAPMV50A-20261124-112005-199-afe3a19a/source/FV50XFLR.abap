*----------------------------------------------------------------------*
*   INCLUDE FV50XFLR                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  LR_REFERENCE_DATA_REFRESH
*&---------------------------------------------------------------------*
FORM LR_REFERENCE_DATA_REFRESH.

  CHECK AUFRUFER NE CHART.
  CALL FUNCTION 'SHP_LIPSRF_REFRESH'.
  CALL FUNCTION 'SHP_LIPSPO_REFRESH'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LR_REFERENCE_DATA_UPDATEH
*&---------------------------------------------------------------------*
FORM LR_REFERENCE_DATA_UPDATE.

  CHECK AUFRUFER NE CHART.
  CALL FUNCTION 'SHP_LIPSRF_UPDATE'
       EXPORTING
            IF_SYNCHRON   = V50AGL-SYNCHRON.
  CALL FUNCTION 'SHP_LIPSPO_UPDATE'
       EXPORTING
            IF_SYNCHRON   = V50AGL-SYNCHRON.

ENDFORM.