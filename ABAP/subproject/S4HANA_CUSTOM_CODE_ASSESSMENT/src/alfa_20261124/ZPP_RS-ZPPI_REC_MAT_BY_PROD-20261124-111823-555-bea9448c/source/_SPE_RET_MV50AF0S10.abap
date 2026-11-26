*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S10
*&---------------------------------------------------------------------*
FORM batch_creation_for_ich                                   "v_XAN-SPM
              USING    ls_likp  TYPE likp
                       ls_xlips TYPE lipsvb
              CHANGING it_delivery_batch TYPE /spe/batch_spljoi_t
                       it_verpo          TYPE vsep_t_verpo
                       ef_charg
                       ef_lichn
                       ef_subrc.


  DATA: lf_subrc TYPE sy-subrc,
        lf_charg TYPE charg_d,
        lf_lichn TYPE lichn,
        lf_umvkn LIKE lips-umvkn,
        lf_umvkz LIKE lips-umvkz.

  DATA: ls_delivery_batch TYPE /spe/ret_batch_spljoi.

  DATA: ls_bncom   TYPE bncom.
  DATA: is_mcha LIKE mcha.
  DATA: es_mcha LIKE mcha.

  FIELD-SYMBOLS: <fs_delivery_batch> TYPE /spe/ret_batch_spljoi,
                 <fs_verpo> TYPE verpo.

  LOOP AT it_delivery_batch ASSIGNING <fs_delivery_batch>
                        WHERE vbeln_new = ls_xlips-vbeln AND
                              item_new  = ls_xlips-posnr.

    CHECK <fs_delivery_batch>-ich_charg NE xlips-charg.       "n_1620662
    CLEAR: lf_charg.

      IF NOT <fs_delivery_batch>-ich_charg IS INITIAL.
* check batch already exist plant / storge location
        PERFORM mchar_select(sapfv50p) USING ls_xlips-matnr
                                             ls_xlips-werks
                                             ls_xlips-lgort
                                           <fs_delivery_batch>-ich_charg
                                             ls_xlips-sobkz
                                             ls_xlips-eprio
                                             ls_xlips-rules
                                             ls_xlips-kzbef
                                             lf_subrc.

        IF lf_subrc = 0.
          lf_charg  = <fs_delivery_batch>-ich_charg.
* check batch exists on plant level
        ELSE.
          PERFORM mchar_select(sapfv50p) USING ls_xlips-matnr
                                               ls_xlips-werks
                                               '    '
                                           <fs_delivery_batch>-ich_charg
                                               ls_xlips-sobkz
                                               ls_xlips-eprio
                                               ls_xlips-rules
                                               ls_xlips-kzbef
                                               lf_subrc.

          IF lf_subrc = 0.
            lf_charg  = <fs_delivery_batch>-ich_charg.
*RS 20050915 Begin of 879700
          ELSE.
*Check whether there are multiple items with the same ICH batch, create one internal batch only for them
*but only, if COO is the same
            LOOP AT it_delivery_batch INTO ls_delivery_batch
               WHERE ich_charg = <fs_delivery_batch>-ich_charg
                    AND atnam = <fs_delivery_batch>-atnam
                    AND atwrt = <fs_delivery_batch>-atwrt.

              IF ls_delivery_batch-vbeln_new = <fs_delivery_batch>-vbeln_new
                 AND ls_delivery_batch-item_new = <fs_delivery_batch>-item_new.
                CONTINUE.
              ELSE.
                lf_charg = ls_delivery_batch-charg.
              ENDIF.
            ENDLOOP.
*RS 20050915 End of 879700
          ENDIF.
       ENDIF.
      ENDIF.

    IF lf_charg IS INITIAL.
      ls_bncom-mandt = sy-mandt.
      ls_bncom-matnr = ls_xlips-matnr.
      ls_bncom-werks = ls_xlips-werks.
      ls_bncom-lgort = ls_xlips-lgort.

      es_mcha-matnr  = ls_xlips-matnr.
      es_mcha-charg  = lf_charg.
      es_mcha-werks  = ls_xlips-werks.
      es_mcha-bwtar  = ls_xlips-bwtar.

* If ICH-batch does not exist, store it in the vendor batch field
      IF     lf_charg IS INITIAL AND
         NOT <fs_delivery_batch>-ich_charg IS INITIAL AND
         NOT ls_xlips-lichn IS INITIAL.
        es_mcha-licha  = ls_xlips-charg.
      ELSE.
        es_mcha-licha  = ls_xlips-lichn.
      ENDIF.
      IF es_mcha-licha IS INITIAL.
        es_mcha-licha = <fs_delivery_batch>-ich_charg.
      ENDIF.

      es_mcha-lifnr  = ls_likp-lifnr.

*Customer is in the role of ship-from party in the returns process
      IF es_mcha-lifnr IS INITIAL.
        es_mcha-lifnr = ls_likp-kunnr.
      ENDIF.

*Move COO to batch master for automatic classification
      IF <fs_delivery_batch>-atnam EQ 'LOBM_HERKL'. "#ec_no_text
        es_mcha-herkl = <fs_delivery_batch>-atwrt.
      ENDIF.

      MOVE-CORRESPONDING ls_likp TO  ls_bncom.
      MOVE-CORRESPONDING ls_xlips TO ls_bncom.

*... Purchase order number, item
      ls_bncom-ebeln = ls_xlips-vgbel.
      ls_bncom-ebelp = ls_xlips-vgpos.

*... Delivery number, item
      ls_bncom-lfbel = ls_xlips-vbeln.
      ls_bncom-lfpos = ls_xlips-posnr.

*-----------------------------------------------------------------------
*...Ermittlung IM spezifisches Customizing bzgl.
*   T159L XWMHD, Ermittlung des MH-Datum (Ebene Werk)
*   T156  KZMHD, Ermittlung des MH-Datum (Ebene Bewegungsart)
*   T156  KZCLA, Merkmalsbewertung der Chargenklasse
*   T156  CHNEU, Charge anlegen manuell oder automatisch
*-----------------------------------------------------------------------
*...CHNEU Chargenanlage
*   automatische Anlage, wenn CHNEU blank, A,B,C
*   manuelle Anlage,     wenn CHNEU blank, A,B,D,E,F
*   keine Anlage,        wenn CHNEU G
*-----------------------------------------------------------------------
*   _ automatisch / manuell ohne Prüfung
*   A automatisch / manuell mit Prüfung gegen externen Nummernkr.
*   B automatisch / manuell mit Prüfung im USER EXIT
*   C automatisch / keine manuelle Neuanlage
*   D	manuell ohne Prüfung
*   E	manuell mit Prüfung gegen externen Nummernkreis
*   F	manuell mit Prüfung im USER EXIT
*   G	keine Neuanlage
*-----------------------------------------------------------------------
*...KZCLA Möglichkeit der Chargenklassifizierung bei Warenbewegungen
*   _ Kein Ansprung der Chargenklassifizierung
*   1 Klassifizierung erfolgt im Hintergrund (alle Chargen)
*   2 Klassifizierung nur hell bei Mußmerkmalen (alle Chargen)
*   3 Klassifizierung wird immer hell aufgerufen (alle Chargen)
*   4 Klassifizierung wird nur bei neuen Chargen hell aufgerufen
*-----------------------------------------------------------------------

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* The batch creation works only in case if customizing table TCUCH
* Batch Configuration is set for automatically batch number creation!!!!
* field AUTBN (Automatic batch number allocation active/inactive) must
* be set to '1'
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


      CALL FUNCTION 'VB_CREATE_BATCH'
        EXPORTING
          ymcha                        = es_mcha
          new_lgort                    = ls_xlips-lgort
          bypass_lock                  = ' '
          message_when_auto            = ' '
          x_bncom                      = ls_bncom
          kzcla                        = '1'
          xkcfc                        = ' '
        IMPORTING
          ymcha                        = is_mcha
        EXCEPTIONS
          no_material                  = 1
          no_batch                     = 2
          no_plant                     = 3
          material_not_found           = 4
          plant_not_found              = 5
          stoloc_not_found             = 6
          lock_on_material             = 7
          lock_on_plant                = 8
          lock_on_batch                = 9
          lock_system_error            = 10
          no_authority                 = 11
          batch_exist                  = 12
          stoloc_exist                 = 13
          illegal_batch_number         = 14
          no_batch_handling            = 15
          no_valuation_area            = 16
          valuation_type_not_found     = 17
          no_valuation_found           = 18
          error_automatic_batch_number = 19
          cancelled                    = 20
          wrong_status                 = 21
          interval_not_found           = 22
          number_range_not_extern      = 23
          object_not_found             = 24
          error_check_batch_number     = 25
          no_external_number           = 26
          no_customer_number           = 27
          no_class                     = 28
          error_in_classification      = 29
          inconsistency_in_key         = 30
          OTHERS                       = 31.


* transfer return code from batch creation
      IF sy-subrc <> 0.
        ef_subrc = sy-subrc.
        RETURN.
      ENDIF.
    ENDIF.
* BATCH WAS GENERATED
* populate automatically generated batch number to LIPS --> XLIPS
    IF sy-subrc = 0 AND NOT is_mcha-charg IS INITIAL.
* update batch table woth automatically generated batch number
      lips-charg  = is_mcha-charg.
      IF <fs_delivery_batch>-atnam EQ 'LOBM_HERKL'. "#ec_no_text
        lips-spe_herkl = <fs_delivery_batch>-atwrt.
      ENDIF.
* populate vendor batch to LIPS --> XLIPS
      lips-lichn = <fs_delivery_batch>-ich_charg.
* update handling unit items with batch number
      LOOP AT it_verpo ASSIGNING <fs_verpo> WHERE
                               vbeln = ls_xlips-vbeln AND
                               posnr = ls_xlips-posnr.

        <fs_verpo>-charg = is_mcha-charg.

      ENDLOOP.
* BATCH ALREADY EXISTS
    ELSEIF NOT lf_charg IS INITIAL.
* update batch table with automatically generated batch number
      lips-charg = lf_charg.
      IF <fs_delivery_batch>-atnam EQ 'LOBM_HERKL'. "#ec_no_text
        lips-spe_herkl = <fs_delivery_batch>-atwrt.
      ENDIF.
* populate vendor batch to LIPS --> XLIPS
      lips-lichn = <fs_delivery_batch>-ich_lichn.

* update handling unit items with batch number
      LOOP AT it_verpo ASSIGNING <fs_verpo> WHERE
                                vbeln = ls_xlips-vbeln AND
                                posnr = ls_xlips-posnr.

        <fs_verpo>-charg = lips-charg.

      ENDLOOP.
    ENDIF.
*RS 20050915 Begin of 879700
    <fs_delivery_batch>-charg = lips-charg.
*RS 20050915 End of 879700
  ENDLOOP.

ENDFORM.                         "batch_creation_from_ich     "^_XAN-SPM