*---------------------------------------------------------------------*
*       FORM TSTL_SELECT                                              *
*---------------------------------------------------------------------*
*       Steuertypen pro Land lesen                                    *
*---------------------------------------------------------------------*
FORM TSTL_SELECT USING US_TALND
                       US_LFDNR
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_TALND NE TSTL-TALND OR
         US_LFDNR NE TSTL-LFDNR.

  IF US_TALND = SPACE.
    CLEAR: TSTL.
    EXIT.
  ENDIF.


  SELECT SINGLE * FROM TSTL WHERE TALND = US_TALND
                              AND LFDNR = US_LFDNR.
  IF SY-SUBRC NE 0.
    CLEAR: TSTL.
    IF US_ERROR NE SPACE.
      MESSAGE E088 WITH US_TALND US_LFDNR.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.