*----------------------------------------------------------------------*
***INCLUDE MV50A_DISPLAY_ORDER_CRMF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  display_order_crm
*&---------------------------------------------------------------------*
FORM display_order_crm  USING    if_vbelv        TYPE vbelv
                                 if_rfcdest      TYPE rfcdest.

  DATA  : lf_crmguid  TYPE crmguid
        , lt_crmguids TYPE STANDARD TABLE OF crmguid
        , lr_vbelv    TYPE RANGE OF vbelv WITH HEADER LINE
        , lf_mess     TYPE c LENGTH 80
        .

  lr_vbelv-sign   = 'I'.
  lr_vbelv-option = 'EQ'.
  lr_vbelv-low    = if_vbelv.
  APPEND lr_vbelv.

* get GUID from CRM (  BAPI_BUSPROCESSND_GETLIST )
  CALL FUNCTION 'BAPI_BUSPROCESSND_GETLIST'
    DESTINATION if_rfcdest
    TABLES
      guid                  = lt_crmguids
      object_id_sel         = lr_vbelv
    EXCEPTIONS
      system_failure        = 1  MESSAGE lf_mess
      communication_failure = 2  MESSAGE lf_mess.

  IF sy-subrc IS NOT INITIAL OR
     lt_crmguids[] IS INITIAL.
    MESSAGE e001(vl) WITH lf_mess.
  ELSE.

    READ TABLE lt_crmguids INTO lf_crmguid INDEX 1.

*   Call remote function for Display of CRM order
    CALL FUNCTION 'BAPI_BUSPROCESSND_DISPLAY'
      DESTINATION if_rfcdest
      EXPORTING
        business_process      = lf_crmguid
      EXCEPTIONS
        system_failure        = 1  MESSAGE lf_mess
        communication_failure = 2  MESSAGE lf_mess.

    IF sy-subrc = 1.
      MESSAGE e001(vl) WITH lf_mess.
    ELSEIF sy-subrc <> 0.
      MESSAGE e007(/spe/vl) WITH if_vbelv if_rfcdest.
    ENDIF.
  ENDIF.

ENDFORM.                    " display_order_crm