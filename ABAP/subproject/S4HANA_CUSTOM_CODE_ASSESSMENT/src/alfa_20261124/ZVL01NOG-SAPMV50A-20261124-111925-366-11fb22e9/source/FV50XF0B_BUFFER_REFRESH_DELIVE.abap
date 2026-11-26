*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_BUFFER_REFRESH_DELIVE                             *
*----------------------------------------------------------------------*
FORM buffer_refresh_delivery TABLES xlikp STRUCTURE likpvb.

DATA:
  ls_delivery_key  TYPE leshp_delivery_key
, lt_delivery_keys TYPE leshp_delivery_key_t
.
FIELD-SYMBOLS:

  <ls_likp> TYPE likpvb
.

  LOOP AT xlikp ASSIGNING <ls_likp>
                WHERE      updkz <> updkz_delete.

    ls_delivery_key-handle = <ls_likp>-handle.
    ls_delivery_key-vbeln  = <ls_likp>-vbeln.
    COLLECT ls_delivery_key INTO lt_delivery_keys.

  ENDLOOP.

  IF 1 = 1.
    CALL FUNCTION 'LE_DELIVERY_REFRESH_BUFFER'
         EXPORTING  it_delivery_keys = lt_delivery_keys
         EXCEPTIONS OTHERS           = 2.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.