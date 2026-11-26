*eject
*----------------------------------------------------------------------*
*               FORM BEST_SUCHEN_LIEF                                  *
*----------------------------------------------------------------------*
*    Bestellungen suchen über Vorgängerbeleg Umlager-Lieferung         *
*----------------------------------------------------------------------*
FORM BEST_SUCHEN_LIEF.
  DATA: REF_EBELN LIKE WUEB-EBELN,
        REF_EBELP LIKE WUEB-EBELP.
  CALL FUNCTION 'SD_DELIVERY_ITEMS_RECEIVE'
       EXPORTING
            VBELN                  = RM07M-VBELN
            WERKS                  = RM07M-WERKS
            IF_LOCK                = 'X'                    "note435772
            IS_T156                = T156
       TABLES
            WUEB                   = WUEB
       EXCEPTIONS
            NO_DELIVERY            = 1
            DELIVERY_NOT_SUITABLE  = 2
            DELIVERY_NOT_POSTED_GI = 3
            NO_ITEMS_RECEIVING     = 4
            NO_RECEIVING_PLANT     = 5
            NO_DELIVERY_ITEM       = 6
            NO_MOVEMENT_TYPE       = 7                      "note435772
            DELIVERY_LOCKED        = 8.

  IF NOT SY-SUBRC IS INITIAL.
    SET CURSOR FIELD 'RM07M-VBELN'.
    MESSAGE E865 WITH RM07M-VBELN SY-SUBRC.
  ENDIF.
  ZWUEB = X.
* two times the same PO number and PO item numer            "note197073
* -> batch split in delivery (XSPLIT)                       "note197073
  SORT WUEB BY EBELN EBELP VBELN VBELP.                     "note197073
  READ TABLE WUEB INDEX 1.                                  "note197073
  IF SY-SUBRC IS INITIAL.                                   "note197073
    REF_EBELN = WUEB-EBELN.                                 "note197073
    REF_EBELP = WUEB-EBELP.                                 "note197073
    LOOP AT WUEB FROM 2.                                    "note197073
      IF WUEB-EBELN EQ REF_EBELN AND                        "note197073
         WUEB-EBELP EQ REF_EBELP.                           "note197073
        XSPLIT = X.                                         "note197073
        EXIT.                                               "note197073
      ENDIF.                                                "note197073
      REF_EBELN = WUEB-EBELN.                               "note197073
      REF_EBELP = WUEB-EBELP.                               "note197073
    ENDLOOP.                                                "note197073
  ENDIF.                                                    "note197073

ENDFORM.