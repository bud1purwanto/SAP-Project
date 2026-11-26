***INCLUDE MV50AF0F_FCODE_DRCK .
*---------------------------------------------------------------------*
*       FORM FCODE_DRCK                                               *
*---------------------------------------------------------------------*
*       Ausgabe auf Drucker                                           *
*---------------------------------------------------------------------*
FORM fcode_drck USING us_t185f STRUCTURE t185f
                      us_t185  STRUCTURE t185
                      us_t185v STRUCTURE t185v.

  DATA: da_vbeln LIKE likp-vbeln,
        da_message_printed(1) TYPE c.

  DATA: ls_t185f LIKE t185f,
        ls_t185  LIKE t185,
        ls_t185v LIKE t185v,
        lf_subrc LIKE sy-subrc.

  ls_t185f = us_t185f.
  ls_t185  = us_t185.
  ls_t185v = us_t185v.

* Ausgabe aufrufen
  CALL FUNCTION 'RV_MESSAGE_DIALOG'
       EXPORTING
            pi_kappl              = tvlk-kappl
            pi_objky              = xobjky
            pi_kschl              = tvlk-kschl
            pi_data_from_buffer   = space
            pi_faxoutput          = charx
       IMPORTING
            message_printed       = da_message_printed
       EXCEPTIONS
            cancel                = 1
            message_not_printable = 2
            no_message            = 2
            print_error           = 3
            print_error_dial      = 9                         "n_1451524
            OTHERS                = 4.
  lf_subrc = sy-subrc.

  us_t185f = ls_t185f.
  us_t185  = ls_t185.
  us_t185v = ls_t185v.

  CASE lf_subrc.
    WHEN 0.
      IF da_message_printed EQ charx.
        MESSAGE s084.
        COMMIT WORK.
      ENDIF.
      LEAVE.
    WHEN 1.
      LEAVE.
    WHEN 2.
      MESSAGE s085.
      LEAVE.
    WHEN 3.
      MESSAGE s086.
      IF da_message_printed EQ charx.
        COMMIT WORK.
      ENDIF.
      LEAVE.
    WHEN 9.                                                 "v_n_1451524
      MESSAGE s086.
      COMMIT WORK.
      LEAVE.                                                "^_n_1451524
    WHEN OTHERS.
      MESSAGE s086.                                            "n_639113
      LEAVE.
  ENDCASE.

ENDFORM.