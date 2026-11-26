*----------------------------------------------------------------------*
***INCLUDE MV50AF0C_CUA_FCODE_BADI .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CUA_EXCLUDE_BADI
*&---------------------------------------------------------------------*
*       Enable/ Disable new fcodes (EhP4)
*----------------------------------------------------------------------*
FORM cua_exclude_badi .
  DATA:
    lb_badi   TYPE REF TO shp_badi_cua_fcode_allow,
    lt_fcode  TYPE if_ex_shp_cua_fcode_allow=>gty_fcode_allow_t,
    ls_fcode  TYPE if_ex_shp_cua_fcode_allow=>gty_fcode_allow_s.

  GET BADI lb_badi.

  CALL BADI lb_badi->allow_fcodes
    EXPORTING
      is_t180   = t180
      is_tvlk   = tvlk
      is_v50agl = v50agl
      is_likp   = likp
      is_vbuk   = vbuk
      it_xlips  = xlips[]
      it_xvbup  = xvbup[]
      is_ekko   = ekko
      it_xekpo  = xekpo[]
      it_xeket  = xeket[]
      is_vbak   = vbak
      it_xvbap  = xvbap[]
    CHANGING
      ct_fcode  = lt_fcode.

  LOOP AT lt_fcode INTO ls_fcode.
    PERFORM cua_fcode_allow USING ls_fcode-fcode ls_fcode-allow.
  ENDLOOP.

ENDFORM.                    " CUA_EXCLUDE_BADI