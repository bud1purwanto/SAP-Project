*----------------------------------------------------------------------*
*   INCLUDE LMIGOSP2                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_split_quantity IMPLEMENTATION.

************************************************************************
* Includes with methods
************************************************************************
INCLUDE lmigosp3.                            "methods from PBO and PAI

************************************************************************
* Constructor
************************************************************************
METHOD constructor.
  DATA: lt_okcodes     TYPE lif_migo_frame=>ty_t_okcodes,
        lt_sending     TYPE lif_migo_frame=>ty_t_message_ids,
        lt_receiving   TYPE lif_migo_frame=>ty_t_message_ids.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  lif_migo_frame~class_id = 'MIGO_SPLIT_QUANTITY'.
* Messages
  APPEND 'SPLIT_QUANTITY'      TO lt_receiving.
  APPEND 'ITEMDETAIL_LINE_SET' TO lt_sending.
  APPEND 'MIGO_TIP_REQUEST'    TO lt_sending.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer  = me
      it_receiving   = lt_receiving
      it_sending     = lt_sending
      it_okcodes     = lt_okcodes.
ENDMETHOD.

************************************************************************
* Message handler
************************************************************************
METHOD lif_migo_frame~message_handler.
  CASE i_message_id.
    WHEN 'SPLIT_QUANTITY'.
      CALL METHOD reset_split_quantity.
      p_selected_line = is_message-data1.
      CALL METHOD popup_call.
  ENDCASE.
ENDMETHOD.

************************************************************************
* OK-code handler
************************************************************************
METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.

************************************************************************
* PBO module before start of LOOP: Prepare variables, modify
* screen.
************************************************************************
METHOD pbo.
  CALL METHOD super->pbo.
  CALL METHOD status_set.
ENDMETHOD.

************************************************************************
* PBO module within LOOP: Get data from kernel and transfer them to
* the screen.
************************************************************************
METHOD pbo_loop.
  READ TABLE pt_gosplit INTO gosplit INDEX tv_gosplit-current_line.
  IF sy-subrc <> 0.
    gosplit = ps_gosplit_default.
  ENDIF.
  p_displayed_lines = sy-loopc.
ENDMETHOD.

************************************************************************
* PAI module before loop
************************************************************************
METHOD pai_exit.
* If processing terminated, delete the table of displayed lines
* so that LINE_INSERT will not insert them.
  CLEAR pt_gosplit.                                              "354046
  SET SCREEN 0.
  LEAVE SCREEN.
ENDMETHOD.

************************************************************************
* PAI module within LOOP: Transfer data back to the kernel
************************************************************************
METHOD pai_loop.
* ls_filter: save fields, which are not displayed in tableview
* because they are not transported via dynpro transport.
* Exception is field LGORT because it should be garanteed that LGORT
* fits to LGOBE in gosplit via manual transport with function
* MM_SLOC_CONVERT.
  DATA: BEGIN OF ls_filter,
          erfme             TYPE gosplit-erfme,
*         lgort             type gosplit-lgort,
          bwtar_from_refdoc TYPE gosplit-bwtar_from_refdoc,
        END OF ls_filter.
* ls_compare is necessary to enable a check if user has changed data
* on screen.
  DATA: BEGIN OF ls_compare,
          erfme             TYPE gosplit-erfme,
          lgort             TYPE gosplit-lgort,
          bwtar_from_refdoc TYPE gosplit-bwtar_from_refdoc,
        END OF ls_compare.
* the following data definitions are necessary in order to check
* if user has modified a line. We can not ask for gosplit in general
* because due to dynpro transportation there might be non actual
* values in gosplit.
  DATA: ls_dynpro_gosplit TYPE gosplit,                   "315518
        ls_kernel_gosplit TYPE gosplit.                   "315518
* new 'split quantity'-line
  IF gosplit-split_line IS INITIAL
  AND NOT gosplit-erfmg IS INITIAL.
    p_split_line = p_split_line + 1.
    gosplit-split_line    = p_split_line.
    MOVE-CORRESPONDING gosplit TO ps_gosplit.
    APPEND ps_gosplit TO pt_gosplit.
    EXIT.
  ENDIF.
* delete line (when line has no quantity) or modify line
  IF NOT gosplit-split_line IS INITIAL.
    READ TABLE pt_gosplit INTO ps_gosplit WITH KEY
                   split_line = gosplit-split_line.
    IF sy-subrc IS INITIAL.
      CLEAR ls_compare.                                   "315518
      MOVE-CORRESPONDING ps_gosplit TO ls_kernel_gosplit. "315518
      MOVE-CORRESPONDING gosplit TO ls_dynpro_gosplit.    "315518
      MOVE-CORRESPONDING ls_compare TO ls_dynpro_gosplit. "315518
      MOVE-CORRESPONDING ls_compare TO ls_kernel_gosplit. "315518
*     if ps_gosplit ne gosplit and gosplit-erfmg is initial.
      IF ls_dynpro_gosplit NE ls_kernel_gosplit AND       "315518
         ls_dynpro_gosplit-erfmg IS INITIAL.              "315518
        DELETE pt_gosplit INDEX sy-tabix.
*     elseif ps_gosplit ne gosplit.
      ELSEIF ls_dynpro_gosplit NE ls_kernel_gosplit.      "315518
          MOVE-CORRESPONDING ps_gosplit TO ls_filter.
          MOVE-CORRESPONDING gosplit    TO ps_gosplit.
          MOVE-CORRESPONDING ls_filter  TO ps_gosplit.
          MODIFY pt_gosplit FROM ps_gosplit INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMETHOD.
************************************************************************
* PAI module after loop
************************************************************************
METHOD pai_end.
  CALL METHOD cursor_set.
  CALL METHOD sum_get.
  CALL METHOD ucomm_handle.
ENDMETHOD.

************************************************************************
* Convertation of storage location (with data of local goitem)
************************************************************************
METHOD pai_convert.
    CALL FUNCTION 'MM_SLOC_CONVERT'
    CHANGING
      c_plant     = ps_goitem-werks
      c_planttext = ps_goitem-name1
      c_sloc      = gosplit-lgort
      c_sloctext  = gosplit-lgobe.
ENDMETHOD.
************************************************************************
* Resulution of the cursor position
************************************************************************
METHOD cursor_position_resolve.
  e_name  = 'SPLIT_QUANTITY'.
  e_tabix = p_selected_line.
ENDMETHOD.

************************************************************************
* Resulution of the cursor position
************************************************************************
METHOD pov_gosplit_bwtar.
  CHECK     ps_goitem-bwtor IS INITIAL.
  CHECK NOT ps_goitem-bwtty IS INITIAL.
  CALL FUNCTION 'MBEW_BWTAR_HELP'
        EXPORTING
             matnr         = ps_goitem-matnr
             bwkey         = ps_goitem-bwkey
             aktyp         = a
        IMPORTING
             bewertungsart = gosplit-bwtar.
ENDMETHOD.



************************************************************************
ENDCLASS.