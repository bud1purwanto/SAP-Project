*&---------------------------------------------------------------------*
*&  Include           ZSDR_CUSTOMIZING_MASTER1_F01
*&---------------------------------------------------------------------*


FORM GET_DATA .
  CLEAR: IT_CUST.
  REFRESH: IT_CUST.

  CLEAR: IT_ENTRIES2.
  REFRESH: IT_ENTRIES2.

  SELECT
    MARA~MATNR MARA~CUOBF T001K~BUKRS
    INTO CORRESPONDING FIELDS OF TABLE IT_CUST
    FROM MARA JOIN MARC ON MARA~MATNR = MARC~MATNR
    JOIN T001K ON MARC~WERKS = T001K~BWKEY
    WHERE MARA~MTPOS_MARA EQ '0002' AND
      MARA~MTART EQ 'ZFGS'
      AND T001K~BUKRS EQ V_BUKRS.

  LOOP AT IT_CUST.

    CALL FUNCTION 'VC_I_GET_CONFIGURATION_IBASE'
      EXPORTING
        INSTANCE            = IT_CUST-CUOBF
*       BUSINESS_OBJECT     =
*       LANGUAGE            = SY-LANGU
*       IV_INVALID_POSSIBLE = ' '
*       IV_NEUTRAL          = ' '
      TABLES
        CONFIGURATION       = IT_ENTRIES2
*       ET_CONF_WITH_AUTHOR =
      EXCEPTIONS
        INSTANCE_NOT_FOUND  = 1
        OTHERS              = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.


    "- Kode Film
    READ TABLE IT_ENTRIES2 WITH KEY ATNAM = 'ZZCODE'.
    IF SY-SUBRC = 0.
      IT_CUST-ZCODE = IT_ENTRIES2-ATWRT.
    ENDIF.


    CLEAR: IT_ENTRIES.
    REFRESH: IT_ENTRIES.
    CALL FUNCTION 'CARD_TABLE_READ_ENTRIES'
      EXPORTING
        VAR_TABLE       = 'ZZCODE'
      TABLES
        VAR_TAB_ENTRIES = IT_ENTRIES
      EXCEPTIONS
        ERROR           = 1
        OTHERS          = 2.

    IT_TEMP[] = IT_ENTRIES[].

    DELETE IT_ENTRIES WHERE VTVALUE NE IT_CUST-ZCODE.

    LOOP AT IT_ENTRIES.
      CLEAR : WA_TEMP.
      LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO  = IT_ENTRIES-VTLINENO
                                     AND VTCHARACT = 'ZZCODE'
                                     AND VTVALUE   = IT_CUST-ZCODE.
        CLEAR : V_VTLINENO.
        V_VTLINENO = WA_TEMP-VTLINENO.
      ENDLOOP.
    ENDLOOP.

    CLEAR : WA_TEMP.
    LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO  = V_VTLINENO
                                   AND VTCHARACT = 'ZZTYPE'.
      CLEAR : V_VTVALUE.
      V_VTVALUE = WA_TEMP-VTVALUE.
    ENDLOOP.

    IT_CUST-ZTYPE = V_VTVALUE.

    CLEAR : WA_TEMP.
    LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO  = V_VTLINENO
                                   AND VTCHARACT = 'ZZTHICKNESS'.
      CLEAR : V_VTVALUE.
      V_VTVALUE = WA_TEMP-VTVALUE.
    ENDLOOP.

    IT_CUST-ZTHICK = V_VTVALUE.

    CLEAR : WA_TEMP.
    LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO  = V_VTLINENO
                                   AND VTCHARACT = 'ZZDENSITY'.
      CLEAR : V_VTVALUE.
      V_VTVALUE = WA_TEMP-VTVALUE.
    ENDLOOP.

    IT_CUST-ZDENSITY = V_VTVALUE.



    CLEAR : WA_TEMP.
    LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO  = V_VTLINENO
                                   AND VTCHARACT = 'ZZEXPIREDLIVE'.
      CLEAR : V_VTVALUE.
      V_VTVALUE = WA_TEMP-VTVALUE.
    ENDLOOP.

    IT_CUST-ZEXPIRED = V_VTVALUE.


    CLEAR : WA_TEMP.
    LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO  = V_VTLINENO
                                   AND VTCHARACT = 'ZZGRAMMAGE'.
      CLEAR : V_VTVALUE.
      V_VTVALUE = WA_TEMP-VTVALUE.
    ENDLOOP.

    IT_CUST-ZGRAMMAGE = V_VTVALUE.

    MODIFY IT_CUST.

  ENDLOOP.

  SORT IT_CUST ASCENDING BY MATNR.


ENDFORM.                    "GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .
  IF IT_CUST[] IS INITIAL.
    MESSAGE 'No Data Selected' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.

ENDFORM.                    " DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON2 USING '' :
       'BUKRS'    ''  ''  ''  13   'Company Code'    ''   ''  ''  '',
       'MATNR'    ''  ''  ''  18   'Material Number'    ''   ''  ''  '',
       'ZCODE'    ''  ''  ''  15   'Kode Film'    ''   ''  ''  '',
       'ZTYPE'    ''  ''  ''  15   'Type Film'    ''   ''  ''  '',
       'ZTHICK'    ''  ''  ''  15   'Thickness (Micron)'    ''   ''  ''  '',
       'ZDENSITY'    ''  ''  ''  15   'Density (g/cm3)'    ''   ''  ''  '',
       'ZEXPIRED'    ''  ''  ''  15   'Expired Life'    ''   ''  ''  '',
       'ZGRAMMAGE'    ''  ''  ''  15   'Grammage'    ''   ''  ''  ''.


ENDFORM.                    " F_FIELD_CATALOG

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
*  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
*  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-ZEBRA = 'X'.

ENDFORM.                    " F_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .

  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
*      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = IT_CUST
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    "F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDR_CUST'.
ENDFORM.                    " F_ALV_STATUS
" F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON2 USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_ICON.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
  T_FIELDCAT-NO_ZERO       = ''.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    "F_ALV_FIELDCATG_ICON2
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_TREATMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_TREATMENT .
  DATA : ATINN LIKE CAWN-ATINN.
  CLEAR: IT_ENTRIES,IT_TEMP,IT_TREATMENT.
  REFRESH: IT_ENTRIES,IT_TEMP,IT_TREATMENT.
  CALL FUNCTION 'CARD_TABLE_READ_ENTRIES'
    EXPORTING
      VAR_TABLE       = 'ZZTREATMENT'
    TABLES
      VAR_TAB_ENTRIES = IT_ENTRIES
    EXCEPTIONS
      ERROR           = 1
      OTHERS          = 2.
  IT_TEMP[] = IT_ENTRIES[].
  SORT IT_TEMP BY VTLINENO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IT_TEMP COMPARING VTLINENO.
  LOOP AT IT_TEMP.
    CLEAR IT_TREATMENT.
    READ TABLE IT_ENTRIES WITH KEY VTLINENO = IT_TEMP-VTLINENO VTCHARACT = 'ZZTREATMENT'.
    IF SY-SUBRC EQ 0.
      IT_TREATMENT-TREATMENT = IT_ENTRIES-VTVALUE.
    ENDIF.
    READ TABLE IT_ENTRIES WITH KEY VTLINENO = IT_TEMP-VTLINENO VTCHARACT = 'ZZINSIDE'.
    IF SY-SUBRC EQ 0.
      CLEAR ATINN.
      PERFORM INTERNAL USING 'ZZINSIDE' CHANGING ATINN.
      SELECT SINGLE ATWTB INTO IT_TREATMENT-INSIDE
        FROM CAWNT
        JOIN CAWN ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
        WHERE CAWN~ATWRT = IT_ENTRIES-VTVALUE
        AND CAWN~ATINN = ATINN
        AND CAWNT~SPRAS EQ 'EN'.
*      IT_TREATMENT-INSIDE = IT_ENTRIES-VTVALUE.
    ENDIF.
    READ TABLE IT_ENTRIES WITH KEY VTLINENO = IT_TEMP-VTLINENO VTCHARACT = 'ZZOUTSIDE'.
    IF SY-SUBRC EQ 0.
      CLEAR ATINN.
      PERFORM INTERNAL USING 'ZZOUTSIDE' CHANGING ATINN.
      SELECT SINGLE ATWTB INTO IT_TREATMENT-OUTSIDE
        FROM CAWNT
        JOIN CAWN ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
        WHERE CAWN~ATWRT = IT_ENTRIES-VTVALUE
        AND CAWN~ATINN = ATINN
        AND CAWNT~SPRAS EQ 'EN'.
*      IT_TREATMENT-OUTSIDE = IT_ENTRIES-VTVALUE.
    ENDIF.
    APPEND IT_TREATMENT.
  ENDLOOP.
ENDFORM.                    " GET_DATA_TREATMENT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA_TREATMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA_TREATMENT .
  IF IT_TREATMENT[] IS INITIAL.
    MESSAGE 'No Data Selected' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG_01.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL_01.

ENDFORM.                    " DISPLAY_DATA_TREATMENT
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_01 .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON2 USING 'IT_TREATMENT' :
       'TREATMENT'    ''  ''  ''  18   'Treatment'    ''   ''  ''  '',
       'INSIDE'    ''  ''  ''  15   'Inside'    ''   ''  ''  '',
       'OUTSIDE'    ''  ''  ''  15   'Outside'    ''   ''  ''  ''.
ENDFORM.                    " F_FIELD_CATALOG_01
*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL_01 .

  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
*      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = IT_TREATMENT
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM .                   "F_LIST_DETAIL_01
*&---------------------------------------------------------------------*
*&      Form  INTERNAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0641   text
*      <--P_ATINN  text
*----------------------------------------------------------------------*
FORM INTERNAL  USING    P_TEXT
               CHANGING P_ATINN.
CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = P_TEXT
    IMPORTING
      OUTPUT = P_ATINN.

ENDFORM.                    " INTERNAL