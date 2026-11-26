*eject
*---------------------------------------------------------------------*
*       MODULE BWART_HILFE                                            *
*---------------------------------------------------------------------*
*       POP-UP's zur Selektion der Bewegungsart werden vorbereitet.   *
*---------------------------------------------------------------------*
MODULE BWART_HILFE.
  DATA: BEGIN OF XDYNPREAD OCCURS 2.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END OF XDYNPREAD.
  DATA: LOC_REPID LIKE SY-REPID.
  DATA: LOC_DYNNR LIKE SY-DYNNR.
  DATA: LOC_PROTECT TYPE CHAR1.                              "note596073
  CLEAR: XDYNPREAD, LOC_PROTECT.                             "note596073
  REFRESH XDYNPREAD.                                         "note596073
  LOC_REPID = SY-REPID.
  LOC_DYNNR = SY-DYNNR.
  IF T158-KZBEW IS INITIAL OR XKZBEW = 1.
    MOVE 'RM07M-BWARTWA' TO XDYNPREAD-FIELDNAME.
  ELSE.
    MOVE 'RM07M-BWARTWE' TO XDYNPREAD-FIELDNAME.
  ENDIF.
  APPEND XDYNPREAD.
* SOBKZ is not present on the search popup being used in MB1B"note747650
* to look for PO's (LOC_PROTECT would be set below, even     "note747650
* though it shouldn't)                                       "note747650
  IF NOT SY-DYNNR = '1404'.                                  "note747650
    MOVE 'RM07M-SOBKZ' TO XDYNPREAD-FIELDNAME.
    APPEND XDYNPREAD.
  ENDIF.                                                     "note747650
  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME               = LOC_REPID
            DYNUMB               = LOC_DYNNR
       TABLES
            DYNPFIELDS           = XDYNPREAD
       EXCEPTIONS
            INVALID_ABAPWORKAREA = 1
            INVALID_DYNPROFIELD  = 2
            INVALID_DYNPRONAME   = 3
            INVALID_DYNPRONUMMER = 4
            INVALID_REQUEST      = 5
            NO_FIELDDESCRIPTION  = 6
            INVALID_PARAMETER    = 7
            UNDEFIND_ERROR       = 8
            OTHERS               = 9.
  LOOP AT XDYNPREAD.
    IF XDYNPREAD-FIELDNAME EQ 'RM07M-SOBKZ'.
      RM07M-SOBKZ = XDYNPREAD-FIELDVALUE.
    ELSE.
      RM07M-BWART = XDYNPREAD-FIELDVALUE.
    ENDIF.
    IF XDYNPREAD-FIELDNAME EQ 'RM07M-BWARTWA' AND            "note596073
       XDYNPREAD-FIELDINP  EQ SPACE OR                       "note596073
       XDYNPREAD-FIELDNAME EQ 'RM07M-SOBKZ' AND              "note596073
       XDYNPREAD-FIELDINP  EQ SPACE.                         "note596073
         LOC_PROTECT = X.                                    "note596073
     ENDIF.                                                  "note596073
  ENDLOOP.

  IF T158-KZBEW IS INITIAL OR XKZBEW = 1.
    IF OLD_BWARTWA IS INITIAL.
      OLD_BWARTWA = RM07M-BWART.
      OLD_SOBKZ = RM07M-SOBKZ.
    ENDIF.
  ELSE.
    IF OLD_BWARTWE IS INITIAL.
      OLD_BWARTWE = RM07M-BWART.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'MB_SELECT_MOVEMENT_TYPE'
       EXPORTING
            TCODE  = T158-TCODE
            HILFE  = HLP-M
            ANFBI  = ANF_BILD
            XKZBW  = XKZBW
            XKZBEW = XKZBEW
            KZBEW  = T158-KZBEW
            DISP   = LOC_PROTECT                             "note596073
       IMPORTING
            BWART  = RM07M-BWART
            SOBKZ  = RM07M-SOBKZ.
  IF NOT RM07M-BWART IS INITIAL.
    IF T158-KZBEW IS INITIAL OR XKZBEW = 1.
      RM07M-BWARTWA = RM07M-BWART.
    ELSE.
      RM07M-BWARTWE = RM07M-BWART.
    ENDIF.
  ELSE.
    IF T158-KZBEW IS INITIAL OR XKZBEW = 1.
      RM07M-BWART = RM07M-BWARTWA = OLD_BWARTWA.
      RM07M-SOBKZ = OLD_SOBKZ.
      SET PARAMETER ID 'BWA' FIELD RM07M-BWART.
    ELSE.
      RM07M-BWART = RM07M-BWARTWE = OLD_BWARTWE.
      SET PARAMETER ID 'BWE' FIELD RM07M-BWART.
    ENDIF.
  ENDIF.
* HIER DYNP_VALUES_UPDATE, DA PBO ab 3.1 NICHT MEHR PROZESSIERT WIRD
  LOOP AT XDYNPREAD.
    IF XDYNPREAD-FIELDNAME EQ 'RM07M-SOBKZ'.
       XDYNPREAD-FIELDVALUE = RM07M-SOBKZ.
    ELSE.
       XDYNPREAD-FIELDVALUE = RM07M-BWART.
    ENDIF.
    MODIFY XDYNPREAD.
  ENDLOOP.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
       EXPORTING
            DYNAME               =  LOC_REPID
            DYNUMB               =  LOC_DYNNR
       TABLES
            DYNPFIELDS           =  XDYNPREAD
       EXCEPTIONS
            OTHERS               = 4.
ENDMODULE.