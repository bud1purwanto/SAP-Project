*eject
*---------------------------------------------------------------------*
*       FORM KUNDENAUFTRAGSPRUEFUNG                                   *
*---------------------------------------------------------------------*
*       Kundenauftrag prüfen.                                         *
*---------------------------------------------------------------------*
form kundenauftragspruefung using k_kdauf like  mseg-kdauf
                                  k_kdpos like  mseg-kdpos
                                  k_kdein like  mseg-kdein
                                  k_vbtyp like vm07m-vbtyp
                                  k_matnr like  mseg-matnr
                                  k_sobkz like  mseg-sobkz
                         changing k_kzbws like mseg-kzbws
                                  k_cuobj like dm07m-cuobj
                                  k_kzvbr like dm07m-umkzvbr.

  data: temp-cuobj like dm07m-cuobj,
        temp-matnr like mseg-matnr,
        l_sobkz    like mseg-sobkz,
        rc         like  sy-subrc.
  clear: temp-matnr, temp-cuobj.

  call function 'SD_DOCUMENT_ACCOUNT_ASSIGNMENT'
       exporting
            i_document_number     = k_kdauf
            i_item_number         = k_kdpos
            i_schedule_line       = k_kdein
            i_sales_document_type = k_vbtyp
       importing
            e_cuobj               = temp-cuobj
            e_material            = temp-matnr
            e_sobkz               = l_sobkz
            e_kzbws               = k_kzbws
            e_kzvbr               = k_kzvbr.

  if l_sobkz is initial and not k_sobkz is initial.         "457901
    if not k_kdauf is initial and not k_kdpos is initial.   "457901
      CALL FUNCTION 'MB_CHECK_T160M'                        "457901
           EXPORTING                                        "457901
              I_ARBGB          = 'M7'                       "457901
              I_msgnr          = '374'                      "457901
              I_MSGV1          = l_sobkz                    "457901
              I_MSGV2          = k_sobkz                    "457901
              I_OUTPUT         = 'X'.                       "457901
    endif.                                                  "457901
  endif.
  if not temp-cuobj is initial and temp-matnr = k_matnr.
    k_cuobj = temp-cuobj.
  endif.

endform.