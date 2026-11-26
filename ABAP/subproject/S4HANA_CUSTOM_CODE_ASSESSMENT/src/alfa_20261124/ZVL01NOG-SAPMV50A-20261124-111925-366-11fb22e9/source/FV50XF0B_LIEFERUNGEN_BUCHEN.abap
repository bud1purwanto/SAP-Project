***INCLUDE FV50xF0B_LIEFERUNG_BUCHEN
*---------------------------------------------------------------------*
*       FORM LIEFERUNG_verBUCHEN_db
*---------------------------------------------------------------------*
FORM lieferungen_verbuchen_db.

  DATA: ls_apoinf LIKE shp_apoinf.                          "APO
  DATA: BEGIN OF lt_sdfields OCCURS 0.
          INCLUDE STRUCTURE atpfield.
  DATA: END OF lt_sdfields.
  DATA: lc_vbtyp_wa(1) TYPE c.

* SPE INB RG 03.12.2004 Write back tables into the ID handling
  DATA: lo_asn TYPE REF TO /spe/cl_id_handling.

  lc_vbtyp_wa = vbtyp_wa(1).

  FIELD-SYMBOLS: <xvbfa> LIKE vbfavb.

  CALL FUNCTION 'ND_EXITS_ACTIVE_CHECK'
    EXCEPTIONS
      exits_not_active = 1
      OTHERS           = 2.

  IF sy-subrc EQ 0.
*       prepare APO relevant informations:
    READ TABLE xvbfa WITH KEY
               vbelv   = likp-vbeln
               BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      LOOP AT xvbfa ASSIGNING <xvbfa> FROM sy-tabix.
        IF <xvbfa>-vbelv NE likp-vbeln.
          EXIT.
        ENDIF.
        IF <xvbfa>-updkz NE updkz_new.
          CONTINUE.
        ENDIF.

        IF <xvbfa>-vbtyp_n = lc_vbtyp_wa.
          ls_apoinf-origin = 'A'.        "posting goods issue
          EXIT.
        ENDIF.
        IF <xvbfa>-vbtyp_n = vbtyp_wa_storno.
          ls_apoinf-origin = 'B'.        "posting goods issue storno
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    PERFORM vbbed_apo_fuellen.
    IF ls_apoinf-origin EQ 'A'.
      PERFORM yvbbe_apo_rework.
    ENDIF.
*   APO need transacton guid either from precessor interface or
*   from own application.
    IF v50agl-apotrguid IS INITIAL.         "no trguid from interface
      CALL FUNCTION 'TRANSACTION_HANDLING'
        EXPORTING
          im_trfct       = 'l'
        CHANGING
          ch_trguid      = v50agl-apotrguid
        EXCEPTIONS
          internal_error = 1
          OTHERS         = 2.
    ENDIF.

    PERFORM apo_build_sdfields
         TABLES lt_sdfields
         USING  ls_apoinf-origin.

  ENDIF.                       "End of APO interface data

  %x.                                                 "#EC NOBREAK "AIP

  IF ( /SPE/CL_CTRL=>IS_EWM( I_LGNUM = XLIKP-LGNUM ) = GC_TRUE OR              "v_n_1233529
   /SPE/CL_CTRL=>IS_ACTIVE_VL60_DISPATCH( I_LGNUM = XLIKP-LGNUM ) = GC_TRUE )
    AND XLIKP-VBTYP CA VBTYP_LIAV
   OR XLIKP-SPE_LE_SCENARIO EQ GC_LE_SCENARIO-TPOP.
*   Write back was already done during the dispatching
  ELSE.                                                                          "n_1456119
*   SPE INB ST/RG Write back tables into the ID handling
    LO_ASN ?= /SPE/CL_INB_ACTION_INFO=>GET_OBJECT(
       I_NAME = /SPE/CL_INB_ACTION_INFO=>C_OBJ_DELIVERY ).
    IF NOT LO_ASN IS INITIAL.
*     Fill the delivery tables from the CORE
      read table xlikp into lo_asn->as_likp index 1.
      read table xvbuk into lo_asn->as_vbuk index 1.
      lo_asn->at_lips[]   = xlips[].
      lo_asn->at_vbadr[]  = xvbadr[].
      lo_asn->at_vbapf[]  = xvbapf[].
      lo_asn->at_vbfa[]   = xvbfa[].
      lo_asn->at_vbpa[]   = xvbpa[].
      lo_asn->at_vbup[]   = xvbup[].
      lo_asn->at_vbuv[]   = xvbuv[].
    ENDIF.
  ENDIF.                                                                       "^_n_1233529

  IF v50agl-synchron = space.
ENHANCEMENT-SECTION     lieferungen_verbuchen_db_01 SPOTS es_fv50xf0b_lieferungen_buchen INCLUDE BOUND.
    CALL FUNCTION 'RV_DELIVERIES_SAVE' IN UPDATE TASK
      EXPORTING
        ip_mult          = v50agl-mult
        ip_split         = v50agl-split
        is_apoinf        = ls_apoinf
        ip_apotrguid     = v50agl-apotrguid
        if_create_uclief = v50agl-create_uclief              "AIP
      TABLES
        fxlikp_t         = xlikp
        fxlips           = xlips
        fxvbapf          = xvbapf
        fxvbfa           = xvbfa
        fxvbpa           = xvbpa
        fxvbuk           = xvbuk
        fxvbup           = xvbup
        fxvbuv           = xvbuv
        fxvbbe           = xvbbe
        fxapoi           = lt_sdfields
        fxvbbs           = xvbbs
        fylikp_t         = ylikp
        fylips           = ylips
        fyvbfa           = yvbfa
        fyvbpa           = yvbpa
        fyvbuk           = yvbuk
        fyvbup           = yvbup
        fyvbuv           = yvbuv
        fyvbbe           = yvbbe
        fyvbbs           = yvbbs
        fxsadr           = xvbadr
        fysadr           = yvbadr
        fxkomv           = tkomv.
END-ENHANCEMENT-SECTION.
  ELSE.
*   Wichtig, bei WM-Transportauftragsrückmeldung muß synchron
*   ohne COMMIT verbucht werden !!!!
ENHANCEMENT-SECTION     lieferungen_verbuchen_db_02 SPOTS es_fv50xf0b_lieferungen_buchen INCLUDE BOUND.
    CALL FUNCTION 'RV_DELIVERIES_SAVE'
      EXPORTING
        ip_mult          = v50agl-mult
        ip_split         = v50agl-split
        is_apoinf        = ls_apoinf
        ip_apotrguid     = v50agl-apotrguid
        if_create_uclief = v50agl-create_uclief              "AIP
      TABLES
        fxlikp_t         = xlikp
        fxlips           = xlips
        fxvbapf          = xvbapf
        fxvbfa           = xvbfa
        fxvbpa           = xvbpa
        fxvbuk           = xvbuk
        fxvbup           = xvbup
        fxvbuv           = xvbuv
        fxvbbe           = xvbbe
        fxapoi           = lt_sdfields
        fxvbbs           = xvbbs
        fylikp_t         = ylikp
        fylips           = ylips
        fyvbfa           = yvbfa
        fyvbpa           = yvbpa
        fyvbuk           = yvbuk
        fyvbup           = yvbup
        fyvbuv           = yvbuv
        fyvbbe           = yvbbe
        fyvbbs           = yvbbs
        fxsadr           = xvbadr
        fysadr           = yvbadr
        fxkomv           = tkomv
      EXCEPTIONS
        error_message    = 99.                              "v_n_525602
END-ENHANCEMENT-SECTION.

    IF sy-subrc = 99.
      MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.                                                  "^_n_525602
  ENDIF.

*  IDoc an Transportplanungssysteme senden, wenn Beleg gelöscht
*  wird und bereits versandt wurde
  IF ylikp_updkz = updkz_delete
    OR ( xvbuk-trsta = space AND yvbuk-trsta <> space ).
    CALL FUNCTION 'SD_TPS_DELIV_DELETE_IDOC'
      EXPORTING
        vbeln  = likp-vbeln
        commit = space
      EXCEPTIONS
        OTHERS = 1.
    CALL FUNCTION 'LE_CFP_DELIV_DELETE_IDOC'
      EXPORTING
        vbeln  = likp-vbeln
        commit = space
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.


ENDFORM.                    "LIEFERUNGEN_VERBUCHEN_DB