*----------------------------------------------------------------------*
*   INCLUDE MV45AFFE_FELDAUSWAHL_102                                   *
*----------------------------------------------------------------------*
form feldauswahl_102.
  loop at screen.
    if sy-binpt is initial or not cattaktiv is initial.
      if screen-name = 'RV45A-DOCNUM'.
        screen-active = 0.
        modify screen.
      endif.
    endif.
  endloop.

* IF 'search with date', disable further search-functions
  if t180-trtyp eq chara and   "Display
     t180-trvog eq char0 and   "Order
     gv_asuc eq 'X' and        "Search with date
     not gv_vbak_special_archiving is initial.
    loop at screen.
      if screen-group1 = 'NOA'.
        screen-active = 0.
        modify screen.
      endif.
    endloop.
* In all other cases disable the search-range for a date
  else.
    loop at screen.
      if screen-group1 = 'ARC'.
        screen-active = 0.
        modify screen.
      endif.
    endloop.
    clear gv_erdat_sel-low.
    clear gv_erdat_sel-high.
  endif.

endform.                    "FELDAUSWAHL_102