*----------------------------------------------------------------------*
*   INCLUDE LMIGOJB1                                                   *
*----------------------------------------------------------------------*
CLASS lcl_migo_nota_fiscal DEFINITION.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor,
    j_1b_set_subcontr
      IMPORTING
        i_subcontr type abap_bool,
    j_1b_get_subcontr
      RETURNING
        value(r_subcontr) type abap_bool,
*   Note 381582
    j_1b_nf_button_disabled
      RETURNING
        value(r_nf_button_disabled) type abap_bool,
    j_1b_im_nfbutton_check
      importing
        i_bwart type bwart,
*
    j_1b_relevance_check
      IMPORTING
        is_got156 TYPE got156
        is_gohead type gohead      "785319
        is_goplant type goplant    "785319
      CHANGING
        cs_goitem TYPE goitem
        cv_xblnr type  gohead-xblnr,
*  note 804327
    j_1b_check_brazil
      IMPORTING
        iv_bukrs type bukrs
      EXPORTING
        ev_brazil type xfeld.
*
PRIVATE SECTION.
  DATA: p_subcontr type abap_bool,
        p_nf_button_disabled type abap_bool.               "Note 381582
  METHODS:
    j_1b_nota_fiscal_button,
    j_1b_im_tx_tax_proc_set
      CHANGING
        i_goitem TYPE goitem,
    nota_fiscal_dialog
      IMPORTING
        i_migo_cancel  TYPE abap_bool
        i_migo_display TYPE abap_bool
        i_migo_create  TYPE abap_bool
      CHANGING
        i_t_ymseg      TYPE ty_t_mseg,
*
    get_nf_number_from_gi
      IMPORTING
        iv_vbeln        TYPE vbeln_vl
      CHANGING
        cv_xblnr        TYPE gohead-xblnr,

    read_original_nf
      IMPORTING
        i_mblnr         TYPE mblnr
        i_mjahr         TYPE mjahr
        i_vbeln         TYPE vbeln
      CHANGING
        c_xblnr         type gohead-xblnr,

    set_ref_item
       IMPORTING
         i_mblnr        type mblnr
         i_zeile        type mblpo
         i_mjahr        type mjahr
         i_menge        type menge_d                       "Note 1008878
         i_erfmg        type erfmg                         "Note 1008878
         i_take_it      type mb_take_it
       CHANGING                                            "Note 1008878
         c_j_1bexbase   type j_1bexbase,                   "Note 1008878

    cancel_taxes
       IMPORTING
         is_header       type gohead
         is_item         type goitem
         is_plant        type goplant.

ENDCLASS.