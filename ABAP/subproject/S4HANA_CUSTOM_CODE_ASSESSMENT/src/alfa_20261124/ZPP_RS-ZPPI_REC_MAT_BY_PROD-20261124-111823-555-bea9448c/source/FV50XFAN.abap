*----------------------------------------------------------------------*
*   INCLUDE FV50XFAN                                                   *
*----------------------------------------------------------------------*
* this form can be used for special checks or traps
* after this point, the update of the delivery begins

FORM DELIVERY_SYSTEM_CHECK.
* loop at xlikp where updkz ne updkz_delete.
*   call function 'PACKING_CHECK'
*     exporting xlikp-vbeln.
*     importing rcode.
*     if rcode ne 0.
*       if v50agl-sammelgang = 'X'.
*         perform lieferung_loeschen.
*       else.
*         message E123.
*     endif.
* endloop.
*
ENDFORM.