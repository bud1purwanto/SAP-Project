***INCLUDE FV50XF0B_APPOINTMENTS_BUCHEN .
*---------------------------------------------------------------------*
*       FORM APPOINTMENTS_BUCHEN                                      *
*---------------------------------------------------------------------*
FORM APPOINTMENTS_BUCHEN.

  IF LIKP-VBTYP CA VBTYP_MMLI AND
    T180-TRTYP = CHARV.
    IF NOT YLIKP-LGNUM IS INITIAL
       AND NOT YLIKP-LGTOR IS INITIAL
       AND NOT YLIKP-WADAT IS INITIAL.

      CALL FUNCTION 'W_APPOINTMENT_DELIVERY_CHECK'
           EXPORTING
                I_LIKP  = LIKP
                I_YLIKP = YLIKP
           EXCEPTIONS
                OTHERS  = 0.

      CALL FUNCTION 'W_APPOINTMENT_SN_UPDATE'
           EXCEPTIONS
                OTHERS = 0.
    ENDIF.
  ENDIF.

ENDFORM.