*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_COPY_SERIAL_NUMBERS_
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  copy_serial_numbers_from_po
*&---------------------------------------------------------------------*
*       This form copies serial numbers from purchase orders into
*       inbound deliveries. The following restriction exist:
*       - Serial numbers for partially delivered scheduling lines are
*         copied as reference only. A manual check of the serial numbers
*         is required.
*       - Items with batch management need batch assigned. Else skip.
*----------------------------------------------------------------------*
FORM copy_serial_numbers_from_po
     USING is_xlikp TYPE likpvb.

  DATA: lt_eket               TYPE STANDARD TABLE OF eket,
        lf_message            TYPE c,
        lf_ebelp              TYPE ebelp,
        lf_anzsn              TYPE risa0-anzahl,
        lf_quantity           TYPE lips-lfimg,
        lf_vorgang            TYPE tj01-vrgng.

  FIELD-SYMBOLS: <ls_eket> TYPE eket.

  LOOP AT xlips WHERE vbeln EQ is_xlikp-vbeln
                  AND updkz NE updkz_delete.

    CHECK: xlips-vgbel NE space AND
           xlips-vgtyp EQ vbtyp_bestell AND
           xlips-serail NE space.                         "n_1269661.

*   Batch management required but batch not given by PO
    IF xlips-xchpf EQ charx AND
       xlips-xchar EQ charx AND
       xlips-charg IS INITIAL.
       IF 1 = 2. MESSAGE w745 WITH lips-vgbel lips-vgpos. ENDIF.
       PERFORM message_vbfs_aufbauen USING space
                                           lips-posnr
                                           '745'
                                           'W'
                                           'VL'
                                           xlips-vgbel
                                           xlips-vgpos
                                           space
                                           space.
      CONTINUE.
    ENDIF.

    slips-tabix = sy-tabix.
    ilips-tabix = sy-tabix.

    PERFORM lips_bearbeiten_vorbereiten(sapfv50p).

*   determine lf_vorgang
    PERFORM sn_status_operation_determine(sapfv50w)
                                  USING    likp-vbtyp
                                           tvlk-aufer
                                           lips
                                           space
                                  CHANGING lf_vorgang.

*   ...needed to avoid type conflicts
    lf_ebelp = lips-vgpos.

    CALL FUNCTION 'ME_EKET_SINGLE_READ_ITEM'
      EXPORTING
        pi_ebeln            = lips-vgbel
        pi_ebelp            = lf_ebelp
      TABLES
        pto_eket            = lt_eket
      EXCEPTIONS
        err_no_record_found = 1
        OTHERS              = 2.

    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    SORT lt_eket BY ebeln ebelp eindt.
    lf_quantity = lips-lfimg.
    lf_message  = space.

    LOOP AT lt_eket ASSIGNING <ls_eket>.
*     If scheduling line is partially completed serial numbers are
*     copied as reference only for this specific PO item
*     --> Manual check is required
      IF <ls_eket>-dabmg NE 0 AND
         <ls_eket>-dabmg LT <ls_eket>-menge.
        lf_message = charx.
        EXIT.
      ENDIF.
      SUBTRACT <ls_eket>-menge FROM lf_quantity.
    ENDLOOP.

    IF lf_message NE space.
*     Serial numbers are copied as reference only. Manual check is required.
      IF 1 = 2. MESSAGE w743 WITH lips-vgbel lips-vgpos space space. ENDIF.
      PERFORM message_vbfs_aufbauen USING space
                                          lips-posnr
                                          '743'
                                          'W'
                                          'VL'
                                          lips-vgbel
                                          lips-vgpos
                                          <ls_eket>-etenr
                                          space.
    ENDIF.

    CHECK NOT lt_eket[] IS INITIAL.

    LOOP AT lt_eket ASSIGNING <ls_eket>.

*   ...needed to avoid type conflicts
      lf_anzsn = lips-lgmng.

      CALL FUNCTION 'SERIAL_COPY_PO_LS'
        EXPORTING
          profile                    = lips-serail
          material                   = lips-matnr
          quantity                   = lf_anzsn
          j_vorgang                  = lf_vorgang
          i_ebeln                    = <ls_eket>-ebeln
          i_ebelp                    = <ls_eket>-ebelp
          i_etenr                    = <ls_eket>-etenr
          i_lief_nr                  = lips-vbeln
          i_lief_pos                 = lips-posnr
          i_debitor                  = is_xlikp-kunnr
          i_vbtyp                    = is_xlikp-vbtyp
          i_bwart                    = lips-bwart
          i_m_charge                 = <ls_eket>-charg
*         I_BSTCH                    =
       IMPORTING
         anzsn                       = lips-anzsn
       EXCEPTIONS
         objectlist_not_found        = 1
         OTHERS                      = 2.

      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    IF *lips NE lips.
      PERFORM xlips_aendern(sapfv50p).
    ENDIF.

  ENDLOOP.

ENDFORM.                    " copy_serial_numbers_from_po