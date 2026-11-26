*---------------------------------------------------------------------*
*       FORM TVAP_SELECT                                              *
*---------------------------------------------------------------------*
*       Auftragspositionstypentabelle mit Texttabelle lesen           *
*---------------------------------------------------------------------*
FORM TVAP_SELECT USING US_PSTYV
                       US_ERROR
                       CH_SUBRC.

  IF US_ERROR IS INITIAL.
    CALL FUNCTION 'SD_TVAP_SELECT'
         EXPORTING
              I_PSTYV   = US_PSTYV
         IMPORTING
              E_TVAP    = TVAP
         EXCEPTIONS
              NOT_FOUND = 01.
    CH_SUBRC = SY-SUBRC.
  ELSE.
    CALL FUNCTION 'SD_TVAP_SELECT'
         EXPORTING
              I_PSTYV = US_PSTYV
         IMPORTING
              E_TVAP  = TVAP.
  ENDIF.
ENHANCEMENT-POINT TVAP_SELECT_10 SPOTS ES_SAPMV45A.
ENDFORM.