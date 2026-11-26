*----------------------------------------------------------------------*
*          Serialnummernpflicht wird geprüft.                          *
*----------------------------------------------------------------------*
FORM serialnummern_pruefen.

* check not ( xdeliv = x and vm07m-xstor  = '1' ).     "note 305993  "n1031590
** handling-unit-kriterium:                                  "HUM    "n1031590
*  CHECK ( xdeliv IS INITIAL OR xdeliv = '1' ) OR            "HUM    "n1031590
*        ( xdeliv = x AND NOT xbapi IS INITIAL ).            "HUM    "n1031590
* take over serial numbers only for slocs without HU                 "n1031590
  CHECK t001l-xhupf is initial.                                      "n1031590

  DATA: lv_process_serial TYPE abap_bool.                   "EhP604

  DATA: zanzsn LIKE mseg-menge.
  DATA: eanzsn LIKE mseg-menge.

  CLEAR xanzsn.
  IF NOT dm07m-sernp IS INITIAL.
    PERFORM serialpflicht_ermitteln.
ENHANCEMENT-POINT MM07MSE0_SERIALNUMMERN_PRUE_01 SPOTS ES_MM07MSE0_SERIALNUMMERN_PRUE INCLUDE BOUND.
    IF NOT xmbwl IS INITIAL AND xbapi IS INITIAL AND xmigo IS INITIAL
       AND xcanc IS INITIAL                                 "note419362
       AND mseg-kzbew IS INITIAL AND im_process IS INITIAL
       AND i_t377-serpflicht = ndrei
       AND t158-vgart NE vgart_wq
       AND t158-vgart NE vgart_wi
       AND t158-vgart NE vgart_wh
       AND mseg-bwart NE bwart_340                          "955370
       AND mseg-bwart NE bwart_341
       AND mseg-bwart NE bwart_342
       AND t158-vgart NE vgart_ws.
      MESSAGE e175.
    ENDIF.
    CHECK xmbwl IS INITIAL OR
          ( NOT xmbwl IS INITIAL AND NOT xbapi IS INITIAL ) OR
*        ( NOT XCANC IS INITIAL AND T158-VGART = VGART_WS ). "note172578
* The following line replaces the correction made by note 172578.    "ac
          ( NOT xmbwl IS INITIAL AND NOT xcanc IS INITIAL
            AND im_process <> l                                "ac temp
             ) OR
          ( NOT xmbwl IS INITIAL AND NOT xmigo IS INITIAL ).
*    IF NOT i_t377-serpflicht IS INITIAL.                  "929713
    IF i_t377-serpflicht NE '01'.                           "929713
      xanzsn = mseg-menge / 1000.
      zanzsn = xanzsn * 1000.
      eanzsn = mseg-menge - zanzsn.
      IF eanzsn >< null.
*     BEGIN OF NOTE 1639087                                    "1639087
      CALL FUNCTION 'MB_CHECK_T160M'
         EXPORTING
              i_arbgb  = 'M7'
              i_msgnr  = '172'
              i_output = space
         IMPORTING
              rc       = rc.
      IF rc = 0.
*         new logic, allow decimal quantities for optional serial
          IF i_t377-serpflicht NE '02'.
            MESSAGE e172.
          ELSEIF ( i_t377-serpflicht EQ '02' AND ccode EQ ccod-nser )
*           issue message if serial number popup is requested
            OR ( i_t377-serpflicht EQ '02' AND
                 dm07m-anzsn IS NOT INITIAL AND xmbwl IS INITIAL ).
*           issue message if serial number is already there and the
*           quantity will be changed afterwards again
        MESSAGE e172.
      ENDIF.
      ELSE.
*         never allow decimal quantities
          MESSAGE e172.
        ENDIF.
*     END OF NOTE 1639087                                      "1639087
      ENDIF.

*--begin of changes EhP604---------------------------------------------------
*     the recent and unreadable monster IF command was
*     hashed into small IF commands
*      IF ( NOT dm07m-anzsn EQ xanzsn AND
*           i_t377-serpflicht EQ ndrei ) OR
**          NDREI = Serialnummernpflicht
*         ( NOT dm07m-anzsn EQ xanzsn AND
*           i_t377-serpflicht EQ nzwei
*         AND ( MSEG-KZBEW = F OR
**               mseg-kzbew = l added for delivery items which have been
**               added in the delivery (not contained in the PO)
*               ( ( mseg-kzbew = b or mseg-kzbew = l ) AND    "note385402
*               NOT vm07m-vbeln IS INITIAL ) ) ) OR           "note385402
**          NZWEI = Serialnummern kann sein
**          MSEG-KZBEW = B eingefuegt fuer WE zur Lief. mit mb0a
*         ( NOT dm07m-anzsn EQ xanzsn AND
*           i_t377-serpflicht EQ nzwei AND
*           NOT xbapi IS INITIAL ) OR
**          NZWEI = Serialnummern kann sein + BAPI: dann für alle KZBEW
*         ( NOT dm07m-anzsn EQ xanzsn AND
*           i_t377-serpflicht EQ nzwei AND
*           NOT xmigo IS INITIAL ) OR
**          NZWEI = Serialnummern kann sein + MIGO: dann für alle KZBEW
**          during a reversal with optional serial numbers the copy of
**          serial numbers from the original document needs to be started
**          automatically.
**          this if-branch is relevant for mbst and
**          mb_cancel_goods_movement
*         ( i_t377-serpflicht EQ nzwei and                    "note419362
*           vm07m-xstor = 2 ) or                              "note419362
*         ( dm07m-anzsn GT null AND NOT dm07m-anzsn EQ xanzsn ) OR
*           ccode EQ ccod-nser.
*        PERFORM serialnummern_pflegen.
*      ENDIF.

      lv_process_serial = abap_false.

      DO  1 TIMES.
*       use a "dummy" DO loop to make this list of IF
*       commands readable and allow debugging

        IF ( NOT dm07m-anzsn EQ xanzsn AND
           i_t377-serpflicht EQ ndrei ).
*          NDREI = Serialnummernpflicht
          lv_process_serial = abap_true.
          EXIT.
        ENDIF.

        IF  ( NOT dm07m-anzsn EQ xanzsn AND
              i_t377-serpflicht EQ nzwei
              AND ( mseg-kzbew = f OR
*               mseg-kzbew = l added for delivery items which have been
*               added in the delivery (not contained in the PO)
               ( ( mseg-kzbew = b OR mseg-kzbew = l ) AND   "note385402
               NOT vm07m-vbeln IS INITIAL ) ) ).            "note385402
*         NZWEI = Serialnummern kann sein
*         MSEG-KZBEW = B eingefuegt fuer WE zur Lief. mit mb0a
          lv_process_serial = abap_true.
          EXIT.
        ENDIF.

        IF  ( NOT dm07m-anzsn EQ xanzsn AND
            i_t377-serpflicht EQ nzwei AND
            NOT xbapi IS INITIAL ).
*         NZWEI = Serialnummern kann sein + BAPI: dann für alle KZBEW
          lv_process_serial = abap_true.
          EXIT.
        ENDIF.

        IF  ( NOT dm07m-anzsn EQ xanzsn AND
              i_t377-serpflicht EQ nzwei AND
              NOT xmigo IS INITIAL ).
*         NZWEI = Serialnummern kann sein + MIGO: dann für alle KZBEW
          lv_process_serial = abap_true.
          EXIT.
        ENDIF.

*       during a reversal with optional serial numbers the copy of
*       serial numbers from the original document needs to be started
*       automatically.
*       this if-branch is relevant for mbst and
*       mb_cancel_goods_movement
        IF ( i_t377-serpflicht EQ nzwei AND                 "note419362
           vm07m-xstor = 2 ).                               "note419362
          lv_process_serial = abap_true.
          EXIT.
        ENDIF.

        IF ( dm07m-anzsn GT null AND NOT dm07m-anzsn EQ xanzsn ).
          lv_process_serial = abap_true.
          EXIT.
        ENDIF.

        IF  ccode EQ ccod-nser.
          lv_process_serial = abap_true.
          EXIT.
        ENDIF.

*        IF  NOT dm07m-anzsn       EQ xanzsn      AND       "1451997
*                i_t377-serpflicht EQ nzwei       AND       "1451997
*                xbesttyp          EQ ibtyp_avis.           "1451997
**          consider inbound deliveries when posting GR     "1451997
**          using transaction MB0A                          "1451997
*          lv_process_serial = abap_true.                   "1451997
*          EXIT.                                            "1451997
*        ENDIF.                                             "1451997

        IF NOT dm07m-anzsn       EQ xanzsn    AND
               i_t377-serpflicht EQ nzwei     AND
           NOT mseg-ebeln        IS INITIAL   AND
               xmigo             IS INITIAL   AND
               xbapi             IS INITIAL   AND
               CL_MMPUR_SWITCH_CHECK=>get_serial01_switch_state( ) = abap_true.
*         consider movements to a PO including normal and
*         return items during transaction MB01
          lv_process_serial = abap_true.
          EXIT.
        ENDIF.

ENHANCEMENT-POINT EHP604_MM07MSE0_SERIALNUMME_01 SPOTS ES_MM07MSE0_SERIALNUMMERN_PRUE INCLUDE BOUND .

      ENDDO.

*     evaluate the result : do or not do ?
      IF  lv_process_serial = abap_true.
*       process the serial numbers
        PERFORM serialnummern_pflegen.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "serialnummern_pruefen