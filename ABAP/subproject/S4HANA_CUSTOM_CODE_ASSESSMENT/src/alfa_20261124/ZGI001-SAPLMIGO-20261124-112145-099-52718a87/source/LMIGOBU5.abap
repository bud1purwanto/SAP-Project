*----------------------------------------------------------------------*
*   INCLUDE LMIGOBU5: Buffers for movement types                       *
*----------------------------------------------------------------------*
************************************************************************
* Reads got156 data from buffer or t156 and updates buffer if necessary
************************************************************************
  METHOD move_type_get.
    DATA: ls_t156      TYPE t156.
* look for movement type data in the buffer table
    READ TABLE pt_move_buffer INTO e_got156
                              WITH TABLE KEY bwart = i_move.
    IF sy-subrc <> 0.
* read movement type data from data base
      CLEAR e_got156.
      SELECT SINGLE * FROM t156 INTO ls_t156 WHERE bwart = i_move.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_t156 TO e_got156.
        INSERT e_got156 INTO TABLE pt_move_buffer.
      ELSE.
*     No insert into the buffer
        MESSAGE e001(mick) WITH i_move
                           RAISING not_found.
      ENDIF.
    ENDIF.
*   table migo_t156 is fully DB buffered -> no need to program an
*   additional buffer here.
*   If i_move = initial select of migo_t156 is never reached ->
*   We can issue an error message without exception.
    SELECT SINGLE * FROM migo_t156
                    INTO es_migo_t156
                    WHERE bustr = e_got156-bustr.
    IF sy-subrc <> 0.
      MESSAGE e060(migo) WITH e_got156-bustr.
    ENDIF.
  ENDMETHOD.                    "move_type_get

************************************************************************
* Reads T156n from buffer or T156n and updates buffer if necessary
************************************************************************
  METHOD move_type_next_get.
    DATA: ls_buffer TYPE pty_move_next_buffer,
          ls_t156n  TYPE t156n.
* look for move_next data in the buffer table
    READ TABLE  pt_move_next_buffer INTO ls_buffer
                         WITH TABLE KEY bwart = i_move
                                        fcode = i_fcode.
    IF sy-subrc = 0.
      e_move_next = ls_buffer-bwart_next.
      EXIT.
    ENDIF.
* read data from data base
    CLEAR e_move_next.
    SELECT SINGLE * FROM t156n INTO ls_t156n WHERE bwart = i_move
                                             AND   fcode = i_fcode.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_t156n TO ls_buffer.
      INSERT ls_buffer INTO TABLE pt_move_next_buffer.
      e_move_next = ls_buffer-bwart_next.
    ELSE.
*   No insert into the buffer
      MESSAGE e001(mick) WITH i_move
                         RAISING not_found.
    ENDIF.
  ENDMETHOD.                       "MOVE_TYPE_NEXT_GET
************************************************************************
* Reads T156t data from buffer or t156t
* and updates buffer if necessary
************************************************************************
  METHOD move_type_text_get.
    DATA: lt_t156t            TYPE TABLE OF t156t,
          ls_t156t            TYPE t156t,
          ls_move_text_buffer TYPE pty_s_move_text_buffer.
* Look for data in buffer
    READ TABLE pt_move_text_buffer INTO ls_move_text_buffer
                               WITH TABLE KEY match = i_match
                                              spras = i_langu
                                              bwart = i_move
                                              sobkz = i_spec_stock
                                              kzbew = i_mov_ind
                                              kzzug = i_rec_ind
                                              kzvbr = i_consumpt
                               TRANSPORTING   btext.
    IF sy-subrc = 0.
      e_move_text = ls_move_text_buffer-btext.
      EXIT.
    ELSE.
* Look for data in db with exact key
      SELECT SINGLE * FROM t156t INTO ls_t156t
                      WHERE spras = i_langu
                      AND   bwart = i_move
                      AND   sobkz = i_spec_stock
                      AND   kzbew = i_mov_ind
                      AND   kzzug = i_rec_ind
                      AND   kzvbr = i_consumpt.
      IF sy-subrc = 0.
        e_move_text = ls_t156t-btext.
        MOVE-CORRESPONDING ls_t156t TO ls_move_text_buffer.
        ls_move_text_buffer = i_match.
        INSERT ls_move_text_buffer INTO TABLE pt_move_text_buffer.
        EXIT.
      ELSEIF i_match = abap_true.
        MESSAGE e010 WITH i_move i_spec_stock
                     RAISING not_found.
      ENDIF.
    ENDIF.
    CLEAR e_move_text.
* No exact match was found => search t156t with abbrivated key
* look for data in db
    SELECT * FROM t156t INTO TABLE lt_t156t
             WHERE spras = i_langu
             AND   bwart = i_move
             AND   sobkz = i_spec_stock.
    IF sy-subrc <> 0.
      MESSAGE e010 WITH i_move i_spec_stock
                   RAISING not_found.
    ELSE.
* Look for first possible entry (sobkz = ' ')
      SORT lt_t156t BY bwart sobkz kzbew kzzug kzvbr.
      READ TABLE lt_t156t INTO ls_t156t WITH KEY spras = i_langu
                                                 bwart = i_move
                                                 sobkz = i_spec_stock.
      e_move_text = ls_t156t-btext.
      ls_move_text_buffer-match = i_match.
      ls_move_text_buffer-spras = i_langu.
      ls_move_text_buffer-bwart = i_move.
      ls_move_text_buffer-sobkz = i_spec_stock.
      ls_move_text_buffer-kzbew = i_mov_ind.
      ls_move_text_buffer-kzzug = i_rec_ind.
      ls_move_text_buffer-kzvbr = i_consumpt.
      ls_move_text_buffer-btext = ls_t156t-btext.
      INSERT ls_move_text_buffer INTO TABLE pt_move_text_buffer.
    ENDIF.
  ENDMETHOD.                                 "MOVE_TYPE_TEXT_GET
************************************************************************
* Reads T158 data from buffer or t158
* and updates buffer if necessary           - note 315434
************************************************************************
  METHOD trx_control_get.                                   "315434
    DATA: ls_158_buffer TYPE t158.
    CLEAR: e_wever.
    CHECK NOT i_tcode IS INITIAL.
* Try to find entry in buffer table------------------------------------*
    READ TABLE pt_158_buffer INTO ls_158_buffer
                             WITH TABLE KEY tcode = i_tcode.
    IF sy-subrc = 0.
      e_wever = ls_158_buffer-wever.
      EXIT.
    ENDIF.
* Entry not found in buffer => read from database ---------------------*
    ls_158_buffer-tcode = i_tcode.
    SELECT SINGLE * FROM t158 INTO ls_158_buffer WHERE tcode = i_tcode.
    IF sy-subrc = 0.
      e_wever   = ls_158_buffer-wever.
*   Insert into buffer
      INSERT ls_158_buffer INTO TABLE pt_158_buffer.
    ELSE.
*   No insert into the buffer, raise exception
      MESSAGE e001(mick) WITH    i_tcode
                         RAISING not_found.
    ENDIF.
  ENDMETHOD.                                 "TRX_CONTROL_GET
************************************************************************
* Reads T158B data from buffer or T158B
* and updates buffer if necessary           - note 556499
************************************************************************
METHOD auto_po_get.                                    "556499
  DATA: ls_158b_buffer TYPE t158b.

  CLEAR: e_xautopo.

* Try to find entry in buffer table------------------------------------*
  READ TABLE pt_158b_buffer INTO ls_158b_buffer
                            WITH TABLE KEY tcode = i_tcode
                                           bwart = i_bwart.
  IF sy-subrc = 0.
*   Automatic creation of a purchase order / returns order during a
*   goods receipt is only allowed for XKZBEW = 3 or XKZBEW = 4.
    IF ls_158b_buffer-xkzbew = 3 OR ls_158b_buffer-xkzbew = 4.
      e_xautopo = abap_true.
    ENDIF.
    EXIT.
  ENDIF.

* Entry not found in buffer => read from database ---------------------*
  SELECT SINGLE * FROM t158b INTO ls_158b_buffer WHERE tcode = i_tcode
                                                 AND   bwart = i_bwart.
  IF sy-subrc = 0.
*   Automatic creation of a purchase order / returns order during a
*   goods receipt is only allowed for XKZBEW = 3 or XKZBEW = 4.
    IF ls_158b_buffer-xkzbew = 3 OR ls_158b_buffer-xkzbew = 4.
      e_xautopo = abap_true.
    ENDIF.
*   Insert into buffer
    INSERT ls_158b_buffer INTO TABLE pt_158b_buffer.
  ELSE.
*   No insert into the buffer, raise exception
    MESSAGE e096(m7) WITH i_bwart RAISING not_found.
  ENDIF.
ENDMETHOD.

************************************************************************
* Get allowed movement types (from MIGO_T156 and T158B)
************************************************************************
  METHOD allowed_mvt_get.
    DATA: lt_bustr TYPE HASHED TABLE OF bustr
                   WITH UNIQUE KEY table_line,
          l_bustr  TYPE bustr,
          l_mvt    TYPE bwart,
          l_tabix  TYPE sy-tabix.

    et_mvt = pt_mvt.
*   Are there any changes?
    CHECK p_migo_action <> i_migo_action OR
          p_migo_mode   <> i_migo_mode.
    CLEAR et_mvt.
* Select allowed movement types for transaction MIGO from T158B
* - Always read with "MIGO"
* - Skip entries with T158B-XKZBEW = 2
* - Skip entries BWART = 605/606
    SELECT bwart INTO TABLE et_mvt
                 FROM t158b WHERE tcode = 'MIGO'
                              AND xkzbew <> '2'
                              AND bwart  <> '605'
                              AND bwart  <> '606'.
*   Remove from storage loc.
    IF i_migo_action = 'A09'.
      SELECT bustr FROM migo_t156 INTO TABLE lt_bustr
                WHERE xremove_from_mvt = 'X'.
*   Place in storage loc.
    ELSEIF i_migo_action = 'A10'.
      SELECT bustr FROM migo_t156 INTO TABLE lt_bustr
                 WHERE xplace_in_mvt = 'X'.
*   Transfer
    ELSEIF i_migo_mode = 'GT'.
      SELECT bustr FROM migo_t156 INTO TABLE lt_bustr
               WHERE xtransfer_mvt = 'X'.
*   Not a transfer posting
    ELSEIF i_migo_mode <> 'GT'.
      SELECT bustr FROM migo_t156 INTO TABLE lt_bustr
                 WHERE xtransfer_mvt = ' '.
    ENDIF.
    LOOP AT et_mvt INTO l_mvt.
      l_tabix = sy-tabix.
      SELECT SINGLE bustr FROM t156 INTO l_bustr
                    WHERE bwart = l_mvt.
      READ TABLE lt_bustr WITH KEY table_line = l_bustr
                                        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        DELETE et_mvt INDEX l_tabix.
      ENDIF.
    ENDLOOP.
*   Save information for the next CALL.
    pt_mvt        = et_mvt.
    p_migo_mode   = i_migo_mode.
    p_migo_action = i_migo_action.

  ENDMETHOD.                    "allowed_mvt_get
************************************************************************
* Checks if a movement type is allowed for the current process
************************************************************************
  METHOD allowed_mvt_check.
    READ TABLE pt_mvt WITH KEY table_line = i_bwart
    TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      MESSAGE e001(mick) WITH i_bwart                    "dummy message
                  RAISING not_allowed.
    ENDIF.
  ENDMETHOD.                    "allowed_mvt_check

************************************************************************
* Reads T156Q data from buffer or T156Q and updates buffer if necessary
* and reads data from T377    -    note752637
************************************************************************
METHOD  serial_relevance_check.
  data: ls_t377  type t377,
        ls_t156q type t156q.

  clear e_serialize.

* Try to find entry in buffer table
  READ TABLE pt_156q_buffer INTO ls_t156q
                            WITH TABLE KEY bwart  = i_bwart
                                           sobkz  = i_sobkz
                                           kzbew  = i_kzbew
                                           kzzug  = i_kzzug
                                           kzvbr  = i_kzvbr.
  if not sy-subrc is initial.
*   entry is not yet in buffer -> read data base and update buffer.
    SELECT SINGLE * INTO  ls_t156q
                    FROM  t156q
                    WHERE bwart  = i_bwart
                    AND   sobkz  = i_sobkz
                    AND   kzbew  = i_kzbew
                    AND   kzzug  = i_kzzug
                    AND   kzvbr  = i_kzvbr.
    if sy-subrc is initial.                                      "856548
      insert ls_t156q into table pt_156q_buffer.                 "856548
    else.                                                        "856548
      clear ls_t156q.                                            "856548
    endif.                                                       "856548
  endif.

  CALL FUNCTION 'SERIAL_PROFILE_READ'
    EXPORTING
      profile_r            = i_sernp
      OPERATION_R          = 'MMSL'
      SNBWG_R              = ls_t156q-snbwg
      PFLEGE               = 'X'
    IMPORTING
      T_377                = ls_t377
    EXCEPTIONS
      NO_T377P_ENTRY       = 1
      NO_T377_ENTRY        = 2
      OTHERS               = 3.

  IF sy-subrc <> 0.
    CLEAR ls_t377.
  ENDIF.

  if ls_t377-SERPFLICHT = '02' or ls_t377-SERPFLICHT = '03'.
    e_serialize = abap_true.
  else.
    e_serialize = abap_false.
  endif.
  IF goitem-kzwes = s AND goitem-bustr = '103'.                 "1667402
*   No S/N for non-valuated GR-blocked stock                    "1667402
    e_serialize = abap_false.                                   "1011948
  ENDIF.                                                        "1011948

ENDMETHOD.