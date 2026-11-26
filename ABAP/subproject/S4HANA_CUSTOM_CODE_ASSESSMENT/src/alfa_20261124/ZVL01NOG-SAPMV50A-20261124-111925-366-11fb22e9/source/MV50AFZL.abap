*----------------------------------------------------------------------*
*   INCLUDE MV50AFZL                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  KZKOR_DETERMINE
*&---------------------------------------------------------------------*
*       In delivery creation process for sales orders there is the
*       possibility to restrict the delivery creation to some order
*       items.
*       If these order items are member of a delivery group, but not
*       all items of this delivery group are includes in the
*       restriction range of the order item nubers, you can specify
*       in this routine what to do.
*       This effects Delivery creation in Dialog
*       (VL01, VL01N) and delivery change, function deliver sales order
*       (VL02, VL02N, FCode RAUF).
*
*----------------------------------------------------------------------*
*      <-- CF_KZKOR  flag, how to handle incomplete delivery groups
*----------------------------------------------------------------------*


FORM kzkor_determine CHANGING cf_kzkor TYPE c.

    cf_kzkor = ' '.  "Deliver incomplete delivery groups as specified

*   cf_kzkor = '1'.  "Add items of incomplete selected delivery groups

*   cf_kzkor = '2'.  "do not deliver any item of incomplete del-groups

ENDFORM.