*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TAXI_INITIALIZE_CARRI                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TAXI_INITIALIZE_CARRIERSCREEN
*&---------------------------------------------------------------------*
*
*       Initialisation of the carrier dynpro. Called from dynpro
*       1000, 2000 and 3000 in PBO
*----------------------------------------------------------------------*
form taxi_initialize_carrierscreen.

  statics: sf_taxi_screen_group like taxi_screen_group,
           sf_vbeln             like likp-vbeln,
           st_inactive_fcodes   type table of taxi_inactive_fcodes.

* Variable for the tabstrip control belonging to the current screen
* group
  field-symbols: <taxi_tabstrip> like taxi_tabstrip.

* Get attributes of the tab strip control for the current screen group
  read table taxi_screen_groups
     with key screen_group = taxi_screen_group.
  assign (taxi_screen_groups-tabstrip_name) to <taxi_tabstrip>.

* Performance: Initalization of screen groups is only necessary if
* screen group changes or a new document is processed or if this is
* triggered by the application
  if sf_taxi_screen_group ne taxi_screen_group or
     sf_vbeln ne likp-vbeln or
     v50agl-force_tab_init ne space.

    clear v50agl-force_tab_init.

*   Documentary Batch - show tab only when active
    if gf_docubatch_active is initial and
      st_inactive_fcodes   is initial.
      append 'DOBA_T'
        to st_inactive_fcodes.
    endif.

*   Create captions of the tab index (inactive tabs are handled in form
*   TAXI_INSERT_CUST_TABS)
    call function 'TAXI_CREATE_CAPTIONS'
      exporting
        program                 = 'SAPMV50A'
        screen_group            = taxi_screen_group
      importing
        tabstrip_captions       = taxi_tabstrip_captions
      tables
        inactive_fcodes         = st_inactive_fcodes
      exceptions
        no_tabs_for_screengroup = 1
        no_caption_for_fcode    = 2
        others                  = 3.

    if sy-subrc ne 0.
      message a347 with 'SAPMV50A' taxi_screen_group.
    endif.

*   Enable additional tab pages and influence sequence of tabs; suppress
*   inactive tabs
    perform taxi_insert_cust_tabs.

  endif.

* Wenn das Flag TAXI_HEADER_INITIALIZED gesetzt ist, bedeutet dies,
* dass das Headersubscreendynpro seine Felddaten aus dem aktuellen
* Pool beziehen kann. Dies kann nur dann nicht erfüllt sein, wenn der
* Subscreen aus einem anderen Pool gerufen wird. Anders ausgedrückt,
* wird der Subscreen innerhalb eines Trägerdynpros dieses Pool
* gerufen, sind die Kopfdaten grundsätzlich initialisiert.
  taxi_header_initialized = 'X'.

* Suppress tabs without captions
  call function 'TAXI_INITIALIZE_CARRIERSCREEN'
    exporting
      tabstrip_captions = taxi_tabstrip_captions
    exceptions
      others            = 0.

* Was there a change of the current panel or document?
  if taxi_panel ne *taxi_panel
        or taxi_screen_group ne *taxi_screen_group
        or sf_vbeln ne likp-vbeln.
*   If yes bring active tab to the front
    perform taxi_activate_tab
            tables   taxi_screen_groups
            using    taxi_fcode
                     taxi_screen_group
            changing <taxi_tabstrip>.
  endif.

* Save current screen group (to avoid unnecessary tab initializations)
  sf_taxi_screen_group = taxi_screen_group.
  sf_vbeln = likp-vbeln.

endform.                               " TAXI_INITIALIZE_CARRIERSCREEN