*----------------------------------------------------------------------*
*   INCLUDE LMIGOEQ2                                                   *
*   Enqueue management
*----------------------------------------------------------------------*

CLASS lcl_migo_enqueue IMPLEMENTATION.

************************************************************************
* Read the current enqueue state of user and save
************************************************************************
METHOD save.
  DATA: ls_enqueue TYPE ty_s_enqueue.
* If the transaction has not been called via function module interface,
* it is certainly running as a separate roll area and therefore
* can safely use DEQUEUE_ALL.
  CHECK lcl_migo_globals=>external_call_active = abap_true.      "377195
* Read current enqueues by SAP-user
  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      guname                = sy-uname                    "#EC DOM_EQUAL
    TABLES
      enq                   = ls_enqueue-tab
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc = 0.
*   Insert it together with the state ID
    SORT ls_enqueue-tab.
    ls_enqueue-failure = abap_false.
  ELSE.
*   In case of systme failure during ENQUEUE_READ, keep this in
*   mind to avoid deleting locks later on (conservative strategy).
    ls_enqueue-failure = abap_true.
  ENDIF.
  ls_enqueue-id = i_state_id.
  DELETE pt_enqueue WHERE id = i_state_id.
  INSERT ls_enqueue INTO TABLE pt_enqueue.
ENDMETHOD.

************************************************************************
* Restore an enqueue state
************************************************************************
METHOD restore.
  DATA: lt_current_enqueue TYPE STANDARD TABLE OF seqg3,
        ls_enqueue         TYPE seqg3,
        lt_delete          TYPE STANDARD TABLE OF seqg3,
        ls_state           TYPE ty_s_enqueue,
        l_enqueue_user     TYPE eqeusr,
        l_msg_text(100)    TYPE c,
        lt_goitem          TYPE TABLE OF goitem,               "n1397313
        ls_batchitems      TYPE goitem,                        "n1397313
        ls_bncom           TYPE bncom.                         "n1523750
* MIGO not called externally --> use DEQUEUE_ALL
  IF lcl_migo_globals=>external_call_active = abap_false.        "377195
    CALL FUNCTION 'DEQUEUE_ALL'.                                 "377195
*   function module 'VB_BATCHES_IN_BUFFER_ENQUEUE' replaced by "n1397313
*   new function module 'VB_ENQUEUE_BATCH' which needs to get  "n1397313
*   called for each batch                                      "n1397313
*    CALL FUNCTION 'VB_BATCHES_IN_BUFFER_ENQUEUE'.               "522650
    CALL METHOD lcl_migo_globals=>kernel->get_pt_goitem        "n1397313
      IMPORTING e_pt_goitem = lt_goitem.                       "n1397313
    LOOP AT lt_goitem INTO ls_batchitems                       "n1397313
      WHERE charg IS NOT INITIAL.
      move-corresponding ls_batchitems to ls_bncom.            "n1523750
      CALL FUNCTION 'VB_ENQUEUE_BATCH'                         "n1397313
        EXPORTING
          x_bncom                 = ls_bncom
          MATNR                   = ls_batchitems-matnr        "n1397313
          CHARG                   = ls_batchitems-charg        "n1397313
          WERKS                   = ls_batchitems-werks.       "n1397313
    ENDLOOP.                                                   "n1397313
*   note 1150161 : Release lock on serial numbers ITOB-Buffer
    CALL FUNCTION 'ITOB_BUF_CLEANUP'                            "1150161
     EXPORTING                                                  "1150161
              I_USE_DEFAULT_HANDLE = 'X'                        "1150161
              I_READ_BUFFER        = 'X'                        "1150161
              I_WRITE_BUFFER       = 'X'                        "1150161
              I_RESET_LOCK         = 'X'                        "1150161
     EXCEPTIONS                                                 "1150161
              OTHERS = 1.                                       "1150161
    EXIT.                                                        "377195
  ENDIF.                                                         "377195
* Read the requested state and leave if there was any problem during
* enqueue read (conservative behaviour). If the ID does not
* exist, the check will be successful and the table will be initial.
* This occurs if MIGO has been started directly by transactioncode.
  READ TABLE pt_enqueue INTO ls_state WITH TABLE KEY id = i_state_id.
  CHECK ls_state-failure = abap_false.
* Get the current enqueue user.
* After COMMIT WORK, the enqueues are handed to the update process
* and the online gets a new number. So it is ensured that
* the online process will not delete lock entries that are already
* in the update.
  CALL 'C_ENQUEUE'
    ID 'OPCODE' FIELD '7'
    ID 'ENQKVB' FIELD l_enqueue_user.
* Read enqueues for the SAP-user
  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      guname                = sy-uname                    "#EC DOM_EQUAL
    TABLES
      enq                   = lt_current_enqueue
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.
* Exit if any problem
  CHECK sy-subrc = 0.
* Check all entries of my internal mode for presence at the
* requested state. Purge entries of all scopes.
  LOOP AT lt_current_enqueue INTO ls_enqueue
                                     WHERE ( gusrvb = l_enqueue_user OR
                                             gusr   = l_enqueue_user ).
    READ TABLE ls_state-tab WITH KEY table_line = ls_enqueue
                            BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      APPEND ls_enqueue TO lt_delete.
    ENDIF.
  ENDLOOP.
* Finished if nothing to delete
  CHECK NOT lt_delete IS INITIAL.
* Delete the new ones. The solution of note 310895 is not longer
* necessary as with release 470, function ENQUE_DELETE always has the
* option to suppress syslog entries.
  CALL FUNCTION 'ENQUE_DELETE'
    EXPORTING
      suppress_syslog_entry = x
    TABLES
      enq                   = lt_delete.
ENDMETHOD.


ENDCLASS.