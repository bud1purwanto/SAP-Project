***INCLUDE MV45AF0P_PH_VTEXT_GET .
*---------------------------------------------------------------------*
*       FORM PH_VTEXT_GET                                             *
*---------------------------------------------------------------------*
*       Produkthierarchietext besorgen                                *
*---------------------------------------------------------------------*
FORM PH_VTEXT_GET USING US_PRODH
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_PRODH NE XDISP_T179-PRODH.

  IF US_PRODH = SPACE.
    CLEAR: PH_VTEXT, XDISP_T179-PRODH.
    EXIT.
  ENDIF.

  REFRESH: XDISP_T179.
  CLEAR:   XDISP_T179.
  XDISP_T179-MANDT = SY-MANDT.
  XDISP_T179-PRODH = US_PRODH.

  APPEND XDISP_T179.

  CALL FUNCTION 'RV_PRODUKTHIERARCHIE_TEXT_GET'
       EXPORTING
            SPRAS     = SY-LANGU
       TABLES
            DISP_T179 = XDISP_T179
       EXCEPTIONS
            OTHERS    = 1.

  IF SY-SUBRC NE 0.
    CLEAR: PH_VTEXT.
    IF US_ERROR NE SPACE.
      MESSAGE E412 WITH US_PRODH.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ELSE.
    PH_VTEXT = XDISP_T179-VTEXT.
  ENDIF.

ENDFORM.