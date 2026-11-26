*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PROCESS_DEADLINE_SCRE                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DEADLINE_SCREEN
*&---------------------------------------------------------------------*
form process_deadline_screen.

  data: lf_change_flag type c.

* Translate FCODEs for leafing
  case fcode.
    when 'FPAG_T'.
      fcode = 'TSEG_P--'.
    when 'PPAG_T'.
      fcode = 'TSEG_P-'.
    when 'NPAG_T'.
      fcode = 'TSEG_P+'.
    when 'LPAG_T'.
      fcode = 'TSEG_P++'.
  endcase.

  call function 'SD_DEADLINE_PAI_INTERFACE'
       exporting
            if_event         = fcode
       importing
            ef_modif         = lf_change_flag
       exceptions
            handle_not_found = 1
            fatal_error      = 2
            others           = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
* Filter FCODES to be processed by the deadline module
  if fcode cs 'TSEG_'.                                      "HP_361216
    fcode = fcode_gleiche_seite.
  endif.

  if lf_change_flag ne space and
     r185d-dataloss is initial.
    r185d-dataloss = charx.
  endif.

endform.                               " PROCESS_DEADLINE_SCREEN