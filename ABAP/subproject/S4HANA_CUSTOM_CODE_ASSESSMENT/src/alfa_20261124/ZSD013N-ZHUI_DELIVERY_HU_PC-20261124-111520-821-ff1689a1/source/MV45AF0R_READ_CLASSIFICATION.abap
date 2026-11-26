*&---------------------------------------------------------------------*
*&      Form READ_CLASSIFICATION                                       *
*&---------------------------------------------------------------------*
*       SÜW: Systemübergreifender Warenfluss                           *
*       (Cross-System Flow of Goods)                                   *
*       For items which are subject to Cross-System Flow of Goods      *
*       and which work with batches the classification has to be       *
*       re-read in order to be passed to the delivery system via IDoc. *
*       This form is called from beleg_sichern (MV45AF0B_BELEG_SICHERN)*
*----------------------------------------------------------------------*
FORM read_classification
              CHANGING ct_allocations     TYPE bapi3060_allocations
                       ct_valuations_char TYPE bapi3060_valuations_char
                       ct_valuations_curr TYPE bapi3060_valuations_curr
                       ct_valuations_num  TYPE bapi3060_valuations_num.

  DATA: ls_objhdrs TYPE bapi3060_object_header,
        lt_objhdrs TYPE bapi3060_object_headers.

  REFRESH: ct_allocations,
           ct_valuations_char,
           ct_valuations_curr,
           ct_valuations_num,
           lt_objhdrs.

  CLEAR:   ls_objhdrs.

  LOOP AT xvbap WHERE NOT cuobj_ch IS INITIAL AND
                      NOT logsys   IS INITIAL.
    ls_objhdrs-clobjectkey = xvbap-cuobj_ch.
    INSERT ls_objhdrs INTO TABLE lt_objhdrs.
  ENDLOOP.

  IF NOT lt_objhdrs IS INITIAL.
    CALL FUNCTION 'CLBPAX_READ_CLASSIFICATIONS'
         EXPORTING
              t_object_keys     = lt_objhdrs
         IMPORTING
              t_allocations     = ct_allocations
              t_valuations_char = ct_valuations_char
              t_valuations_curr = ct_valuations_curr
              t_valuations_num  = ct_valuations_num.
  ENDIF.

ENDFORM.