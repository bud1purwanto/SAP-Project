*----------------------------------------------------------------------*
*   INCLUDE RKRFCGROUPINC_EVENTS                                       *
*----------------------------------------------------------------------*

DATA: rfcgr_displayformat TYPE n VALUE '0'.

*---------------------------------------------------------------------*
*       FORM rfcgrp_selscreen_output                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM rfcgrp_selscreen_output.
  STATICS:
     st_1st_time TYPE xflag VALUE 'X',
     sd_textpool TYPE textpool OCCURS 50,
     sd_text_ngw(30) TYPE c.

  DATA:
     ld_rfcgr TYPE spta_rfcgr,
     ld_textpool     LIKE LINE OF sd_textpool.

  IF NOT st_1st_time IS INITIAL.
    CLEAR st_1st_time.
    READ TEXTPOOL 'RKRFCGROUPINC_TEXTPOOL' INTO sd_textpool.
    IF NOT rfcgroup IS INITIAL.
      SET PARAMETER ID 'SPTA_RFCGR' FIELD rfcgroup.
      rfcproc = 'X'.
    ENDIF.
    LOOP AT sd_textpool INTO ld_textpool WHERE id = 'I'.
      CASE ld_textpool-key.
        WHEN 'PVA'. rfcproct    = ld_textpool-entry.
        WHEN 'NGW'. sd_text_ngw = ld_textpool-entry.
        WHEN 'SGR'. rfcgrt      = ld_textpool-entry.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  GET PARAMETER ID 'SPTA_RFCGR' FIELD ld_rfcgr.

  CASE rfcgr_displayformat.
    WHEN 0.
      IF NOT rfcproc IS INITIAL
         AND rfcgroup IS INITIAL.
        rfcgroup = ld_rfcgr.
      ENDIF.
    WHEN 1.
  ENDCASE.
  IF ld_rfcgr IS INITIAL.
    CALL FUNCTION 'ICON_CREATE'
         EXPORTING
              name   = 'ICON_ENTER_MORE'
              info   = sd_text_ngw
         IMPORTING
              result = rfcpbt1.
  ELSE.
    CALL FUNCTION 'ICON_CREATE'
         EXPORTING
              name   = 'ICON_DISPLAY_MORE'
              info   = sd_text_ngw
         IMPORTING
              result = rfcpbt1.
  ENDIF.
  CASE rfcgr_displayformat.
    WHEN 0.
      LOOP AT SCREEN.
        IF screen-name = 'RFCPBT1'.
          screen-active = 0.
          MODIFY SCREEN.
        ELSEIF screen-name = 'RFCGROUP'
            OR screen-name = 'RFCGRT'.
          IF rfcproc IS INITIAL.
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    WHEN 1.
      LOOP AT SCREEN.
        IF     screen-name = 'RFCGRT'
            OR screen-name = 'RFCGROUP'.
          screen-active = 0.
          MODIFY SCREEN.
        ELSEIF screen-name = 'RFCPBT1'.
          IF rfcproc IS INITIAL.
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM rfcgrp_selscreen                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM rfcgrp_selscreen.
  DATA:
     ld_rfcgr TYPE spta_rfcgr,
     ld_invalid_rfcgrp TYPE xflag.

  CASE sy-ucomm.
    WHEN 'RFCDISP'.
      rfcgr_displayformat = 1 - rfcgr_displayformat.
      CLEAR sy-ucomm.
      EXIT.
  ENDCASE.

  IF NOT rfcgroup IS INITIAL.
    SELECT COUNT(*) FROM rzllitab
           WHERE classname = rfcgroup. "#EC CI_BYPASS
    IF sy-dbcnt = 0.
      ld_invalid_rfcgrp = 'X'.
    ENDIF.
  ENDIF.

  CASE rfcgr_displayformat.
    WHEN 0.
      IF rfcgroup IS INITIAL.
        GET PARAMETER ID 'SPTA_RFCGR' FIELD rfcgroup.
      ENDIF.
      IF NOT rfcproc IS INITIAL
         AND rfcgroup IS INITIAL.
        SET CURSOR FIELD rfcgroup.
        IF sy-ucomm = 'RFCPROC'.
          MESSAGE s002(spta).
        ELSE.
          MESSAGE e002(spta).
        ENDIF.
        EXIT.
      ENDIF.
      IF NOT ld_invalid_rfcgrp IS INITIAL
        AND NOT rfcproc IS INITIAL.
        MESSAGE e004(spta) WITH rfcgroup.
      ENDIF.

      IF NOT rfcgroup IS INITIAL
        AND ld_invalid_rfcgrp IS INITIAL.
        SET PARAMETER ID 'SPTA_RFCGR' FIELD rfcgroup.
      ENDIF.
      IF rfcproc IS INITIAL.
        CLEAR rfcgroup.
      ENDIF.
    WHEN 1.
      IF sy-ucomm = 'RFCPBT1'.
        PERFORM rfcgrp_selection_list
           CHANGING
              ld_rfcgr.
      ELSEIF NOT rfcproc IS INITIAL.
        GET PARAMETER ID 'SPTA_RFCGR' FIELD ld_rfcgr.
        IF ld_rfcgr IS INITIAL.
          PERFORM rfcgrp_selection_list
             CHANGING
                ld_rfcgr.
        ENDIF.
        IF ld_rfcgr IS INITIAL.
          IF sy-ucomm = 'RFCPROC'.
            MESSAGE s002(spta).
          ELSE.
            MESSAGE e002(spta).
          ENDIF.
          EXIT.
        ENDIF.
      ENDIF.
      rfcgroup = ld_rfcgr.
      IF NOT ld_rfcgr IS INITIAL.
        SET PARAMETER ID 'SPTA_RFCGR' FIELD ld_rfcgr.
      ENDIF.
      IF rfcproc IS INITIAL.
        CLEAR rfcgroup.
      ENDIF.
  ENDCASE.
ENDFORM.                               "RFCGRP_SELSCREEN

*---------------------------------------------------------------------*
*       FORM rfcgrp_start_of_selection                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM rfcgrp_start_of_selection.
ENDFORM.                               "RFCGRP_START_OF_SELECTION

*---------------------------------------------------------------------*
*       FORM rfcgrp_init                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM rfcgrp_init.
  PERFORM kass_fw_event_register
     USING:
        kass_fw_event-selection_screen_output
        'RFCGRP_SELSCREEN_OUTPUT'
        kass_fw_priority-before_main
        kass_fw_default_reg_options.
  PERFORM kass_fw_event_register
     USING
        kass_fw_event-selection_screen
        'RFCGRP_SELSCREEN'
        kass_fw_priority-before_main
        kass_fw_default_reg_options.
  PERFORM kass_fw_event_register
     USING
        kass_fw_event-start_of_selection
        'RFCGRP_START_OF_SELECTION'
        kass_fw_priority-before_main
        kass_fw_default_reg_options.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM rfcgrp_selection_list                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  value(p_rfcgrp_in)                                            *
*  <--  value(p_rfcgrp_out)                                           *
*---------------------------------------------------------------------*
FORM rfcgrp_selection_list
   CHANGING
      value(p_rfcgrp) TYPE spta_rfcgr.

  DATA:
     ld_curow  TYPE sy-tabix,
     lt_f4ftab TYPE STANDARD TABLE OF help_value
                    WITH HEADER LINE,
  BEGIN OF lt_f4vtab OCCURS 0,
    line(100) TYPE c,
  END OF lt_f4vtab.

  SELECT classname FROM rzllitab INTO TABLE lt_f4vtab
                   WHERE grouptype = 'S'.

  SORT lt_f4vtab.
  DELETE ADJACENT DUPLICATES FROM lt_f4vtab.
  READ TABLE lt_f4vtab WITH KEY = p_rfcgrp.
  IF sy-subrc = 0.
    ld_curow = sy-tabix.
  ENDIF.

  lt_f4ftab-tabname    = 'RZLLITAB'.
  lt_f4ftab-fieldname  = 'CLASSNAME'.
  lt_f4ftab-selectflag = 'X'.
  APPEND lt_f4ftab.


  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
       EXPORTING
            curow                     = ld_curow
       IMPORTING
            select_value              = p_rfcgrp
       TABLES
            fields                    = lt_f4ftab
            valuetab                  = lt_f4vtab
       EXCEPTIONS
            field_not_in_ddic         = 1
            more_then_one_selectfield = 2
            no_selectfield            = 3
            OTHERS                    = 4.
ENDFORM.                               " rfcgrp_selection_list

INITIALIZATION.
  PERFORM rfcgrp_init.