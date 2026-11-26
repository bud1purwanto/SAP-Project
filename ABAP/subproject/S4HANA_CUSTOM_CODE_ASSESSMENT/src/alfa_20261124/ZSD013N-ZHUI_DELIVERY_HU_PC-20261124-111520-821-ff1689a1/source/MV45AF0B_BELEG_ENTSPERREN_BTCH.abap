*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_BELEG_ENTSPERREN_BTCH                   *
*&---------------------------------------------------------------------*
FORM BELEG_ENTSPERREN_BTCH USING US_VBELN.

  CHECK: T180-TRTYP EQ CHARV,
         NOT US_VBELN IS INITIAL.

  CALL FUNCTION 'DEQUEUE_EVVBAKE'
         EXPORTING
              MODE_VBAK = CHARS
              VBELN     = con_enqueue_batch.

ENDFORM.