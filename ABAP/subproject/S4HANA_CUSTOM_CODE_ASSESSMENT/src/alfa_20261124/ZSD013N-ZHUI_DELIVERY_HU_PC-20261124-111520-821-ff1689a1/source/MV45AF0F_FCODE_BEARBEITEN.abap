*---------------------------------------------------------------------*
*       FORM FCODE_BEARBEITEN                                         *
*---------------------------------------------------------------------*
*       Aufruf des Funktionsbausteins 'SCREEN_SEQUENCE_CONTROL'       *
*       Standardroutine zur Funktionscodebehandlung                   *
*       Der Fcode wird mit dem Folgefcode besetzt                     *
*---------------------------------------------------------------------*
FORM fcode_bearbeiten.
ENHANCEMENT-POINT FCODE_BEARBEITEN_01 SPOTS ES_SAPMV45A STATIC.

  DATA: no_dialog_mode(1) TYPE c.

* Enjoy: Double klick use GL_FCODE
  IF NOT gl_fcode IS INITIAL.
    fcode = gl_fcode.                  "  use saved global fcode
    CLEAR gl_fcode.
  ENDIF.

* Tabstrip-Funktionscode filtern und ggf. umsetzen
  PERFORM taxi_filter_and_convert_fcode.
* Fcode umsetzen, falls kein Text Edit Control vorhanden
  PERFORM text_control_convert_fcode.
ENHANCEMENT-POINT FCODE_BEARBEITEN_10 SPOTS ES_SAPMV45A.
* Wenn an dieser Stelle noch der Fcode Cursor_Selection sitzt,
* muß er durch den Default Code ersetzt werden
  IF fcode EQ fcode_cursor_selection.
    fcode = fcode_gleiche_seite.
  ENDIF.
* Ist noch ein Fcode vom Typ 1 da ? Dann zuerst diesen abarbeiten.
  PERFORM funktion_ausfuehren.
  CLEAR: flag-no.
  old_fcode = fcode.
ENHANCEMENT-POINT FCODE_BEARBEITEN_02 SPOTS ES_SAPMV45A.
* Gruppenaufruf Verfuegbarkeit (Hell)
  IF FCODE NE FCODE_BELEG_VERFUEGBARKEIT    AND
     FCODE NE FCODE_BELEG_VERFUEGBARKEIT_SW AND
     FCODE NE FCODE_GRUPPEN_VERFUEGBARKEIT. "Damit es nicht zum Doppelaufruf kommt
    PERFORM verfuegbarkeit_pruefen_gruppen(sapfv45p) USING verarb_hell.
  ENDIF.
* Cross-Selling Popup
  PERFORM cross_sell_popup(sapfv45p).
* Kopfsummen nicht bei der Hintergrundverarbeitung
* A=Hell, E=Fehler, N=Dunkel
  IF  SY-BINPT EQ CHARX
  AND (  BI_INFO-BDC_AMODUS EQ CHARN
      OR BI_INFO-CTU_AMODUS EQ CHARN
      OR BI_INFO-CDU_AMODUS EQ CHARN )
  AND BACKGROUND_DEBUG IS INITIAL.
    NO_DIALOG_MODE = CHARX.
  ENDIF.

  IF rv45z-docnum IS INITIAL AND
     rv45a-docnum IS INITIAL AND
     no_dialog_mode IS INITIAL AND
     rv45a-amode NE charc.
    PERFORM kopfsummen_bilden(sapfv45k).
  ENDIF.

* Richtige Daten für die aktuelle Position wieder bereitstellen
  IF NOT vbap-posnr IS INITIAL.
    PERFORM xvbap_lesen_allgemein(sapfv45p) USING vbap-posnr
                                                  space
                                         CHANGING svbap-tabix.
  ENDIF.

* Tablecontrol für Positionsdetailbild auf richtige Position setzen
  IF   fcode = 'UER3'
    OR fcode = fcode_msr_item_overview.
    PERFORM xvbap_item_detail_tabix_set(sapfv45p).
  ENDIF.

* Avoid endless loop in case of having had active tab FCODE_FPLAN_KOPF
* in previous order and no billing plan data in current order type.
* In this case switch to default header fcode
  IF fcode EQ fcode_fplan_kopf AND
     tvak-fpart IS INITIAL.
    fcode = c_taxi_default_head_fcode.
  ENDIF.
*Enjoy Tabstrip-Controls
ENHANCEMENT-SECTION     FCODE_BEARBEITEN_11 SPOTS ES_SAPMV45A.
  IF fcode = 'UER1' OR fcode = 'UER2' OR fcode = 'UBST'
  OR fcode = 'UBSF' OR fcode = 'UVER' OR fcode = 'UERL'
  OR fcode = 'UECO' OR fcode = 'ITEX' OR fcode = 'ITCO'
  OR fcode = 'HEEX' OR fcode = 'HECO' OR fcode = 'UER3'
  OR fcode = fcode_msr_item_overview.
    indx-usera = sy-uname.
    indx-pgmid = sy-repid.
    IF fcode <> 'ITEX' AND fcode <> 'ITCO' AND fcode <> 'HEEX'
    AND fcode <> 'HECO'.
      uebor = fcode.
    ENDIF.
    WRITE vbak-auart TO indxkey(4).
    WRITE sy-uname TO indxkey+4(12).
    IF NOT uebor IS INITIAL.
      EXPORT item_detail_counter header_detail_counter uebor
       TO MEMORY ID indxkey.
    ENDIF.
  ENDIF.                               " End Enjoy
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT FCODE_BEARBEITEN_12 SPOTS ES_SAPMV45A STATIC.

* Call SD Sales BAdI
  DATA: l_sd_sales_basic_exit TYPE REF TO if_ex_badi_sd_sales_basic,
            active TYPE xfeld,
            da_new_fcode TYPE fcode.
  CALL FUNCTION 'GET_HANDLE_SD_SALES_BASIC'
    IMPORTING
      handle = l_sd_sales_basic_exit
      active = active.
  IF active = charx.
    da_new_fcode = fcode.
    CALL METHOD l_sd_sales_basic_exit->flow_logic
      EXPORTING
        i_program      = t180-agidv
        i_header_group = tvak-kopgr
        i_item_group   = tvap-posgr
        i_fcode        = fcode
      CHANGING
        c_fake_fcode   = da_new_fcode.
    IF fcode NE da_new_fcode.
      fcode = da_new_fcode.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SCREEN_SEQUENCE_CONTROL'
       EXPORTING
            programm        = t180-agidv
            kopfgruppe      = tvak-kopgr
            positionsgruppe = tvap-posgr
            funktion        = fcode
       IMPORTING
            cua_status      = t185v-status
            cua_titel       = t185v-ctitel
            cua_para1       = t185v-para1
            cua_para2       = t185v-para2
            cua_para3       = t185v-para3
            cua_para4       = t185v-para4
            folgefunktion   = fcode
            dunkel          = t185-dunkel
            leave           = flag-leave
*           GUI-Redesign 4.0: Header-Subscreen- und Tabstrip-Subscreen-
*                             Nummer für Folgeort ermitteln:
            dynprobaustein1 = taxi_header_subscreen
            dynprobaustein2 = taxi_body_subscreen.

ENHANCEMENT-POINT FCODE_BEARBEITEN_13 SPOTS ES_SAPMV45A STATIC.

* Kopfsummen nicht bei der Hintergrundverarbeitung
* A=Hell, E=Fehler, N=Dunkel
  IF  SY-BINPT EQ CHARX
  AND (  BI_INFO-BDC_AMODUS EQ CHARN
      OR BI_INFO-CTU_AMODUS EQ CHARN
      OR BI_INFO-CDU_AMODUS EQ CHARN )
  AND BACKGROUND_DEBUG IS INITIAL.
    NO_DIALOG_MODE = CHARX.
  ENDIF.

  IF rv45z-docnum IS INITIAL AND
     rv45a-docnum IS INITIAL AND
     no_dialog_mode IS INITIAL AND
     rv45a-amode NE charc.
    PERFORM kopfsummen_bilden(sapfv45k).
  ENDIF.
  IF flag-leave NE space.
    t185f-fcode = fcode.
    LEAVE.
  ENDIF.

ENDFORM.                    "fcode_bearbeiten