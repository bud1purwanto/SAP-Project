*&---------------------------------------------------------------------*
*&  Include           ZQMI_PROP_CLASS_IMPLEMENTATION
*&---------------------------------------------------------------------*


*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* §5.2 implement the events for handling the events of cl_salv_table
*---------------------------------------------------------------------*
CLASS LCL_HANDLE_EVENTS IMPLEMENTATION.
  METHOD ON_USER_COMMAND.
*    perform catch_function_code_salv using e_salv_function." text-i08.
  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_handle_events IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_REPORT IMPLEMENTATION.

  METHOD GENERATE_OUTPUT.
    DATA: LX_MSG TYPE REF TO CX_SALV_MSG.
    TRY.
        CL_SALV_TABLE=>FACTORY(
          IMPORTING
            R_SALV_TABLE = O_ALV
          CHANGING
            T_TABLE      = <F_TAB> ).
      CATCH CX_SALV_MSG INTO LX_MSG.
    ENDTRY.

*   Get the column object
    DATA: LO_COLS      TYPE REF TO CL_SALV_COLUMNS_TABLE.
*   modify individual properties
    DATA: LO_COLUMN    TYPE REF TO CL_SALV_COLUMN_TABLE,
          FNAME        TYPE LVC_FNAME,
          LTXT         TYPE SCRTEXT_L,
          MTXT         TYPE SCRTEXT_M,
          STXT         TYPE SCRTEXT_S.
    LO_COLS = O_ALV->GET_COLUMNS( ).
    LO_COLS->SET_OPTIMIZE( 'X' ).
    TAB_COUNT = 0.

    "JIKA MIXING
    IF RM = 'X'.
      LOOP AT LT_TOT_COMP INTO LA_COMP.
        TAB_COUNT = TAB_COUNT + 1.
        TRY.
            IF TAB_COUNT = 1 OR TAB_COUNT = 3 .
              MOVE LA_COMP-NAME TO FNAME.
              MOVE LA_COMP-NAME TO LTXT.
            ELSEIF TAB_COUNT = 2.
              MOVE LA_COMP-NAME TO FNAME.
              CONCATENATE 'MATERIAL' 'DESC' INTO LTXT SEPARATED BY SPACE.
            ELSEIF TAB_COUNT = 4 OR TAB_COUNT = 5.
              MOVE LA_COMP-NAME TO FNAME.
              SHIFT LA_COMP-NAME RIGHT CIRCULAR BY 3 PLACES.
              CONCATENATE 'STANDARD' LA_COMP-NAME(3) INTO LTXT SEPARATED BY SPACE.
            ELSE.

              MOVE LA_COMP-NAME TO FNAME.

              CLEAR WA_ITAB.
              READ TABLE ITAB2 INTO WA_ITAB WITH KEY ZFIELDNAME = LA_COMP-NAME.

              IF SY-SUBRC = 0.
                MOVE WA_ITAB-AUFNR TO LTXT.
              ENDIF.
            ENDIF.

            LO_COLUMN ?= LO_COLS->GET_COLUMN( FNAME ).
            LO_COLUMN->SET_LONG_TEXT( LTXT ).               "#EC NOTEXT

            "- SET KEY FREEZE
            IF TAB_COUNT = 1 OR TAB_COUNT = 2 OR TAB_COUNT = 3 OR TAB_COUNT = 4 OR TAB_COUNT = 5.
              LO_COLUMN ?= LO_COLS->GET_COLUMN( FNAME ).
              LO_COLUMN->SET_KEY( ).
              LO_COLUMN->SET_KEY_PRESENCE_REQUIRED( ).
            ENDIF.
          CATCH CX_SALV_NOT_FOUND.                      "#EC NO_HANDLER
        ENDTRY.
      ENDLOOP.

    ELSE. "JIKA SELAIN MIXING
      LOOP AT LT_TOT_COMP INTO LA_COMP.
        TAB_COUNT = TAB_COUNT + 1.
        TRY.
            IF TAB_COUNT = 1 .
              MOVE LA_COMP-NAME TO FNAME.
              LTXT = 'FILM TYPE'.
            ELSEIF TAB_COUNT = 2 .
              MOVE LA_COMP-NAME TO FNAME.
              MOVE LA_COMP-NAME TO LTXT.
            ELSEIF TAB_COUNT = 3 OR TAB_COUNT = 4.
              MOVE LA_COMP-NAME TO FNAME.
              SHIFT LA_COMP-NAME RIGHT CIRCULAR BY 3 PLACES.

              CONCATENATE 'STANDARD' LA_COMP-NAME(3) INTO LTXT SEPARATED BY SPACE.
            ELSE.
              MOVE LA_COMP-NAME TO FNAME.
              CLEAR WA_ITAB.
              READ TABLE ITAB2 INTO WA_ITAB WITH KEY ZFIELDNAME = LA_COMP-NAME.

              IF SY-SUBRC = 0.
                MOVE WA_ITAB-ZZNOMORROLL TO LTXT.
              ENDIF.
            ENDIF.
            LO_COLUMN ?= LO_COLS->GET_COLUMN( FNAME ).
            LO_COLUMN->SET_LONG_TEXT( LTXT ).

            "- SET KEY FREEZE
            IF TAB_COUNT = 1 OR TAB_COUNT = 2 OR TAB_COUNT = 3 OR TAB_COUNT = 4.
              LO_COLS->SET_KEY_FIXATION( ).
              LO_COLUMN ?= LO_COLS->GET_COLUMN( FNAME ).
              LO_COLUMN->SET_KEY( ).

              LO_COLUMN->SET_KEY_PRESENCE_REQUIRED( ).
            ENDIF.

          CATCH CX_SALV_NOT_FOUND.                      "#EC NO_HANDLER
        ENDTRY.
      ENDLOOP.
    ENDIF.
*
* $*$*.....CODE_ADD_2 - Begin..................................2..*$*$*
*
*    Set display setting
    CALL METHOD SET_DISPLAY_SETTING
      CHANGING
        CO_ALV = O_ALV.

*     ***    Calling the pfststus
    CALL METHOD SET_PF_STATUS
      CHANGING
        CO_ALV = O_ALV.
*
*   Calling the top of page method
    CALL METHOD ME->SET_TOP_OF_PAGE
      CHANGING
        CO_ALV = O_ALV.

    DATA: LR_EVENTS TYPE REF TO CL_SALV_EVENTS_TABLE.

    LR_EVENTS = O_ALV->GET_EVENT( ).

    CREATE OBJECT GR_EVENTS.

*... §6.1 register to the event USER_COMMAND
    SET HANDLER GR_EVENTS->ON_USER_COMMAND FOR LR_EVENTS.


*$*$*.....CODE_ADD_2 - End....................................2..*$*$*
*
*
* Displaying the ALV
*   Here we will call the DISPLAY method to get the output on the screen
    O_ALV->DISPLAY( ).
*
  ENDMETHOD.                    "generate_output


  METHOD SET_PF_STATUS.
**
*   Calling method to set the PF-Status
    CO_ALV->SET_SCREEN_STATUS(
      PFSTATUS      =  'ZSTATUS'
      REPORT        =  'ZQMI_PROP_SELECT'
      SET_FUNCTIONS = CO_ALV->C_FUNCTIONS_ALL ).
*
  ENDMETHOD.                    "set_pf_status


  METHOD SET_TOP_OF_PAGE.
*
    DATA: LO_HEADER  TYPE REF TO CL_SALV_FORM_LAYOUT_GRID,
          LO_H_LABEL TYPE REF TO CL_SALV_FORM_LABEL,
          LO_H_FLOW  TYPE REF TO CL_SALV_FORM_LAYOUT_FLOW,
          VTYPE(30)  TYPE C,
          VDATE(50) TYPE C.
*
*   header object
    CREATE OBJECT LO_HEADER.

*   information in Bold
    IF R1 = 'X'.
      VTYPE = 'Jumbo Roll'.
    ELSEIF  R2 = 'X'.
      VTYPE = 'Slit Roll'.
    ELSEIF  R3 = 'X'.
      VTYPE = 'Aging'.
    ELSEIF  RM = 'X'.
      VTYPE = 'Mixing'.
    ENDIF.

    CONCATENATE 'Material Type :' VTYPE INTO VTYPE SEPARATED BY SPACE.
    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 1 ).
    LO_H_LABEL->SET_TEXT( 'Properties Report for Production' ).

    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 2 COLUMN = 1 ).
    LO_H_LABEL->SET_TEXT( VTYPE ).

    CONCATENATE 'Inspection Lot Date :' DATES 'to' DATEF INTO VDATE  SEPARATED BY SPACE.
    LO_H_LABEL = LO_HEADER->CREATE_LABEL( ROW = 3 COLUMN = 1 ).
    LO_H_LABEL->SET_TEXT( VDATE ).

*   set the top of list using the header for Online.
    CO_ALV->SET_TOP_OF_LIST( LO_HEADER ).
*
*   set the top of list using the header for Print.
    CO_ALV->SET_TOP_OF_LIST_PRINT( LO_HEADER ).
*
  ENDMETHOD.                    "set_top_of_page
*
  METHOD SET_END_OF_PAGE.
*
    DATA: LO_FOOTER  TYPE REF TO CL_SALV_FORM_LAYOUT_GRID,
          LO_F_LABEL TYPE REF TO CL_SALV_FORM_LABEL,
          LO_F_FLOW  TYPE REF TO CL_SALV_FORM_LAYOUT_FLOW.
*
*   footer object
    CREATE OBJECT LO_FOOTER.
*
*   information in bold
    LO_F_LABEL = LO_FOOTER->CREATE_LABEL( ROW = 1 COLUMN = 1 ).
    LO_F_LABEL->SET_TEXT( 'Footer .. here it goes' ).
*
*   tabular information
    LO_F_FLOW = LO_FOOTER->CREATE_FLOW( ROW = 2  COLUMN = 1 ).
    LO_F_FLOW->CREATE_TEXT( TEXT = 'This is text of flow in footer' ).
*
    LO_F_FLOW = LO_FOOTER->CREATE_FLOW( ROW = 3  COLUMN = 1 ).
    LO_F_FLOW->CREATE_TEXT( TEXT = 'Footer number' ).
*
    LO_F_FLOW = LO_FOOTER->CREATE_FLOW( ROW = 3  COLUMN = 2 ).
    LO_F_FLOW->CREATE_TEXT( TEXT = 1 ).
*
*   Online footer
    CO_ALV->SET_END_OF_LIST( LO_FOOTER ).
*
*   Footer in print
    CO_ALV->SET_END_OF_LIST_PRINT( LO_FOOTER ).
*
  ENDMETHOD.                    "set_end_of_page

  METHOD SET_DISPLAY_SETTING.
*
    DATA: LO_DISPLAY TYPE REF TO CL_SALV_DISPLAY_SETTINGS.
*
*   get display object
    LO_DISPLAY = O_ALV->GET_DISPLAY_SETTINGS( ).
*
*   set ZEBRA pattern
    LO_DISPLAY->SET_STRIPED_PATTERN( 'X' ).
*
*   Title to ALV
    LO_DISPLAY->SET_LIST_HEADER( 'Properties Report for Production' ).
*
  ENDMETHOD.                    "SET_DISPLAY_SETTING


ENDCLASS.                    "lcl_report IMPLEMENTATION