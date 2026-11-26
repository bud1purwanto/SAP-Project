*---------------------------------------------------------------------*
*       FORM FCODE_ANZE                                               *
*---------------------------------------------------------------------*
*       Umsetzen des FCodes ANZE in den jeweiligen Transaktionscode   *
*---------------------------------------------------------------------*
FORM FCODE_ANZE.

  DATA: DA_TCODE LIKE SY-TCODE.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

ENHANCEMENT-SECTION     FCODE_ANZE_01 SPOTS ES_SAPMV45A.
  DA_TCODE = SY-TCODE.
END-ENHANCEMENT-SECTION.
  DA_TCODE+3(1) = CHAR3.
  LEAVE TO TRANSACTION DA_TCODE.

ENDFORM.