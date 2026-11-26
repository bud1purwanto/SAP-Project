***INCLUDE RKASSEFW .

INCLUDE rkassela.
TABLES: sscrfields.

PARAMETERS kokrs TYPE tka01-kokrs MODIF ID cac.

* Workflow Abilities
INCLUDE rkasmawf.

TYPES: BEGIN OF lt_kass_fw_event,
          event     TYPE kass_t_fw_event ,
          form(80)  TYPE c,
       END OF lt_kass_fw_event.

DATA: BEGIN OF kass_fw_data,
        init   TYPE xflag ,
        actvt  TYPE tj01-vrgng ,
        events TYPE lt_kass_fw_event OCCURS 0 ,
        no_kokrs_set TYPE c,
        hide_kokrs   TYPE xflag,
      END OF kass_fw_data.

DATA: kass_fw_cur_event,
      kass_fw_last_kokrs LIKE kokrs.

* Events
INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM kass_fw_kokrs_online_init.
  PERFORM kass_fw_display_adjust.
  PERFORM kass_fw_event_process
     USING
        kass_fw_event-selection_screen_output
        'SENDER_SELSCREEN_OUTPUT'.

AT SELECTION-SCREEN.
  PERFORM kass_fw_set_kokrs.
  PERFORM kass_fw_event_process
     USING
       kass_fw_event-selection_screen
       'SENDER_SELSCREEN'.

AT SELECTION-SCREEN ON kokrs.
  PERFORM kass_fw_check_kokrs_edited.

START-OF-SELECTION.
  PERFORM kass_fw_kokrs_batch_init.
  PERFORM kass_fw_event_process
     USING
       kass_fw_event-start_of_selection
       space.

END-OF-SELECTION.
  PERFORM kass_fw_event_process
     USING
       kass_fw_event-end_of_selection
       space.


*========================= Forms =====================================*

*---------------------------------------------------------------------*
*       FORM kass_fw_init                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_vrgng                                                       *
*---------------------------------------------------------------------*
FORM kass_fw_init
  USING
     p_vrgng   TYPE tj01-vrgng
     p_options TYPE kass_fw_t_init_options.

  CHECK kass_fw_data-init IS INITIAL.

  kass_fw_data-init = 'X'.
  kass_fw_data-actvt = p_vrgng.
  kass_fw_data-no_kokrs_set = p_options-no_kokrs_set.
  kass_fw_data-hide_kokrs   = p_options-hide_kokrs.

* popup for controlling area when online and without report variant
* (field KOKRS is not filled at INITIALIZATION for report variants)
  IF sy-batch IS INITIAL AND sy-slset IS INITIAL.           "MA
    CALL FUNCTION 'K_KOKRS_SET'
         IMPORTING
              e_kokrs = kokrs.
  ENDIF.

  PERFORM ('SENDER_INITIALIZATION') IN PROGRAM (sy-repid)
       IF FOUND.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM kass_fw_activity_set                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_vrgng                                                       *
*---------------------------------------------------------------------*
FORM kass_fw_activity_set
   USING
      p_vrgng TYPE tj01-vrgng.
  kass_fw_data-actvt = p_vrgng.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM kass_fw_activity_get                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_vrgng                                                       *
*---------------------------------------------------------------------*
FORM kass_fw_activity_get
   CHANGING
      p_vrgng TYPE tj01-vrgng.
  p_vrgng = kass_fw_data-actvt.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM kass_fw_event_register                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_eventname                                                   *
*  -->  p_formname                                                    *
*---------------------------------------------------------------------*
FORM kass_fw_event_register
  USING
     p_eventname    TYPE kass_t_fw_event
     p_formname     TYPE c
     p_priority     TYPE kass_fw_t_priority
     p_reg_options  TYPE kass_fw_t_reg_options.

  DATA: ld_event LIKE LINE OF kass_fw_data-events.

  READ TABLE kass_fw_data-events
             TRANSPORTING NO FIELDS
             WITH KEY event = p_eventname
                      form  = p_formname.
  IF sy-subrc <> 0 .
    ld_event-event = p_eventname.
    ld_event-form  = p_formname.
    APPEND ld_event TO kass_fw_data-events.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM kass_fw_event_process                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_event                                                       *
*  -->  p_senderform                                                  *
*---------------------------------------------------------------------*
FORM kass_fw_event_process
  USING
     p_event      TYPE kass_t_fw_event
     p_senderform TYPE c.

  DATA: ld_event LIKE LINE OF kass_fw_data-events.

  IF NOT p_senderform IS INITIAL.
    PERFORM (p_senderform) IN PROGRAM (sy-repid)
          IF FOUND.
  ENDIF.
  CALL FUNCTION 'K_KOKRS_SET'
       EXPORTING
            display   = 'X'
            popup     = '0'
       IMPORTING
            e_kokrs   = kokrs
       EXCEPTIONS
            not_found = 0
            OTHERS    = 0.
  kass_fw_last_kokrs = kokrs.
  LOOP AT kass_fw_data-events INTO ld_event
       WHERE event = p_event
         AND form  <> p_senderform.
    PERFORM (ld_event-form) IN PROGRAM (sy-repid).
    CALL FUNCTION 'K_KOKRS_SET'
         EXPORTING
              display   = 'X'
              popup     = '0'
         IMPORTING
              e_kokrs   = kokrs
         EXCEPTIONS
              not_found = 0
              OTHERS    = 0.
    kass_fw_last_kokrs = kokrs.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM kass_fw_kokrs_batch_init                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM kass_fw_kokrs_batch_init.
  STATICS: sd_1st_time TYPE xflag VALUE 'X'.

  CHECK NOT sd_1st_time IS INITIAL.
  CLEAR sd_1st_time.
  CHECK NOT sy-batch IS INITIAL.
  IF NOT kokrs IS INITIAL.
    CALL FUNCTION 'K_KOKRS_SET'
         EXPORTING
              display = 'X'
              i_kokrs = kokrs
              popup   = '0'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  kass_fw_kokrs_online_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM kass_fw_kokrs_online_init.
  STATICS: sd_1st_time TYPE xflag VALUE 'X'.

* Process only once
  CHECK NOT sd_1st_time IS INITIAL.
  CLEAR sd_1st_time.

* Standard CUA status with change of controlling area
  IF sy-batch IS INITIAL AND
     kass_fw_data-no_kokrs_set = space AND
     ( sy-pfkey = '%_00' OR sy-pfkey = '%_VC' ).
    CALL FUNCTION 'RS_EXTERNAL_SELSCREEN_STATUS'
         EXPORTING
              p_fb = 'KASS_SET_PF_STATUS'.
  ENDIF.

* process popup for controlling area in online
* ( not at initialization, but at selection-screen output)
  IF sy-batch IS INITIAL AND kokrs IS INITIAL.
    CALL FUNCTION 'K_KOKRS_SET'
         IMPORTING
              e_kokrs = kokrs.
  ELSEIF NOT kokrs IS INITIAL.
    CALL FUNCTION 'K_KOKRS_SET'
         EXPORTING
              i_kokrs = kokrs
              popup   = '0'.
  ENDIF.

ENDFORM.                               " kass_fw_kokrs_online_init

*&---------------------------------------------------------------------*
*&      Form  kass_fw_set_kokrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM kass_fw_set_kokrs.

  CHECK sy-ucomm = 'OKKS'.

  CALL FUNCTION 'K_KOKRS_SET'
       EXPORTING
            display = space
            i_kokrs = kokrs
            popup   = '1'
       IMPORTING
            e_kokrs = kokrs.

ENDFORM.                               " kass_fw_set_kokrs

*---------------------------------------------------------------------*
*       FORM kass_fw_hide_kokrs                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM kass_fw_hide_kokrs.
  kass_fw_data-hide_kokrs = 'X'.
ENDFORM.                               " kass_fw_hide_kokrs


*---------------------------------------------------------------------*
*       FORM kass_fw_show_kokrs                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM kass_fw_show_kokrs.
  kass_fw_data-hide_kokrs = space.
ENDFORM.                               " kass_fw_show_kokrs


*---------------------------------------------------------------------*
*       FORM kass_fw_check_kokrs_edited                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM kass_fw_check_kokrs_edited.
  CHECK kass_fw_data-hide_kokrs IS INITIAL
        AND kass_fw_last_kokrs NE kokrs.

  CALL FUNCTION 'K_KOKRS_SET'
       EXPORTING
            display = space
            i_kokrs = kokrs
            popup   = '0'
       IMPORTING
            e_kokrs = kokrs.

  kass_fw_last_kokrs = kokrs.
ENDFORM.                               " kass_fw_check_kokrs_edited

*---------------------------------------------------------------------*
*       FORM kass_fw_display_adjust                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM kass_fw_display_adjust.
  IF NOT kass_fw_data-hide_kokrs IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'CAC'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                               " kass_fw_display_adjust