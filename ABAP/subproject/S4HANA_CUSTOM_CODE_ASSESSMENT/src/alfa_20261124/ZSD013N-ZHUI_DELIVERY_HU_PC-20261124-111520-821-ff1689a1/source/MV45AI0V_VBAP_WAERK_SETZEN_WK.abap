*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBAP_WAERK_SETZEN_WK                              *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       MODULE VBAP-WAERK_SETZEN_WK                                   *
*---------------------------------------------------------------------*
*       After entering a target value fill currency before putting    *
*       this value into VBAP in order the currency format is set      *
*       correctly                                                     *
*---------------------------------------------------------------------*
MODULE VBAP-WAERK_SETZEN_WK.

  DATA: DA_REPID      LIKE SY-REPID,
        DA_DYNNR      LIKE SY-DYNNR,
        DA_DYNPFIELDS LIKE DYNPREAD OCCURS 3 WITH HEADER LINE.

  CLEAR   DA_DYNPFIELDS.
  REFRESH DA_DYNPFIELDS.

  DA_REPID = SY-REPID.
  DA_DYNNR = SY-DYNNR.
  DA_DYNPFIELDS-FIELDNAME = 'VBAP-ZWERT'.
  DA_DYNPFIELDS-STEPL     = SY-STEPL.
  APPEND DA_DYNPFIELDS.

  DA_REPID = SY-REPID.
  DA_DYNNR = SY-DYNNR.
  DA_DYNPFIELDS-FIELDNAME = 'RV45A-AWERT'.
  DA_DYNPFIELDS-STEPL     = SY-STEPL.
  APPEND DA_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME               = DA_REPID
            DYNUMB               = DA_DYNNR
       TABLES
            DYNPFIELDS           = DA_DYNPFIELDS
       EXCEPTIONS
            INVALID_ABAPWORKAREA = 1
            INVALID_DYNPROFIELD  = 2
            INVALID_DYNPRONAME   = 3
            INVALID_DYNPRONUMMER = 4
            INVALID_REQUEST      = 5
            NO_FIELDDESCRIPTION  = 6
            INVALID_PARAMETER    = 7
            UNDEFIND_ERROR       = 8
            DOUBLE_CONVERSION    = 9
            STEPL_NOT_FOUND      = 10
            OTHERS               = 11.

  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT DA_DYNPFIELDS.
    IF NOT DA_DYNPFIELDS-FIELDVALUE IS INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.
  CHECK SY-SUBRC = 0 AND
        NOT DA_DYNPFIELDS-FIELDVALUE IS INITIAL.

* Fill currency already in VBAP to get right formatting of value
  VBAP-WAERK = VBAK-WAERK.

* Avoid error 00 011
  IF VBAK-WAERK NE *VBAK-WAERK OR
     NOT CURRENCY_CHANGED IS INITIAL.
    CLEAR VBAP-WAERK.
  ENDIF.

ENDMODULE.