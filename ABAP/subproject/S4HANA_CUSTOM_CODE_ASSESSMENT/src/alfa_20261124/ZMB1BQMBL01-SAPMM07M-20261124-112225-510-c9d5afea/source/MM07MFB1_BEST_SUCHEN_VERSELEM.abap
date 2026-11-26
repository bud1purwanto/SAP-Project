*eject
*----------------------------------------------------------------------*
*               FORM BEST_SUCHEN_VERSELEM                              *
*----------------------------------------------------------------------*
*    Bestellungen suchen über Versandelemente zu Avis, Grob-WE oder    *
*    Lieferung                                                         *
*----------------------------------------------------------------------*
FORM BEST_SUCHEN_VERSELEM.
  DATA: H_LIEF LIKE RM07M-VBELN.
  DATA: REF_EBELN LIKE WUEB-EBELN,
        REF_EBELP LIKE WUEB-EBELP.
  IF NOT RM07M-VLIEF IS INITIAL.
    H_LIEF = RM07M-VLIEF.
  ELSEIF NOT RM07M-GWELF IS INITIAL.
    X_GROBWE = X.
    H_LIEF = RM07M-GWELF.
  ELSE.
    H_LIEF = RM07M-VBELN.
* in case several inbound deliveries exists for the same PO "1597702
* H_LIEF have to be mapped to H-LIEFK for the purchasing    "1597702
* interface  otherwise double positons will be displayed    "1597702
    H_LIEFK = H_LIEF.                                       "1597702
  ENDIF.

  CALL FUNCTION 'MB_SELECT_SHIPPING_UNITS'
       EXPORTING
            I_VBELN           = H_LIEF
       TABLES
            T_VEPWE           = XVEPWE
       EXCEPTIONS
            NO_SHIPPING_UNITS = 1
            CCODE_MISSING     = 2
            OTHERS            = 3.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
* two times the same PO number and PO item numer            "note197073
* -> batch split in delivery (XSPLIT)                       "note197073
  SORT XVEPWE BY EBELN EBELP VBELN POSNR.                   "note197073
  READ TABLE XVEPWE INDEX 1.                                "note197073
  IF SY-SUBRC IS INITIAL.                                   "note197073
    REF_EBELN = XVEPWE-EBELN.                               "note197073
    REF_EBELP = XVEPWE-EBELP.                               "note197073
    LOOP AT XVEPWE FROM 2.                                  "note197073
      IF XVEPWE-EBELN EQ REF_EBELN AND                      "note197073
         XVEPWE-EBELP EQ REF_EBELP.                         "note197073
        XSPLIT = X.                                         "note197073
        EXIT.                                               "note197073
      ENDIF.                                                "note197073
      REF_EBELN = XVEPWE-EBELN.                             "note197073
      REF_EBELP = XVEPWE-EBELP.                             "note197073
    ENDLOOP.                                                "note197073
  ENDIF.                                                    "note197073

ENDFORM.