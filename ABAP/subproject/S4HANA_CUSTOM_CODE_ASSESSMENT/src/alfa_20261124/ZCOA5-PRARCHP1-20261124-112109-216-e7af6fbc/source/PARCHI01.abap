*&--------------------------------------------------------------------*
*       INCLUDE PARCHI01
*&--------------------------------------------------------------------*
* Form-Include P-Archivierung 1
*&--------------------------------------------------------------------*


*&--------------------------------------------------------------------*
*&      Form  initialization
*&--------------------------------------------------------------------*
FORM initialization USING i_autyp
                          i_object.

* Berechtigung zur Archivierung ?
  DATA: actvt_tmp LIKE tact-actvt VALUE '06'.
  AUTHORITY-CHECK OBJECT 'C_AFKO_ATY'
        ID 'ACTVT' FIELD actvt_tmp
        ID 'AUTYP' FIELD i_autyp.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE a677(co).
  ENDIF.

* Archivierungsobjekt PP_ORDER vorhanden?
  SELECT SINGLE * FROM arch_obj WHERE object = i_object.
  IF sy-dbcnt = 0.
    MESSAGE a058(00) WITH i_object space space 'ARCH_OBJ'.
  ENDIF.

ENDFORM.                    "initialization


*&--------------------------------------------------------------------*
*&      Form  at_selection_screen_output
*&--------------------------------------------------------------------*
FORM at_selection_screen_output CHANGING cv_pretst   TYPE char1
                                         cv_preprd   TYPE char1.

  STATICS:
    sv_slset   TYPE sy-slset.
  DATA:
    ls_key     TYPE rsvarkey,
    lv_testrun TYPE char1,
    lt_dirtab  TYPE TABLE OF cdir WITH HEADER LINE.

  CHECK sv_slset <> sy-slset.
* a variant was loaded
  sv_slset = sy-slset.

* check if it was an old variant
  ls_key-report  = sy-repid.
  ls_key-variant = sy-slset.
  IMPORT DIRECTORY INTO lt_dirtab FROM DATABASE vari(va) ID ls_key.
  READ TABLE lt_dirtab WITH KEY name = 'TESTRUN'
       TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.
* it was an old variant => load old parameter
  IMPORT testrun = lv_testrun FROM DATABASE vari(va) ID ls_key.

  CLEAR:
    cv_pretst,
    cv_preprd.
* transfer old paramters to new parameters
  IF NOT lv_testrun IS INITIAL.
    cv_pretst = yx.
  ELSE.
    cv_preprd = yx.
  ENDIF.

ENDFORM.                    "at_selection_screen_output


*---------------------------------------------------------------------*
*       FORM CHECK_SELECTION_SCREEN                                   *
*---------------------------------------------------------------------*
FORM check_selection_screen USING iv_loev TYPE char1
                                  iv_loek TYPE char1.

* Mindestens eine Funktion anwählen
  IF     iv_loev IS INITIAL
     AND iv_loek IS INITIAL.
    MESSAGE e889(co) WITH text-004 '' '' ''.
  ENDIF.

ENDFORM.                    "CHECK_SELECTION_SCREEN


*---------------------------------------------------------------------*
*       FORM CHECK_SELID                                              *
*---------------------------------------------------------------------*
FORM check_selid.

* Prüfen, ob Selid zulässig ist
  CHECK NOT selid IS INITIAL.
  SELECT SINGLE * FROM tj48 WHERE selid EQ selid.
  IF sy-subrc <> 0.
    MESSAGE e889(co) WITH text-005 '' '' ''.
  ENDIF.

ENDFORM.                    "CHECK_SELID


*---------------------------------------------------------------------*
*       FORM ACTIVITIES_ON_ORDER                                      *
*---------------------------------------------------------------------*
FORM activities_on_order USING iv_loev        TYPE char1
                               iv_loek        TYPE char1
                               iv_testrun     TYPE char1
                               iv_summary_msg TYPE char1.

  IF NOT caufv_tab[] IS INITIAL.

    CALL FUNCTION 'ORDER_CHANGE_FOR_ACTIVITY'
      EXPORTING
        flg_lkz              = iv_loek
        flg_lvm              = iv_loev
        selid                = selid
        testrun              = iv_testrun
        intervall            = interval
        init_tables          = yx
        maxnumber            = maxnum
        export_msg_to_memory = space
        i_flg_summary_msg    = iv_summary_msg
      TABLES
        caufv_tab            = caufv_tab
        table_of_messages    = mess_tab
      EXCEPTIONS
        nothing_to_do        = 01
        wrong_selid          = 02.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

* Authority-Check Protokoll einfügen
  INSERT LINES OF lt_mess INTO mess_tab INDEX 1.

ENDFORM.                    "ACTIVITIES_ON_ORDER

*---------------------------------------------------------------------*
*       Form  STORE_MESS_TAB
*---------------------------------------------------------------------*
FORM store_mess_tab USING id    LIKE  mess_tab-arbgb
                          ty    LIKE  mess_tab-msgty
                          nr    LIKE  mess_tab-msgnr
                          v1
                          sp    LIKE  mess_tab-spras
                          ph    LIKE  mess_tab-phase
                          aufnr LIKE  mess_tab-aufnr.
  CLEAR mess_tab.
  mess_tab-arbgb = id.
  mess_tab-msgty = ty.
  mess_tab-msgnr = nr.
  mess_tab-msgv1 = v1.
  mess_tab-spras = sp.
  mess_tab-phase = ph.
  mess_tab-aufnr = aufnr.
  APPEND mess_tab.
ENDFORM.                    "STORE_MESS_TAB

*---------------------------------------------------------------------*
*       FORM WRITE_PROTOCOLL_NEW                                      *
*---------------------------------------------------------------------*
FORM write_protocoll_new.

  DATA: phase_tmp,
        ld_msgno TYPE sy-msgno,
        aufnr_text(12).

  CALL FUNCTION 'ARCHIVE_PROTOCOL_INIT'
    EXPORTING
      i_detailprotocol  = p_prot
      i_protocol_output = p_prot_o.

  SORT mess_tab BY phase aufnr.
  LOOP AT mess_tab.
*   don't ouput old summary message
    IF     mess_tab-arbgb = 'CO'
       AND mess_tab-msgnr = '442'.
      CONTINUE.
    ENDIF.

    IF mess_tab-phase NE phase_tmp.
      phase_tmp = mess_tab-phase.
    ENDIF.

    ld_msgno = mess_tab-msgnr.
    WRITE mess_tab-aufnr TO aufnr_text.

*   IF    mess_tab-phase = '0'  "number of statuses that can be set
    IF    mess_tab-phase = '8'  "orders for which status DLFL can be set
       OR mess_tab-phase = '9'  "orders for which status DLT  can be set
       OR mess_tab-phase = '-'. "no orders found
      CALL FUNCTION 'ARCHIVE_PROTOCOL_COLLECT_APPL'
        EXPORTING
          i_object  = aufnr_text
          i_msgtype = 1
          i_msgid   = mess_tab-arbgb+0(20)
          i_msgno   = ld_msgno
          i_msgv1   = mess_tab-msgv1
          i_msgv2   = mess_tab-msgv2
          i_msgv3   = mess_tab-msgv3
          i_msgv4   = mess_tab-msgv4.
    ELSEIF mess_tab-msgty = 'E'.
      CALL FUNCTION 'ARCHIVE_PROTOCOL_COLLECT_APPL'
        EXPORTING
          i_object  = aufnr_text
          i_msgtype = 2
          i_msgid   = mess_tab-arbgb+0(20)
          i_msgno   = ld_msgno
          i_msgv1   = mess_tab-msgv1
          i_msgv2   = mess_tab-msgv2
          i_msgv3   = mess_tab-msgv3
          i_msgv4   = mess_tab-msgv4.
    ELSE.
      CALL FUNCTION 'ARCHIVE_PROTOCOL_COLLECT_APPL'
        EXPORTING
          i_object  = aufnr_text
          i_msgtype = 3
          i_msgid   = mess_tab-arbgb+0(20)
          i_msgno   = ld_msgno
          i_msgv1   = mess_tab-msgv1
          i_msgv2   = mess_tab-msgv2
          i_msgv3   = mess_tab-msgv3
          i_msgv4   = mess_tab-msgv4.
    ENDIF.
  ENDLOOP.

  CLEAR mess_tab.

  CALL FUNCTION 'ARCHIVE_PROTOCOL_WRITE_APPL'.

ENDFORM.                    "WRITE_PROTOCOLL_NEW