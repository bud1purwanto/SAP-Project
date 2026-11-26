*&---------------------------------------------------------------------*
*&  Include           PARCHI04                                         *
*&---------------------------------------------------------------------*


*&--------------------------------------------------------------------*
*&      Form  orders_select
*&--------------------------------------------------------------------*
FORM orders_select USING i_autyp.

  DATA: r_loekz TYPE RANGE OF caufv-loekz,
        BEGIN OF lt_deleted_orders OCCURS 0,
          objnr LIKE jest-objnr,
        END OF lt_deleted_orders,
        BEGIN OF lt_aut_check OCCURS 0,
          auart TYPE caufv-auart,
          werks TYPE caufv-werks,
        END OF lt_aut_check.

  FIELD-SYMBOLS: <ls_caufv> TYPE caufv.

  GET TIME FIELD starttime.

* Soll/Istliefertermin bis
  aedatv = '99991231'.
  IF NOT interval IS INITIAL.
    aedatv = sy-datum - interval.
    ltrmi = 'ENB00010101'.
    ltrmi-high = aedatv.
    APPEND ltrmi.
  ELSEIF NOT ltrmi[] IS INITIAL.
    ltrmi = 'EEQ'.
    CLEAR ltrmi-low.
    CLEAR ltrmi-high.
    APPEND ltrmi.
  ENDIF.
ENHANCEMENT-POINT PARCHI04_01 SPOTS ES_PARCHI04 STATIC INCLUDE BOUND.
ENHANCEMENT-POINT PARCHI04_02 SPOTS ES_PARCHI04 INCLUDE BOUND.

  CLEAR r_loekz[].
* -> wenn nur gv_loeV angewählt wurde, dann muß das Löschkennzeichen
* -> auf blank sitzen
  IF     set_loev = 'X'
     AND set_loek IS INITIAL.                                "Fall 1
    APPEND 'IEQ ' TO r_loekz.
* -> wenn nur SET_LQEK angewählt wurde, dann muß das Löschkennzeichen
* -> auf 'X' sitzen
  ELSEIF     set_loev IS INITIAL
         AND set_loek = 'X'.                                 "Fall 2
    APPEND 'IEQX' TO r_loekz.
* -> wenn beides angewählt wurde, dann darf das Löschkennzeichen
* -> nicht berücksichtigt werden
*  ELSEIF      set_loev = 'X'
*          AND set_loek = 'X'.                             "Fall 3
*   R_LOEKZ remains empty ==> LOEKZ = X and space is selected
  ENDIF.

* check range aufnr, if it only contains single values, including
  DESCRIBE TABLE aufnr LINES sy-tfill.
  LOOP AT aufnr WHERE sign   <> 'I'
                   OR option <> 'EQ'.
    EXIT.
  ENDLOOP.
* The value of the delivery date in  caufv is not reliable, it
* may happen that this value is empty or wrong. The delivery date
* stored in item-data is correct.
  IF    aufnr[]  IS INITIAL
     OR sy-tfill <  100
     OR sy-subrc IS INITIAL.
*   range aufnr is initial or contains less than 100 entries
*   or it contains entries <> IEQ
ENHANCEMENT-SECTION     PARCHI04_03 SPOTS ES_PARCHI04 INCLUDE BOUND.
    IF NOT ltrmi[] IS INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE caufv_tab
                 from caufv JOIN afpo
                          ON caufv~aufnr = afpo~aufnr
                            AND afpo~posnr = '0001'
                          WHERE caufv~aufnr IN aufnr
                            AND autyp =  i_autyp
*                           only leading order will be read
                            AND (    maufnr  =  space
                                  OR maufnr  IS NULL
                                  OR prodnet =  space
                                  OR prodnet IS NULL  )
                            AND loekz IN r_loekz
                            AND werks IN werks
                            AND auart IN auart
                            AND dispo IN dispo
                            AND fevor IN fevor
                            AND gstrp IN gstrp
                            AND gltrp <= aedatv
                            AND ltrmi IN ltrmi.
    ELSE.
      SELECT * FROM caufv INTO TABLE caufv_tab
                          WHERE aufnr IN aufnr
                            AND autyp =  i_autyp
*                           only leading order will be read
                            AND (    maufnr  =  space
                                  OR maufnr  IS NULL
                                  OR prodnet =  space
                                  OR prodnet IS NULL  )
                            AND loekz IN r_loekz
                            AND werks IN werks
                            AND auart IN auart
                            AND dispo IN dispo
                            AND fevor IN fevor
                            AND gstrp IN gstrp
                            AND gltrp <= aedatv.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ELSE.
*   range aufnr only contains IEQ => select by aufnr-low to avoid
*   dump SAPSQL_STMNT_TOO_LARGE
ENHANCEMENT-SECTION     PARCHI04_04 SPOTS ES_PARCHI04 INCLUDE BOUND.
    IF NOT ltrmi[] IS INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE caufv_tab
                 from caufv JOIN afpo
                          ON caufv~aufnr = afpo~aufnr
                            AND afpo~posnr = '0001'
                          FOR ALL ENTRIES IN aufnr
                          WHERE caufv~aufnr = aufnr-low
                            AND autyp = i_autyp
*                           only leading order will be read
                            AND (    maufnr  =  space
                                  OR maufnr  IS NULL
                                  OR prodnet =  space
                                  OR prodnet IS NULL  )
                            AND loekz IN r_loekz
                            AND werks IN werks
                            AND auart IN auart
                            AND dispo IN dispo
                            AND fevor IN fevor
                            AND gstrp IN gstrp
                            AND gltrp <= aedatv
                            AND ltrmi IN ltrmi.
    ELSE.
      SELECT * FROM caufv INTO TABLE caufv_tab
                          FOR ALL ENTRIES IN aufnr
                          WHERE aufnr = aufnr-low
                            AND autyp = i_autyp
*                           only leading order will be read
                            AND (    maufnr  =  space
                                  OR maufnr  IS NULL
                                  OR prodnet =  space
                                  OR prodnet IS NULL  )
                            AND loekz IN r_loekz
                            AND werks IN werks
                            AND auart IN auart
                            AND dispo IN dispo
                            AND fevor IN fevor
                            AND gstrp IN gstrp
                            AND gltrp <= aedatv.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ENDIF.

  SORT caufv_tab BY aufnr.

ENHANCEMENT-POINT PARCHI04_05 SPOTS ES_PARCHI04 INCLUDE BOUND.
* Remove all orders from the selection that are already deleted
  IF NOT set_loek IS INITIAL
    AND NOT caufv_tab[] IS INITIAL.
    SELECT objnr FROM jest INTO TABLE lt_deleted_orders
                 FOR ALL ENTRIES IN caufv_tab
                 WHERE objnr = caufv_tab-objnr
                   AND stat  = 'I0013'
                   AND inact = space.
    LOOP AT lt_deleted_orders.
      READ TABLE caufv_tab WITH KEY objnr = lt_deleted_orders-objnr
                           BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE caufv_tab INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
    FREE lt_deleted_orders.
  ENDIF.

* Berechtigung Werk/Auftragsart
  CLEAR lt_aut_check[].
  LOOP AT caufv_tab ASSIGNING <ls_caufv>.
    lt_aut_check-auart = <ls_caufv>-auart.
    lt_aut_check-werks = <ls_caufv>-werks.
    COLLECT lt_aut_check.
  ENDLOOP.

  LOOP AT lt_aut_check.
    CALL FUNCTION 'CO_ZF_AUTHORITY_CHECK'
      EXPORTING
        i_autyp                   = i_autyp
        i_auart                   = lt_aut_check-auart
        i_werks                   = lt_aut_check-werks
        i_aktyp                   = '06'
        i_chk_cat_act             = space
      EXCEPTIONS
        no_auth_cat_act           = 1
        no_auth_type_plant        = 2
        no_auth_cat_typ_plant_act = 3
        incorrect_parameters      = 4
        OTHERS                    = 5.
    IF NOT sy-subrc IS INITIAL.
      CLEAR lt_mess.
      lt_mess-arbgb = sy-msgid.
      lt_mess-msgty = sy-msgty.
      lt_mess-msgnr = sy-msgno.
      lt_mess-msgv1 = sy-msgv1.
      lt_mess-msgv2 = sy-msgv2.
      lt_mess-msgv3 = sy-msgv3.
      lt_mess-msgv4 = sy-msgv4.
      lt_mess-spras = sy-langu.
      lt_mess-dupcount = 1.
      lt_mess-phase = '-'.             "wegen Sortierreihenfolge
      IF sy-msgno = '883'.
        CONCATENATE lt_mess-msgv1 ' (C_AFKO_AWA)' INTO lt_mess-msgv1.
      ENDIF.
      APPEND lt_mess.
      DELETE caufv_tab WHERE auart = lt_aut_check-auart
                         AND werks = lt_aut_check-werks.
    ENDIF.
  ENDLOOP.
  FREE lt_aut_check.

  IF     caufv_tab[] IS INITIAL
     AND lt_mess[]   IS INITIAL.
    CLEAR lt_mess.
    lt_mess-arbgb = 'CO'.
    lt_mess-msgty = 'I'.
    lt_mess-msgnr = '176'.
    lt_mess-spras = sy-langu.
    lt_mess-dupcount = 1.
    lt_mess-phase = '-'.               "wegen Sortierreihenfolge
    APPEND lt_mess.
  ENDIF.

ENDFORM.                    "orders_select