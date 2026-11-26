*----------------------------------------------------------------------*
*       FORM STRUCT_EXBWR_RECORD                                       *
*----------------------------------------------------------------------*
*       record proposed values of WB_STOCK_VALUES_FIND in zmseg for    *
*       reasons of a possible reversal;                                *
*       thus, when the reversal is processed we know about the original*
*       distribution of components values;                             *
*----------------------------------------------------------------------*
form struct_exbwr_record tables p_xpxvaf structure pxvaf.

  data: h_update,
        h_tabix like sy-tabix.
* in p_xpxvaf there are all items which belong to the struct. art.
* and additionally their proposed values
  loop at p_xpxvaf.
    if not p_xpxvaf-exwrt is initial.
* get corresponding line in zmseg
      read table zmseg with key zeile = p_xpxvaf-zeile.
      if sy-subrc is initial.
        move sy-tabix to h_tabix.
        clear h_update.
* just update on exbwr if there has not been entered a value before
        if zmseg-exbwr is initial.
* don't update on original head of struct. art.
          if not ( zmseg-urzei    = zmseg-zeile  and
                   p_xpxvaf-xhead = x            and
                   zmseg-xauto is initial ).
            h_update = x.
          elseif p_xpxvaf-xstru = x  and  zmseg-vprsv = s.
* special case: direct stock transfer by 317 (or 318); value of head
* gets calculated by sum of components values; in case of S-price head
* -> record sum in order to be able to reproduce price diff. posting
            read table zdm07m index zmseg-zeile.
            if sy-subrc is initial.
* mvmt type 317: shkzg = s, mvmt type 318: shkzg = h
              if zdm07m-xstbw is initial  and  zmseg-shkzg = s  or
                 zdm07m-xstbw = x         and  zmseg-shkzg = h.
                h_update = x.
              endif.
            endif.
          endif.
        endif.
        if not h_update is initial.
* finally: record proposed value in zmseg-exbwr
          zmseg-exbwr = p_xpxvaf-exwrt.
          modify zmseg index h_tabix transporting exbwr.
        endif.
      endif.
    endif.
  endloop.

endform.