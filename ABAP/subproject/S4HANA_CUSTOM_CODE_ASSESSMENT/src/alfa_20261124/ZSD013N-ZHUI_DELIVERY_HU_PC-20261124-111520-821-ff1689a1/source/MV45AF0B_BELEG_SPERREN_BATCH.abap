*----------------------------------------------------------------------*
*   INCLUDE MV45AF0B_BELEG_SPERREN_BATCH                               *
*----------------------------------------------------------------------*
FORM BELEG_SPERREN_BATCH USING US_OBJECT.
  IF US_OBJECT EQ 'VBAK' AND CALL_BAPI_SIMULATION_MODE IS INITIAL.
    CALL FUNCTION 'ENQUEUE_EVVBAKE'
         EXPORTING
              MODE_VBAK = CHARS
              VBELN     = con_enqueue_batch
         EXCEPTIONS
                FOREIGN_LOCK.
    if sy-subrc ne 0.
      message a120(v2).
    endif.
  ENDIF.
ENDFORM.