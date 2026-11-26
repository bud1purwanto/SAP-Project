*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_SETZEN                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM CUA_SETZEN                                               *
*---------------------------------------------------------------------*
FORM cua_setzen.

enhancement-point cua_setzen_01 spots es_sapmv50a.
  DATA: lf_vbeln(10) TYPE c,
        wa_cua_exclude LIKE LINE OF cua_exclude.                    "SIT
* Dynamical FCODES are activated or deactivated here
* If the activation of FCODES depends on the document but does not
* change during the delivery processing use form CUA_EXCLUDE_STATIC
  PERFORM cua_exclude_dynamic.

  IF fehler = 'X'.
    t185v-status = 'FS  '.
  ENDIF.

  PERFORM uc_screen_save(sapfv50u) USING fcode.

*-Kein CUA-Status: ist erlaubt fuer Fenster --------------------------*
  CHECK t185v-status NE space.

* Text for the function for posting goods movement
  IF tvlk-vbtyp CA vbtyp_mmli OR
     tvlk-vbtyp EQ vbtyp_lire.
    gf_wabu_ftext = 'Wareneingang buchen'(032).
  ELSEIF tvlk-vbtyp EQ space.
    IF t180-bldgr EQ gc_new_dialog_inb.
      gf_wabu_ftext = 'Wareneingang buchen'(032).
    ELSE.
      gf_wabu_ftext = 'Warenausgang buchen'(033).
    ENDIF.
  ELSE.
    gf_wabu_ftext = 'Warenausgang buchen'(033).
  ENDIF.

* Title for table control with all items
  IF xlips_umfang EQ xlips_umfang_ucha.                     "
    gf_tc_title = 'Chargenstruktur Position &1'(030).
    REPLACE '&1' WITH gf_title_posnr INTO gf_tc_title.
    CONDENSE gf_tc_title.
  ELSEIF xlips_umfang EQ xlips_umfang_uhau.
    gf_tc_title = 'Nur Hauptpositionen'(048).
  ELSE.
    gf_tc_title = 'Alle Positionen'(031).
  ENDIF.

* Status setzen
  SET PF-STATUS t185v-status OF PROGRAM programmname
                                EXCLUDING cua_exclude.

*-Kein CUA-Titel vorgegeben: alter Wert bleibt -----------------------*
  CHECK t185v-ctitel NE space.

* Build title for window
  IF likp-vbeln NS '$' AND
     NOT likp-vbeln IS INITIAL.
    WRITE likp-vbeln TO lf_vbeln NO-ZERO LEFT-JUSTIFIED.
  ENDIF.
  CLEAR text.
  IF t180-tcode CS 'VLPOD'.
    text = text-047.
    CONCATENATE text tvlkt-vtext
                lf_vbeln rv50a-txt_titcua
                INTO text
                SEPARATED BY space.
  ELSE.
    CONCATENATE tvlkt-vtext
                lf_vbeln rv50a-txt_titcua
                INTO text
                SEPARATED BY space.
  ENDIF.

  SET TITLEBAR t185v-ctitel OF PROGRAM programmname
                            WITH text.

ENDFORM.                    "CUA_SETZEN
*eject