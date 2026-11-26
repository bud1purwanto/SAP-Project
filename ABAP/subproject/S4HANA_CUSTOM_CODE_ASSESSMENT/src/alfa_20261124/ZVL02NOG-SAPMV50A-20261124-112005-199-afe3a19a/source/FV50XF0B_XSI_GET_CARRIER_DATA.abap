*----------------------------------------------------------------------*
*   INCLUDE FV50YF0B_XSI_GET_DATA                                      *
*----------------------------------------------------------------------*
FORM xsi_get_carrier_data.
  data : lf_posnr like LIPS-POSNR,                        "v_n_948179
        lf_msgty_set_for_vbfs LIKE v50agl-msgty_set_for_vbfs,
        c_xsilog like bapiret2 occurs 0 with header line. "^_n_948179

  IF not  tvshp-xsiactive is initial.

    CALL FUNCTION 'XSI_GET_CARRIER_DATA_LV'
         TABLES
              xlikpvb = xlikp
              ylikpvb = ylikp
              xlipsvb = xlips
              ylipsvb = ylips
              xvbpavb = xvbpa
              yvbpavb = yvbpa
              xsadrvb = xvbadr
              ysadrvb = yvbadr
              c_xsilog = c_xsilog                           "n_948179
         EXCEPTIONS
              OTHERS  = 1.
    IF sy-subrc ne 0.
* -- incompletion log.
    ENDIF.
    lf_msgty_set_for_vbfs  = v50agl-msgty_set_for_vbfs.   "v_n_948179
    v50agl-msgty_set_for_vbfs = 'EWIS'.
    cvbak-vbeln = xlikp-vbeln.
    loop at c_xsilog.
      perform message_handling(sapmv50a) using lf_posnr
                                                c_xsilog-NUMBER
                                                c_xsilog-TYPE
                                                c_xsilog-ID
                                                c_xsilog-MESSAGE_V1
                                                c_xsilog-MESSAGE_V2
                                                c_xsilog-MESSAGE_V3
                                                c_xsilog-MESSAGE_V4.
    endloop.
    v50agl-msgty_set_for_vbfs = lf_msgty_set_for_vbfs.    "^_n_948179
  ENDIF.
ENDFORM.