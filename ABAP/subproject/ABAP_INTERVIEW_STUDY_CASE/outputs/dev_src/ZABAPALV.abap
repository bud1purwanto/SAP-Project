*&---------------------------------------------------------------------*
*&  Include           ZABAPALV                                         *
*&---------------------------------------------------------------------*
TYPE-POOLS: SLIS.

* Data for listviewer
DATA: D_REPID      LIKE SY-REPID,
      T_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      WA_KEYINFO   TYPE SLIS_KEYINFO_ALV,
      T_COLOR      TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE,
      WA_LAYOUT    TYPE SLIS_LAYOUT_ALV,
      T_PRINT      TYPE SLIS_PRINT_ALV,
      T_SORT       TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE,
      T_EXCLUDING  TYPE SLIS_T_EXTAB WITH HEADER LINE,
      T_EVENTS     TYPE SLIS_T_EVENT WITH HEADER LINE,
      T_EVENT_EXIT TYPE SLIS_T_EVENT_EXIT WITH HEADER LINE,
      T_LIST_TOP   TYPE SLIS_T_LISTHEADER,

* Variants
      WA_VARIANTE        LIKE DISVARIANT,
      WA_DEF_VARIANTE    LIKE DISVARIANT,
      D_VARIANT_EXIT(1) TYPE C.

DATA:
  GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
  G_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
  GS_STARTDATE        LIKE SY-DATUM,
  GS_ENDDATE          LIKE SY-DATUM.


CONSTANTS:
  C_YES VALUE 'X',
  C_NO  VALUE SPACE.

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG USING FU_TYPES
                           FU_FNAME
                           FU_REFTB
                           FU_REFLD
                           FU_NOOUT
                           FU_OUTLN
                           FU_FLTXT
                           FU_DOSUM
                           FU_HOTSP
                           FU_JUST.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg

*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_WT_FRZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TYPES   text
*      -->FU_FNAME   text
*      -->FU_REFTB   text
*      -->FU_REFLD   text
*      -->FU_NOOUT   text
*      -->FU_OUTLN   text
*      -->FU_FLTXT   text
*      -->FU_DOSUM   text
*      -->FU_HOTSP   text
*      -->FU_JUST    text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_WT_FRZ USING FU_TYPES
                                  FU_FNAME
                                  FU_REFTB
                                  FU_REFLD
                                  FU_NOOUT
                                  FU_OUTLN
                                  FU_FLTXT
                                  FU_DOSUM
                                  FU_HOTSP
                                  FU_JUST.

  CLEAR: T_FIELDCAT.
  T_FIELDCAT-FIX_COLUMN    = 'X'.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    "

*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_WT_ZERO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TYPES   text
*      -->FU_FNAME   text
*      -->FU_REFTB   text
*      -->FU_REFLD   text
*      -->FU_NOOUT   text
*      -->FU_OUTLN   text
*      -->FU_FLTXT   text
*      -->FU_DOSUM   text
*      -->FU_HOTSP   text
*      -->FU_JUST    text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_WT_ZERO USING FU_TYPES
                                   FU_FNAME
                                   FU_REFTB
                                   FU_REFLD
                                   FU_NOOUT
                                   FU_OUTLN
                                   FU_FLTXT
                                   FU_DOSUM
                                   FU_HOTSP
                                   FU_JUST.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
*  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    "F_ALV_FIELDCATG_WT_ZERO

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON USING FU_TYPES
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
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
  T_FIELDCAT-NO_ZERO       = 'X'.
  T_FIELDCAT-FIX_COLUMN    = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg_icon

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON_WT_ZERO USING FU_TYPES
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
*  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg_icon

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG2 USING FU_TYPES
                            FU_FNAME
                            FU_REFTB
                            FU_REFLD
                            FU_NOOUT
                            FU_OUTLN
                            FU_FLTXT
                            FU_DOSUM
                            FU_HOTSP
                            FU_JUST
                            FU_NO_ZERO.


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
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-NO_ZERO       = FU_NO_ZERO.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg2
*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_curr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0426   text
*      -->P_0427   text
*      -->P_0428   text
*      -->P_0429   text
*      -->P_0430   text
*      -->P_0431   text
*      -->P_0432   text
*      -->P_0433   text
*      -->P_0434   text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_CURR USING FU_TYPES
                            FU_FNAME
                            FU_REFTB
                            FU_REFLD
                            FU_NOOUT
                            FU_OUTLN
                            FU_FLTXT
                            FU_DOSUM
                            FU_HOTSP
                            FU_CFIELD.

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
  T_FIELDCAT-CFIELDNAME    = FU_CFIELD.
  T_FIELDCAT-CTABNAME      = FU_TYPES.
  T_FIELDCAT-NO_ZERO       = ''.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " F_FIELDCATG_CURR

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_curr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0426   text
*      -->P_0427   text
*      -->P_0428   text
*      -->P_0429   text
*      -->P_0430   text
*      -->P_0431   text
*      -->P_0432   text
*      -->P_0433   text
*      -->P_0434   text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_CURR_FIXED USING FU_TYPES
                            FU_FNAME
                            FU_REFTB
                            FU_REFLD
                            FU_NOOUT
                            FU_OUTLN
                            FU_FLTXT
                            FU_DOSUM
                            FU_HOTSP
                            FU_CURR.

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
*  t_fieldcat-cfieldname    = fu_cfield.
*  t_fieldcat-ctabname      = fu_types.
  T_FIELDCAT-DATATYPE      = 'CURR'.
  T_FIELDCAT-CURRENCY      = FU_CURR.
  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " F_FIELDCATG_CURR

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_quan
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0426   text
*      -->P_0427   text
*      -->P_0428   text
*      -->P_0429   text
*      -->P_0430   text
*      -->P_0431   text
*      -->P_0432   text
*      -->P_0433   text
*      -->P_0434   text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_QUAN USING FU_TYPES
                            FU_FNAME
                            FU_REFTB
                            FU_REFLD
                            FU_NOOUT
                            FU_OUTLN
                            FU_FLTXT
                            FU_DOSUM
                            FU_HOTSP
                            FU_QFIELD
                            FU_JUST.

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
  T_FIELDCAT-QFIELDNAME    = FU_QFIELD.
  T_FIELDCAT-QTABNAME      = FU_TYPES.
  T_FIELDCAT-NO_ZERO       = ''.
  T_FIELDCAT-JUST          = FU_JUST.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " F_FIELDCATG_QUAN
*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_6316   text
*      -->P_6317   text
*      -->P_6318   text
*      -->P_6319   text
*      -->P_6320   text
*      -->P_6321   text
*      -->P_6322   text
*      -->P_6323   text
*      -->P_6324   text
*      -->P_6325   text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_NUMBER USING FU_TYPES
                            FU_FNAME
                            FU_NOOUT
                            FU_OUTLN
                            FU_NO_SIGN
                            FU_NO_ZERO
                            FU_FLTXT
                            FU_DOSUM
                            FU_EXPONENT
                            FU_DECIMALS_OUT.

  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-NO_ZERO       = FU_NO_ZERO.
  T_FIELDCAT-NO_SIGN       = FU_NO_SIGN.
  T_FIELDCAT-EXPONENT      = FU_EXPONENT.
  T_FIELDCAT-DECIMALS_OUT  = FU_DECIMALS_OUT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-DATATYPE      = 'FLTP'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.


ENDFORM.                    " f_alv_fieldcatg_number
*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TYPES   text
*      -->FU_FNAME   text
*      -->FU_REFTB   text
*      -->FU_REFLD   text
*      -->FU_NOOUT   text
*      -->FU_OUTLN   text
*      -->FU_FLTXT   text
*      -->FU_DOSUM   text
*      -->FU_HOTSP   text
*      -->FU_JUST    text
*      -->FU_ICON    text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_SO USING FU_TYPES
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
*                           FU_CHK
*                           FU_INPUT
*                           FU_EDIT.

  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
*  T_FIELDCAT-CHECKBOX      = FU_CHK.
*  T_FIELDCAT-INPUT          = 'X'.
*  T_FIELDCAT-EDIT          = FU_EDIT.
*  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg

*&--------------------------------------------------------------------*
*&      Form  f_header
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM F_HEADER_ALV USING FD_LINE_SIZE TYPE P.
  DATA LFLG_GRID.
  DATA LD_LINE_SIZE TYPE P.

  LD_LINE_SIZE = FD_LINE_SIZE.

  IMPORT LFLG_GRID FROM MEMORY ID 'ALV_GRID_TOP_OF_PAGE'.
  IF LFLG_GRID = 'X'.
    CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
      EXPORTING
*       I_LOGO             = 'ENJOYSAP_LOGO'
        IT_LIST_COMMENTARY = T_LIST_TOP.

  ENDIF.

ENDFORM.                    " F_HEADER


*-- add by Alifi at 16-08-2012
FORM F_ALV_FIELDCATG_01 USING FU_TAB
                                FU_FNAME
                                FU_TYPES
                                FU_REFTB
                                FU_REFLD
                                FU_CTAB
                                FU_CFIELD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_JUST
                                FU_ICON
                                FU_ZERO
                                FU_KEY
                                FU_HOTSP.

  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TAB.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-DATATYPE       = FU_TYPES.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-CTABNAME      = FU_CTAB.
  T_FIELDCAT-CFIELDNAME    = FU_CFIELD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
  T_FIELDCAT-NO_ZERO       = FU_ZERO.
  T_FIELDCAT-KEY       = FU_KEY.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.
ENDFORM.                    " f_alv_fieldcatg_01
*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_COST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TYPES   text
*      -->FU_FNAME   text
*      -->FU_REFTB   text
*      -->FU_REFLD   text
*      -->FU_NOOUT   text
*      -->FU_OUTLN   text
*      -->FU_FLTXT   text
*      -->FU_DOSUM   text
*      -->FU_HOTSP   text
*      -->FU_JUST    text
*      -->FU_COLOR   text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_COST USING FU_TYPES
                           FU_FNAME
                           FU_REFTB
                           FU_REFLD
                           FU_NOOUT
                           FU_OUTLN
                           FU_FLTXT
                           FU_DOSUM
                           FU_HOTSP
                           FU_JUST
                           FU_COLOR.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-NO_ZERO       = 'X'.
  T_FIELDCAT-EMPHASIZE     = FU_COLOR.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg
