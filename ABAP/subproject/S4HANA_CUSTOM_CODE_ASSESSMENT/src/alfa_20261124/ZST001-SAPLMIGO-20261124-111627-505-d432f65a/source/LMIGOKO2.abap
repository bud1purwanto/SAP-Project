*----------------------------------------------------------------------*
*   INCLUDE LMIGOKO2                                                   *
*----------------------------------------------------------------------*
* METHOD OUTPUT_DETERMINATION
*----------------------------------------------------------------------*
METHOD output_determination.
  DATA: l_noauth  TYPE abap_bool,
        l_werks   TYPE goitem-werks,
        ls_mseg   TYPE mseg,
        lt_dummy  TYPE STANDARD TABLE OF msgpa,
        ls_got156 TYPE got156,
        ls_t156   TYPE t156,
        ls_nastkey TYPE ty_s_nastkey,
        lt_nastkey TYPE ty_t_nastkey,
        l_msg_objky   TYPE nast-objky,
        l_msg_objtyp  TYPE tojtb-name VALUE 'MSEG',
        lt_xnast TYPE STANDARD TABLE OF vnast,
        lt_ynast TYPE STANDARD TABLE OF nast,
        ls_vm07m TYPE vm07m.                                     "755953

  FIELD-SYMBOLS: <goitem> TYPE goitem.
* Map ps_mkpf and ps_gohead (wever can be changed) - note 315434
  ps_mkpf_nast-wever = ps_gohead-wever.                     "315434
* Header fill----------------------------------------------------------
  CALL FUNCTION 'COMMUNICATION_AREA_KOMKBME'
       EXPORTING
            msg_mkpf     = ps_mkpf_nast
*           MSG_T158     =
*           MSG_PR_UNAME =
       TABLES
            tab_part     = lt_dummy
            .
* Item data------------------------------------------------------------
  LOOP AT pt_goitem ASSIGNING <goitem>.
*   Authority-check
    IF <goitem>-werks <> l_werks.
      IF NOT cl_mmim_auth=>check( i_object = 'M_MSEG_WMB'
                                  i_actvt  = '04'
                                 i_value1 = <goitem>-werks ) IS INITIAL.
        l_noauth = abap_true.
        EXIT.
      ENDIF.
      l_werks = <goitem>-werks.
    ENDIF.
* Item fill
    CALL METHOD lcl_migo_buffer=>move_type_get
      EXPORTING
        i_move   = <goitem>-bwart
      IMPORTING
        e_got156 = ls_got156
      EXCEPTIONS
        OTHERS   = 1.
    MOVE-CORRESPONDING ls_got156 TO ls_t156.
    IF <goitem>-xlbtype = c.                                    "1176516
      READ TABLE pt_mseg_nast WITH KEY                          "1176516
                  mblnr   = <goitem>-mblnr                      "1176516
                  mjahr   = <goitem>-mjahr                      "1176516
                  line_id = <goitem>-global_counter             "1176516
                       INTO ls_mseg.                            "1176516
      CHECK sy-subrc = 0.                                       "1176516
    ELSE.                                                       "1176516
      READ TABLE pt_mseg_nast WITH TABLE KEY mblnr = <goitem>-mblnr
                                           mjahr = <goitem>-mjahr
                                           zeile = <goitem>-zeile
                       INTO ls_mseg.
    CHECK sy-subrc = 0.
    ENDIF.                                                      "1176516
*   Read label data from mat.master for late printing in MIGO    "755953
    IF ls_vm07m IS INITIAL AND NOT ls_mseg-matnr IS INITIAL.     "755953
      SELECT SINGLE etiar etifo FROM mara                        "755953
        INTO CORRESPONDING FIELDS OF ls_vm07m                    "755953
        WHERE matnr = ls_mseg-matnr.                             "755953
    ENDIF.                                                       "755953

    CALL FUNCTION 'COMMUNICATION_AREA_KOMPBME'
         EXPORTING
              msg_mkpf  = ps_mkpf_nast
              msg_mseg  = ls_mseg
              msg_t156  = ls_t156
              msg_vm07m = ls_vm07m                               "755953
         TABLES
              tab_part  = lt_dummy.
* Messaging for item
    ls_nastkey-mblnr = <goitem>-mblnr.
    ls_nastkey-mjahr = <goitem>-mjahr.
    IF <goitem>-xlbtype = c.                                    "1176516
      ls_nastkey-zeile = ls_mseg-zeile.                         "1176516
    ELSE.                                                       "1176516
      ls_nastkey-zeile = <goitem>-zeile.
    ENDIF.                                                      "1176516
    l_msg_objky = ls_nastkey.
    CALL FUNCTION 'MESSAGING'
         EXPORTING
              applikation                 = c_nast_appl  "#EC DOM_EQUAL
              msg_objky                   = l_msg_objky
              schema                      = 'ME0001'
*           GRUPPENVERARBEITUNG         =
              pi_objtype                  = l_msg_objtyp
              pi_item                     = x
*      IMPORTING
*           PE_UNPROCESSED_OUTPUT       =
         TABLES
              msg_part                    = lt_dummy
         EXCEPTIONS
*           APPLIKATION_NICHT_VORHANDEN = 1
*           SCHEMA_NICHT_VORHANDEN      = 2
              OTHERS                      = 3
              .
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.

  ENDLOOP.
*
  IF l_noauth = abap_true.             "No authorization
    MESSAGE i122(m7) WITH <goitem>-werks.
    EXIT.
  ENDIF.

* After messaging, check if some messages have been generated and
* need to be updated and set field GOHEAD-XNAPR.
  CALL FUNCTION 'RV_MESSAGES_GET'
       EXPORTING
            msg_kappl      = c_nast_appl                    "ME
*           MSG_OBJKY_FROM = ' '
*           MSG_OBJKY_TO   = ' '
       TABLES
            tab_xnast      = lt_xnast
            tab_ynast      = lt_ynast
       EXCEPTIONS
            error_message  = 4
            .
  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
               sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF lt_xnast IS INITIAL.
    MESSAGE i032.                "output determination found nothing
    clear ps_gohead-xnapr.                                  "315434
    EXIT.
  ENDIF.
* Messages have been found => update
* MB_MESSAGE_UPDATE sets a PERFORM ON COMMIT => UPDATE TASK
  CALL FUNCTION 'MB_MESSAGE_UPDATE'
       EXPORTING
            m_kappl = c_nast_appl                           "ME
*           M_OBJKY = ' '
       EXCEPTIONS
            error_message  = 4
            .
  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
               sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    MESSAGE i570(m7).                                       "315434
  ENDIF.

  COMMIT WORK AND WAIT.

* now set the current MIGO fields in GOHEAD and GOITEM
  CALL METHOD lcl_migo_globals=>kernel->output_exist
    EXPORTING
      i_mblnr    = ps_gohead-mblnr
      i_mjahr    = ps_gohead-mjahr
    IMPORTING
      i_exist    = ps_gohead-xnapr
      it_nastkey = lt_nastkey.
  LOOP AT pt_goitem ASSIGNING <goitem>.
    READ TABLE lt_nastkey WITH TABLE KEY mblnr = <goitem>-mblnr
                                         mjahr = <goitem>-mjahr
                                         zeile = <goitem>-zeile
                          TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      <goitem>-nast = abap_true.
    ENDIF.
  ENDLOOP.
  CALL METHOD status_derive.
ENDMETHOD.                    "output_determination
*----------------------------------------------------------------------*
* METHOD OUTPUT_EXIST
*----------------------------------------------------------------------*
*   importing i_mblnr type mblnr
*             i_mjahr type mjahr
*   EXPORTING i_exist    TYPE abap_bool
*             it_nastkey TYPE ty_t_nastkey,
* Check if there are any NAST entries for a material document
*----------------------------------------------------------------------*
METHOD output_exist.
  DATA: l_objky_from TYPE nast-objky,
        l_objky_to   TYPE nast-objky.
  DATA: ls_xnast TYPE vnast,
        lt_xnast TYPE STANDARD TABLE OF vnast,
        lt_ynast TYPE STANDARD TABLE OF nast.
  DATA: ls_nastkey TYPE ty_s_nastkey.
* Clear before beginning
  CLEAR: it_nastkey,
          i_exist.
* Fill range for material document item: 0001 - 9999
  ls_nastkey-mblnr = i_mblnr.
  ls_nastkey-mjahr = i_mjahr.
  ls_nastkey-zeile = '0001'.
  l_objky_from    = ls_nastkey.
  ls_nastkey-zeile = '9999'.
  l_objky_to      = ls_nastkey.

* Read NAST records for material document
  CALL FUNCTION 'RV_MESSAGES_READ'
    EXPORTING
      msg_kappl    = c_nast_appl                      "ME
      msg_objky    = l_objky_from
      msg_objky_to = l_objky_to.

  CALL FUNCTION 'RV_MESSAGES_GET'
    EXPORTING
      msg_kappl      = c_nast_appl                    "ME
      msg_objky_from = l_objky_from
      msg_objky_to   = l_objky_to
    TABLES
      tab_xnast      = lt_xnast
      tab_ynast      = lt_ynast.

* Set returning flag r_exist
  IF lt_xnast IS INITIAL.
    i_exist = abap_false.
  ELSE.
    i_exist = abap_true.
    LOOP AT lt_xnast INTO ls_xnast.
      ls_nastkey-mblnr = ls_xnast-objky(10).
      ls_nastkey-mjahr = ls_xnast-objky+10(4).
      ls_nastkey-zeile = ls_xnast-objky+14(4).
      INSERT ls_nastkey INTO TABLE it_nastkey.
    ENDLOOP.
  ENDIF.
ENDMETHOD.                             "OUTPUT_EXIST
*----------------------------------------------------------------------*
* METHOD OUTPUT_SHOW
*----------------------------------------------------------------------*
*   IMPORTING i_mblnr    TYPE mblnr
*             i_mjahr    TYPE mjahr
*             i_zeile    TYPE mblpo,
* Sends full screen of output maintenance as reaction to pushbutton
* MIGO_OK_NAST_SHOW on output detail tabstrip
*----------------------------------------------------------------------*
METHOD output_show.
  DATA: l_btext    TYPE dv70a-btext,
        ls_t185f   TYPE t185f,
        ls_t185v   TYPE t185v,
        l_objky    TYPE nast-objky,
        ls_dfies   TYPE dfies,
        l_cua_text TYPE dfies-scrtext_m,
        ls_nastkey TYPE ty_s_nastkey,
        lt_partner TYPE STANDARD TABLE OF msgpa.
* Get field description 'material document' from DDIC
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname    = 'GOITEM'
      lfieldname = 'MBLNR'
    IMPORTING
      dfies_wa   = ls_dfies
    EXCEPTIONS
      OTHERS     = 1.
  IF sy-subrc = 0.
    l_cua_text = ls_dfies-scrtext_m.
  ENDIF.
* Fill first line of full screen: material document + item
  l_btext = l_cua_text.
  l_btext+20(1) = '$'.
  CONDENSE l_btext.
  SEARCH l_btext FOR '$'.
  sy-fdpos = sy-fdpos - 1.
  WRITE '....................' TO l_btext+sy-fdpos(20).
  WRITE space TO l_btext+20(1).
  WRITE i_mblnr TO l_btext+21.
  WRITE i_zeile TO l_btext+32.

* Fill values for screen control
  ls_t185f-fcode = 'ENT1'.
  ls_t185f-trtyp = a.                  "display mode

* Fill object key
  ls_nastkey-mblnr = i_mblnr.
  ls_nastkey-mjahr = i_mjahr.
  ls_nastkey-zeile = i_zeile.
  l_objky         = ls_nastkey.


  CALL FUNCTION 'RV_MESSAGES_MAINTENANCE'
       EXPORTING
*           MIN_BILD     = 'S'
            min_btext    = l_btext
            min_cua_text = l_cua_text
            min_kalsm    = 'ME0001'
            min_kappl    = c_nast_appl                      "ME
            min_objky    = l_objky
*           MIN_T185     = l_t185
            min_t185f    = ls_t185f
            min_t185v    = ls_t185v
*           MIN_OBJKY_TO = ' '
*           PI_OBJTYPE   = ' '
            pi_preview   = 'X'
*      IMPORTING
*           MEX_FCODE    =
*           MEX_T185F    =
*           MEX_T185V    =
*           MEX_UPDAT    =
       TABLES
            mtb_part     =  lt_partner
            .
ENDMETHOD.                             "OUTPUT_SHOW