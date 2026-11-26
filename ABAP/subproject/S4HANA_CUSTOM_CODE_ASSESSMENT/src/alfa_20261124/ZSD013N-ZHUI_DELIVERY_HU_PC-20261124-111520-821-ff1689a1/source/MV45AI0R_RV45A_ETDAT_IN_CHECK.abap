*&---------------------------------------------------------------------*
*&  Include           MV45AI0R_RV45A_ETDAT_IN_CHECK                    *
*&---------------------------------------------------------------------*
module rv45a_etdat_in_check.

  data: da_etdat like vbep-edatu,
        da_prgbz like vbep-prgrs.

  if not rv45a-etdat is initial and
     not rv45a-prgbz is initial.
    call function 'PERIOD_AND_DATE_CONVERT_INPUT'
         exporting
              dialog_date_is_in_the_past = space
              external_date              = rv45a-etdat
              external_period            = rv45a-prgbz
         importing
              internal_date              = da_etdat
              internal_period            = da_prgbz
         exceptions
              no_data                    = 1
              period_invalid             = 2
              date_invalid               = 3.
    case sy-subrc.
      when 1.
        set cursor field 'RV45A-PRGBZ' line sy-stepl.
        message e394.
      when 2.
        set cursor field 'RV45A-PRGBZ' line sy-stepl.
        message e346 with rv45a-prgbz.
      when 3.
        set cursor field 'RV45A-PRGBZ' line sy-stepl.
        message e345 with rv45a-etdat rv45a-prgbz.
    endcase.
  endif.

endmodule.