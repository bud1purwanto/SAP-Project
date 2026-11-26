*----------------------------------------------------------------------*
*   INCLUDE LMIGOKH1                                                   *
*   Kernel header operations  implementation
*----------------------------------------------------------------------*
* METHOD HEADER_GET
*    EXPORTING e_gohead TYPE gohead
*----------------------------------------------------------------------*
* Send in PBO of header carrier the header data
* from kernel to header screens
*----------------------------------------------------------------------*
METHOD header_get.
  e_gohead = ps_gohead.
ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HEADER_MODIFY
*   IMPORTING i_gohead TYPE gohead
*----------------------------------------------------------------------*
* Receive in PAI of header carrier the header data
* from header screens to kernel
*----------------------------------------------------------------------*
METHOD header_modify.
  ps_gohead = i_gohead.
ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HEADER_DEFAULTS_SET
*----------------------------------------------------------------------*
* Set default data in PS_GOHEAD in creation mode only
* (Defaults for posting date, document date, print indicator)
* No proposal of document date in cancel or return mode
* Called in kernel reset
*----------------------------------------------------------------------*
METHOD header_defaults_set.
* WEVER has to be set in display mode as well    "315434
  IF ps_gohead-wever is initial.                 "315434
    ps_gohead-wever = s_defaults-wever.          "315434
  ENDIF.                                         "315434
* Defaults only in creation mode
  CHECK s_action-create = abap_true.
  IF s_action-cancel = abap_false AND s_action-return = abap_false
                                  AND s_action-subsequent = abap_false.
    IF ps_gohead-bldat IS INITIAL.
      ps_gohead-bldat = sy-datlo.
    ENDIF.
  ENDIF.
  IF ps_gohead-budat IS INITIAL.
    ps_gohead-budat = sy-datlo.
ENHANCEMENT-POINT HEADER_DEFAULTS_SET_01 SPOTS ES_SAPLMIGO.
  ENDIF.
ENHANCEMENT-POINT HEADER_DEFAULTS_SET_02 SPOTS ES_SAPLMIGO.
* Set print indicator
  GET PARAMETER ID 'NDR' FIELD ps_gohead-xnapr.
ENHANCEMENT-POINT HEADER_DEFAULTS_SET_03 SPOTS ES_SAPLMIGO.
ENDMETHOD.