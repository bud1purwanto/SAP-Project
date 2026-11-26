*---------------------------------------------------------------------*
*       FORM FCODE_ANLE                                               *
*---------------------------------------------------------------------*
*       Umsetzen des FCodes ANLE in den jeweiligen Transaktionscode   *
*---------------------------------------------------------------------*
FORM FCODE_ANLE.

  DATA: DA_TCODE LIKE SY-TCODE.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

ENHANCEMENT-SECTION     FCODE_ANLE_01 SPOTS ES_SAPMV45A.
  DA_TCODE = SY-TCODE.
  DA_TCODE+3(1) = CHAR1.
END-ENHANCEMENT-SECTION.
  LEAVE TO TRANSACTION DA_TCODE.

ENDFORM.