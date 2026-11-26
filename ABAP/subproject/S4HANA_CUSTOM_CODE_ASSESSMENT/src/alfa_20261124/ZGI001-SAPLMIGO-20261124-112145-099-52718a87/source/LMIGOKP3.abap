*----------------------------------------------------------------------*
*   INCLUDE LMIGOKP3                                                   *
*   Predocument handling in the kernel
*----------------------------------------------------------------------*

************************************************************************
* Dump the current status of the kernel to the database
************************************************************************
METHOD predocument_save.
  DATA: loref_predoc  TYPE REF TO cl_mmim_datastore,
        lt_wmdata     TYPE STANDARD TABLE OF wms_migo_pal,
        lt_qcert_migo TYPE STANDARD TABLE OF qcert_migo,
        lt_mseg_refdoc      TYPE  mb_mseg.                  "MAA2

* Open dataset for write
  CREATE OBJECT loref_predoc.
  CALL METHOD loref_predoc->open( i_guid = i_guid
    i_mode = cl_mmim_datastore=>c_write ).
* Dump the data
  DEFINE def_predoc_write.
    call method loref_predoc->write
      exporting
        i_name = &1
        i_data = &2.
  END-OF-DEFINITION.
  def_predoc_write 'P_LINE_ID'           p_line_id.
  def_predoc_write 'S_CONTROL'           s_control.
  def_predoc_write 'PS_GOHEAD'           ps_gohead.
  def_predoc_write 'PT_GOITEM'           pt_goitem.
  def_predoc_write 'PT_GOSERIAL_KERNEL'  pt_goserial_kernel.
  def_predoc_write 'PT_GOFREIGHT_KERNEL' pt_gofreight_kernel.
* Dump WM data
  CALL FUNCTION 'GET_ALL_DATA_FROM_WM'
    TABLES
      tab_wms_migo_context = lt_wmdata.
  def_predoc_write 'LT_WMDATA' lt_wmdata.
* Dump QM data
  CALL FUNCTION 'QBCK_MIGO_ALL_TO_MM'
    TABLES
      e_qcert_migo_tab = lt_qcert_migo.
  def_predoc_write 'LT_QCERT_MIGO' lt_qcert_migo.
* Dump MAA2 Reference document
  READ TABLE pt_goitem WITH KEY xhistma = 'X'               "MAA2
                       TRANSPORTING NO FIELDS.              "MAA2
  IF sy-subrc IS INITIAL.                                   "MAA2
    CALL METHOD go_mmim_maa_2->maa_read_mseg_refdoc         "MAA2
           IMPORTING                                        "MAA2
           et_mseg_refdoc       = lt_mseg_refdoc[].         "MAA2
    def_predoc_write 'LT_MSEG_REFDOC' lt_mseg_refdoc.       "MAA2
  ENDIF.                                                    "MAA2
* BAdI: Predoc save (note 552774)
  IF NOT lcl_migo_globals=>if_badi IS INITIAL.
    CALL METHOD lcl_migo_globals=>if_badi->hold_data_save
      EXPORTING
        i_guid = i_guid.
  ENDIF.
* Def_predoc structure still missing
* Close
  CALL METHOD loref_predoc->close.
  FREE loref_predoc.
ENDMETHOD.                    "predocument_save

************************************************************************
* Restore the current status of the kernel from the database.
************************************************************************
METHOD predocument_load.
  DATA: loref_predoc TYPE REF TO cl_mmim_datastore,
        ls_control   TYPE ty_s_control,
        lt_wmdata    TYPE STANDARD TABLE OF wms_migo_pal,
        ls_goitem    TYPE goitem,
        lt_qcert_migo TYPE STANDARD TABLE OF qcert_migo,
        lt_mseg_refdoc      TYPE  mb_mseg.                  "MAA2

* First of all, we execute a kernel reset
  CALL METHOD reset.
* Open the predocument
  CREATE OBJECT loref_predoc.
  CALL METHOD loref_predoc->open( i_guid = i_guid
    i_mode = cl_mmim_datastore=>c_read ).
  DEFINE def_predoc_read.
    call method loref_predoc->read
      exporting
        i_name = &1
      importing
        e_data = &2.
  END-OF-DEFINITION.
* Restore the kernel mode
  def_predoc_read 'S_CONTROL' ls_control.
  ls_control-new_line_mode = space.
* Check combination for valididy
  READ TABLE lcl_migo_globals=>t_cust
             WITH KEY action = ls_control-action
                      refdoc = ls_control-refdoc
                      TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    MESSAGE s025.
    CALL METHOD loref_predoc->close.
    EXIT.
  ENDIF.
  CALL METHOD mode_set( is_control = ls_control
    i_keep_vgart = abap_true ).
* Fill data
  def_predoc_read 'P_LINE_ID'           p_line_id.
  def_predoc_read 'PS_GOHEAD'           ps_gohead.
  def_predoc_read 'PT_GOITEM'           pt_goitem.
  def_predoc_read 'PT_GOSERIAL_KERNEL'  pt_goserial_kernel.
  def_predoc_read 'PT_GOFREIGHT_KERNEL' pt_gofreight_kernel.
  def_predoc_read 'LT_MSEG_REFDOC'      lt_mseg_refdoc.     "MAA2
* Fill WM data
  def_predoc_read 'LT_WMDATA' lt_wmdata.
  CALL FUNCTION 'SEND_ALL_DATA_TO_WM'
    TABLES
      tab_wms_migo_context = lt_wmdata.
* Fill QM data (predoc structure still missing)
  def_predoc_read 'LT_QCERT_MIGO' lt_qcert_migo.
  CALL FUNCTION 'QBCK_MIGO_ALL_TO_QM'
    TABLES
      i_qcert_migo_tab = lt_qcert_migo.
* Fill MAA2 Reference document                              "MAA2
  IF NOT lt_mseg_refdoc[] IS INITIAL.                       "MAA2
    CALL METHOD go_mmim_maa_2->maa_dump_mseg_refdoc         "MAA2
          EXPORTING                                         "MAA2
          it_mseg_refdoc       = lt_mseg_refdoc[].          "MAA2
    def_predoc_read 'LT_MSEG_REFDOC' lt_mseg_refdoc.        "MAA2
  ENDIF.                                                    "MAA2
* BAdI: Predoc load
  IF NOT lcl_migo_globals=>if_badi IS INITIAL.
    CALL METHOD lcl_migo_globals=>if_badi->hold_data_load
      EXPORTING
        i_guid = i_guid.
  ENDIF.
* Manipulations PT_GOITEM
* CUOBJ_CH is cleared. It represents the number with that a
* batch-determination has occured. During this process, new selection
* criteria can be defined which are posted ON COMMIT. As we do not
* know whether the document has really been posted after STORE within
* the same LUW, we clear the number. As a result, stored documents
* have no reference to the search strategy in MSEG.
* Furthermore, it might be possible that the newly created search
* criteria are not saved. Our tip gives a hint on that.
* The same applies to the profitability object number. This is also
* a kind of internal number for a set of data entered on the accounting
* screen (note 552774)
  CLEAR ls_goitem.
  MODIFY pt_goitem FROM ls_goitem TRANSPORTING cuobj_ch
                                               paobjnr
                  WHERE NOT cuobj_ch IS INITIAL OR
                        NOT paobjnr  IS INITIAL.
* same with documentary batch: stick to physical process and enter batch
* when document is really posted
  IF lcl_migo_globals=>doc_batch_active = abap_true.
    MODIFY pt_goitem FROM ls_goitem
             TRANSPORTING docubatch_charg
                          docubatch_mult_entries
                    WHERE NOT docubatch_charg IS INITIAL OR
                          NOT docubatch_mult_entries IS INITIAL.
  ENDIF.
* Regenerate fieldselection table for the document
  LOOP AT pt_goitem INTO ls_goitem.
    CALL METHOD lcl_migo_screenmodification=>template_copy
      EXPORTING
        i_global_counter = ls_goitem-global_counter.
    CALL METHOD screen_modify_line( ls_goitem ).
    CALL METHOD screen_modify_transfer_fields( ls_goitem ).
  ENDLOOP.
* Derive a new status
  CALL METHOD status_derive.
* Exit
  CALL METHOD loref_predoc->close.
  FREE loref_predoc.
ENDMETHOD.                    "predocument_load