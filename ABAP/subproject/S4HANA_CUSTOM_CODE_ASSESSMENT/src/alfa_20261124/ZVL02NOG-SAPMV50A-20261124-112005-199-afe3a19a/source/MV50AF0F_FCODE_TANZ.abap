***INCLUDE MV50AF0F_FCODE_TANZ .
*---------------------------------------------------------------------*
*       FORM FCODE_TANZ                                               *
*---------------------------------------------------------------------*
*       Anzeigen Torbelegung                                          *
*---------------------------------------------------------------------*
FORM FCODE_TANZ USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  CALL FUNCTION 'W_APPOINTMENT_DISPLAY_SN'
       EXPORTING
            I_VBELN              = LIKP-VBELN
            I_VBTYP              = LIKP-VBTYP
       EXCEPTIONS
            NO_APPOINTMENT_FOUND = 1
            OTHERS               = 2.
  IF SY-SUBRC NE 0.
    MESSAGE I164(W#) WITH LIKP-VBELN.
  ENDIF.
ENDFORM.