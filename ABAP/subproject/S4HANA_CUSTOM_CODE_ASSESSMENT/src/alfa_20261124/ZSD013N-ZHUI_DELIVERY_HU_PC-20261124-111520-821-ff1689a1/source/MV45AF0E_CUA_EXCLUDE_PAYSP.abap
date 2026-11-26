*----------------------------------------------------------------------*
***INCLUDE MV45AF0E_CUA_EXCLUDE_PAYSP .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CUA_EXCLUDE_PAYSP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cua_exclude_paysp .

* Payment Service Provider
  DATA: da_fcode LIKE cua_exclude-function,
        lv_fcode_not_active TYPE c,
        lv_no_input TYPE xfeld.
  IF vbak-sppaym EQ cv_sppaym01.
    IF t180-trtyp EQ charv AND
    sy-dyngr NE 'ANFO'.
      DO VARYING da_fcode FROM cua_exclu_paysp-f01
                          NEXT cua_exclu_paysp-f02.
        IF da_fcode EQ cua_exclu_paysp-f99.
          EXIT.
        ENDIF.
        PERFORM paysp_check_fcode_active USING    da_fcode
                                                  space
                                         CHANGING lv_fcode_not_active.
        IF lv_fcode_not_active EQ abap_true.
          cua_exclude-function = da_fcode.
          APPEND cua_exclude.
        ENDIF.
      ENDDO.
      IF vbuk-abstk EQ charc.
        PERFORM paysp_check_fcode_active USING    da_fcode
                                          space
                                 CHANGING lv_fcode_not_active.
        IF lv_fcode_not_active EQ abap_true.
          APPEND 'SERL' TO cua_exclude.
        ENDIF.
      ENDIF.
      CALL METHOD gr_paysp->get_fieldcheck_general_sls
        EXPORTING
          is_vbak     = vbak
          is_tvak     = tvak
          iv_trtyp    = t180-trtyp
        IMPORTING
          ev_no_input = lv_no_input.
      IF lv_no_input IS NOT INITIAL AND
         vbuk-abstk CA 'BC'.
        APPEND 'BABS' TO cua_exclude.
      ENDIF.
    ENDIF.
    APPEND 'LOES' TO cua_exclude.
  ENDIF.

ENDFORM.                    " CUA_EXCLUDE_PAYSP