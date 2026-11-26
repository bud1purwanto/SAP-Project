*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_AUPSTAB_ANZLFG                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_AUPSTAB_ANZLFG
*&---------------------------------------------------------------------*
*       Aus dem Belegfluß bestimmen, zu welchen Auftrtagspositionen
*       Lieferungen bestehen
*----------------------------------------------------------------------*
FORM korr_aupstab_anzlfg TABLES aupstab TYPE      vlkor_aupstab
                                pvbap   STRUCTURE vbapvb.
DATA:
  lf_lfgsa                LIKE vbup-lfgsa
, lf_order_item_delivered
, lf_not_in_this_delivery
.
  LOOP AT aupstab.

    CLEAR lf_not_in_this_delivery.

    READ TABLE xvbfa WITH KEY vbelv   =  aupstab-vbeln
                              posnv   =  aupstab-posnr
                              vbeln   =  xlikp-vbeln
                     BINARY SEARCH.
    IF sy-subrc = 0. lf_order_item_delivered = charx.
    ELSE.            lf_order_item_delivered = space.
    ENDIF.

*   check whether order item
*   + is not relevant for  delivery-group-check
*     -  not relevant for  delivery  or
*     - already completely delivered or
*                          cancelled
*   + is included in this  delivery

*   special scenario: completely delivered by delivery split
*   in the same package => there are parts of the deli group in
*   other deliveries
    IF aupstab-lfgsa           EQ 'C' AND
       lf_order_item_delivered EQ space.
      LOOP AT xvbfa TRANSPORTING NO FIELDS
                    WHERE vbelv EQ aupstab-vbeln AND
                          posnv EQ aupstab-posnr AND
                          vbeln NE xlikp-vbeln   AND
                          updkz CA 'UI'.
        EXIT.
      ENDLOOP.
      IF sy-subrc EQ 0.
        lf_not_in_this_delivery = charx.
      ENDIF.
    ENDIF.

    IF (     aupstab-lfgsa           CA ' C'
       OR    lf_order_item_delivered  = charx
       ).

*     Increment order-items delivered - not for delivery split
      IF lf_not_in_this_delivery NE charx.
        aupstab-anzlfg = aupstab-anzlfg + 1.
      ENDIF.
      IF lf_order_item_delivered = charx.

*       Increment  order-items delivered in this delivery
        aupstab-anzlfa = aupstab-anzlfa + 1.

      ENDIF.

      MODIFY aupstab TRANSPORTING anzlfg anzlfa.

    ENDIF.
  ENDLOOP.
ENDFORM.                               " KORR_AUPSTAB_ANZLFG

*&---------------------------------------------------------------------*
*&      Form  korr_aupstab_anzlfg_spe
*&---------------------------------------------------------------------*
*   Search from the XLIPS for which items of the unchecked
*   delivery a checked delivery has been created.
*----------------------------------------------------------------------*
FORM korr_aupstab_anzlfg_spe TABLES aupstab TYPE vlkor_aupstab.

DATA:
  lf_lfgsa                LIKE vbup-lfgsa
, lf_order_item_delivered
, lf_not_in_this_delivery
.

FIELD-SYMBOLS :
    <ls_xlips>  TYPE lipsvb.

  LOOP AT aupstab.

    CLEAR lf_not_in_this_delivery.
*   Only entries in XLIPS that are not to be deleted should be
*   processed
*   In case of create unchecked deliveries only the entries with
*   UPDKZ = I;U or initial should be used
    IF NOT v50agl-create_uclief IS INITIAL.
       LOOP AT xlips TRANSPORTING NO FIELDS
                     WHERE  vgbel = aupstab-vbeln
                         AND    vgpos = aupstab-posnr
                         AND    vbeln = xlikp-vbeln
                         AND  ( updkz = updkz_new    OR
                                updkz = updkz_update OR
                                updkz = updkz_old ).
         EXIT.
       ENDLOOP.
    ELSE.
       READ TABLE xlips TRANSPORTING NO FIELDS
                              WITH KEY vgbel   =  aupstab-vbeln
                                       vgpos   =  aupstab-posnr
                                       vbeln   =  xlikp-vbeln.
    ENDIF.


    IF sy-subrc = 0. lf_order_item_delivered = charx.
    ELSE.            lf_order_item_delivered = space.
    ENDIF.

*   check whether order item
*   + is not relevant for  delivery-group-check
*     -  not relevant for  delivery  or
*     - already completely delivered or
*                          cancelled
*   + is included in this  delivery

*   special scenario: completely delivered by delivery split
*   in the same package => there are parts of the deli group in
*   other deliveries
    IF aupstab-lfgsa           CA ' C' AND
      lf_order_item_delivered EQ space.
      CLEAR lf_not_in_this_delivery .
      LOOP AT xlips ASSIGNING <ls_xlips>
                    WHERE vgbel EQ aupstab-vbeln
                      AND vgpos EQ aupstab-posnr
                      AND ( updkz = updkz_new    OR
                            updkz = updkz_update OR
                            updkz = updkz_old ).
         IF NOT <ls_xlips>-vbeln = xlikp-vbeln.
            lf_not_in_this_delivery = charx.
            EXIT.
         ENDIF.
      ENDLOOP.

    ENDIF.

    IF (     aupstab-lfgsa           CA ' C'
       OR    lf_order_item_delivered  = charx
       ).

*     Increment order-items delivered - not for delivery split
      IF lf_not_in_this_delivery NE charx.
        aupstab-anzlfg = aupstab-anzlfg + 1.
      ENDIF.
*     Increment order-items delivered in this delivery
      IF lf_order_item_delivered = charx.
        aupstab-anzlfa = aupstab-anzlfa + 1.
      ENDIF.

      MODIFY aupstab TRANSPORTING anzlfg anzlfa.

    ENDIF.
  ENDLOOP.
ENDFORM.                               " KORR_AUPSTAB_ANZLFG_SPE