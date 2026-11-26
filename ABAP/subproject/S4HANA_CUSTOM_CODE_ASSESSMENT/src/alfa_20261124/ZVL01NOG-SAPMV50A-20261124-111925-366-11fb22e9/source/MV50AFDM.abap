*----------------------------------------------------------------------*
*   INCLUDE MV50AFDM                                                   *
*
*   Call-back routines for deadline maintenance
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DELIVERY_PAI_FCODE_CHECK
*&---------------------------------------------------------------------*
FORM delivery_pai_fcode_check
       USING    value(i_fcode)           LIKE sy-ucomm
                value(i_at_exit_command) TYPE c
                value(i_display)         TYPE c
                value(i_overview)        TYPE c
       CHANGING c_not_allowed            TYPE c.

  DATA:
    l_fcode   LIKE t185-fcode,
    l_retcode LIKE sy-subrc.

  l_fcode = i_fcode.
*  perform fcode_permitted(sapmv56a) changing l_fcode
*                                             l_retcode.
  IF l_retcode = 0.
    c_not_allowed = false.
  ELSE.
    c_not_allowed = true.
  ENDIF.
ENDFORM.                    " delivery_PAI_FCODE_CHECK

*&---------------------------------------------------------------------*
*&      Form  delivery_PAI_FCODE_PROCESS
*&---------------------------------------------------------------------*
FORM delivery_pai_fcode_process
       USING    value(i_fcode)           LIKE sy-ucomm
                value(i_at_exit_command) TYPE c
                value(i_display)         TYPE c
                value(i_overview)        TYPE c
                value(i_changes)         TYPE c
       CHANGING c_leave_maintainance     TYPE c
                c_leave_transaction      TYPE c
                c_save                   TYPE c.

  CONSTANTS:
    true(1)  TYPE c VALUE 'X',
    false(1) TYPE c VALUE space.
  DATA:
    l_answer(1)          TYPE c,
    l_data_changed(1)    TYPE c.


* first process fcode which do not leave the stage maintainance
  c_leave_maintainance = false.
  c_leave_transaction  = false.
  c_save               = false.

* CASE I_FCODE.
*   application specific fcode processing
* ENDCASE.

* all other fcodes which the stage maintainance does not process
* will leave the stage maintainance
  c_leave_maintainance = true.

* by convention all fcodes which leave the transaction are marked
* as 'EXIT COMMAND' in the GUI-Status. Moreover, there are some other
* fcodes which intend to leave:
  IF i_at_exit_command = true OR
     i_fcode = 'SICH'.
    c_leave_transaction = true.
  ELSE.
    c_leave_transaction = false.
  ENDIF.

* if we are in display mode, saving is not necessary
  IF i_display = true.
    c_save  = false.
    EXIT.
  ENDIF.

* we are not in display mode, saving might be necessary
  IF i_fcode = 'SICH'.
*   'SAVE' was pressed:
    c_save = true.
    c_leave_maintainance = true.
    c_leave_transaction  = true.
  ELSE.
*   if we leave the transaction check if there are any changes
    IF c_leave_transaction = true.
      IF NOT sy-datar IS INITIAL.
        l_data_changed = true.
      ELSE.
*       check if changes were made
*       if sy-subrc = 1.
*         l_data_changed = false.
*       else.
*         l_data_changed = true.
*       endif.
      ENDIF.
      IF l_data_changed = false.
*       there are no changes, saving is not necessary
        c_save = false.
      ELSE.
*       there are changes, ask if data should be saved
        CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
             EXPORTING
                  defaultoption = 'Y'
*                 diagnosetext1 = space              "XXX
*                 textline1     = space              "XXX
*                 titel         = space              "XXX
                  diagnosetext1 = text-pt1
                  textline1     = text-pt2
                  titel         = text-pti
             IMPORTING
                  answer        = l_answer.
        CASE l_answer.
          WHEN 'N'.
*           saving was not requested but we still want to leave
            c_save               = false.
            c_leave_maintainance = false.
            c_leave_transaction  = true.
          WHEN 'A'.
*           user cancelled his activity, do not leave nor save
            c_save               = false.
            c_leave_maintainance = false.
            c_leave_transaction  = false.
          WHEN 'J'.
            c_save               = true.
            c_leave_maintainance = true.
            c_leave_transaction  = true.
        ENDCASE.

      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " delivery_PAI_FCODE_PROCESS

*&---------------------------------------------------------------------*
*&      Form  delivery_PBO_FIELD_MODIF
*&---------------------------------------------------------------------*
FORM delivery_pbo_field_modif
       USING    i_display  TYPE c
                i_itsegdia TYPE vltm_dialog
                i_overview TYPE c
       CHANGING c_screen   LIKE screen.

*  perform feld_auswahl_feld(sapmv56a)
*            using c_xvtts.

*   call function 'SD_delivery_FIELD_CONTROL'
*        exporting
*             is_vttk       = c_xvttk
*             is_vtts       = i_xvtts
*             only_display  = i_display
*        changing
*             screen        = c_screen
*        exceptions
*             others  = 1.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

ENDFORM.                    " delivery_PBO_FIELD_MODIF

*&---------------------------------------------------------------------*
*&      Form  delivery_PBO_SET_PFSTAT
*&---------------------------------------------------------------------*
FORM delivery_pbo_set_pfstat
       TABLES i_exclude_tab
              i_dyntext_tab STRUCTURE dyntext_def
       USING  value(i_display) TYPE c
              value(i_dynpro)  LIKE sy-dynnr.

  DATA:
    l_my_exclude_tab LIKE sy-ucomm OCCURS 0 WITH HEADER LINE.
  FIELD-SYMBOLS:
    <dyntext> TYPE smp_dyntxt.

  APPEND LINES OF i_exclude_tab TO l_my_exclude_tab.
  IF NOT i_display IS INITIAL.
    APPEND fcode_sichern TO l_my_exclude_tab.
  ENDIF.

  LOOP AT i_dyntext_tab.
    ASSIGN (i_dyntext_tab-fieldname) TO <dyntext>.
    MOVE-CORRESPONDING i_dyntext_tab TO <dyntext>.
  ENDLOOP.

  CASE sy-dynnr.

    WHEN '0300'.
*     overview of stages
*     externally defined inactive fcodes for this screen:
*     append 'XXXX' to l_my_exclude_tab.
      SET PF-STATUS 'TERM' EXCLUDING l_my_exclude_tab.
      SET TITLEBAR 'T00'.

  ENDCASE.
ENDFORM.                    " delivery_PBO_SET_PFSTAT