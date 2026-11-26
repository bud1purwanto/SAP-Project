*eject
*---------------------------------------------------------------------*
*       FORM KUNDENAUFTRAG_PRUEFEN                                    *
*---------------------------------------------------------------------*
*       Kundenauftrag prüfen.                                         *
*---------------------------------------------------------------------*
form kundenauftrag_pruefen.

  data: l_kdauf type mseg-kdauf,                               " 607325
        l_kdpos type mseg-kdpos,                               " 607325
        l_kzbws type mseg-kzbws,                               "1472888
        ls_mssa like xmssa.                                    "1472888
* The EHP604 condition variable has no effect for the core code
* conditions, it's value changes only in the switched code. This
* usage makes possible to avoid enh. sections.
  DATA: EHP604_KUNDENAUFTRAG_PRUEFE_01 VALUE space.           "DT071219

  if fcausw-xlist is initial.

ENHANCEMENT-POINT EHP604_KUNDENAUFTRAG_PRUEFE_01 SPOTS ES_SAPMM07M.
    if mseg-sobkz = e OR
       EHP604_KUNDENAUFTRAG_PRUEFE_01 IS NOT INITIAL.         "DT071219
      l_kzbws = mseg-kzbws.                                    "1472888
      perform kundenauftragspruefung using mseg-mat_kdauf
                                           mseg-mat_kdpos
                                           mseg-kdein
                                          vm07m-vbtyp
                                           mseg-matnr
                                           mseg-sobkz       "457901
                                 changing  mseg-kzbws
                                           dm07m-cuobj
                                           dm07m-umkzvbr.
    endif.
* begin of note 1472888
      read table xmssa into ls_mssa with key matnr = mseg-matnr
                                                  werks = mseg-werks
                                                  sobkz = mseg-sobkz
                                                  vbeln = mseg-mat_kdauf
                                                  posnr = mseg-mat_kdpos.
     if sy-subrc = 0 and ls_mssa-rmssa is initial
        and l_kzbws <> mseg-kzbws.
         "only in case of the material master already exists
         "take the kzbws from material master and not from SD
         mseg-kzbws = ls_mssa-kzbws.
     endif.
*end of note  1472888
ENHANCEMENT-POINT EHP604_KUNDENAUFTRAG_PRUEFE_02 SPOTS ES_SAPMM07M.
    if mseg-umsok = e OR
       EHP604_KUNDENAUFTRAG_PRUEFE_01 IS NOT INITIAL.         "DT071219
* note 607325: logic, for which sales order the check has to be done is
* taken over from UMLAGERUNG_PRUEFEN.
      if xmigo = x.                                            " 607325
*     MIGO fills KDAUF/ KDPOS for receiving side -> use those
        l_kdauf = mseg-kdauf.                                  " 607325
        l_kdpos = mseg-kdpos.                                  " 607325
      elseif dm07m-fausw+60(1) = minus or                      " 607325
             mseg-kdauf is initial.                            " 607325
*     2 possibilities when MSEG-MAT_KDAUF has to be used for the
*     receiving side:
*     1. movement type does not allow to enter a sales order for the
*     receiving side -> receiving and issuing order are the same
*     2. field KDAUF can be entered but there is no entry
        l_kdauf = mseg-mat_kdauf.                              " 607325
        l_kdpos = mseg-mat_kdpos.                              " 607325
      else.                                                    " 607325
        l_kdauf = mseg-kdauf.                                  " 607325
        l_kdpos = mseg-kdpos.                                  " 607325
      endif.                                                   " 607325

      perform kundenauftragspruefung using    l_kdauf          " 607325
                                              l_kdpos          " 607325
                                           mseg-kdein
                                          vm07m-vbtyp
                                           mseg-matnr
                                           mseg-umsok       "457901
                                 changing dm07m-umkzbws
                                          dm07m-ucuob
                                          dm07m-umkzvbr.
      dm07m-setkzbws = x.
    endif.

  else.
    perform kundenauftragspruefung using msegk-mat_kdauf
                                         msegk-mat_kdpos
                                         msegk-kdein
                                         vm07m-vbtyp
                                         mseg-matnr
                                         msegk-sobkz        "457901
                                changing msegk-kzbws
                                         dm07m-cuobj
                                         dm07m-umkzvbr.
  endif.

endform.