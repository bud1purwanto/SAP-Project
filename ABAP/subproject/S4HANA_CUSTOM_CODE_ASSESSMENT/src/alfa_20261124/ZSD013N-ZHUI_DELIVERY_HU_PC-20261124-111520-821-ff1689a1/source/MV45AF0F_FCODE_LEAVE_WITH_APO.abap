*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_LEAVE_WITH_APO                              *
*----------------------------------------------------------------------*

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