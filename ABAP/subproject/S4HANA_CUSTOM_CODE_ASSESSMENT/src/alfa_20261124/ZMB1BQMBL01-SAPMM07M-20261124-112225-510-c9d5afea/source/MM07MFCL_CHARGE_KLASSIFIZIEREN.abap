*eject
*----------------------------------------------------------------------*
*       FORM CHARGE_KLASSIFIZIEREN_CFC                                 *
*----------------------------------------------------------------------*
*       Klassifizieren der Charge über CFC                             *
*----------------------------------------------------------------------*
FORM charge_klassifizieren_cfc.

DATA: co_wipb_before_batch_cl TYPE REF TO if_ex_co_wipb_before_batch_cl.
DATA: l_wipbatch_active TYPE xfeld.
DATA: lv_wipb_cuobj TYPE cuobj.

enhancement-point charge_klassifizieren_cfc_01 spots es_sapmm07m static.
* DDB bereitstellen
  CALL FUNCTION 'CLAP_DDB_UPDATE_CLASSIFICATION'
       EXPORTING
            pobtab                    = cl_ptable
            class                     = cl_class
            object                    = cl_object
            classtype                 = cl_klart
*            std_flag                  = x         "note 1626078
       EXCEPTIONS
            allocation_exist          = 1
            no_authority_type         = 2
            classytpe_not_def         = 3
            no_valid_sign_class       = 4
            no_authority_class        = 5
            class_status_not_valid    = 6
            class_date_not_valid      = 7
            class_not_found           = 8
            no_multi_classify         = 9
            foreign_lock              = 10
            system_failure            = 11
            unit_incompatible         = 12
            table_no_multitab         = 13
            other_change_number       = 14
            status_read_only          = 15
            change_kssk_not_allowed   = 16
            change_ausp_not_allowed   = 17
            set_aennr                 = 18
            change_nr_not_exist       = 19
            date_in_past              = 20
            error_class               = 21
            error_date_restriction    = 22
            error_status              = 23
            mtart_not_exist           = 24
            mtart_classif_not_allowed = 25
            OTHERS                    = 26.

* Alle Merkmale beschaffen
  CALL FUNCTION 'CTMS_DDB_HAS_CHARACTERISTICS'
       TABLES
            exp_characteristics      = cl_api_char
       EXCEPTIONS
            not_found                = 1
            no_characteristic_in_ddb = 2
            OTHERS                   = 3.
  CHECK sy-subrc IS INITIAL.

* Objekt-Merkmale beschaffen
  CALL FUNCTION 'CTMS_DDB_HAS_OBJECT_CHAR'
       TABLES
            exp_characteristics         = cl_api_ochar
       EXCEPTIONS
            has_no_objectcharacteristic = 1
            OTHERS                      = 2.
  IF sy-subrc IS INITIAL.
    SORT cl_api_char BY atinn.
    LOOP AT cl_api_ochar.
      READ TABLE cl_api_char WITH KEY cl_api_ochar-atinn BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        DELETE cl_api_char INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CO_WIPB_TCUWIPB_READ'
  IMPORTING
    e_wipbatch_active       = l_wipbatch_active
  EXCEPTIONS
    not_found               = 1
    OTHERS                  = 2.

  IF l_wipbatch_active IS NOT INITIAL.              "WIP batch active
ENHANCEMENT-SECTION     EHP4_CHARGE_KLASSIFIZIEREN_01 SPOTS ES_SAPMM07M.
*   Merkmale gegen QM prüfen
    READ TABLE cl_api_char INDEX 1.
    CHECK sy-subrc IS INITIAL.
    IF NOT vm07m-qplos IS INITIAL.
      LOOP AT cl_api_char.
        cl_qmsp_key-matnr = cl_object.
        cl_qmsp_key-atinn = cl_api_char-atinn.
        READ TABLE cl_qmsp WITH KEY cl_qmsp_key-matnr BINARY SEARCH.
        tabix = sy-tabix.
        IF sy-subrc IS INITIAL.
          READ TABLE cl_qmsp WITH KEY cl_qmsp_key BINARY SEARCH.
          tabix = sy-tabix.
          IF sy-subrc IS INITIAL.
            IF cl_qmsp-ok IS INITIAL.
              DELETE cl_api_char.
            ENDIF.
          ELSE.
            MOVE-CORRESPONDING cl_qmsp_key TO cl_qmsp.
            cl_qmsp-ok = x.
            INSERT cl_qmsp INTO cl_qmsp INDEX tabix.
          ENDIF.
        ELSE.
          SELECT * FROM qmsp WHERE matnr EQ cl_qmsp_key-matnr
                               AND atinn NE 0.
            MOVE-CORRESPONDING qmsp TO cl_qmsp.
            APPEND cl_qmsp.
          ENDSELECT.
          IF sy-dbcnt IS INITIAL.
            MOVE-CORRESPONDING cl_qmsp_key TO cl_qmsp.
            cl_qmsp-ok = x.
            INSERT cl_qmsp INTO cl_qmsp INDEX tabix.
          ELSE.
            SORT cl_qmsp BY matnr atinn.
            READ TABLE cl_qmsp WITH KEY cl_qmsp_key BINARY SEARCH.
            tabix = sy-tabix.
            IF sy-subrc IS INITIAL.
              DELETE cl_api_char.
            ELSE.
              MOVE-CORRESPONDING cl_qmsp_key TO cl_qmsp.
              cl_qmsp-ok = x.
              INSERT cl_qmsp INTO cl_qmsp INDEX tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ELSE.
*   Merkmale gegen QM prüfen
ENHANCEMENT-SECTION     CHARGE_KLASSIFIZIEREN_CFC_02 SPOTS ES_SAPMM07M.
    READ TABLE cl_api_char INDEX 1.
    CHECK sy-subrc IS INITIAL.
    IF NOT vm07m-qplos IS INITIAL.
      LOOP AT cl_api_char.
        cl_qmsp_key-matnr = cl_object.
        cl_qmsp_key-atinn = cl_api_char-atinn.
        READ TABLE cl_qmsp WITH KEY cl_qmsp_key-matnr BINARY SEARCH.
        tabix = sy-tabix.
        IF sy-subrc IS INITIAL.
          READ TABLE cl_qmsp WITH KEY cl_qmsp_key BINARY SEARCH.
          tabix = sy-tabix.
          IF sy-subrc IS INITIAL.
            IF cl_qmsp-ok IS INITIAL.
              DELETE cl_api_char.
            ENDIF.
          ELSE.
            MOVE-CORRESPONDING cl_qmsp_key TO cl_qmsp.
            cl_qmsp-ok = x.
            INSERT cl_qmsp INTO cl_qmsp INDEX tabix.
          ENDIF.
        ELSE.
          SELECT * FROM qmsp WHERE matnr EQ cl_qmsp_key-matnr
                               AND atinn NE 0.
            MOVE-CORRESPONDING qmsp TO cl_qmsp.
            APPEND cl_qmsp.
          ENDSELECT.
          IF sy-dbcnt IS INITIAL.
            MOVE-CORRESPONDING cl_qmsp_key TO cl_qmsp.
            cl_qmsp-ok = x.
            INSERT cl_qmsp INTO cl_qmsp INDEX tabix.
          ELSE.
            SORT cl_qmsp BY matnr atinn.
            READ TABLE cl_qmsp WITH KEY cl_qmsp_key BINARY SEARCH.
            tabix = sy-tabix.
            IF sy-subrc IS INITIAL.
              DELETE cl_api_char.
            ELSE.
              MOVE-CORRESPONDING cl_qmsp_key TO cl_qmsp.
              cl_qmsp-ok = x.
              INSERT cl_qmsp INTO cl_qmsp INDEX tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ENDIF.

* Sind noch Merkmale vorhanden?
  READ TABLE cl_api_char INDEX 1.
  CHECK sy-subrc IS INITIAL.

* Attribute löschen
  REFRESH cl_api_ch_att.

* Attribute besorgen
  CALL FUNCTION 'CTMS_DDB_CHAR_HAS_ATTRIBUTES'
       TABLES
            imp_characteristics = cl_api_char
            exp_attributes      = cl_api_ch_att
       EXCEPTIONS
            OTHERS              = 1.

* Bisherige Klassifizierung
ENHANCEMENT-POINT CHARGE_KLASSIFIZIEREN_CFC_08 SPOTS ES_SAPMM07M STATIC.
ENHANCEMENT-POINT CHARGE_KLASSIFIZIEREN_CFC_09 SPOTS ES_SAPMM07M.
  REFRESH cl_api_val_s.
  CALL FUNCTION 'CTMS_DDB_HAS_VALUES'
       EXPORTING
            assigned_values     = x
            allowed_values      = space
       TABLES
            imp_characteristics = cl_api_char
            exp_values          = cl_api_value
       EXCEPTIONS
            not_found           = 1
            OTHERS              = 2.
  LOOP AT cl_api_value.
    MOVE-CORRESPONDING cl_api_value TO cl_api_val_s.
    APPEND cl_api_val_s.
  ENDLOOP.

* Werte besorgen
  REFRESH cl_api_val_i.
  CALL FUNCTION 'CTMS_DDB_HAS_VALUES'
       EXPORTING
            default_values      = x
       TABLES
            imp_characteristics = cl_api_char
            exp_values          = cl_api_value
       EXCEPTIONS
            not_found           = 1
            OTHERS              = 2.
  LOOP AT cl_api_value.
    MOVE-CORRESPONDING cl_api_value TO cl_api_val_i.
    APPEND cl_api_val_i.
  ENDLOOP.

* Wertetabelle zwischenspeichern
  SORT cl_api_char   BY atinn.
  SORT cl_api_ch_att BY atinn.
  SORT cl_api_val_i  BY atinn.
  SORT cl_api_val_s  BY atinn.
  cl_api_val_o[] = cl_api_val_s[].

ENHANCEMENT-POINT CHARGE_KLASSIFIZIEREN_CFC_10 SPOTS ES_SAPMM07M STATIC.


  IF l_wipbatch_active IS NOT INITIAL.              "WIP batch active
ENHANCEMENT-POINT EHP4_CHARGE_KLASSIFIZIEREN_02 SPOTS ES_SAPMM07M.
  ELSE.
ENHANCEMENT-POINT CHARGE_KLASSIFIZIEREN_CFC_03 SPOTS ES_SAPMM07M.
ENHANCEMENT-POINT CHARGE_KLASSIFIZIEREN_CFC_04 SPOTS ES_SAPMM07M.

ENHANCEMENT-POINT CHARGE_KLASSIFIZIEREN_CFC_05 SPOTS ES_SAPMM07M.
  ENDIF.

ENHANCEMENT-POINT CHARGE_KLASSIFIZIEREN_CFC_11 SPOTS ES_SAPMM07M.

  IF l_wipbatch_active IS NOT INITIAL.              "WIP batch active
ENHANCEMENT-POINT EHP4_CHARGE_KLASSIFIZIEREN_03 SPOTS ES_SAPMM07M.
  ELSE.                                             "WIP batch not active
ENHANCEMENT-POINT CHARGE_KLASSIFIZIEREN_CFC_06 SPOTS ES_SAPMM07M.
  ENDIF.

  IF l_wipbatch_active IS NOT INITIAL.              "WIP batch active
ENHANCEMENT-SECTION     EHP4_CHARGE_KLASSIFIZIEREN_04 SPOTS ES_SAPMM07M.
*   Aufruf das Customer Function Call
    CALL CUSTOMER-FUNCTION '004'
         EXPORTING
              i_mseg  = mseg
              i_vm07m = vm07m
              i_dm07m = dm07m
              i_mkpf  = mkpf
         TABLES
              characters = cl_api_char
              attributes = cl_api_ch_att
              max_values = cl_api_val_i
              values     = cl_api_val_s.
END-ENHANCEMENT-SECTION.
  ELSE.                                             "WIP batch not active
ENHANCEMENT-SECTION     CHARGE_KLASSIFIZIEREN_CFC_07 SPOTS ES_SAPMM07M.
*   Aufruf das Customer Function Call
    CALL CUSTOMER-FUNCTION '004'
         EXPORTING
              i_mseg  = mseg
              i_vm07m = vm07m
              i_dm07m = dm07m
              i_mkpf  = mkpf
         TABLES
              characters = cl_api_char
              attributes = cl_api_ch_att
              max_values = cl_api_val_i
              values     = cl_api_val_s.
END-ENHANCEMENT-SECTION.
  ENDIF.

* Überprüfung der Übergebenen Werte bzüglich ATINN
  LOOP AT cl_api_val_s.
    READ TABLE cl_api_char WITH KEY cl_api_val_s-atinn BINARY SEARCH.
    IF NOT sy-subrc IS INITIAL.
      DELETE cl_api_val_s.
    ENDIF.
  ENDLOOP.

* Überprüfung der zu löschenden Werte
  REFRESH cl_api_val_d.
  LOOP AT cl_api_val_o.
    LOOP AT cl_api_val_s WHERE atinn EQ cl_api_val_o-atinn
                           AND atwtb EQ cl_api_val_o-atwtb.
    ENDLOOP.
    IF NOT sy-subrc IS INITIAL.
      APPEND cl_api_val_o TO cl_api_val_d.
    ENDIF.
  ENDLOOP.

* Überprüfung der Übergebenen Werte Änderungen
  LOOP AT cl_api_val_s.
    LOOP AT cl_api_val_o WHERE atinn EQ cl_api_val_s-atinn
                           AND atwtb EQ cl_api_val_s-atwtb.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      DELETE cl_api_val_s.
    ENDIF.
  ENDLOOP.

  DATA: xerror(30) TYPE c.
* Löschen der Bewertung
  READ TABLE cl_api_val_d INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'CTMS_DDB_DEL_VALUE'
         TABLES
              imp_values                    = cl_api_val_d
              exp_values_error              = cl_api_val_e
         EXCEPTIONS
              currency_check                = 1
              date_check                    = 2
              format_check                  = 3
              illegal_internal_baseunit     = 4
              interval_check                = 5
              pattern_check                 = 6
              time_check                    = 7
              unit_check                    = 8
              value_not_found               = 9
              display_mode                  = 10
              characteristic_not_found      = 11
              characteristic_enqueue        = 12
              objectcharacteristic          = 13
              characteristic_not_selectable = 14
              no_valid_dimension            = 15
              interval_not_allowed          = 16
              input_to_long                 = 17
              value_contradiction           = 18
              OTHERS                        = 19.

    IF NOT sy-subrc IS INITIAL.
      CASE sy-subrc.
        WHEN 1.  MOVE 'CURRENCY_CHECK'                TO xerror.
        WHEN 2.  MOVE 'DATE_CHECK'                    TO xerror.
        WHEN 3.  MOVE 'FORMAT_CHECK'                  TO xerror.
        WHEN 4.  MOVE 'ILLEGAL_INTERNAL_BASEUNIT'     TO xerror.
        WHEN 5.  MOVE 'INTERVAL_CHECK'                TO xerror.
        WHEN 6.  MOVE 'PATTERN_CHECK'                 TO xerror.
        WHEN 7.  MOVE 'TIME_CHECK'                    TO xerror.
        WHEN 8.  MOVE 'UNIT_CHECK'                    TO xerror.
        WHEN 9.  MOVE 'VALUE_NOT_FOUND'               TO xerror.
        WHEN 10. MOVE 'DISPLAY_MODE'                  TO xerror.
        WHEN 11. MOVE 'CHARACTERISTIC_NOT_FOUND'      TO xerror.
        WHEN 12. MOVE 'CHARACTERISTIC_ENQUEUE'        TO xerror.
        WHEN 13. MOVE 'OBJECTCHARACTERISTIC'          TO xerror.
        WHEN 14. MOVE 'CHARACTERISTIC_NOT_SELECTABLE' TO xerror.
        WHEN 15. MOVE 'NO_VALID_DIMENSION'            TO xerror.
        WHEN 16. MOVE 'INTERVAL_NOT_ALLOWED'          TO xerror.
        WHEN 17. MOVE 'INPUT_TO_LONG'                 TO xerror.
        WHEN 18. MOVE 'VALUE_CONTRADICTION'           TO xerror.
        WHEN 19. MOVE 'OTHERS'                        TO xerror.
      ENDCASE.

      READ TABLE cl_api_val_e INDEX 1.

*     PERFORM NACHRICHTENCODE_ERMITTELN(SAPFM07M) USING 'LB' '035'.
* Nachrichtencode gibt die Meldung selber aus => geändert auf FB
      CALL FUNCTION 'MB_CHECK_T160M'
           EXPORTING
                i_arbgb  = 'LB'
                i_msgnr  = '035'
                i_msgv1  = cl_object
                i_msgv2  = cl_api_val_e-atnam
                i_msgv3  = cl_api_val_e-atwtb
                i_msgv4  = xerror
                i_output = space
           IMPORTING
                rc       = rc.
      CASE rc.
        WHEN 2.
          MESSAGE e035(lb) WITH cl_object cl_api_val_e-atnam
                                cl_api_val_e-atwtb xerror.
        WHEN 1.
          MESSAGE w035(lb) WITH cl_object cl_api_val_e-atnam
                                cl_api_val_e-atwtb xerror.
        WHEN OTHERS.
          MESSAGE s035(lb) WITH cl_object cl_api_val_e-atnam
                                cl_api_val_e-atwtb xerror.
      ENDCASE.
    ENDIF.
  ENDIF.

* Bewertung
  READ TABLE cl_api_val_s INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'CTMS_DDB_SET_VALUE'
         TABLES
              imp_values                    = cl_api_val_s
              exp_values_error              = cl_api_val_e
         EXCEPTIONS
              currency_check                = 1
              date_check                    = 2
              format_check                  = 3
              illegal_internal_baseunit     = 4
              interval_check                = 5
              pattern_check                 = 6
              time_check                    = 7
              unit_check                    = 8
              value_not_found               = 9
              no_valid_dimension            = 10
              interval_not_allowed          = 11
              display_mode                  = 12
              characteristic_not_found      = 13
              value_not_possible            = 14
              characteristic_enqueue        = 15
              objectcharacteristic          = 16
              only_one_value_allowed        = 17
              characteristic_not_selectable = 18
              input_to_long                 = 19
              OTHERS                        = 20.

    IF NOT sy-subrc IS INITIAL.
      CASE sy-subrc.
        WHEN 1.  MOVE 'CURRENCY_CHECK'                TO xerror.
        WHEN 2.  MOVE 'DATE_CHECK'                    TO xerror.
        WHEN 3.  MOVE 'FORMAT_CHECK'                  TO xerror.
        WHEN 4.  MOVE 'ILLEGAL_INTERNAL_BASEUNIT'     TO xerror.
        WHEN 5.  MOVE 'INTERVAL_CHECK'                TO xerror.
        WHEN 6.  MOVE 'PATTERN_CHECK'                 TO xerror.
        WHEN 7.  MOVE 'TIME_CHECK'                    TO xerror.
        WHEN 8.  MOVE 'UNIT_CHECK'                    TO xerror.
        WHEN 9.  MOVE 'VALUE_NOT_FOUND'               TO xerror.
        WHEN 10. MOVE 'NO_VALID_DIMENSION'            TO xerror.
        WHEN 11. MOVE 'INTERVAL_NOT_ALLOWED'          TO xerror.
        WHEN 12. MOVE 'DISPLAY_MODE'                  TO xerror.
        WHEN 13. MOVE 'CHARACTERISTIC_NOT_FOUND'      TO xerror.
        WHEN 14. MOVE 'VALUE_NOT_POSSIBLE'            TO xerror.
        WHEN 15. MOVE 'CHARACTERISTIC_ENQUEUE'        TO xerror.
        WHEN 16. MOVE 'OBJECTCHARACTERISTIC'          TO xerror.
        WHEN 17. MOVE 'ONLY_ONE_VALUE_ALLOWED'        TO xerror.
        WHEN 18. MOVE 'CHARACTERISTIC_NOT_SELECTABLE' TO xerror.
        WHEN 19. MOVE 'INPUT_TO_LONG'                 TO xerror.
        WHEN 20. MOVE 'OTHERS'                        TO xerror.
      ENDCASE.

      READ TABLE cl_api_val_e INDEX 1.

*     PERFORM NACHRICHTENCODE_ERMITTELN(SAPFM07M) USING 'LB' '035'.
      CALL FUNCTION 'MB_CHECK_T160M'
           EXPORTING
                i_arbgb  = 'LB'
                i_msgnr  = '035'
                i_msgv1  = cl_object
                i_msgv2  = cl_api_val_e-atnam
                i_msgv3  = cl_api_val_e-atwtb
                i_msgv4  = xerror
                i_output = space
           IMPORTING
                rc       = rc.
      CASE rc.
        WHEN 2.
          MESSAGE e035(lb) WITH cl_object cl_api_val_e-atnam
                                cl_api_val_e-atwtb xerror.
        WHEN 1.
          MESSAGE w035(lb) WITH cl_object cl_api_val_e-atnam
                                cl_api_val_e-atwtb xerror.
        WHEN OTHERS.
          MESSAGE s035(lb) WITH cl_object cl_api_val_e-atnam
                                cl_api_val_e-atwtb xerror.
      ENDCASE.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'CLAP_FETCH_VALUES'
       EXPORTING
            object    = cl_object
            classtype = cl_klart
       EXCEPTIONS
            OTHERS    = 1.

ENDFORM.