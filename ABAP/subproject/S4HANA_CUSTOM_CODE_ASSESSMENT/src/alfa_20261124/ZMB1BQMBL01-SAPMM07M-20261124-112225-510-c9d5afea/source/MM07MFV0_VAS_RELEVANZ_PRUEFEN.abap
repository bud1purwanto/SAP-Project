*&---------------------------------------------------------------------*
*&      Form  VAS_RELEVANZ_PRUEFEN
*&---------------------------------------------------------------------*
*       text: checks whether vas is active for the actual po item and
*             whether the service is fulfilled
*----------------------------------------------------------------------*
FORM VAS_RELEVANZ_PRUEFEN.

  data: h_message_tab type FRM_MESSAGE_TAB_T,
        h_mseg like mseg.

  move-corresponding fuss to h_mseg.

* exception 'message_output' is not handled -> message of function
* module will be output automatically and table h_message_tab doesn't
* need to be handled with
  CALL FUNCTION 'W_VAS_GR_CHECK'
       EXPORTING
            i_mkpf                = mkpf
            i_mseg                = h_mseg
       tables
            et_messagelog         = h_message_tab
       EXCEPTIONS
            DO_NOT_ACCEPT_GR_ITEM = 1
            INTERFACE_ERROR       = 2
*            MESSAGE_OUTPUT        = 3
*            OTHERS                = 4
          .

  IF sy-subrc = 1.
* po item shall not be taken over
    clear rm07m-xselk.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " VAS_RELEVANZ_PRUEFEN