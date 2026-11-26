*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CHECK_TCODE_AUTHORIZA (HP_378423)       *
*&---------------------------------------------------------------------*

form check_tcode_authorization using value(if_tcode) like sy-tcode
                               changing cf_subrc like sy-subrc.

  cf_subrc = 0.

  call function 'AUTHORITY_CHECK_TCODE'
    exporting
      tcode  = if_tcode
    exceptions
      ok     = 1
      not_ok = 2
      others = 3.

  if sy-subrc gt 1.
    cf_subrc = sy-subrc.
  endif.

endform.                    "check_tcode_authorization