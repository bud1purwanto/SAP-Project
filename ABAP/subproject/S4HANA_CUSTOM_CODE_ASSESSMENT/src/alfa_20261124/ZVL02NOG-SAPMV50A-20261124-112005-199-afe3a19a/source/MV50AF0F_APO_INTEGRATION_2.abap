*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_APO_INTEGRATION_2                                 *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_LEAVE_WITH_APO                                     *
*---------------------------------------------------------------------*
*       Eventuell vorhandene Delta-Sätze im APO-Server abbauen        *
*---------------------------------------------------------------------*
FORM NMODUL_FOR_TCODE_APO.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM FCODE_LEAVE_WITH_APO                                     *
*---------------------------------------------------------------------*
*       Eventuell vorhandene Delta-Sätze im APO-Server abbauen        *
*---------------------------------------------------------------------*
FORM FCODE_LEAVE_WITH_APO.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

* Folgebildsteuerung
  PERFORM FCODE_LEAVE(SAPLV00F).

ENDFORM.
*eject
*&---------------------------------------------------------------------*
*&      Form  LEAVE_TO_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM LEAVE_TO_TRANSACTION USING  PF_TCODE LIKE SY-TCODE.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

  LEAVE TO TRANSACTION PF_TCODE.

ENDFORM.                    " LEAVE_TO_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  LEAVE_
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM LEAVE_.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

  LEAVE.

ENDFORM.                    " LEAVE_TO_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  LEAVE_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM LEAVE_SCREEN.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

  LEAVE SCREEN.

ENDFORM.                    " LEAVE_TO_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  set_screen_0_leave_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM SET_SCREEN_0_LEAVE_SCREEN.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

  SET SCREEN 0.
  LEAVE SCREEN.

ENDFORM.                    " LEAVE_TO_TRANSACTION