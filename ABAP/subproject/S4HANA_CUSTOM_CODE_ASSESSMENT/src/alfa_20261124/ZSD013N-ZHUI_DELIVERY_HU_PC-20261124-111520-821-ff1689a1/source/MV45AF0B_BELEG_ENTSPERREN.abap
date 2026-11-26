*eject
*---------------------------------------------------------------------*
*       FORM BELEG_ENTSPERREN                                         *
*---------------------------------------------------------------------*
*       Der Beleg wird komplett entsperrt                             *
*---------------------------------------------------------------------*
FORM BELEG_ENTSPERREN USING US_VBELN.

  CHECK: T180-TRTYP NE CHARA,
         NOT US_VBELN IS INITIAL.

  CALL FUNCTION 'DEQUEUE_EVVBAKE'
       EXPORTING
            VBELN = US_VBELN.

ENDFORM.