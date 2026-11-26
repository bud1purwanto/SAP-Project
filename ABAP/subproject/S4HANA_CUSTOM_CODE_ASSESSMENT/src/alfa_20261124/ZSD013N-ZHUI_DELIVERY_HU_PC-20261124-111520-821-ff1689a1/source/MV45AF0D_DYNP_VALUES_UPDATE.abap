*----------------------------------------------------------------------*
*   INCLUDE MV45AF0D_DYNP_VALUES_UPDATE                                *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DYNP_VALUES_UPDATE
*&---------------------------------------------------------------------*
*       Feldtransport auf Dynpro
*----------------------------------------------------------------------*
form dynp_values_update using us_repid
                              us_dynnr
                              us_field
                              us_value
                     changing ch_subrc.

  data: da_dynpfield_tab like dynpread occurs 0 with header line,
        da_stepl like sy-stepl,
        da_repid like d020s-prog,
        da_dynnr like d020s-dnum.

  ch_subrc = 4.
  refresh da_dynpfield_tab.

  move us_repid to da_repid.
  move us_dynnr to da_dynnr.

  get cursor line da_stepl.
  move da_stepl to da_dynpfield_tab-stepl.
  move us_field to da_dynpfield_tab-fieldname.
  move us_value to da_dynpfield_tab-fieldvalue.
  append da_dynpfield_tab.

  call function 'DYNP_VALUES_UPDATE'
       exporting
            dyname               = da_repid
            dynumb               = da_dynnr
       tables
            dynpfields           = da_dynpfield_tab
       exceptions
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            undefind_error       = 7
            others               = 8.

  if sy-subrc eq 0.
    ch_subrc = 0.
  endif.

endform.                               " DYNP_VALUES_UPDATE