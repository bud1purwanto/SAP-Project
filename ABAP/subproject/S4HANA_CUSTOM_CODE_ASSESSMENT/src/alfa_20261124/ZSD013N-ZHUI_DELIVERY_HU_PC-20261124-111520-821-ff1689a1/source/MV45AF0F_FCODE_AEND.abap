*---------------------------------------------------------------------*
*       FORM FCODE_AEND                                               *
*---------------------------------------------------------------------*
*       Umsetzen des FCodes AEND in den jeweiligen Transaktionscode   *
*---------------------------------------------------------------------*
FORM FCODE_AEND.

  DATA: DA_TCODE LIKE SY-TCODE,
        DA_AUTHORITY_SUBRC LIKE SY-SUBRC.

ENHANCEMENT-SECTION     FCODE_AEND_01 SPOTS ES_SAPMV45A.
  DA_TCODE(3) = SY-TCODE.
  DA_TCODE+3(1) = CHAR2.
END-ENHANCEMENT-SECTION.

* Berechtigung pruefen
  PERFORM CHECK_AUTHORITY_TRANS USING DA_TCODE
                                CHANGING DA_AUTHORITY_SUBRC.

  IF DA_AUTHORITY_SUBRC EQ 0.
*   APO-Deltasätze löschen
    CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
         EXCEPTIONS
              OTHERS  = 1.
    IF SY-CALLD IS INITIAL.
      LEAVE TO TRANSACTION DA_TCODE.
    ELSE.
      CALL TRANSACTION DA_TCODE  AND SKIP FIRST SCREEN.
      LEAVE.
    ENDIF.
  ELSE.
    MESSAGE I001(V10) WITH DA_TCODE.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
  ENDIF.

ENDFORM.