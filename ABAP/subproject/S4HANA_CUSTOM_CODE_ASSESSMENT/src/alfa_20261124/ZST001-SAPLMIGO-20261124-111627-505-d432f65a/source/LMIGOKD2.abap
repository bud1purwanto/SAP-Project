*----------------------------------------------------------------------*
*   INCLUDE LMIGOKD2                                                   *
*   Append a delivery note
*----------------------------------------------------------------------*

METHOD delivery_note_read.
  TYPES: BEGIN OF ty_s_list,
           lifnr TYPE elifn,
           mblnr TYPE mblnr,
           mjahr TYPE mjahr,
           bldat TYPE bldat,
         END OF ty_s_list.
  DATA: ls_mebex TYPE m_mebex,
        lt_mebex TYPE STANDARD TABLE OF m_mebex,
        ls_list  TYPE ty_s_list,
        lt_list  TYPE STANDARD TABLE OF ty_s_list,
        ls_fc    TYPE slis_fieldcat_alv,
        lt_fc    TYPE slis_t_fieldcat_alv,
        ls_sel   TYPE slis_selfield,
        l_lines  TYPE i.

* Read data from matchcode index MEBE-X.
* It has XBLNR at the first position.
* VGABE = 1 --> Only materialdocuments posted as goods receipt.
  SELECT * FROM m_mebex INTO TABLE lt_mebex
                        WHERE xblnr = i_delivery_note
                          AND vgabe = '1'.                       "206074
  IF sy-subrc <> 0.
    def_msg_add oref_doc_log w 'M7' '247' space space space space.
    EXIT.
  ENDIF.
* Send a popup with the found deliveries
  LOOP AT lt_mebex INTO ls_mebex.
    CLEAR ls_list.
    ls_list-mblnr = ls_mebex-belnr.
    ls_list-mjahr = ls_mebex-gjahr.
    SELECT SINGLE lifnr INTO (ls_list-lifnr) FROM ekko
           WHERE ebeln = ls_mebex-ebeln.
    SELECT SINGLE bldat INTO (ls_list-bldat) FROM mkpf
           WHERE mblnr = ls_list-mblnr
             AND mjahr = ls_list-mjahr.
    APPEND ls_list TO lt_list.
  ENDLOOP.
  SORT lt_list BY lifnr mblnr mjahr.
  DELETE ADJACENT DUPLICATES FROM lt_list.

* Only one hit --> take immedeately, otherwise popup to select
  DESCRIBE TABLE lt_list LINES l_lines.
  IF l_lines = 1.
    ls_sel-tabindex = 1.
  ELSE.
    ls_fc-fieldname = 'LIFNR'. ls_fc-ref_tabname = 'EKKO'.
    APPEND ls_fc TO lt_fc.
    ls_fc-fieldname = 'MBLNR'. ls_fc-ref_tabname = 'MKPF'.
    APPEND ls_fc TO lt_fc.
    ls_fc-fieldname = 'MJAHR'. ls_fc-ref_tabname = 'MKPF'.
    APPEND ls_fc TO lt_fc.
    ls_fc-fieldname = 'BLDAT'. ls_fc-ref_tabname = 'MKPF'.
    APPEND ls_fc TO lt_fc.
    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_tabname               = 'LT_LIST'
        it_fieldcat             = lt_fc
      IMPORTING
        es_selfield             = ls_sel
      TABLES
        t_outtab                = lt_list.
  ENDIF.
* If terminated, leave
  CHECK ls_sel-tabindex <> 0.
* Start taking the selected material document
  READ TABLE lt_list INTO ls_list INDEX ls_sel-tabindex.
  CALL METHOD materialdocument_get
    EXPORTING
      i_mat_doc  = ls_list-mblnr
    CHANGING
      c_doc_year = ls_list-mjahr.
ENDMETHOD.