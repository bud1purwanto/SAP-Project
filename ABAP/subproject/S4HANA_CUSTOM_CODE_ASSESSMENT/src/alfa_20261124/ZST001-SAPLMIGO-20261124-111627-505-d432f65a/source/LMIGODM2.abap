*----------------------------------------------------------------------*
*   INCLUDE LMIGODM2                                                   *
*   Detail tabstrip material implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_material IMPLEMENTATION.
  METHOD pbo.
    CALL METHOD super->pbo.
*   Special handling for HFDAT and VFDAT: here only if no batch
    LOOP AT SCREEN.
      IF screen-name = 'GOITEM-VFDAT'   OR
         screen-name = 'GOITEM-HSDAT'   OR
         screen-name = 'GOITEM-UMHSDAT' OR
         screen-name = 'GOITEM-UMVFDAT'.
        IF lcl_migo_globals=>kernel->s_action-migo_mode <> 'GT'.
          IF goitem-xchpf = abap_true AND goitem-kzbew <> o.
*           Do not use INVISIBLE = ON. Only ACTIVE = OFF overrides
*           the INPUT/OUTPUT-settings from SUPER->PBO.
            screen-active = c_mod_off.
          ENDIF.
        ELSE.
          IF goitem-shkzg = 'S' AND goitem-xchpf = abap_true.
            screen-active = c_mod_off.
          ENDIF.
*         In case of valuation type field, the valuation type is
*         never on the batch tabstrip in case of receiving batch
*         is the UM-batch.
          IF screen-name <> 'GOITEM-BWTAR'.
            IF goitem-shkzg = 'H' AND goitem-umxchpf = abap_true.
              screen-active = c_mod_off.
            ENDIF.
          ENDIF.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

*----------------------------------------------------------------------*
* Method SET_SUBSCREEN
*----------------------------------------------------------------------*
  METHOD subscreen_set.
    g_sub_date_batch = '0311'.
    IF lcl_migo_globals=>kernel->s_action-migo_mode = 'GT' AND
       goitem-shkzg = 'H'.
      g_sub_date_batch = '0312'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.