*----------------------------------------------------------------------*
*   INCLUDE FV50XFDF                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  DLFLD_REFRESH
*&---------------------------------------------------------------------*
FORM DLFLD_REFRESH.

  CHECK AUFRUFER NE CHART.
  CALL FUNCTION 'SHP_DLFLD_REFRESH'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DLFLD_UPDATE
*&---------------------------------------------------------------------*
FORM DLFLD_UPDATE.

  CHECK AUFRUFER NE CHART.
  CALL FUNCTION 'SHP_DLFLD_UPDATE'
       EXPORTING
            IF_SYNCHRON   = V50AGL-SYNCHRON.

ENDFORM.