*eject
*---------------------------------------------------------------------*
*       FORM FCODE_BEARBEITEN                                         *
*---------------------------------------------------------------------*
*       Der eingegebene Funktionscode wird geprueft und das naechste  *
*       Dynpro ermittelt.                                             *
*       Ausserdem wird geprueft, ob noch eine neue Position hinzu-    *
*       gefuegt werden darf, oder ob die maximale Anzahl von Buchungs-*
*       zeilen bereits erreicht ist.                                  *
*---------------------------------------------------------------------*
FORM fcode_bearbeiten.

* SPE ST 27.01.2005
* VL-MM Consistency
  CLASS /spe/cl_inb_action_info definition LOAD.

  DATA:
    l_shkzg      type mseg-shkzg,
    l_dialog     type char30,
    l_action1    type char30,
    l_action2    type char30,
    l_action3    type char30.

  DATA: ls_isc_buchen_aufbereiten TYPE isc_buchen_aufbereiten. "IS2ERP

ENHANCEMENT-POINT MM07MFF0_FCODE_BEARBEITEN_03 SPOTS ES_SAPMM07M STATIC.

  IF fcausw-xbuch IS INITIAL.

    IF fcode = 'J1BA'.                 "localization Brazil
      PERFORM j_1b_nf_document_function.          "localization Brazil
    ENDIF.                             "localization Brazil

    PERFORM dynpro_selektieren(sapfm07m) USING vgart
                                               fcode
                                          t158-trtyp
                                         rm07m-kzbew.
  ELSE.
    IF t158-trtyp = h.
      READ TABLE ymseg INDEX 1.
      IF sy-subrc IS INITIAL.
ENHANCEMENT-POINT MM07MFF0_FCODE_BEARBEITEN_04 SPOTS ES_SAPMM07M.

        PERFORM buchen_aufbereiten
                                    CHANGING ls_isc_buchen_aufbereiten. "IS2ERP
        PERFORM buchen_nummernvergabe.
        CALL FUNCTION 'MB_XAB_NUMBER_GET'.                  "note 434093

ENHANCEMENT-POINT MM07MFF0_FCODE_BEARBEITEN_02 SPOTS ES_SAPMM07M.

        PERFORM buchen_ausfuehren.
        PERFORM ta_automatisch.
        SET PARAMETER ID 'MBN' FIELD xmkpf-mblnr.
        SET PARAMETER ID 'MJA' FIELD xmkpf-mjahr.
        MESSAGE s060 WITH xmkpf-mblnr.
ENHANCEMENT-POINT FCODE_BEARBEITEN_02 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-SECTION     FCODE_BEARBEITEN_01 SPOTS ES_SAPMM07M.
*       commit work.                                        "note 365976
        IF LVS_TAFKZ = X.                                   "note 365976
          COMMIT WORK AND WAIT.                             "note 365976
        ELSE.                                               "note 365976
          COMMIT WORK.                                      "note 365976
        ENDIF.                                              "note 365976
END-ENHANCEMENT-SECTION.
        IF NOT folgekz IS INITIAL.
          folgekz = b.
        ENDIF.
      ENDIF.
    ELSE.
ENHANCEMENT-POINT BESTELLUNG_PRUEFEN_01 SPOTS ES_SAPMM07M.
      PERFORM buchen_vorbereiten USING vw.
      IF NOT vw IS INITIAL.
        CALL FUNCTION 'MB_CHANGE_DOCUMENT' IN UPDATE TASK
             TABLES
                  zmkpf = xmkpf
                  zmseg = xmseg.
      ENDIF.
      COMMIT WORK.
      IF NOT folgekz IS INITIAL.
        folgekz = b.
      ENDIF.
    ENDIF.
    IF lvs_tafkz = x.
      CALL TRANSACTION con_tcode_lt06.
    ENDIF.
*-- Bei CALL-TRANSACTION
    IF NOT sy-calld IS INITIAL.
      LEAVE.
    ENDIF.
*-- Bei Aufruf aus Batch-Input oder Reports
    IF sy-binpt IS INITIAL.
*{   DELETE         TRDK903272                                        1
*\      LEAVE TO TRANSACTION tcode.
*}   DELETE
*{   INSERT         TRDK903272                                        2
     TCODE = CL_DYNPRO=>GET_CURRENT_TRANSACTION( ) .
     LEAVE TO TRANSACTION tcode.
*}   INSERT
    ELSE.
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.
ENDFORM.