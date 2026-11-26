*----------------------------------------------------------------------*
*     Serialnummern kopieren aus Bestellung für WE (LOG_SERNO_MM)      *
*     Form added by note 1523905, shifted from form ser_we_wa          *
*----------------------------------------------------------------------*
FORM ser_po_we.
  DATA: l_flag_copy_serial      TYPE  abap_bool,
        l_anzsn                 TYPE  ser03-anzsn,
        l_anzsn_max             TYPE  ser03-anzsn,
        l_anzsn_sum             TYPE  ser03-anzsn,          "1439646
        l_zeilen_id_copy        TYPE  mesg-zeile,
        l_serial_commit         TYPE  c,
        l_status_not_allowed    TYPE  c,
        lt_eket                 TYPE  STANDARD TABLE OF eket,
        ls_eket_keytab          TYPE  ekbel,
        lt_eket_keytab          TYPE  STANDARD TABLE OF ekbel.

  FIELD-SYMBOLS : <l_fs_eket>    TYPE  eket.

* function : suggest serial numbers from PO MM 11/200
  IF cl_mmpur_switch_check=>get_serial01_switch_state( ) = abap_false.
    RETURN.
  ENDIF.

* in the case a GR is posted for material with serial
* numbers profile look for and copy the serial numbers
* whose are assigned to the EKET Scheduling Agreement
* Schedule Lines EKET of the current PO item

  l_flag_copy_serial = abap_false.
* check for allowed serial processes with PO
  IF  im_process IS INITIAL  AND      " not in a delivery process
      mseg-ebeln IS NOT INITIAL AND   " for PO          "1444106
      strtyp     <> a        AND      " no display transaction
      vm07m-xstor <> 2.               " no cancel process.

    IF  dm07m-reswk IS INITIAL.
*     GR for a normal PO
      IF  xbesttyp NE ibtyp_avis.
*       PO has no inbound delivery
        l_flag_copy_serial = abap_true.
      ENDIF.
    ELSE.
*     GR for stock transfer PO
      IF  g_flag_message_m7352 = abap_true.
*       GR without reference to the related delivery
        l_flag_copy_serial = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT l_flag_copy_serial = abap_true.
    RETURN.
  ENDIF.

* read the Scheduling Agreement Schedule Lines EKET of the
* current PO item
  MOVE-CORRESPONDING  mseg TO ls_eket_keytab.
  APPEND ls_eket_keytab TO lt_eket_keytab.

  CALL FUNCTION 'ME_EKET_ARRAY_READ_ITEM'
*     EXPORTING
*     PI_BYPASSING_BUFFER        =
*     PI_REFRESH_BUFFER          =
    TABLES
      pti_eket_keytab            = lt_eket_keytab
      pto_eket_tab               = lt_eket
    EXCEPTIONS
      OTHERS                     = 1.

  IF NOT sy-subrc IS INITIAL.
    RETURN.
  ELSE.
*   schedule lines found -> go on
  ENDIF.

  SORT lt_eket.
* look for all assigned serial numbers for the selection
  l_anzsn_max = 999999999.

  LOOP AT lt_eket ASSIGNING <l_fs_eket>.
* carry out this function moudule for all EKET entries

    CALL FUNCTION 'SERIAL_COPY_PO_MM'
         EXPORTING
           profile                  = dm07m-sernp
           material                 = matnum
           quantity                 = l_anzsn_max
           j_vorgang                = vm07m-vrgng
           i_ebeln                  = mseg-ebeln
           i_ebelp                  = mseg-ebelp
           i_etenr                  = <l_fs_eket>-etenr
           mblnr                    = smblnr
           mjahr                    = mkpf-mjahr
           zeile                    = mseg-zeile
           blart                    = mkpf-blart
           bwart                    = mseg-bwart
           shkzg                    = mseg-shkzg
           m_werk                   = mseg-werks
           m_lager                  = mseg-lgort
           l_charge                 = mseg-charg            "1131392
           m_charge                 = charge
           kreditor                 = mseg-lifnr
*          DEBITOR                  =
           bstch                    = bstch
           bstup                    = bstup
*          R_MATERIAL               =
           i_operation              = 'MMSL'
           budat                    = mkpf-budat
*          KMATNR                   =
*          CUOBJ                    =
*          EMATN                    =
*          KDAUF                    =
*          KDPOS                    =
           snbwg                    = s156s-snbwg
         IMPORTING
           anzsn                    = l_anzsn
           zeilen_id                = l_zeilen_id_copy
           serial_commit            = l_serial_commit
           status_not_allowed       = l_status_not_allowed
         EXCEPTIONS
           OTHERS                   = 1.

    IF sy-subrc <> 0.
*     no action in the case when no entries have been found
    ENDIF.
    l_anzsn_sum = l_anzsn_sum + l_anzsn.                    "1439646
  ENDLOOP.

  dm07m-anzsn = l_anzsn_sum.                                "1523905

  IF upd_seri IS INITIAL.
    upd_seri = l_serial_commit.
  ENDIF.

ENDFORM.                    " SER_PO_WE