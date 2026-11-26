*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PREPARE_DEADLINE_SCRE                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PREPARE_DEADLINE_SCREEN
*&---------------------------------------------------------------------*
form prepare_deadline_screen.

  data: lf_display type c.

  if t180-trtyp eq chara or
     likp-vbtyp eq vbtyp_mmli.                                "SPE
    lf_display = 'X'.
  else.
    lf_display = ' '.
  endif.
* Determine template
  if likp-tsegtp is initial.                                  "HP_208584
    perform tvlk_select using likp-lfart space sy-subrc.
    likp-tsegtp = tvlk-tsegtp.
  endif.

* Get GUID if not existing yet
  if likp-handle is initial.                                  "HP_210935
    call function 'GUID_CREATE'
         importing
              ev_guid_22 = likp-handle.
  endif.

* Fill header with time zones if not yet existing
  if likp-tzonis is initial or                                "HP_210935
     likp-tzonrc is initial.
    perform likp_fuellen_time_zones(sapfv50k).
  endif.

  if v50agl-deadline_init eq space.
    call function 'SD_DEADLINE_PREPARE'
         exporting
              i_deadline_no    = likp-ternr
              i_handle         = likp-handle
              i_ddl_exist      = likp-tsegfl
              i_docnum         = likp-vbeln
              i_table_appl     = 'LIKP'
              opt_display      = lf_display
         importing
              e_deadline_no    = likp-ternr
*             E_HANDLE         =
              e_ddl_exist      = likp-tsegfl
         changing
              obj_wa           = likp
         exceptions
              invalid_tcode    = 1
              no_deadlines     = 2
              app_anchor_error = 3
              tseg_cust_error  = 4
              others           = 5
              .
    if sy-subrc eq 0.
      v50agl-deadline_init = charx.
    endif.
  endif.

  call function 'SD_DEADLINE_PBO_INTERFACE'
       exporting
            opt_display = lf_display
       exceptions
            fatal_error = 1
            others      = 2.
  if sy-subrc ne 0.
    clear v50agl-deadline_init.
  endif.

* If the deadline screen can not be initialized correctly an empty dummy
* screen must be sent
  if v50agl-deadline_init eq space.
    gf_deadline_program = 'SAPMV50A'.
    gf_deadline_screen  = '2900'.
    message s001(vlt).
  else.
    gf_deadline_program = 'SAPLTSED'.
    gf_deadline_screen  = '0100'.
  endif.

endform.                               " PREPARE_DEADLINE_SCREEN