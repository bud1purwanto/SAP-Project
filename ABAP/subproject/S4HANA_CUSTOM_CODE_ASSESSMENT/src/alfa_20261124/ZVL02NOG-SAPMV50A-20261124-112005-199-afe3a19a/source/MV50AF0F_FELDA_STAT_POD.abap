*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FELDA_STAT_POD                                    *
*----------------------------------------------------------------------*
form feldauswahl_stat_pod changing cf_exit_flag type c.

*... in case of display mode or missing GI status no field
*    can be changed
  if t180-trtyp eq chara
  or ( xvbuk-wbstk ne charc and gv_sit_retpo is initial ).
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

ENHANCEMENT-POINT FELDAUSWAHL_STAT_POD_01 SPOTS ES_SAPMV50A .

  if tvpodvb-podmul eq '@1E@' and not lips-posnr is initial
    and t185v-panel eq 'UPOD'.
    if screen-name = 'TVPODVB-PODMG'       or
       screen-name = 'TVPODVB-LFIMG_DIFF'  or
       screen-name = 'TVPODVB-GRUND'       or
       screen-name = 'TVPODVB-LGMNG_DIFF'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if t185v-panel eq 'PPOD'         and
     not lips-posnr is initial     and
     screen-name = 'TVPODVB-GRUND' and
     not tvpodvb-grund eq space.  "OR NOT TVPODVB-GRUND EQ '0000' ).
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

  if xvbuk-pdstk ca ' C' and
    ( screen-name = 'LIKP-PODAT'   or
      screen-name = 'LIKP-POTIM'   or
      screen-name = 'BT_QPOD' ).
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

  if xvbuk-pdstk ca 'AB' and screen-name = 'BT_SPOD'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if xvbuk-pdstk ca ' C' and screen-name = 'BT_QPOD'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
*
  if not lipsd-chmult is initial.
    if screen-name = 'TVPODVB-PODMG'       or
       screen-name = 'TVPODVB-LFIMG_DIFF'  or
       screen-name = 'TVPODVB-GRUND'       or
       screen-name = 'RV50A-PODMUL'        or                  "n_572814
       screen-name = 'TVPODVB-LGMNG_DIFF'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name = 'LIPS-VRKME'          or
     screen-name = 'LIPS-MEINS'.
    if likp-vbtyp eq vbtyp_liav and not lips-kzpod is initial.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

endform.                    "FELDAUSWAHL_STAT_POD