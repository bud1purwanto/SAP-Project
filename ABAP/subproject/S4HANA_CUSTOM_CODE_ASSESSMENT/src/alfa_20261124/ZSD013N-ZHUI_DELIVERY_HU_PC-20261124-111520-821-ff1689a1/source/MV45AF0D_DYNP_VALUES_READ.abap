*---------------------------------------------------------------------*
*       FORM DYNP_VALUES_READ                                         *
*---------------------------------------------------------------------*
*       Wert zu einem Feld vor dem Feldtransport lesen                 *
*---------------------------------------------------------------------*
FORM DYNP_VALUES_READ USING US_REPID
                            US_DYNNR
                            US_FIELD
                   CHANGING CH_VALUE
                            CH_SUBRC.

  DATA: DA_DYNPFIELD_TAB LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
        DA_REPID LIKE D020S-PROG,
        DA_DYNNR LIKE D020S-DNUM.

  CH_SUBRC = 4.
  CLEAR CH_VALUE.
  REFRESH DA_DYNPFIELD_TAB.

  MOVE US_REPID TO DA_REPID.
  MOVE US_DYNNR TO DA_DYNNR.

  MOVE US_FIELD TO DA_DYNPFIELD_TAB-FIELDNAME.
  APPEND DA_DYNPFIELD_TAB.

  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME               = DA_REPID
            DYNUMB               = DA_DYNNR
       TABLES
            DYNPFIELDS           = DA_DYNPFIELD_TAB
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
            OTHERS               = 10.

  IF SY-SUBRC EQ 0.
    READ TABLE DA_DYNPFIELD_TAB INDEX 1.
    IF SY-SUBRC EQ 0.
      CH_VALUE = DA_DYNPFIELD_TAB-FIELDVALUE.
      CH_SUBRC = 0.
    ENDIF.
  ENDIF.

ENDFORM.