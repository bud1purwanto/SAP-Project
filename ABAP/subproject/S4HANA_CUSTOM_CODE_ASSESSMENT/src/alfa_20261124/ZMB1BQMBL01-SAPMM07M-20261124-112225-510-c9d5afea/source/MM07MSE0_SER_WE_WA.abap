*----------------------------------------------------------------------*
*     Serialnummern für WE zur Bestellung und sonstige Warenbew.       *
*----------------------------------------------------------------------*
FORM ser_we_wa USING cuobj LIKE dm07m-cuobj
                     stdpd LIKE dm07m-stdpd.
  DATA: l_zeilen_id LIKE  mesg-zeile,
        l_t_mesg LIKE smesg OCCURS 0,                       "449318
        l_s_mesg_first_error LIKE smesg,                    "449318
        l_s_mesg LIKE smesg,
        l_msgno LIKE sy-msgno,
        l_dummy(72),
        l_msg_sent TYPE c,
        l_upd_seri TYPE c,                                  "note333842
        l_exit_flag TYPE c,                                 "624195
        l_is_solution TYPE xfeld.


ENHANCEMENT-POINT MM07MSE0_SER_WE_WA_02 SPOTS ES_MM07MTOP STATIC .

  IF xbapi IS INITIAL AND xmigo IS INITIAL.
    IF mkpf-vgart = vgart_wi.
      PERFORM serialnumber_show_inv.
    ELSEIF l_is_solution IS INITIAL AND mseg-maa_urzei IS INITIAL OR
         ( l_is_solution IS INITIAL AND NOT mseg-maa_urzei IS INITIAL"MAA2
                                    AND NOT aktyp = 'A' ) .          "MAA2
      CALL FUNCTION 'SERIALPROFILE_CHECK'
           EXPORTING
                activity      = strtyp
                debitor       = mseg-kunnr                  "HW637667
*               material      = mseg-matnr
                material      = matnum
                ematn         = mseg-ematn
*               r_material    = mseg-ummat
                r_material    = ummatnum
                operation     = op_mmsl
                j_vorgang     = vm07m-vrgng
                profile       = dm07m-sernp
                quantity      = xanzsn
                mblnr         = smblnr
                mjahr         = mkpf-mjahr
                zeile         = mseg-zeile
                blart         = mkpf-blart
                bwart         = mseg-bwart
                shkzg         = mseg-shkzg
                lieferant     = mseg-lifnr
                m_werk        = mseg-werks
                m_lager       = mseg-lgort
                l_charge      = mseg-charg                      "1131392
                m_charge      = charge
*               DOCUMENT      = MSEG-MAT_KDAUF
*               ITEM          = MSEG-MAT_KDPOS
                document      = mseg-kdauf
                item          = mseg-kdpos
                kmatnr        = stdpd
                cuobj         = cuobj
*               kmatnr        = dm07m-stdpd
*               cuobj         = dm07m-cuobj
                snbwg         = s156s-snbwg
                bstch         = bstch
                bstup         = bstup
                budat         = mkpf-budat
           IMPORTING
                anzsn         = dm07m-anzsn
                exit_flag     = l_exit_flag.                "624195

*     In case of posting exit transaction if cancel has been     "624195
*     selected on the serial popup.                              "624195
      IF NOT l_exit_flag IS INITIAL AND fcode_next = fcod-bu.    "624195
        MESSAGE s428.                                            "624195
        LEAVE TO TRANSACTION sy-tcode.                           "624195
      ENDIF.                                                     "624195
    ELSEIF NOT mseg-maa_urzei IS INITIAL.                         "MAA2
      TYPES: BEGIN OF ty_zeile,                                   "MAA2
               zeile TYPE mseg-zeile,                             "MAA2
              xanzsn TYPE risa0-anzahl,                           "MAA2
             END OF ty_zeile.                                     "MAA2
      DATA: lt_zeile            TYPE  TABLE OF ty_zeile,          "MAA2
            ls_zeile            TYPE  ty_zeile,                   "MAA2
            lo_mmim_maa_2       TYPE  REF TO cl_mmim_maa_2,       "MAA2
            lt_mseg_refdoc      type  mb_mseg,                    "MAA2
            ls_mseg_refdoc      type  mseg,                       "MAA2
            anzsn               type  dm07m-anzsn.                "MAA2
      FIELD-SYMBOLS: <fs_zeile> TYPE  ty_zeile.                   "MAA2
      CALL METHOD cl_mmim_maa_2=>get_singleton_instance           "MAA2
        RECEIVING                                                 "MAA2
          ro_singleton = lo_mmim_maa_2.                           "MAA2
      CALL METHOD lo_mmim_maa_2->maa_read_mseg_refdoc             "MAA2
                 IMPORTING                                        "MAA2
                 et_mseg_refdoc       = lt_mseg_refdoc[].         "MAA2
*     get line from original mseg                                 "MAA2
      LOOP AT lt_mseg_refdoc INTO ls_mseg_refdoc WHERE            "MAA2
                     mblnr      = mseg-mblnr     AND              "MAA2
                     mjahr      = mseg-mjahr     AND              "MAA2
                     maa_urzei  = mseg-maa_urzei AND              "MAA2
                     ebeln      = mseg-ebeln     AND              "MAA2
                     ebelp      = mseg-ebelp.                     "MAA2
        ls_zeile-zeile  = ls_mseg_refdoc-zeile.                   "MAA2
        ls_zeile-xanzsn = ls_mseg_refdoc-menge / 1000.            "MAA2
        APPEND ls_zeile TO lt_zeile.                              "MAA2
      ENDLOOP.                                                    "MAA2
      IF sy-subrc IS INITIAL.   "EHP6 doc                         "MAA2
        clear: anzsn, dm07m-anzsn.                                "MAA2
        LOOP AT lt_zeile ASSIGNING <fs_zeile>.                    "MAA2
          CALL FUNCTION 'SERIALPROFILE_CHECK'                     "MAA2>
               EXPORTING
                    activity      = strtyp
                    debitor       = mseg-kunnr
*                   material      = mseg-matnr
                    material      = matnum
                    ematn         = mseg-ematn
*                   r_material    = mseg-ummat
                    r_material    = ummatnum
                    operation     = op_mmsl
                    j_vorgang     = vm07m-vrgng
                    profile       = dm07m-sernp
                    quantity      = <fs_zeile>-xanzsn             "MAA2
                    mblnr         = smblnr
                    mjahr         = mkpf-mjahr
                    zeile         = <fs_zeile>-zeile              "MAA2
                    blart         = mkpf-blart
                    bwart         = mseg-bwart
                    shkzg         = mseg-shkzg
                    lieferant     = mseg-lifnr
                    m_werk        = mseg-werks
                    m_lager       = mseg-lgort
                    l_charge      = mseg-charg
                    m_charge      = charge
*                   DOCUMENT      = MSEG-MAT_KDAUF
*                   ITEM          = MSEG-MAT_KDPOS
                    document      = mseg-kdauf
                    item          = mseg-kdpos
                    kmatnr        = stdpd
                    cuobj         = cuobj
*                   kmatnr        = dm07m-stdpd
*                   cuobj         = dm07m-cuobj
                    snbwg         = s156s-snbwg
                    bstch         = bstch
                    bstup         = bstup
                    budat         = mkpf-budat
               IMPORTING
                    anzsn         = anzsn                         "MAA2
                    exit_flag     = l_exit_flag.

          dm07m-anzsn = dm07m-anzsn + anzsn.                      "MAA2
*         In case of posting exit transaction if cancel has been
*         selected on the serial popup.
          IF NOT l_exit_flag IS INITIAL AND fcode_next = fcod-bu.
            MESSAGE s428.
            LEAVE TO TRANSACTION sy-tcode.
          ENDIF.
        ENDLOOP.                                                  "MAA2
      ENDIF.                                                      "MAA2<
    ELSE.
*   l_is_solution IS NOT INITIAL
*   industry coding
ENHANCEMENT-POINT EHP604_MM07MSE0_SER_WE_WA_03 SPOTS ES_SAPMM07M.
    ENDIF.
  ELSE.
    CHECK xcanc IS INITIAL.            "no serialno add when CANCEL

*-- Serialnumbers for subcontractor components: (MIGO)           "435377
*   Check if the subcontr. components:                           "435377
*      1. were expanded by MB_CREATE                             "435377
*   or 2. were entered by MIGO                                   "435377
*   Case 1: No serialnumbers could be entered by the user -> e175
*           (e.g. MIGO check/post-button, without expanding the  "435377
*           subcontr. components)                                "435377
*   Case 2: no action neccessary                                 "435377

    IF mseg-kzbew IS INITIAL AND vm07m-pstyp = drei              "435377
           AND dm07m-serial_glc IS INITIAL.                      "435377
*     Serialnumbers obligatory: ERROR                            "435377
      IF i_t377-serpflicht = ndrei.                              "435377
        MESSAGE e175.                                            "435377
*     Serialnumbers optional:   No further processing            "435377
      ELSEIF i_t377-serpflicht = nzwei.                          "435377
        EXIT.                                                    "435377
      ENDIF.                                                     "435377
    ENDIF.                                                       "435377

*   Serialnumbers for subcontractor components: (MIGO)
*   If there are components with serialno., dm07m-serial_glc is filled,
*   Attention: Field 'dm07m-serial_glc' is the line-number which is used
*   in serialnumber-coding (->important information for renumber).
*   note 734758 start
    DATA ls_subcon_parent TYPE ty_subcon_parent.
    IF dm07m-serial_glc IS INITIAL.
      READ TABLE gt_subcon_parent INTO ls_subcon_parent
                                  WITH KEY
                                  global_counter = vm07m-global_counter.
      IF sy-subrc = 0.
        dm07m-serial_glc = ls_subcon_parent-serial_glc.
      ELSE.
        if gt_gocomp[] is not initial.                         "1556746
            dm07m-serial_glc = dm07m-zeild.                    "1556746
        else.                                                  "1556746
            dm07m-serial_glc = dm07m-imseg_original.           "1556746
        endif.                                                 "1556746
      ENDIF.
    ENDIF.
*   note 734758 end

*-- Subcontr.Components: No serialnumbers possible for BAPI      "336545
    IF mseg-kzbew IS INITIAL AND vm07m-pstyp = drei AND xbapi = x.
      IF dm07m-serial_glc IS INITIAL.                            "967187
*     Serialnumbers obligatory: ERROR                            "336545
        IF i_t377-serpflicht = ndrei.                            "336545
          MESSAGE e423.                                          "336545
*     Serialnumbers optional:   No further processing            "336545
        ELSEIF i_t377-serpflicht = nzwei.                        "336545
          EXIT.                                                  "336545
        ENDIF.                                                   "336545
      ENDIF.                                                     "967187
    ENDIF.                                                       "336545

ENHANCEMENT-SECTION     SER_WE_WA_01 SPOTS ES_SAPMM07M.
    CALL FUNCTION 'SERNR_ADD_BAPI_MM'
         EXPORTING
              profile               = dm07m-sernp
*             material              = mseg-matnr
              material              = matnum
              l_charge              = mseg-charg                "1131392
              m_charge              = charge
              m_werk                = mseg-werks
              m_lager               = mseg-lgort
              quantity              = xanzsn
              j_vorgang             = vm07m-vrgng
              kmatnr                = stdpd
              cuobj                 = cuobj
*             kmatnr                = dm07m-stdpd
*             cuobj                 = dm07m-cuobj
              mblnr                 = smblnr
              mjahr                 = mkpf-mjahr
              zeile                 = dm07m-serial_glc          "734758
              kdauf                 = mseg-kdauf
              kdpos                 = mseg-kdpos
*             r_material            = mseg-ummat
              r_material            = ummatnum
              ematn                 = mseg-ematn
              lieferant             = mseg-lifnr
              debitor               = mseg-kunnr
              blart                 = mkpf-blart
              bwart                 = mseg-bwart
              shkzg                 = mseg-shkzg
              snbwg                 = s156s-snbwg
              bstch                 = bstch
              bstup                 = bstup
              automatic             = dm07m-xsaut
              budat                 = mkpf-budat
         IMPORTING
              anzsn                 = dm07m-anzsn
              serial_commit         = l_upd_seri             "note333842
              zeilen_id             = l_zeilen_id
         CHANGING
              T_SMESG               = l_t_mesg                   "449318
         EXCEPTIONS
              konfigurations_error  = 1
              serialnumber_errors   = 2
              OTHERS                = 4.
END-ENHANCEMENT-SECTION.
* if MIGO is active. The first E-message is not sent to the
* application log: it is given here as E-message, stops the processing
* of the current item and will be given to the application log
* through the EMSEG.

* Start of note 449318
    IF sy-subrc <> 0 OR
*      transaction MIGO is also interested in w-messages.
      ( xmigo = x AND NOT l_t_mesg IS INITIAL ).
      LOOP AT l_t_mesg INTO l_s_mesg.
        l_msgno = l_s_mesg-txtnr.
* First E-message is stored in l_t_mseg
        IF l_msg_sent IS INITIAL AND l_s_mesg-msgty = 'E'.
          l_s_mesg_first_error = l_s_mesg.
          l_msg_sent = x.
        ELSE.
* Other messages are transmitted to the Appl Log
          IF xmigo = x.
            PERFORM naco_log(sapfm07m) USING l_s_mesg-msgty
                                l_s_mesg-arbgb
                                l_msgno
                                l_s_mesg-msgv1
                                l_s_mesg-msgv2
                                l_s_mesg-msgv3
                                l_s_mesg-msgv4.
          ENDIF.
        ENDIF.
      ENDLOOP.
* Now give the first E-message to stop the current item (=> EMSEG)
      l_msgno = l_s_mesg_first_error-txtnr.
      IF NOT l_msgno IS INITIAL.
        MESSAGE ID l_s_mesg_first_error-arbgb
                TYPE l_s_mesg_first_error-msgty NUMBER l_msgno
                WITH l_s_mesg_first_error-msgv1
                     l_s_mesg_first_error-msgv2
                     l_s_mesg_first_error-msgv3
                     l_s_mesg_first_error-msgv4.
* end of note 449318
      ENDIF.
    ENDIF.
  ENDIF.
  IF upd_seri IS INITIAL.                                   "note333842
    upd_seri = l_upd_seri.                                  "note333842
  ENDIF.                                                    "note333842
ENDFORM.                    "ser_we_wa