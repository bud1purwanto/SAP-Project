*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WE_NEU                                        *
*---------------------------------------------------------------------*
*        Die Fusszeile fuer die Transaktionen Wareneingang zur        *
*        Bestellung bei Neueingabe der Bestellung wird bearbeitet.    *
*---------------------------------------------------------------------*
FORM fusszeile_we_neu.
  DATA I_NOT_VALID TYPE C.                                      "614370
  CHECK t158-trtyp = h.
  CHECK fcausw-xneup NE space OR fcausw-xselp NE space.
  IF NOT rm07m-ebeln IS INITIAL.
    CLEAR dm07m.
    CLEAR vm07m.
    CLEAR mseg.
    PERFORM bewegungsart_pruefen(sapfm07m) USING rm07m-bwart
                                                 space.
    PERFORM bestellung_pruefen USING rm07m-ebeln
                                     rm07m-ebelp
                                     rm07m-lfbja
                                     rm07m-lfbnr
                                     rm07m-lfpos
                                      mseg-shkzg
                                     rm07m-werks
                                     vm07m-kzwes
                                     space
                                     I_NOT_VALID.               "614370

*   SPE ST 27.01.2005 VL-MM Consistency
*   Only the material document should be proposed, for which the goods
*   receipt is possible
    IF /SPE/CL_CUST=>IS_VL_MM_ACTIVE( ) =  'X' AND          "v_n_1248915
                             IM_PROCESS <> 'L' AND "delivery posts
                             XDELIV     <> 'X' AND "delivery is created
                             MKPF-BFWMS <> '1' AND          "^_n_1248915
                             T156-KZWES <> 'S'.    "2-step-GR  n_1373027
      DATA:
        l_tabix                TYPE sy-tabix,
        l_erfmg                TYPE MSEG-ERFMG,
        l_asn_bad_for_gr_bwart TYPE xfeld,
        ls_xebefu              LIKE LINE OF xebefu,
        lt_prot                TYPE sprot_u_tab.

      LOOP AT xebefu INTO ls_xebefu.
        l_tabix = sy-tabix.
        IF NOT ( ls_xebefu-vbeln_vl IS INITIAL ) AND
           NOT ( ls_xebefu-vbelp_vl IS INITIAL ).
          l_erfmg = ls_xebefu-lamng - ls_xebefu-lwmng.
          IF l_erfmg > 0.
            CLEAR l_asn_bad_for_gr_bwart.
            IF ls_xebefu-pstyp NE '3' OR t158-kzbew NE 'O'."AP579836
            CALL FUNCTION 'BORWE_VL_MM_CHECK_ASN_WE'
              EXPORTING
                I_VBELN                = ls_xebefu-vbeln_vl
                I_POSNR                = ls_xebefu-vbelp_vl
                I_ERFMG                = l_erfmg
                I_ERFME                = ls_xebefu-bstme
                I_BWART                = rm07m-BWARTWE
              IMPORTING
                E_ASN_BAD_FOR_GR_BWART = l_asn_bad_for_gr_bwart
              TABLES
                ET_PROT               = lt_prot.
            ENDIF.
            IF l_asn_bad_for_gr_bwart = 'X'.
              DELETE xebefu INDEX l_tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    PERFORM bestellung_uebernehmen USING rm07m-ebeln
                                         rm07m-ebelp
                                         rm07m-werks.
  ENDIF.
  CLEAR: rm07m-ebeln, rm07m-ebelp.
ENDFORM.