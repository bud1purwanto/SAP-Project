*eject
*---------------------------------------------------------------------*
*       FORM BELEG_LESEN                                              *
*---------------------------------------------------------------------*
*       Der Beleg wird gelesen und in die Tabelle YMSEG bzw.          *
*       FUSS gestellt.                                                *
*---------------------------------------------------------------------*
FORM beleg_lesen TABLES it_zeile TYPE ty_t_mblpo.

  DATA: found_in_archiv VALUE space.
  DATA: lv_brazil_tfret TYPE c.
  DATA: lv_brazil_cancsto TYPE xfeld.                       " 822991
  DATA: prreg LIKE t158-prreg.         " Note 647871
* --- IS ADEC GPD EhP4 declarations
  DATA:          ls_st156s TYPE st156s,
                 lv_pspnr  TYPE prps-pspnr.
  FIELD-SYMBOLS: <xmseg>   TYPE mseg.

* MAA2 Begin
* if business function multi account assignment is active
  IF cl_ops_switch_check=>mm_sfws_maa( ) IS NOT INITIAL and
     NOT go_mmim_maa_2 IS BOUND.
* get instance of class CL_MMIM_MAA_2
    go_mmim_maa_2 = cl_mmim_maa_2=>get_singleton_instance( ).
  ENDIF.
* MAA2 End

ENHANCEMENT-POINT SAPMM07M_212 SPOTS ES_SAPMM07M STATIC.
  REFRESH xmkpf.
  REFRESH xmseg.
  IF NOT xaktiv IS INITIAL.
    CHECK NOT rm07m-mblnr IS INITIAL.
  ENDIF.
  CALL FUNCTION 'MB_READ_MATERIAL_HEADER'
    EXPORTING
      mblnr         = rm07m-mblnr
      mjahr         = rm07m-mjahr
      trtyp         = t158-trtyp
      vgart         = vgart_old
    IMPORTING
      kopf          = xmkpf
    EXCEPTIONS
      error_message = 1.

  IF sy-subrc <> 0.
    "is it possible that MB03 is called from AS ?
    IF xmbwl IS INITIAL AND NOT rm07m-mblnr IS INITIAL
     AND NOT rm07m-mjahr IS INITIAL AND t158-trtyp = 'A'.
      IMPORT xmkpf xmseg FROM MEMORY ID rm07m-mblnr.
      "Data stored from AS ok ?
      IF sy-subrc = 0.
        found_in_archiv = 'X'.
        READ TABLE xmkpf INDEX 1.      "Fill header row
      ELSE.
        "Not found in archive data
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
      "Not found in MKPF and not called from AS
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

* Determine whether mat.doc. belongs to Brazilian company code
  CALL FUNCTION 'J_1B_IM_CHECK_BRAZIL_MD'
    EXPORTING
      i_mkpf      = xmkpf
    IMPORTING
      e_brazil    = lv_brazil_tfret                         "520184
      e_cancelsto = lv_brazil_cancsto.                      "822991

  IF NOT lv_brazil_tfret IS INITIAL.                        "520184
* In case of a return delivery that refers to a material document
* belonging to an SD/MM-transfer (via stock transport order), remove
* all PO info from the material doc., so that no further PO-specific
* coding will be executed. That would lead to errors.
    IF t158-fcode = fcod-rl AND xmkpf-vgart = 'WE'.
      PERFORM j_1b_tf_remove_po_mkpf
        CHANGING xmkpf.
    ELSE.
*     Not a return of STO
      CLEAR lv_brazil_tfret.                                "520184
    ENDIF.
  ENDIF.

* MBSU should be able to use a material document, although VGART is not
* WA (e.g. WL). Later the movement type will be checked (-> T156N),
* whether the process 'place in storage location' is allowed or not.
  IF t158-fcode = fcod-su AND xmkpf-vgart NE 'WA'.          "423743
    SELECT SINGLE blart vgart INTO (xmkpf-blart, xmkpf-vgart) "423743
                           FROM t158 WHERE tcode = tcod-mb1b. "423743
    IF NOT sy-subrc IS INITIAL.                             "423743
      MESSAGE e001 WITH 'T158' tcod-mb1b.                   "423743
    ENDIF.                                                  "423743
  ENDIF.                                                    "423743

  vgart = xmkpf-vgart.
  IF t158-trtyp <> h.
*   If version from material document is to be set, ensure that
*   the setting from T158 is cleared. Otherwise, more than one
*   radiobutton may be checked which will cause a dump.
    IF NOT xmkpf-wever IS INITIAL.
      CLEAR: rm07m-wvers1, rm07m-wvers2, rm07m-wvers3.
      CASE xmkpf-wever.
        WHEN 1.
          rm07m-wvers1 = x.
        WHEN 2.
          rm07m-wvers2 = x.
        WHEN 3.
          rm07m-wvers3 = x.
        WHEN OTHERS.
*       Fallback for faulty entries in MKPF. Ugly, but better than notes
          rm07m-wvers3 = x.
      ENDCASE.
    ENDIF.
  ENDIF.
  IF t158-trtyp = h.
    DATA: blart LIKE mkpf-blart,
          blaum LIKE mkpf-blaum,
          bla2d LIKE mkpf-bla2d.
    IF xmkpf-tcode2 IS INITIAL OR xmkpf-tcode2 = 'R/2'.
      MESSAGE e064 WITH xmkpf-mblnr xmkpf-mjahr xmkpf-tcode2(3).
    ENDIF.
    IF sy-tcode NE xmkpf-tcode2 AND xmbwl IS INITIAL.
      SELECT SINGLE * FROM t158 WHERE tcode = sy-tcode.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'T158' sy-tcode.
      ENDIF.
*   Save the checking rule: in case of return delivery and       "647871
*   cancellation the checking rules of these transactions        "647871
*   have not been considered (up until now)                      "647871
      prreg = t158-prreg.                                   "647871
    ENDIF.
*   note 613518: make sure that cancellation is posted with the same
*   document types as the original document. VL09 does not make any
*   difference between the cancellation of an outbound or an inbound
*   delivery. Therefore, the fields are used from the original document
*   instead of T158.
    IF im_process = l.                                      "1354275
      blart = xmkpf-blart.                                  "613518
      blaum = xmkpf-blaum.                                  "613518
      bla2d = xmkpf-bla2d.                                  "613518
    ELSE.                                                   "613518
      blart = t158-blart.
      blaum = t158-blaum.
      bla2d = t158-bla2d.
    ENDIF.                                                  "613518
    SELECT SINGLE * FROM t003m WHERE vgart = vgart.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH '003M' vgart.
    ENDIF.
    SELECT SINGLE * FROM t158v WHERE vgart = vgart.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH '158V' vgart.
    ENDIF.
ENHANCEMENT-POINT SAPMM07M_213 SPOTS ES_SAPMM07M.

*   BAPI works with TCODE = 'MBST' (-> T158-VGART is initial),   "356487
*   therefore VGART has to be determined:                        "356487
ENHANCEMENT-SECTION     ES_MM07MFB1_BELEG_LESEN SPOTS ES_MM07MFB1_BELEG_LESEN.
    IF xmbwl IS INITIAL OR NOT xbapi IS INITIAL             "356487
    OR NOT lv_brazil_cancsto IS INITIAL.                    "822991
      IF NOT t158v-xvorg IS INITIAL.
        MESSAGE e130.
      ENDIF.
      SELECT SINGLE * FROM t158n WHERE vgart = vgart.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH '158N' vgart.
      ENDIF.
      SELECT SINGLE * FROM t158 WHERE tcode = t158n-tcode.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH '158' t158n-tcode.
      ENDIF.
*     restore checking rule from 'original' tcode                "647871
      IF xbapi IS INITIAL AND sy-tcode NE xmkpf-tcode2.     "647871
        t158-prreg = prreg.                                 "647871
      ENDIF.                                                "647871
    ENDIF.                                                  "333016
END-ENHANCEMENT-SECTION.
    IF NOT vgart = t158-vgart.
*     Coding für Kunden, die in T156N speziell von 101/S in frei wollen
*     Dieser Eintrag wird nicht im Standard ausgeliefert SU 101/343
*     IF SY-TCODE = 'MBSU' AND T158-VGART = VGART_WE.
*       SELECT SINGLE * FROM T158 WHERE TCODE = 'MB1B'.
*       IF NOT SY-SUBRC IS INITIAL.
*         MESSAGE E001 WITH '158' 'MB1B'.
*       ENDIF.
*       VGART = T158-VGART.
*     ELSE.
*---- No check needed because different VGART are possible:
*---- HUM      (WF, WE, WL,...)
*---- Delivery (WE, WL)
      IF NOT ( xmbwl = x AND                                "333016
         ( im_process = h OR im_process = l ) ).            "333016
        MESSAGE e066 WITH vgart t158-vgart.
      ENDIF.                                                   "HUM
*     ENDIF.
    ENDIF.
* Do not allow partial cancellations for MSR documents
    IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) = abap_true.
      IF xmkpf-msr_active = abap_true AND t158-fcode <> fcod-st AND xmigo IS INITIAL.
        MESSAGE e378.
      ENDIF.
    ENDIF.
    PERFORM rw_vorgang_setzen USING vgart.
    mkpf-frbnr  = xmkpf-frbnr.
    mkpf-bktxt  = xmkpf-bktxt.
    rm07m-lfsnr = mkpf-xblnr = xmkpf-xblnr.
ENHANCEMENT-POINT BELEG_LESEN_01 SPOTS ES_SAPMM07M.

    IF blart IS INITIAL.
      IF fcode = fcod-ss OR fcode = fcod-st.
        CALL FUNCTION 'FI_DOCUMENT_TYPE_REVERSE'
          EXPORTING
            i_document_type             = xmkpf-blart
          IMPORTING
            e_document_type             = mkpf-blart
          EXCEPTIONS
            document_type_existance     = 01
            rev_document_type_existance = 02.
      ENDIF.
      IF mkpf-blart IS INITIAL.
        mkpf-blart = xmkpf-blart.
      ENDIF.
    ELSE.
      mkpf-blart = blart.
    ENDIF.
    IF blaum IS INITIAL.
      IF fcode = fcod-ss OR fcode = fcod-st.
        CALL FUNCTION 'FI_DOCUMENT_TYPE_REVERSE'
          EXPORTING
            i_document_type             = xmkpf-blaum
          IMPORTING
            e_document_type             = mkpf-blaum
          EXCEPTIONS
            document_type_existance     = 01
            rev_document_type_existance = 02.
      ENDIF.
      IF mkpf-blaum IS INITIAL.
        mkpf-blaum = xmkpf-blaum.
      ENDIF.
    ELSE.
      mkpf-blaum = blaum.
    ENDIF.
    IF bla2d IS INITIAL AND NOT xmkpf-bla2d IS INITIAL.
      IF fcode = fcod-ss OR fcode = fcod-st.
        CALL FUNCTION 'FI_DOCUMENT_TYPE_REVERSE'
          EXPORTING
            i_document_type             = xmkpf-bla2d
          IMPORTING
            e_document_type             = mkpf-bla2d
          EXCEPTIONS
            document_type_existance     = 01
            rev_document_type_existance = 02.
      ENDIF.
      IF mkpf-bla2d IS INITIAL.
        mkpf-bla2d = xmkpf-bla2d.
      ENDIF.
    ELSE.
      mkpf-bla2d = bla2d.
    ENDIF.
    SELECT SINGLE * FROM t003 WHERE blart = mkpf-blaum.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH '003' mkpf-blaum.
    ENDIF.
    IF NOT bla2d IS INITIAL.
      SELECT SINGLE * FROM t003 WHERE blart = mkpf-bla2d.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH '003' mkpf-bla2d.
      ENDIF.
    ENDIF.
    SELECT SINGLE * FROM t003 WHERE blart = mkpf-blart.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH '003' mkpf-blart.
    ENDIF.
    mkpf-vgart = vgart.
    rm07m-kzbew = t158-kzbew.
    IF xmbwl IS INITIAL.
      PERFORM vorgangsart_pruefen.
    ENDIF.
  ELSE.
    mkpf = xmkpf.
    rm07m-lfsnr = mkpf-xblnr.
    rm07m-mtsnr = mkpf-xblnr.
    rm07m-xabln = mkpf-xabln.
ENHANCEMENT-POINT BELEG_LESEN_02 SPOTS ES_SAPMM07M.

    IF NOT rm07m-zeile IS INITIAL AND NOT sy-calld IS INITIAL.
      fcode_next = fcod-ap.
    ENDIF.
  ENDIF.
* Text zur Vorgangsart lesen
  SELECT SINGLE * FROM t158w WHERE spras = sy-langu
                             AND   vgart = vgart.
  IF NOT sy-subrc IS INITIAL.
    CLEAR t158w-ltext.
  ENDIF.
* Beleg wird beim Anzeigen immer komplett gelesen, da es bei der
* Positionierung Probleme gibt.
* Überarbeitung im Zusammenhang mit table widget.
  IF t158-trtyp = h AND
     NOT rm07m-zeile IS INITIAL AND rm07m-zeilb IS INITIAL.
    rm07m-zeilb = rm07m-zeile.
  ENDIF.
  IF found_in_archiv IS INITIAL.
    CALL FUNCTION 'MB_READ_MATERIAL_POSITION'
      EXPORTING
        mblnr     = xmkpf-mblnr
        mjahr     = xmkpf-mjahr
        trtyp     = t158-trtyp
      TABLES
        seqtab    = xmseg
        mblpo_tab = it_zeile.                               "406146

* MAA2 Begin
    LOOP AT xmseg TRANSPORTING NO FIELDS WHERE NOT xmacc IS INITIAL.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL AND xmigo IS INITIAL.
      CALL METHOD go_mmim_maa_2->xmseg_aggregate
        EXPORTING
          iv_fcode  = fcode
          iv_xmbwl  = xmbwl
          iv_xdeliv = rm07m-xdeliv
        CHANGING
          ct_mseg   = xmseg[].
    ENDIF.
* MAA2 End

ENHANCEMENT-POINT EHP604_MM07MFB1_BELEG_LESEN_01 SPOTS ES_SAPMM07M.

*   Brazilian localization:
*   In case of a return delivery that refers to a material document
*   belonging to an SD/MM-transfer (via stock transport order), remove
*   all PO info from the material doc., so that no further PO-specific
*   coding will be executed. That would lead to errors.
    IF lv_brazil_tfret = 'X'.
      PERFORM j_1b_tf_remove_po_mseg
        TABLES xmseg.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT BELEG_LESEN_03 SPOTS ES_SAPMM07M.

  PERFORM beleg_ergaenzen.
  PERFORM nachrichten_lesen.

ENDFORM.