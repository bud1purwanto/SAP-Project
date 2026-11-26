*----------------------------------------------------------------------*
*   INCLUDE MV45AF0S_SD_WORD_PROCESSING_GE                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SD_WORD_PROCESSING_GET
*&---------------------------------------------------------------------*
form sd_word_processing_get.

  data: dataloss like r185d-dataloss.

  call function 'SD_WORD_PROCESSING_GET'
       exporting
            fi_fcode_before_return = fcode
       importing
            fe_change_flag     = dataloss
            FE_FCODE_ON_RETURN = fcode
            fet_xvbuv          = xvbuv[]
       changing
            fet_xthead         = xthead[]
       exceptions
            error_occured      = 1
            others             = 2.
  if sy-subrc <> 0.
    message id sy-msgid type chari number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Kennzeichen Datenverlust übernehmen
  if dataloss = charx.
    r185d-dataloss = charx.
  endif.

endform.                               " SD_WORD_PROCESSING_GET