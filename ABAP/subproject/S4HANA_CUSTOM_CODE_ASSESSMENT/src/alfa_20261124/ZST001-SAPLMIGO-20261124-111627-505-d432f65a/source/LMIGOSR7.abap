*----------------------------------------------------------------------*
*   INCLUDE LMIGOSR7                                                   *
*   Search for reservations
*----------------------------------------------------------------------*

************************************************************************
* Popup for reservation search
************************************************************************
METHOD reservation_search_popup.
  DATA: ls_control TYPE lcl_migo_kernel=>ty_s_control.
  CLEAR gosearch_res.
* Default values for the checkboxes
  ls_control = lcl_migo_globals=>kernel->mode_get( ).
  gosearch_res-open_ = x.
  CASE ls_control-action.
    WHEN 'A07'.
       gosearch_res-issues   = x.
    WHEN 'A08'.
       gosearch_res-issues   = x.
       gosearch_res-receipts = x.
    WHEN OTHERS.
       gosearch_res-receipts = x.
  ENDCASE.
  CALL SCREEN 3020 STARTING AT 5 1.
  IF sy-ucomm = 'OK_START'.
    CALL METHOD reservation_search.
  ENDIF.
ENDMETHOD.


************************************************************************
* Execute the reservation search. Uses logical database MMIMRKPFRESB.
************************************************************************
METHOD reservation_search.

  DATA: lt_reservations TYPE ty_t_reservation,
        ls_message      TYPE lif_migo_frame~ty_s_message.

* Ranges to be sent to the report RM07RESL. It is not possible
* to give the parameters form the popup directly to the select-options
* as this would generate a selection "I EQ space".
  DATA: r_matnr TYPE RANGE OF resb-matnr,
        r_werks TYPE RANGE OF resb-werks,
        r_kostl TYPE RANGE OF rkpf-kostl,
        r_aufnr TYPE RANGE OF rkpf-aufnr,
        r_projn TYPE RANGE OF rkpf-ps_psp_pnr,
        r_nplnr TYPE RANGE OF rkpf-nplnr,
        r_anln1 TYPE RANGE OF rkpf-anln1,
        r_anln2 TYPE RANGE OF rkpf-anln2,
        r_umwrk TYPE RANGE OF rkpf-umwrk,
        r_umlgo TYPE RANGE OF rkpf-umlgo,
        r_kdauf TYPE RANGE OF rkpf-kdauf,
        r_kdpos TYPE RANGE OF rkpf-kdpos,
        r_kdein TYPE RANGE OF rkpf-kdein,
        r_bdter TYPE RANGE OF resb-bdter,
        s_bdter LIKE LINE OF r_bdter.

* A small definition to fill these ranges from the screen data
  DEFINE def_fill.
    data: s_&2 like line of &2.                                  "203543
    if not &1 is initial.
      clear s_&2.
      s_&2-sign = 'I'.
      s_&2-option = 'EQ'.
      s_&2-low = &1.
      append s_&2 to &2.
    endif.
  END-OF-DEFINITION.

  def_fill gosearch_res-matnr      r_matnr.
  def_fill gosearch_res-werks      r_werks.
  def_fill gosearch_res-kostl      r_kostl.
  def_fill gosearch_res-aufnr      r_aufnr.
  def_fill gosearch_res-ps_psp_pnr r_projn.
  def_fill gosearch_res-nplnr      r_nplnr.
  def_fill gosearch_res-anln1      r_anln1.
  def_fill gosearch_res-anln2      r_anln2.
  def_fill gosearch_res-umwrk      r_umwrk.
  def_fill gosearch_res-umlgo      r_umlgo.
  def_fill gosearch_res-kdauf      r_kdauf.
  def_fill gosearch_res-kdpos      r_kdpos.
  def_fill gosearch_res-kdein      r_kdein.

* BDTER: Simulate a select-option
  IF NOT gosearch_res-bdter_from IS INITIAL OR
     NOT gosearch_res-bdter_to   IS INITIAL.
    s_bdter-sign    = 'I'.
    s_bdter-low     = gosearch_res-bdter_from.
    s_bdter-high    = gosearch_res-bdter_to.
    IF s_bdter-high IS INITIAL.
      s_bdter-option = 'EQ'.
    ELSE.
      s_bdter-option = 'BT'.
    ENDIF.
    APPEND s_bdter TO r_bdter.
  ENDIF.

* If the reservation search is used to find orders for goods issue,
* only reservations which have RKPF-AUFNR filled should be found.
  IF lcl_migo_globals=>kernel->s_control-action = 'A07' AND      "203543
     lcl_migo_globals=>kernel->s_control-refdoc = 'R08'.         "203543
    s_r_aufnr-sign   = 'E'.                                      "203543
    s_r_aufnr-option = 'EQ'.                                     "203543
    CLEAR s_r_aufnr-low.                                         "203543
    APPEND s_r_aufnr TO r_aufnr.                                 "203543
  ENDIF.                                                         "203543

* Call RM07RESL (MB25)
  SUBMIT rm07resl AND RETURN
    WITH matnr IN r_matnr
    WITH werks IN r_werks
    WITH bdter IN r_bdter
    WITH kostl IN r_kostl
    WITH aufnr IN r_aufnr
    WITH projn IN r_projn
    WITH nplnr IN r_nplnr
    WITH p_vornr = gosearch_res-vornr
    WITH anln1 IN r_anln1
    WITH anln2 IN r_anln2
    WITH umwrk IN r_umwrk
    WITH umlgo IN r_umlgo
    WITH kdauf IN r_kdauf
    WITH kdpos IN r_kdpos
    WITH kdein IN r_kdein
    WITH p_no_acc = gosearch_res-no_acc
    WITH p_open   = gosearch_res-open_
    WITH p_cancel = gosearch_res-cancel
    WITH p_closed = space                                        "550693
    WITH p_issues = gosearch_res-issues
    WITH p_receip = gosearch_res-receipts
    WITH p_nosave = x
    WITH p_nolist = x.

* Receive result
  IMPORT t_list = lt_reservations FROM MEMORY ID 'RM07RESL_RESULT'.
* Send the searchresult (may be empty)
  ls_message-data1 = 'R09'.
  GET REFERENCE OF lt_reservations INTO ls_message-dref.
  CALL METHOD lcl_migo_frame=>message_send
    EXPORTING
      i_iref_sender = me
      i_message_id  = 'NEW_SEARCHRESULT'
      is_message    = ls_message.

ENDMETHOD.