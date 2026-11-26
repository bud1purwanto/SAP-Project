*eject
*---------------------------------------------------------------------*
*       FORM TVKO_SELECT                                              *
*---------------------------------------------------------------------*
*       Verkaufsorganisation und zugehörigen Buchungskreis lesen      *
*       und zugehörige Adresse lesen                                  *
*---------------------------------------------------------------------*
FORM TVKO_SELECT USING US_VKORG
                       US_ERROR
                       CH_SUBRC.

  DATA: DA_BUKRS LIKE T001-BUKRS.
  CH_SUBRC = 0.

  IF US_VKORG = SPACE.
    CLEAR: TVKO, TVKOT,TVKO_SADR.
    EXIT.
  ENDIF.

  IF US_VKORG NE TVKO-VKORG.
    SELECT SINGLE * FROM TVKO WHERE VKORG = US_VKORG.
    IF SY-SUBRC NE 0.
      CLEAR: TVKO, TVKOT.
      IF US_ERROR NE SPACE.
        MESSAGE E313 WITH US_VKORG.
      ELSE.
        CH_SUBRC = 4.
        EXIT.
      ENDIF.
    ENDIF.
*   Adresse dazulesen
    IF NOT TVKO-ADRNR IS INITIAL AND
       TVKO-ADRNR NE TVKO_SADR-ADRNR.
      CLEAR GV_FB_ADDR_GET_SELECTION.
      GV_FB_ADDR_GET_SELECTION-ADDRNUMBER = TVKO-ADRNR.         "SADR40A
      CALL FUNCTION 'ADDR_GET'
        EXPORTING
          ADDRESS_SELECTION = GV_FB_ADDR_GET_SELECTION
          ADDRESS_GROUP = 'CA01'
        IMPORTING
          SADR = TVKO_SADR
        EXCEPTIONS
          OTHERS            = 01.

      IF SY-SUBRC NE 0.
        CLEAR TVKO_SADR.
      ENDIF.
    ENDIF.
  ENDIF.

* Buchungskreis lesen
  IF VBAK-BUKRS_VF IS INITIAL.
    DA_BUKRS = TVKO-BUKRS.
  ELSE.
    DA_BUKRS = VBAK-BUKRS_VF.
  ENDIF.
ENHANCEMENT-POINT TVKO_SELECT_10 SPOTS ES_SAPMV45A.
  PERFORM T001_SELECT USING DA_BUKRS
                            US_ERROR
                            SY-SUBRC.
  RV45A-BUKRSL = T001-LAND1.
  IF SY-SUBRC NE 0.
    CH_SUBRC = SY-SUBRC.
  ENDIF.

ENDFORM.