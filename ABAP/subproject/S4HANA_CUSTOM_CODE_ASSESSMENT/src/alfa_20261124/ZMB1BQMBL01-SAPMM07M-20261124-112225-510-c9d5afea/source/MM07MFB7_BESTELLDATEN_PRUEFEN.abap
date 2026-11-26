*&---------------------------------------------------------------------*
*&      Form  BESTELLDATEN_PRUEFEN
*&---------------------------------------------------------------------*
*       Die Belegdaten werden gegen die Bestelldaten geprüft.
*    1. Bei ERS-Verfahren wird der Lieferschein geprüft.               *
*    2. Das letztmögliche WE-Datum aus der Bestellung wird geprüft.    *
*    3. Das (früheste) Lieferdatum aus der Bestellung wird geprüft.    *
*    4. Preisfindung wird geprüft.                                     *
*    5. Delivery flow update required but not possible because VBELN   *
*       missing?                                                       *
*----------------------------------------------------------------------*
  FORM bestelldaten_pruefen.
    CHECK t158-trtyp = h.
    CHECK aktyp = h.
ENHANCEMENT-SECTION     BESTELLDATEN_PRUEFEN_01 SPOTS ES_SAPMM07M.
    CHECK t158-kzbew = b.
END-ENHANCEMENT-SECTION.

*   Check for pricing errors in the purchase order
    IF NOT dm07m-prerr IS INITIAL.
      MESSAGE ID 'ME' TYPE 'E' NUMBER '573' WITH mseg-ebeln
                                                 mseg-ebelp
                                                 dm07m-prerr.
    ENDIF.

*   function : suggest serial numbers from PO                   "1444106
*   delete global flag                                          "1444106
    g_flag_message_m7352 = abap_false.                          "1444106

*   Check for ERS handling
    IF xersy IS INITIAL AND NOT dm07m-xersy IS INITIAL AND
       mkpf-xblnr IS INITIAL.
     IF NOT ( vm07m-xstor = '2' AND dm07m-xstbw = 'X' AND       "1364735
              mseg-insmk ='X' ).                                "1364735
      PERFORM nachrichtencode_ermitteln(sapfm07m) USING 'M7' '245'."ok
      xersy = x.
     ENDIF.                                                     "1364735
    ENDIF.

*   Check for last goods receipt date
    IF NOT dm07m-lewed IS INITIAL AND                            "358454
       NOT dm07m-lewed = ' '      AND                            "358454
           mseg-shkzg = s.                                       "358454
      IF mkpf-budat GT dm07m-lewed.
        CALL FUNCTION 'MB_CHECK_T160M'
             EXPORTING
                  i_arbgb  = 'M7'
                  i_msgnr  = '163'
                  i_msgv1  = dm07m-lewed
                  i_output = space
             IMPORTING
                  rc       = rc.
        CASE rc.
          WHEN 0.
          WHEN 1.
            MESSAGE w163 WITH dm07m-lewed.                "log ok
          WHEN 2.
            IF vm07m-kzwes = s.
              MESSAGE w163 WITH dm07m-lewed.              "log ok
              PERFORM naco_log(sapfm07m) USING 'W' 'M7' '163'
                                     dm07m-lewed space space space.
            ELSE.
              MESSAGE e163 WITH dm07m-lewed.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDIF.

*   Check for earliest delivery date
    IF NOT dm07m-frlfd IS INITIAL AND                            "358454
       NOT dm07m-frlfd = ' '      AND                            "358454
           mseg-shkzg  = s.                                      "358454
      IF mkpf-budat LT dm07m-frlfd.
        CALL FUNCTION 'MB_CHECK_T160M'
             EXPORTING
                  i_arbgb  = 'M7'
                  i_msgnr  = '254'
                  i_msgv1  = dm07m-frlfd
                  i_output = space
             IMPORTING
                  rc       = rc.
        CASE rc.
          WHEN 0.
          WHEN 1.
            MESSAGE w254 WITH dm07m-frlfd.
          WHEN 2.
            IF vm07m-kzwes = s.
              MESSAGE w254 WITH dm07m-frlfd.
            ELSE.
              MESSAGE e254 WITH dm07m-frlfd.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDIF.

*   Delivery flow should be updated but can't because we do not
*   have a delivery number.
*   Inserted with note 358454.
    IF NOT dm07m-reswk IS INITIAL AND     "Stock transfer PO
           vm07m-retpo IS INITIAL AND     "Not for returns positions
           (                              "No delivery number
             vm07m-vbeln IS INITIAL OR
             vm07m-vbelp IS INITIAL
           ) AND
           vm07m-pstyp <> '2' AND         "ST-PO-consignment
                                          "not for consignemnt
                                          "transfers
           cl_mmim_cross_system=>plant_in_own_system(
             dm07m-reswk ) = abap_true.    "Not for cross-system PO's
*     Prefetch entire PO data. This is completely buffered and
*     ensures that every PO's data are only read once from the
*     database. The fact that for a PO no data were present is also
*     buffered.
      CALL FUNCTION 'ME_EKPV_READ_WITH_EBELN'
        EXPORTING
          pi_ebeln                   = mseg-ebeln
        EXCEPTIONS
          err_no_records_found       = 1
          OTHERS                     = 2.
      IF sy-subrc = 0.
*       Check whether this PO position has delivery data. This accesses
*       the item data from the buffer.
*       The disadvantage from placing ME_EKPV_READ_WITH_EBELN outside
*       the position loop is that if it does not find anything,
*       ME_EKPV_SINGLE_READ will access the database again for each
*       position.
        CALL FUNCTION 'ME_EKPV_SINGLE_READ'
          EXPORTING
            pi_ebeln         = mseg-ebeln
            pi_ebelp         = mseg-ebelp
          EXCEPTIONS
            no_records_found = 1
            OTHERS           = 2.
        IF sy-subrc = 0.
*         function : suggest serial numbers from PO             "1444106
*         this GR posting should be posted without the          "1444106
*         related delivery -> set global flag                   "1444106
          g_flag_message_m7352 = abap_true.                     "1444106

*         Issue customizeable message
          CALL FUNCTION 'MB_CHECK_T160M'
            EXPORTING
              i_arbgb  = 'M7'
              i_msgnr  = '352'
              i_msgv1  = mseg-ebeln
              i_output = x.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDFORM.                             " BESTELLDATEN_PRUEFEN