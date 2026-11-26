*----------------------------------------------------------------------*
*   INCLUDE MV45AFUV_XVBUV_ANZEIGEN                                    *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM XVBUV_ANZEIGEN                                           *
*---------------------------------------------------------------------*
*       Das Fehlerprotokoll wird am Bildschirm angezeigt              *
*---------------------------------------------------------------------*
FORM xvbuv_anzeigen.

  DATA: da_dfies_tab LIKE dfies.
  DATA: feld(22) TYPE c.
  DATA: xa_lines TYPE p.

  DATA: anzeigepos(6) TYPE c.
  DATA: pack(6) TYPE p.
  DATA: ausgabetext(25) TYPE c.

  REFRESH gt_uvprot_list.
  CLEAR gs_uvprot_layout.
  REFRESH gt_uvprot_fieldcat.
  REFRESH gt_uvprot_events.
  REFRESH gt_uvprot_list_top_of_page.

* ALV temporary global variable to store the report id
  gv_uvprot_repid = sy-repid.
  gv_uvprot_title = sy-title.

* Call incompletion check in tracking if advanced returns is active
  IF gr_msr_sales IS BOUND.
    CALL METHOD gr_msr_sales->check_incompleteness
      EXPORTING
        is_tvak  = tvak
        it_xvbap = xvbap[]
      CHANGING
        ct_xvbuv = xvbuv[].
  ENDIF.

  REFRESH yvbuv.
  DESCRIBE TABLE xvbuv LINES xa_lines.
  IF xa_lines NE 0.
    IF fehler = ' '.
      dynnr = sy-dynnr.
      LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN dynnr.
    ELSE.
      LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN dynnr.
    ENDIF.

    SORT xvbuv BY vbeln posnr sortf etenr parvw tdid tbnam fdnam.

    LOOP AT xvbuv.
      CALL FUNCTION 'RV_FIELD_READ'
        EXPORTING
          fdr_field       = xvbuv-fdnam
          fdr_langu       = sy-langu
          fdr_table       = xvbuv-tbnam
        IMPORTING
          fdr_dfies       = da_dfies_tab
        EXCEPTIONS
          field_not_found = 1
          OTHERS          = 2.
      IF sy-subrc = 0.
        feld = da_dfies_tab-scrtext_l.
      ELSE.
        CONCATENATE xvbuv-tbnam xvbuv-fdnam
          INTO fehlerfeld SEPARATED BY '-'.
      ENDIF.

      pack = xvbuv-posnr.
      anzeigepos = pack.
      CLEAR ausgabetext.
      IF xvbuv-etenr CN '0 '.
        WRITE text-200 TO ausgabetext(20).
        pack = xvbuv-etenr.
        ausgabetext+20(4) = pack.
        CONDENSE ausgabetext.
      ENDIF.
      IF xvbuv-posnr = posnr_low.
        MOVE '      ' TO anzeigepos(6).
      ENDIF.
      IF xvbuv-parvw CN '0 '.
        SELECT SINGLE * FROM tpart WHERE spras = sy-langu
                                   AND   parvw = xvbuv-parvw.
        ausgabetext = tpart-vtext.
        CONDENSE ausgabetext.
      ENDIF.
      IF xvbuv-tdid CN '0 '.
        IF xvbuv-posnr CN ' 0'.
          SELECT SINGLE * FROM ttxit WHERE tdspras  = sy-langu
                                     AND   tdobject = 'VBBP'
                                     AND   tdid     = xvbuv-tdid.
        ELSE.
          SELECT SINGLE * FROM ttxit WHERE tdspras  = sy-langu
                                     AND   tdobject = 'VBBK'
                                     AND   tdid     = xvbuv-tdid.
        ENDIF.
        ausgabetext = ttxit-tdtext.
        CONDENSE ausgabetext.
      ENDIF.
* Reparaturabwicklung
      IF xvbuv-fdnam EQ 'KZEN_OK'.
        WRITE text-201 TO ausgabetext.
        CONDENSE ausgabetext.
      ENDIF.

      MOVE anzeigepos  TO listwa-anzeigepos.
      MOVE ausgabetext TO listwa-ausgabetext.
*     Start Revenue Recognition Project
      IF ( XVBUV-FDNAM =  'SAKUR' or
           XVBUV-FDNAM =  'SAKUC' ) and XVBUV-TBNAM = 'TVRRUR'.
        MOVE DA_DFIES_TAB-SCRTEXT_M TO LISTWA-FELD.
      ELSE.
        MOVE feld TO listwa-feld.
      ENDIF.
*     End Revenue recognition Project
      MOVE fehlerfeld  TO listwa-fehlerfeld.
      APPEND listwa TO gt_uvprot_list.
    ENDLOOP.

*   Liste ausgeben

    PERFORM output_uvprot_alv.

  ELSE.
    MESSAGE s800.
    fehler = ' '.
* Unvollständigkeit Partner-Subscreen - Fehlerflags zurücksetzen
    CLEAR: fehler_kpar_sub,
           fehler_ppar_sub.
    fcode = 'BAFE'.
    PERFORM fcode_bearbeiten.
  ENDIF.

ENDFORM.                    "XVBUV_ANZEIGEN
*eject




* Event Handling
FORM eventtab_build USING xt_events TYPE slis_t_event.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 0
    IMPORTING
      et_events       = xt_events
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  READ TABLE xt_events WITH KEY name = slis_ev_top_of_page
                                         INTO ls_event.
  IF sy-subrc = 0.
    MOVE gc_uvprot_top_of_page TO ls_event-form.
    MODIFY xt_events FROM ls_event INDEX sy-tabix.
  ENDIF.

  READ TABLE xt_events WITH KEY name = slis_ev_user_command
                                         INTO ls_event.
  IF sy-subrc = 0.
    MOVE gc_uvprot_user_command TO ls_event-form.
    MODIFY xt_events FROM ls_event INDEX sy-tabix.
  ENDIF.

  READ TABLE xt_events WITH KEY name = slis_ev_pf_status_set
                                         INTO ls_event.
  IF sy-subrc = 0.
    MOVE gc_uvprot_status_set TO ls_event-form.
    MODIFY xt_events FROM ls_event INDEX sy-tabix.
  ENDIF.


ENDFORM.                    " EVENTTAB_BUILD




* FieldCatalog Building
FORM fieldcatlog_build USING xt_fieldcat TYPE slis_t_fieldcat_alv .

  CONSTANTS :
    lc_anzeigepos    TYPE dd03p-fieldname VALUE 'ANZEIGEPOS',
    lc_ausgabetext   TYPE dd03p-fieldname VALUE 'AUSGABETEXT',
    lc_feld          TYPE dd03p-fieldname VALUE 'FELD',
    lc_fehlerfeld    TYPE dd03p-fieldname VALUE 'FEHLERFELD'.

  DATA:     ls_fieldcat TYPE slis_fieldcat_alv.

  CLEAR ls_fieldcat.
  MOVE text-063 TO ls_fieldcat-reptext_ddic.
  ls_fieldcat-fieldname = lc_anzeigepos.
  ls_fieldcat-just      = 'R'.
  ls_fieldcat-col_pos   = 2.
  APPEND ls_fieldcat TO xt_fieldcat.

  CLEAR ls_fieldcat.
  MOVE text-064 TO ls_fieldcat-reptext_ddic.
  ls_fieldcat-fieldname = lc_ausgabetext.
  ls_fieldcat-col_pos   = 3.
  APPEND ls_fieldcat TO xt_fieldcat.

  CLEAR ls_fieldcat.
  MOVE text-065 TO ls_fieldcat-reptext_ddic.
  ls_fieldcat-fieldname = lc_feld.
  ls_fieldcat-col_pos   = 4.
  APPEND ls_fieldcat TO xt_fieldcat.

*  CLEAR LS_FIELDCAT.
*  MOVE TEXT-066 TO LS_FIELDCAT-REPTEXT_DDIC.
*  LS_FIELDCAT-FIELDNAME = LC_FEHLERFELD.
*  LS_FIELDCAT-NO_OUT    = 'X'.
*  LS_FIELDCAT-COL_POS   = 5.
*  APPEND LS_FIELDCAT TO XT_FIELDCAT.

ENDFORM.                    " FIELDCATLOG_BUILD




* Output Incompleteness log
FORM output_uvprot_alv.

* build the field catalog for the ALV.
  PERFORM fieldcatlog_build USING gt_uvprot_fieldcat[].

* build comments table for top of page
  PERFORM comment_build CHANGING gt_uvprot_list_top_of_page.

* build the event table for the alv
  PERFORM eventtab_build USING gt_uvprot_events[].
*
** build the layout for the ALV.
  PERFORM set_layout_alv CHANGING gs_uvprot_layout.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = gv_uvprot_repid
      i_callback_pf_status_set = gc_uvprot_status_set
      i_callback_user_command  = gc_uvprot_user_command
      i_callback_top_of_page   = gc_uvprot_top_of_page
      i_structure_name         = gc_uvprot_struname
*      I_GRID_TITLE             = GV_UVPROT_TITLE
      is_layout                = gs_uvprot_layout
      it_fieldcat              = gt_uvprot_fieldcat[]
      it_events                = gt_uvprot_events[]
    TABLES
      t_outtab                 = gt_uvprot_list
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " OUTPUT_UVPROT_ALV




* COMMENT_BUILD
FORM comment_build USING xt_uvprot_list_top_of_page TYPE
                                        slis_t_listheader.

  CONSTANTS : lc_h    TYPE c VALUE 'H',
              lc_s    TYPE c VALUE 'S',
              lc_a    TYPE c VALUE 'A'.
  DATA: ls_line TYPE slis_listheader.

  CLEAR ls_line.
  ls_line-typ  = lc_h.
  ls_line-info = gv_uvprot_title.
  APPEND ls_line TO xt_uvprot_list_top_of_page.

  CLEAR ls_line.
  ls_line-typ = lc_s.
  ls_line-key = text-002.
  ls_line-info = kuagv-kunnr.
  ls_line-info+11 = kuagv-name1.
  APPEND ls_line TO xt_uvprot_list_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = lc_a.
  ls_line-info = text-004.
  APPEND ls_line TO xt_uvprot_list_top_of_page.

ENDFORM.                    " COMMENT_BUILD




* TOP_OF_PAGE
FORM uv_top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_uvprot_list_top_of_page.

ENDFORM.                    "UV_TOP_OF_PAGE




* LAYOUT
FORM set_layout_alv  CHANGING xs_layout TYPE slis_layout_alv.

  xs_layout-colwidth_optimize    = gc_x.
  xs_layout-box_fieldname        = 'CHECKBOX'.
  xs_layout-box_tabname          = 'GT_UVPROT_LIST'.
  xs_layout-allow_switch_to_list = gc_x.

ENDFORM.                    " SET_LAYOUT_ALV




* PF_STATUS
FORM uv_pf_status_set USING it_cua_exclude TYPE slis_t_extab.

* GUI-Status für Unvollst.liste
  SET PF-STATUS 'FE_ALV' EXCLUDING CUA_EXCLUDE.

ENDFORM.                    " UV_PF_STATUS_SET




* USER_COMMAND
FORM uv_user_command USING p_fcode LIKE sy-ucomm
                           p_selfield TYPE slis_selfield.

  fcode = p_fcode.
  CASE fcode.                          "FCODE.
    WHEN 'BACK' OR '&F3'.
      fehlerexit = 'X'.
      fehler = ' '.
* Unvollständigkeit Partner-Subscreen - Fehlerflags zurücksetzen
      CLEAR: fehler_kpar_sub,
             fehler_ppar_sub.

      p_selfield-exit = 'X'.
      p_selfield-refresh = 'X'.
      LEAVE.

    WHEN 'FEBE' OR '&IC1'.
      fehler = 'X'.
      READ TABLE xvbuv INDEX p_selfield-tabindex.
      IF sy-subrc = 0.
* Partner-Subscreen-Fehlerflag setzen
        IF xvbuv-tbnam CP 'VBPA'.
          IF xvbuv-posnr IS INITIAL.
            fehler_kpar_sub = charx.
          ELSE.
            fehler_ppar_sub = charx.
          ENDIF.
        ENDIF.
      ENDIF.
      REFRESH yvbuv.

      LOOP AT gt_uvprot_list TRANSPORTING NO FIELDS
                             WHERE checkbox = 'X'.
        READ TABLE xvbuv INDEX sy-tabix.
        yvbuv = xvbuv.
        APPEND yvbuv.
      ENDLOOP.

      DESCRIBE TABLE yvbuv LINES yvbuv_lines.
      IF yvbuv_lines = 0.
        READ TABLE xvbuv INDEX p_selfield-tabindex.
        yvbuv = xvbuv.
        APPEND yvbuv.
      ENDIF.

      PERFORM fcode_fewe_alv USING p_selfield.

    WHEN OTHERS.
      fehler = ' '.
* Unvollständigkeit Partner-Subscreen - Fehlerflags zurücksetzen
      CLEAR: fehler_kpar_sub,
             fehler_ppar_sub.
      fcode = p_fcode.
      fehlerexit = 'X'.
*      P_SELFIELD-EXIT = 'X'.
*      P_SELFIELD-REFRESH = 'X'.
*      LEAVE.
      IF sy-calld = ' '.
*       Aufruf aus VAx1, VAx2, VAx3
        p_selfield-exit = 'X'.
        p_selfield-refresh = 'X'.
        LEAVE.
      ELSE.
*       Aufruf aus VAx5
        LEAVE TO SCREEN 0.
      ENDIF.



  ENDCASE.

ENDFORM.                    "UV_USER_COMMAND




*---------------------------------------------------------------------*
*       FORM FCODE_FEWE                                               *
*---------------------------------------------------------------------*
*       Aufruf der Fehlerbehandlungsliste                             *
*---------------------------------------------------------------------*
FORM fcode_fewe_alv USING p_selfield TYPE slis_selfield.

  DATA: exitflag(1) TYPE c.
  CLEAR exitflag.
  DO.
    DESCRIBE TABLE yvbuv LINES yvbuv_lines.
    IF yvbuv_lines > 0.
      READ TABLE yvbuv INDEX 1.
      READ TABLE xvbuv WITH KEY yvbuv(89).
      IF sy-subrc = 0.
        IF xvbuv-fcode IS INITIAL.
          MESSAGE i003(vu) WITH xvbuv-tbnam xvbuv-fdnam xvbuv-fehgr.
          DELETE yvbuv INDEX 1.
          CONTINUE.
        ENDIF.
        CONCATENATE xvbuv-tbnam xvbuv-fdnam
          INTO fehlerfeld SEPARATED BY '-'.
        DELETE yvbuv INDEX 1.
        PERFORM fehlerbehandlung_alv USING p_selfield.
        PERFORM fcode_bearbeiten.
        exitflag = 'X'.
        EXIT.
      ELSE.
        DELETE yvbuv INDEX 1.
      ENDIF.
      IF exitflag = 'X'. EXIT. ENDIF.
    ELSE.
      fcode = 'FEBA'.
      PERFORM fcode_bearbeiten.
      EXIT.
    ENDIF.
  ENDDO.

  IF sy-calld = ' '.
*   Aufruf aus VAx1, VAx2, VAx3
    p_selfield-exit = 'X'.
    p_selfield-refresh = 'X'.
    LEAVE.
  ELSE.
*   Aufruf aus VAx5
    p_selfield-exit = 'X'.
    p_selfield-refresh = 'X'.
    EXIT.
  ENDIF.
ENDFORM.                    "FCODE_FEWE_ALV





*---------------------------------------------------------------------*
*       FORM FEHLERBEHANDLUNG                                         *
*---------------------------------------------------------------------*
FORM fehlerbehandlung_alv USING p_selfield TYPE slis_selfield.

  DATA: fcode_old LIKE sy-ucomm.
  CLEAR fcode_old.

  fcode_old = fcode.

* Fehler-Window Partner
  IF xvbuv-parvw CN ' '.
    MOVE-CORRESPONDING xvbuv TO xvbpakey.

    IF xvbpakey-parvw = 'AA'
    OR xvbpakey-parvw = 'AW'.
*     Sonderfall Mehrfachrollen AA/AW
      LOOP AT xvbpa WHERE vbeln = xvbpakey-vbeln
                    AND   posnr = xvbpakey-posnr
                    AND   parvw = xvbpakey-parvw
                    AND ( kunnr IS INITIAL OR adrda IS INITIAL ).
        EXIT.
      ENDLOOP.
    ELSE.
      READ TABLE xvbpa WITH KEY xvbpakey.
    ENDIF.
    IF sy-subrc = 0.
      IF xvbpa-posnr > 0.
        IF xvbuv-fcode = 'KPAR' OR
           xvbuv-fcode = 'KPAR_SUB'.
          IF xvbuv-fcode = 'KPAR'.
            xvbuv-fcode = 'PPAR'.
          ENDIF.
          IF xvbuv-fcode = 'KPAR_SUB'.
            xvbuv-fcode = 'PPAR_SUB'.
          ENDIF.
          LOOP AT ivbap.
            IF ivbap-selkz = 'X'.
              ivbap-selkz = ' '.
              MODIFY ivbap.
            ENDIF.
            IF ivbap-posnr = xvbpa-posnr.
              ivbap-selkz = 'X'.
              MODIFY ivbap.
            ENDIF.
          ENDLOOP.
          READ TABLE ivbap WITH KEY xvbpa-posnr BINARY SEARCH.
          IF sy-subrc NE 0.
            ivbap-posnr = xvbpa-posnr.
            ivbap-selkz = 'X'.
            APPEND ivbap.
          ENDIF.
          PERFORM xvbap_lesen_direkt(sapfv45p) USING xvbuv-posnr
                                                     svbap-tabix.
          PERFORM vbap_bearbeiten_vorbereiten(sapfv45p).
        ENDIF.
      ENDIF.

      MOVE xvbuv-fcode TO fcode.
      fehlerexit = 'X'.

      IF sy-calld = ' ' OR fcode_old = 'FEBE' OR fcode_old = '&IC1'.
*        SET SCREEN 700.
        p_selfield-exit = 'X'.
        p_selfield-refresh = 'X'.
*        CALL SCREEN 700.
        LEAVE TO SCREEN 0.
*        LEAVE SCREEN.
      ENDIF.
      CHECK 1 = 2.
    ENDIF.
  ENDIF.                               "Ende PARVW nicht initial

* Fehler-Window Texte
  IF xvbuv-tdid CN ' '.
    MOVE xvbuv-fcode TO fcode.
    MOVE-CORRESPONDING xvbuv TO ftext.
    CASE ftext-posnr.
      WHEN '000000'. ftext-tdobject = 'VBBK'.
      WHEN OTHERS  . ftext-tdobject = 'VBBP'.
    ENDCASE.
    fehlerexit = 'X'.
*    SET SCREEN 700.
    p_selfield-exit = 'X'.
    p_selfield-refresh = 'X'.
*    CALL SCREEN 700.
    LEAVE TO SCREEN 0.
*    LEAVE SCREEN.
    CHECK 1 = 2.
  ENDIF.                               "Ende PARVW nicht initial

* Fehler-Window zum Kopf
  IF xvbuv-posnr EQ space AND
     xvbuv-etenr EQ space.

    IF xvbuv-fcode EQ fcode_kondition_kopf.
      xvbuv-fcode = fcode_kondition_kopf_subsc.
    ENDIF.

    MOVE xvbuv-fcode TO fcode.
    fehlerexit = 'X'.

    IF sy-calld = ' ' OR fcode_old = 'FEBE' OR fcode_old = '&IC1'.
*      SET SCREEN 700.
      p_selfield-exit = 'X'.
      p_selfield-refresh = 'X'.
*      CALL SCREEN 700.
      LEAVE TO SCREEN 0.
*      LEAVE SCREEN.
    ENDIF.
    CHECK 1 = 2.

  ENDIF.

* Fehler-Window zur Positionen
  IF xvbuv-posnr CN '0 ' AND
     xvbuv-etenr CO '0 '.
    PERFORM xvbap_lesen_direkt(sapfv45p) USING xvbuv-posnr
                                               svbap-tabix.
    PERFORM vbap_bearbeiten_vorbereiten(sapfv45p).
* Wegen Umstellung auf neues Konditionsbild ist der folgende MOVE
* erforderlich
    IF xvbuv-fcode EQ fcode_kondition_position.
      xvbuv-fcode = fcode_kondition_position_subsc.
    ENDIF.

    MOVE xvbuv-fcode TO fcode.
    fehlerexit = 'X'.

    IF sy-calld = ' ' OR fcode_old = 'FEBE' OR fcode_old = '&IC1'.
*      SET SCREEN 700.
      p_selfield-exit = 'X'.
      p_selfield-refresh = 'X'.
*      CALL SCREEN 700.
      LEAVE TO SCREEN 0.
*      LEAVE SCREEN.
    ENDIF.
    CHECK 1 = 2.
    EXIT.

  ENDIF.

* Fehler-Window zur Einteilung
  IF xvbuv-posnr NE space AND
     xvbuv-etenr NE space.
    PERFORM xvbap_lesen_direkt(sapfv45p) USING xvbuv-posnr
                                               svbap-tabix.
    PERFORM vbap_bearbeiten_vorbereiten(sapfv45p).
    PERFORM xvbep_lesen_direkt(sapfv45e) USING xvbuv-posnr
                                               xvbuv-etenr
                                               svbep-tabix.
    PERFORM vbep_bearbeiten_vorbereiten(sapfv45e).
    MOVE xvbuv-fcode TO fcode.
    fehlerexit = 'X'.

    IF sy-calld = ' ' OR fcode_old = 'FEBE' OR fcode_old = '&IC1'.
*      SET SCREEN 700.
      p_selfield-exit = 'X'.
      p_selfield-refresh = 'X'.
*      CALL SCREEN 700.
      LEAVE TO SCREEN 0.
*      LEAVE SCREEN.
    ENDIF.
    CHECK 1 = 2.

  ENDIF.
  MOVE 'FEBA' TO fcode.
  fehlerexit = 'X'.
  p_selfield-exit = 'X'.
  p_selfield-refresh = 'X'.
  LEAVE.
  CHECK 1 = 2.

ENDFORM.                    "FEHLERBEHANDLUNG_ALV