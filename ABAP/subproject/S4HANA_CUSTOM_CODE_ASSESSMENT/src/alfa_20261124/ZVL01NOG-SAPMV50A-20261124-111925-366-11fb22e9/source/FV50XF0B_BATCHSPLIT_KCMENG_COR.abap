*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_BATCHSPLIT_KCMENG_COR                             *
*----------------------------------------------------------------------*
form batchsplit_kcmeng_correction using if_kopf_tabix like sy-tabix.

*----------------------------------------------------------------------*
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! *
* Please don't remove this 'check 1 = 2' by your own. If you have any  *
* problems concerning incorrect weights, KC-WEIGHTS or KCMENG quanties *
* feel free to contact SAP-Hotline.                                    *
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! *
*----------------------------------------------------------------------*

  check 1 = 2.



  types: begin of lips_s.
          include structure lipsvb.
  types  end of lips_s.

  types: begin of calc_s,
          kcmeng_ist like lips-kcmeng,
          kcmeng_flo_ist like lips-kcmeng_flo,
          kcmeng_soll like lips-kcmeng,
          kcmeng_flo_soll like lips-kcmeng_flo,
          kcbrgew_soll like lips-kcmeng_flo,          "LIPS-KCBRGEW,
          kcntgew_soll like lips-kcmeng_flo,          "LIPS-KCNTGEW,
          kcgewei_soll like lips-kcgewei,
          kcvolum_soll like lips-kcmeng_flo,          "LIPS-KCVOLUM,
          kcvoleh_soll like lips-kcvoleh,
          kcbrgew_ist like lips-kcbrgew,
          kcntgew_ist like lips-kcntgew,
          kcgewei_ist like lips-kcgewei,
          kcvolum_ist like lips-kcvolum,
          kcvoleh_ist like lips-kcvoleh,
          brgew_soll like lips-kcmeng_flo,            "LIPS-BRGEW,
          ntgew_soll like lips-kcmeng_flo,            "LIPS-NTGEW,
          gewei_soll like lips-gewei,
          volum_soll like lips-kcmeng_flo,            "LIPS-VOLUM,
          voleh_soll like lips-voleh,
          brgew_ist like lips-brgew,
          ntgew_ist like lips-ntgew,
          gewei_ist like lips-gewei,
          volum_ist like lips-volum,
          voleh_ist like lips-voleh,
          count_batch type i.
  types  end of calc_s.

  types: lips_t type lips_s occurs 0.
  types: calc_t type calc_s.

  data: lt_batch_lips type lips_t with header line.
  data: calc_k        type calc_t.
  data: calc_p        type calc_t.
  data: epsilon_pos   type f          value '1E-3'.
  data: epsilon_neg   type f          value '-1E-3'.
  data: result        like lips-kcmeng_flo.
  data: result_flo    like lips-kcmeng_flo.
  data: result_brg    like lips-kcmeng_flo.
  data: result_ntg    like lips-kcmeng_flo.
  data: result_vol    like lips-kcmeng_flo.
  data: nenner        type f.                             "46B
  data: zaehler       type f.                             "46B
  data: gewei_tmp     like lips-gewei.
  data: netto_soll    like lips-kcmeng_flo.               "LIPS-NTGEW.
  data: brutto_soll   like lips-kcmeng_flo.               "LIPS-NTGEW.
  data: save_header   like lips-sobkz.                      "46B
  data: no_volum      like lips-sobkz.                      "46B

*---------------------------------------------------------------------*
*       batch_struc_init                                              *
*---------------------------------------------------------------------*
  clear lt_batch_lips.
  refresh lt_batch_lips.
  clear calc_k.
  clear calc_p.
  clear: save_header, no_volum.
*---------------------------------------------------------------------*
*       save header-weights                                           *
*---------------------------------------------------------------------*
  calc_k-ntgew_ist = xlikp-ntgew.
  calc_k-brgew_ist = xlikp-btgew.
  calc_k-gewei_ist = xlikp-gewei.
  calc_k-voleh_ist = xlikp-voleh.
  calc_k-volum_ist = xlikp-volum.

*---------------------------------------------------------------------*
*       create table only filled batch split items                    *
*---------------------------------------------------------------------*

  loop at xlips  where vbeln = xlikp-vbeln and
                         xchar = 'X' and
                         xchpf = 'X' and
                         charg <> space and
                         kcmeng = 0 and
                         updkz <> updkz_delete.

    lt_batch_lips = xlips.
    append lt_batch_lips.
  endloop.


*----------------------------------------------------------------------*
*loop at xlips for all positionen exclude batch sub items              *
*----------------------------------------------------------------------*
  loop at xlips where vbeln = xlikp-vbeln and
                      uecha = space and
                      updkz <> updkz_delete.

*----------------------------------------------------------------------*
* Main item of a batch split
*----------------------------------------------------------------------*
    if    xlips-xchar     = charx and
          xlips-xchpf     = charx and
          xlips-charg  is initial and
          xlips-uecha  is initial and
          xlips-posnr < '900001'.
*----------------------------------------------------------------------*
* Initialisation main item structure
*----------------------------------------------------------------------*
      clear calc_p.
*----------------------------------------------------------------------*
* calculation of main item kcmeng for all dependend sub items          *
*----------------------------------------------------------------------*
      loop at lt_batch_lips where
                                 vbeln = xlips-vbeln and
                                 uecha = xlips-posnr and
                                 updkz <> updkz_delete.

        calc_p-kcmeng_soll = calc_p-kcmeng_soll + lt_batch_lips-lgmng.
        calc_p-kcmeng_flo_soll =
                       calc_p-kcmeng_flo_soll + lt_batch_lips-lgmng_flo.
        calc_p-count_batch = calc_p-count_batch + 1.

*----------------------------------------------------------------------*
* set weights of batch items, set kcmeng form main item
*----------------------------------------------------------------------*

* here sub_item info
        calc_p-brgew_ist       = lt_batch_lips-brgew.
        calc_p-ntgew_ist       = lt_batch_lips-ntgew.
        calc_p-gewei_ist       = lt_batch_lips-gewei.
        calc_p-volum_ist       = lt_batch_lips-volum.
        calc_p-voleh_ist       = lt_batch_lips-voleh.
* here main_item info
        calc_p-kcmeng_ist      = xlips-kcmeng.
        calc_p-kcmeng_flo_ist  = xlips-kcmeng_flo.
        calc_p-kcbrgew_ist     = xlips-kcbrgew.
        calc_p-kcntgew_ist     = xlips-kcntgew.
        calc_p-kcvolum_ist     = xlips-kcvolum.
        calc_p-kcgewei_ist     = xlips-kcgewei.
*----------------------------------------------------------------------*
* calculation of kcweights in the correct uom, sum of all sub items
*----------------------------------------------------------------------*

        if xlips-kcgewei <> lt_batch_lips-gewei and
           xlips-kcgewei <> space               and
           lt_batch_lips-gewei <> space.

*         PERFORM CONVERSION_FACTOR_GET USING XLIPS-GEWEI
          perform conversion_factor_get using xlips-kcgewei "46B
                                              lt_batch_lips-gewei
                                              zaehler
                                              nenner
                                              gewei_tmp.

*         NETTO_SOLL  = CALC_P-NTGEW_IST * NENNER / ZAEHLER.   "46B
*         BRUTTO_SOLL = CALC_P-BRGEW_IST * NENNER / ZAEHLER.   "46B

          netto_soll  = calc_p-ntgew_ist * zaehler / nenner."46B
          brutto_soll = calc_p-brgew_ist * zaehler / nenner."46B

          calc_p-kcntgew_soll =
                            calc_p-kcntgew_soll + netto_soll.

          calc_p-kcbrgew_soll =
*                            CALC_P-KCBRGEW_SOLL + NETTO_SOLL. "46B
                             calc_p-kcbrgew_soll + brutto_soll.
        else.

          calc_p-kcntgew_soll =
                            calc_p-kcntgew_soll + calc_p-ntgew_ist.
          calc_p-kcbrgew_soll  =
                            calc_p-kcbrgew_soll + calc_p-brgew_ist.

        endif.
        if xlips-kcvoleh = calc_p-voleh_ist.
          calc_p-kcvolum_soll =
                            calc_p-kcvolum_soll + calc_p-volum_ist.
        else.                                               "46B
          no_volum = charx.                                 "46B
        endif.
      endloop.

*----------------------------------------------------------------------*
* update header (XLIKP) with kc-weights of main batch-split item       *
*----------------------------------------------------------------------*
      if xlips-kcgewei <> xlikp-gewei and
                   xlips-kcgewei <> space   and
                   xlikp-gewei <> space.

        perform conversion_factor_get using xlikp-gewei
                                            xlips-kcgewei
                                            zaehler
                                            nenner
                                            gewei_tmp.

*       NETTO_SOLL  = CALC_P-KCNTGEW_SOLL * NENNER / ZAEHLER.  "46B
*       BRUTTO_SOLL = CALC_P-KCBRGEW_SOLL * NENNER / ZAEHLER.  "46B

        netto_soll  = calc_p-kcntgew_soll * zaehler / nenner."46B
        brutto_soll = calc_p-kcbrgew_soll * zaehler / nenner."46B


        calc_k-ntgew_soll =
                          calc_k-ntgew_soll + netto_soll.

        calc_k-brgew_soll =
                          calc_k-brgew_soll + brutto_soll.
      else.
        calc_k-ntgew_soll =
                          calc_k-ntgew_soll + calc_p-kcntgew_soll.
        calc_k-brgew_soll  =
                          calc_k-brgew_soll + calc_p-kcbrgew_soll.

      endif.
      if calc_k-voleh_ist = xlips-kcvoleh.
        calc_k-volum_soll =
*                         CALC_K-VOLUM_SOLL + XLIPS-KCVOLUM.       "46B
                          calc_k-volum_soll + calc_p-kcvolum_soll."46B
      else.                                                 "46B
        no_volum = charx.                                   "46B
      endif.
*----------------------------------------------------------------------*
* check for not distributed quantities to a batch split item           *
* batch-split incomplete                                               *
*----------------------------------------------------------------------*
      if xlips-lfimg > 0 or xlips-lgmng > 0.

        if xlips-gewei <> xlikp-gewei and
                     xlips-gewei <> space   and
                     xlikp-gewei <> space.

          perform conversion_factor_get using xlikp-gewei
                                              xlips-gewei
                                              zaehler
                                              nenner
                                              gewei_tmp.

*         NETTO_SOLL =  XLIPS-NTGEW * NENNER / ZAEHLER.  "46B
*         BRUTTO_SOLL = XLIPS-BRGEW * NENNER / ZAEHLER.  "46B

          netto_soll =  xlips-ntgew * zaehler / nenner.     "46B
          brutto_soll = xlips-brgew * zaehler / nenner.     "46B


          calc_k-ntgew_soll =
                            calc_k-ntgew_soll + netto_soll.

          calc_k-brgew_soll =
                            calc_k-brgew_soll + brutto_soll.
        else.
          calc_k-ntgew_soll =
                            calc_k-ntgew_soll + xlips-ntgew.
          calc_k-brgew_soll  =
                            calc_k-brgew_soll + xlips-brgew.

        endif.
        if calc_k-voleh_ist = xlips-voleh.
          calc_k-volum_soll =
                            calc_k-volum_soll + xlips-volum.
        else.                                               "46B
          no_volum = charx.                                 "46B
        endif.
      endif.

*----------------------------------------------------------------------*
*  update table xlips with different fields
*----------------------------------------------------------------------*
      check calc_p-count_batch > 0.

      result = calc_p-kcmeng_soll - calc_p-kcmeng_ist.
      result_flo = calc_p-kcmeng_flo_soll - calc_p-kcmeng_flo_soll.
      result_brg = calc_p-kcbrgew_ist - calc_p-kcbrgew_soll.
      result_ntg = calc_p-kcntgew_ist - calc_p-kcntgew_soll.
      result_vol = calc_p-kcvolum_ist - calc_p-kcvolum_soll.

      if result     between epsilon_neg and epsilon_pos and
         result_flo between epsilon_neg and epsilon_pos and
         result_brg between epsilon_neg and epsilon_pos and
         result_ntg between epsilon_neg and epsilon_pos and
         result_vol between epsilon_neg and epsilon_pos.

      else.

        xlips-kcmeng     = calc_p-kcmeng_soll.
        xlips-kcmeng_flo = calc_p-kcmeng_flo_soll.
        xlips-kcntgew    = calc_p-kcntgew_soll.
        xlips-kcbrgew    = calc_p-kcbrgew_soll.
        xlips-kcvolum    = calc_p-kcvolum_soll.
        save_header      = charx.                           "46B

        if xlips-updkz <> updkz_delete.
          if xlips-updkz ca 'UI'.
            modify xlips transporting kcmeng
                                      kcmeng_flo
                                      kcbrgew
                                      kcntgew
                                      kcvolum.
          else.
            xlips-updkz = 'U'.
            modify xlips transporting kcmeng
                                      kcmeng_flo
                                      kcbrgew
                                      kcntgew
                                      kcvolum
                                      updkz.

          endif.
        endif.
      endif.
    endif.

*----------------------------------------------------------------------*
* Sub item of a batch split
*----------------------------------------------------------------------*
*    IF     XLIPS-XCHAR     = CHARX AND
*           XLIPS-XCHPF     = CHARX AND
*       NOT XLIPS-CHARG  IS INITIAL AND
*       NOT XLIPS-UECHA  IS INITIAL AND
*           XLIPS-POSNR > '900000'.
*    ENDIF.
*----------------------------------------------------------------------*
* item not batch managed, update (xlikp) with item weights
*----------------------------------------------------------------------*
    if     xlips-xchar is initial and
           xlips-uecha is initial.

      if xlips-gewei <> xlikp-gewei and
             xlips-gewei <> space   and
             xlikp-gewei <> space.

        perform conversion_factor_get using xlikp-gewei
                                            xlips-gewei
                                            zaehler
                                            nenner
                                            gewei_tmp.

*       NETTO_SOLL  = XLIPS-NTGEW * NENNER / ZAEHLER.   "46B
*       BRUTTO_SOLL = XLIPS-BRGEW * NENNER / ZAEHLER.   "46B

        netto_soll  = xlips-ntgew * zaehler / nenner.       "46B
        brutto_soll = xlips-brgew * zaehler / nenner.       "46B


        calc_k-ntgew_soll =
                          calc_k-ntgew_soll + netto_soll.

        calc_k-brgew_soll =
                          calc_k-brgew_soll + brutto_soll.
      else.
        calc_k-ntgew_soll =
                          calc_k-ntgew_soll + xlips-ntgew.
        calc_k-brgew_soll  =
                          calc_k-brgew_soll + xlips-brgew.

      endif.
      if calc_k-voleh_ist = xlips-voleh.
        calc_k-volum_soll =
                          calc_k-volum_soll + xlips-volum.
      else.
        no_volum = charx.
      endif.
    endif.
  endloop.
*----------------------------------------------------------------------*
*  update table xlikp with different fields
*----------------------------------------------------------------------*
  result_brg = calc_k-brgew_ist - calc_k-brgew_soll.
  result_ntg = calc_k-ntgew_ist - calc_k-ntgew_soll.
  result_vol = calc_k-volum_ist - calc_k-volum_soll.

  if save_header = charx.                                   "46B
*    IF     RESULT_BRG BETWEEN EPSILON_NEG AND EPSILON_POS AND
*           RESULT_NTG BETWEEN EPSILON_NEG AND EPSILON_POS AND
*           RESULT_VOL BETWEEN EPSILON_NEG AND EPSILON_POS.

*    ELSE.

    if not calc_k-ntgew_soll is initial.                    "46B
      if not result_ntg between epsilon_neg and epsilon_pos."46B
        xlikp-ntgew = calc_k-ntgew_soll.
      endif.
    endif.                                                  "46B
    if not calc_k-brgew_soll is initial.                    "46B
      if not result_brg between epsilon_neg and epsilon_pos."46B
        xlikp-btgew = calc_k-brgew_soll.
      endif.
    endif.                                                  "46B
    if no_volum <> charx.
      if not calc_k-volum_soll is initial.                  "46B
        if not result_vol between epsilon_neg and epsilon_pos."46B
          xlikp-volum = calc_k-volum_soll.
        endif.                                              "46B
      endif.
    endif.                                                  "46B

    if xlikp-updkz <> updkz_delete.
      if xlikp-updkz ca 'UI'.
        modify xlikp index if_kopf_tabix transporting btgew
                                                      ntgew
                                                      volum.
      else.
        xlikp-updkz = 'U'.
        modify xlikp index if_kopf_tabix transporting btgew
                                                      ntgew
                                                      volum
                                                      updkz.

      endif.
    endif.
*    ENDIF.
  endif.                                                    "46B
endform.                    "BATCHSPLIT_KCMENG_CORRECTION
*---------------------------------------------------------------------*
*       FORM CONVERSION_FACTOR_GET                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_EH1                                                         *
*  -->  I_EH2                                                         *
*  -->  O_ZAEHLER                                                     *
*  -->  O_NENNER                                                      *
*  -->  O_MAXEH                                                       *
*---------------------------------------------------------------------*
form conversion_factor_get using i_eh1     like t006-msehi
                                 i_eh2     like t006-msehi
                                 o_zaehler type numeric
                                 o_nenner  type numeric
                                 o_maxeh   like t006-msehi.

  if i_eh1 ne space and i_eh2 ne space.

    call function 'CONVERSION_FACTOR_GET'
      exporting
        no_type_check        = 'X'
        unit_in              = i_eh1
        unit_out             = i_eh2
      importing
        denominator          = o_zaehler
        numerator            = o_nenner
      exceptions
        conversion_not_found = 01
        overflow             = 02
        type_invalid         = 03
        units_missing        = 04
        unit_in_not_found    = 05
        unit_out_not_found   = 06
        others               = 99.
    if o_zaehler < o_nenner.
      o_maxeh = i_eh1.
    else.
      o_maxeh = i_eh2.
    endif.
  else.
    o_zaehler = 1.
    o_nenner = 1.
    if i_eh1 ne space.
      o_maxeh = i_eh1.
    else.
      o_maxeh = i_eh2.
    endif.
  endif.

endform.                    "CONVERSION_FACTOR_GET