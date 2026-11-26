*----------------------------------------------------------------------*
*   INCLUDE LMIGOSR5                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Search for material documents using report RM07DOCS
************************************************************************
METHOD materialdocument_search.
  DATA: l_flag TYPE char1,                    "Needed for export to MB51
        lt_list TYPE ty_t_materialdocument,
        l_mblnr TYPE mblnr,
        l_mjahr TYPE mjahr,
        ls_message TYPE lif_migo_frame=>ty_s_message.
* Call MB51 and receive the result list
  EXPORT flag    = 'X' TO MEMORY ID 'MB51_FLAG'.
  EXPORT no_list = 'X' TO MEMORY ID 'MB51_NOLIST'.
  CALL TRANSACTION 'MB51'.
* Send the selected item to the first line
*  GET PARAMETER ID 'MBN' FIELD l_mblnr.
*  GET PARAMETER ID 'MJA' FIELD l_mjahr.
*  def_sms 'SEARCH_HAS_NEW_MATDOC' l_mblnr l_mjahr.
* Read the complete list and send around
  IMPORT export_list = lt_list FROM MEMORY ID 'MB51_EXPORT_LIST'.
  GET REFERENCE OF lt_list INTO ls_message-dref.
  ls_message-data1 = 'R02'.
  CALL METHOD lcl_migo_frame=>message_send
    EXPORTING
      i_iref_sender = me
      i_message_id  = 'NEW_SEARCHRESULT'
      is_message    = ls_message.
ENDMETHOD.