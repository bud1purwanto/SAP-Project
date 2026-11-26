*&---------------------------------------------------------------------*
*&  Include           /SPE/MV50AF_POD_INSERT_EKBE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  /spe/insert_ekbe_pod
*&---------------------------------------------------------------------*
*       Add correction delivery to the PO history
*       Not nice ! But least risk here ...
*----------------------------------------------------------------------*
*      -->IF_DELIVERY   Delivery number
*----------------------------------------------------------------------*
FORM /spe/insert_ekbe_pod  USING    if_delivery   TYPE likp-vbeln
                                    if_shkzg      TYPE ekbe-shkzg
                                    if_vgbel      TYPE lips-vgbel
                                    if_vgpos      TYPE lips-vgpos.


  DATA: lt_xekbe    TYPE TABLE OF ekbe
       ,ls_xekbe    TYPE          ekbe
       .

* Fill XEKBE with Core form routine ...
  LOOP AT xlips WHERE vbeln EQ if_delivery.
    PERFORM best_ekbe_aus_lips TABLES lt_xekbe
                                USING xlips.
  ENDLOOP.

* .. and adapt it with the Debit/Credit indicator
  ls_xekbe-shkzg = if_shkzg.
  ls_xekbe-ebeln = if_vgbel.
  ls_xekbe-ebelp = if_vgpos.
  MODIFY lt_xekbe FROM ls_xekbe
                  TRANSPORTING shkzg ebeln ebelp
                  WHERE belnr EQ if_delivery.

  DESCRIBE TABLE lt_xekbe LINES sy-tfill.
  IF sy-tfill > 0.
    CALL FUNCTION 'ME_STATISTICS_LF_EKBE_LIS'
      TABLES
        t_ekbe = lt_xekbe.
    CALL FUNCTION 'ME_UPDATE_DELIVERY' in update task
      TABLES
        xekbe         = lt_xekbe.
  ENDIF.

ENDFORM.                    " /spe/insert_ekbe