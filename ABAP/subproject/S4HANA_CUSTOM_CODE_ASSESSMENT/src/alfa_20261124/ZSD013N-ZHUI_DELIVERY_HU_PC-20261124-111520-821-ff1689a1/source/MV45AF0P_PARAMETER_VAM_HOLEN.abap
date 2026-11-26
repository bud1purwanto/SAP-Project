*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PARAMETER_VAM_HOLEN                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PARAMETER_VAM_HOLEN
*&---------------------------------------------------------------------*
*       den SPA/GPA Parameter VMU die Merkmalsübersicht holen
*----------------------------------------------------------------------*
FORM parameter_vam_holen.

  STATICS: st_first_run.

ENHANCEMENT-POINT PARAMETER_VAM_HOLEN_01 SPOTS ES_SAPMV45A.
  CHECK st_first_run IS INITIAL.
  st_first_run = charx.
  CHECK rv45a-muebs IS INITIAL.

ENHANCEMENT-SECTION     PARAMETER_VAM_HOLEN_02 SPOTS ES_SAPMV45A.
  GET PARAMETER ID 'VAM' FIELD rv45a-muebs.
END-ENHANCEMENT-SECTION.

  IF NOT rv45a-muebs IS INITIAL.
    PERFORM rv45a-muebs_lesen USING    space
                              CHANGING sy-subrc.
  ENDIF.
ENDFORM.                               " PARAMETER_VAM_HOLEN