*----------------------------------------------------------------------*
*   INCLUDE MV45AF0B_BERECHTIGUNG_TRANS                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORITY_TRANS
*&---------------------------------------------------------------------*
*       Berechtigungsprüfung für CALL TRANSACTION
*----------------------------------------------------------------------*
FORM CHECK_AUTHORITY_TRANS USING US_TCODE LIKE SY-TCODE
                           CHANGING CH_SUBRC LIKE SY-SUBRC.

  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
       EXPORTING
            TCODE  = US_TCODE
       EXCEPTIONS
            OK     = 0
            NOT_OK = 1
            OTHERS = 2.

  CH_SUBRC = SY-SUBRC.

ENDFORM.                               " CHECK_AUTHORITY_TRANS
