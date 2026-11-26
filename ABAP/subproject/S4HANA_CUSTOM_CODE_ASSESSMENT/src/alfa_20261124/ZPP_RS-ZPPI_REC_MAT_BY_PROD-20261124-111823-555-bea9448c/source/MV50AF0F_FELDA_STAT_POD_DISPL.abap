*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FELDA_STAT_POD_DISPL                              *
*----------------------------------------------------------------------*
form feldauswahl_stat_pod_displ changing cf_exit_flag type c.

*... in case of display mode no field can be changed
  if t180-trtyp eq chara or xvbuk-pdstk eq space.
    if screen-name = 'TVPODVB-PODMG'       or
       screen-name = 'TVPODVB-LFIMG_DIFF'  or
       screen-name = 'TVPODVB-GRUND'       or
       screen-name = 'TVPODVB-LGMNG_DIFF'  or
       screen-name = 'LIKP-PODAT'          or
       screen-name = 'LIKP-POTIM'          or
       screen-name = 'BT_SPOD'             or
       screen-name = 'BT_QPOD'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name = 'TVPODVB-PODMG'      or
     screen-name = 'TVPODVB-LFIMG_DIFF' or
     screen-name = 'TVPODVB-GRUND'      or
     screen-name = 'TVPODVB-LGMNG_DIFF'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

  if xvbuk-pdstk ca ' C' and
    ( screen-name = 'LIKP-PODAT'   or
      screen-name = 'LIKP-POTIM' ).
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if ( xvbuk-pdstk ca 'AB' OR ( xvbuk-wbstk = charc and gv_sit_retpo is not initial ) )
  and screen-name = 'BT_SPOD'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if xvbuk-pdstk ca ' C' and screen-name = 'BT_QPOD'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

*... inbound scenario cannot handle different Uom
  if screen-name = 'LIPS-VRKME'          or
     screen-name = 'LIPS-MEINS'.
    if likp-vbtyp eq vbtyp_liav and not lips-kzpod is initial.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

endform.                    "FELDAUSWAHL_STAT_POD_DISPL