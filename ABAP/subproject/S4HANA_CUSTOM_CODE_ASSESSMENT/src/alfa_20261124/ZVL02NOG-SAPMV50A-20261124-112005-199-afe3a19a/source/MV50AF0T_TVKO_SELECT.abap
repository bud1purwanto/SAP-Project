*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVKO_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVKO_SELECT                                              *
*---------------------------------------------------------------------*
*       Verkaufsorganisation und zugehörigen Text lesen               *
*---------------------------------------------------------------------*
form tvko_select using ts_vkorg like tvko-vkorg
                       ts_error type c
                       ts_subrc like sy-subrc.

  ts_subrc = 0.
  check: ts_vkorg ne tvko-vkorg or
         tvko-adrnr ne tvko_sadr-adrnr.                     "n_636211

  if ts_vkorg eq space.
    clear: tvko, tvkot.
    clear tvko_sadr.
    exit.
  endif.

  select single * from tvko where vkorg eq ts_vkorg.
  if sy-subrc ne 0.
    clear: tvko, tvkot.
    clear tvko_sadr.
    if ts_error ne space.
      message e313 with ts_vkorg.
    else.
      ts_subrc = 4.
      exit.
    endif.
  endif.

  select single * from tvkot where spras eq sy-langu
                               and vkorg eq ts_vkorg.
  if sy-subrc ne 0.
    ts_subrc = 0.
    clear: tvkot.
  endif.

* Adresse dazulesen
  if not tvko-adrnr is initial.                             "SADR40A
    address_selection-addrnumber = tvko-adrnr.              "SADR40A
    address_selection-nation     = ' '.
    call function 'ADDR_GET'
      exporting
        address_selection = address_selection
        address_group     = 'CA01'
      importing
        sadr              = tvko_sadr
      exceptions
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        others            = 5.
    if sy-subrc ne 0.
      ts_subrc = 0.
      clear tvko_sadr.
      tvko_sadr-adrnr = tvko-adrnr.                         "n_636211
    endif.
  endif.

endform.                    "TVKO_SELECT
*eject