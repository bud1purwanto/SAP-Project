*&---------------------------------------------------------------------*
*&      Form  SERIALNUMBER_SHOW_INV
*&---------------------------------------------------------------------*
*       the serialnumbers were created during a physical inventory
*       -> display the physical inventory-objectlist instead of
*          material document-objectlist.
*----------------------------------------------------------------------*
FORM serialnumber_show_inv.

  SELECT SINGLE * FROM iseg WHERE mblnr = mseg-mblnr
                              AND mjahr = mseg-mjahr
                              AND zeile = mseg-zeile.
  CALL FUNCTION 'INVENTORY_ITEM_DISPLAY'
       EXPORTING
            iblnr     = iseg-iblnr
            zeili     = iseg-zeili
            mjahr     = iseg-gjahr
            output    = 1
       EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    dm07m-anzsn =  xanzsn.
  ENDIF.

ENDFORM.                               " SERIALNUMBER_SHOW_INV