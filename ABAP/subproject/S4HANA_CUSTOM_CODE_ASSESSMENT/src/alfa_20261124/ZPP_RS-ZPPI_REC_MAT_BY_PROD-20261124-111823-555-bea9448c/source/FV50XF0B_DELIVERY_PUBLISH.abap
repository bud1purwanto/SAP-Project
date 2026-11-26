*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_DELIVERY_PUBLISH                                  *
*----------------------------------------------------------------------*
FORM delivery_publish_after_save.

CLASS cl_exithandler DEFINITION LOAD.

DATA:
  lr_delivery_publish        TYPE REF TO if_ex_delivery_publish,
  lf_active                  LIKE charx,
  lt_active_imp              TYPE v_ext_imp OCCURS 0.        "v_n_536540


  CALL FUNCTION 'SHP_CHECK_IMP_BADI_ACTIVE'
    EXPORTING
      if_inter_name        = 'IF_EX_DELIVERY_PUBLISH'
    IMPORTING
      ef_active            = lf_active
    TABLES
      et_active_imp        = lt_active_imp.



  IF lf_active EQ charx.
*   any other implementations besides aip ?
    LOOP AT lt_active_imp TRANSPORTING NO FIELDS
                          WHERE imp_name NS 'PO_DELIVERY_CONFIRM' AND
                                imp_name NS 'SALESORDER_CONFIRM'.
      EXIT.
    ENDLOOP.

    CHECK sy-subrc EQ 0.                                     "^_n_536540

*   get instance for BAdI call
    CALL METHOD cl_exithandler=>get_instance
         EXPORTING
           exit_name       = 'DELIVERY_PUBLISH'             "n_545270
           null_instance_accepted = 'X'                     "n_572145
         CHANGING instance = lr_delivery_publish.

*     call BAdI
      CALL METHOD lr_delivery_publish->publish_after_save.

  ENDIF.



ENDFORM.