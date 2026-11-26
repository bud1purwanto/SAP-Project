*----------------------------------------------------------------------*
*   INCLUDE MV45AF0C_CVBKD_LESEN                                       *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CVBKD_LESEN
*&---------------------------------------------------------------------*
*       CVBKD für spezielle Position lesen
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM CVBKD_LESEN USING US_VBELN
                       US_POSNR.

  SELECT SINGLE * FROM VBKD INTO CVBKD WHERE VBELN = US_VBELN AND
                                             POSNR = US_POSNR.


  IF SY-SUBRC NE 0.
    SELECT SINGLE * FROM VBKD INTO CVBKD WHERE VBELN = US_VBELN AND
                                               POSNR = POSNR_LOW.
  ENDIF.

  IF SY-SUBRC NE 0.
    CLEAR CVBKD.
  ENDIF.

ENDFORM.                    " CVBKD_LESEN