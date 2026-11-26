*----------------------------------------------------------------------*
***INCLUDE MV45A_INTERNAL_HEAD_SET_DATF01 .
*----------------------------------------------------------------------*
FORM internal_head_set_data .

  IF gs_screenbadi_int_h-handler IS BOUND.
    CALL METHOD gs_screenbadi_int_h-handler->transfer_data_to_subscreen
      EXPORTING
        is_t180         = t180
        is_int_head_tab = gs_screenbadi_int_h
      CHANGING
        cs_vbkd         = vbkd
        cs_rv45a        = rv45a
        ct_yvblb        = yvblb[]
        ct_xvblb        = xvblb[]
        ct_yvbadr       = yvbadr[]
        ct_xvbadr       = xvbadr[]
        ct_yvbfa        = yvbfa[]
        ct_yvbep        = yvbep[]
        ct_yvbkd        = yvbkd[]
        ct_yvbpa        = yvbpa[]
        ct_yvbuk        = yvbuk[]
        ct_yvbup        = yvbup[]
        ct_yfpla        = yfpla[]
        ct_yfplt        = yfplt[]
        cs_vbak         = vbak
        ct_xvbap        = xvbap[]
        ct_xkomv        = xkomv[]
        ct_xvbapf       = xvbapf[]
        ct_xvbfa        = xvbfa[]
        ct_xvbep        = xvbep[]
        ct_xvbkd        = xvbkd[]
        ct_xvbpa        = xvbpa[]
        ct_xvbuk        = xvbuk[]
        ct_xvbup        = xvbup[]
        ct_xfpla        = xfpla[]
        ct_xfplt        = xfplt[]
        cs_yvbak        = yvbak
        ct_yvbapf       = yvbapf[]
        ct_yvbap        = yvbap[]
        cs_r185d        = r185d.
  ENDIF.

ENDFORM.                    " INTERNAL_HEAD_SET_DATA