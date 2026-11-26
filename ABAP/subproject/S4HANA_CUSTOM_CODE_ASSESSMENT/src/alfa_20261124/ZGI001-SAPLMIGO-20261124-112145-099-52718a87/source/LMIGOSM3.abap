*----------------------------------------------------------------------*
*   INCLUDE LMIGOSM3                                                   *
*   Screenmodification
*----------------------------------------------------------------------*

CLASS lcl_migo_screenmodification DEFINITION.

*----------------------------------------------------------------------*
* PUBLIC SECTION                                                       *
*----------------------------------------------------------------------*
PUBLIC SECTION.
  TYPES:
*   Access to the COLS-structure of a table control
    BEGIN OF ty_s_column,
      screen   LIKE screen,       "Attributes struktur SCREEN
      index    TYPE i,            "Position of a column on the screen
      selected TYPE char1,        "Indicator 'column selected'
      vislength TYPE icon-oleng,  "Visualised length of a column
      invisible TYPE char1,       "Indicator 'column invisible'
    END OF ty_s_column,
*   Working table without global counter
    BEGIN OF ty_s_fs,
      name TYPE migo_fieldname,
      type TYPE char1,
      work TYPE migo_fs_status,
      mode TYPE migo_fs_status,
      sfac TYPE migo_fs_status,
      work_required TYPE abap_bool,
      mode_required TYPE abap_bool,
      sfac_required TYPE abap_bool,
    END OF ty_s_fs,
    ty_t_fs TYPE HASHED TABLE OF ty_s_fs
            WITH UNIQUE KEY name,
*   Master table with global counter
    BEGIN OF ty_s_fst,
      glc   TYPE migo_global_counter,
      table TYPE ty_t_fs,
    END OF ty_s_fst,
    ty_t_fst TYPE HASHED TABLE OF ty_s_fst
             WITH UNIQUE KEY glc,
*   Table for dynamic column selection in the table control
    BEGIN OF ty_s_dynamic,
      name   TYPE migo_fieldname,
      status TYPE migo_fs_status,
    END OF ty_s_dynamic,
    ty_t_dynamic TYPE STANDARD TABLE OF ty_s_dynamic,
*   Structure for transportation of dynpro data from
*   MIGO_GENERATE_FIELDSELECTION via LMIGOSMG to MIGO.
    BEGIN OF ty_s_generated,
      name        TYPE migo_fieldname,
      dynnr1      TYPE sydynnr,
      dynnr2      TYPE sydynnr,
      type(1)     TYPE c,
      item(1)     TYPE c,
      group1(3)   TYPE c,
      visible(1)  TYPE c,
      input(1)    TYPE c,
      required(1) TYPE c,
    END OF ty_s_generated,
*   Table of dynpro-numbers,
    ty_t_dynnr TYPE STANDARD TABLE OF sydynnr.
ENHANCEMENT-POINT LMIGOSM3_01 SPOTS ES_SAPLMIGO STATIC.

  CONSTANTS:
    c_invisible TYPE migo_fs_status VALUE 0,
    c_visible   TYPE migo_fs_status VALUE 2,
    c_input     TYPE migo_fs_status VALUE 6,
    c_not_valid TYPE migo_fs_status VALUE 8,
    c_item_template TYPE migo_global_counter VALUE 999999.
  CLASS-DATA:
*   Main fieldselection table with global counter. Public to be
*   visibe in the debugger every time.
    t_fieldselection TYPE ty_t_fst READ-ONLY,
*   Table with a list of fieldnames for Buttons used to display
*   things. This is useful to prevent these buttons from beeing
*   disabled by the INVERSION-method of SET.
    t_buttons TYPE ty_t_fieldname READ-ONLY.
  CLASS-METHODS:
    class_constructor,
*   Required fields
    screen_modify_required
      IMPORTING is_goitem   TYPE goitem OPTIONAL
                is_gohead   TYPE gohead OPTIONAL,
*   Main screen modification routines
    main
      IMPORTING i_global_counter TYPE migo_global_counter OPTIONAL,
    template_copy
      IMPORTING i_global_counter TYPE migo_global_counter,
    delete_item
      IMPORTING i_global_counter TYPE migo_global_counter,
    delete_all,
    restore
      IMPORTING i_mode           TYPE abap_bool
                i_global_counter TYPE migo_global_counter,
    set
      IMPORTING
        i_fields         TYPE string                OPTIONAL
        i_inversion      TYPE abap_bool             OPTIONAL
        i_one_way        TYPE abap_bool             OPTIONAL
        it_fields        TYPE ty_t_fieldname        OPTIONAL
        i_global_counter TYPE goitem-global_counter OPTIONAL
        i_mode           TYPE abap_bool             OPTIONAL
        i_status         TYPE migo_fs_status,
    get
      IMPORTING
        i_global_counter TYPE migo_global_counter   OPTIONAL
        i_field          TYPE migo_fieldname
        i_badi           TYPE abap_bool             OPTIONAL
      RETURNING
        value(r_status)  TYPE migo_fs_status,
    get_required                                                 "382998
      IMPORTING                                                  "382998
        i_global_counter    TYPE migo_global_counter OPTIONAL    "382998
        i_field             TYPE migo_fieldname                  "382998
      RETURNING
        value(r_required)   TYPE abap_bool,                      "382998
    dynamic_columns
      CHANGING
        ct_dynamic TYPE ty_t_dynamic,
    set_required
      IMPORTING
        i_field          TYPE migo_fieldname
        i_global_counter TYPE migo_global_counter
        i_mode           TYPE abap_bool DEFAULT abap_false,
    field_locate
      IMPORTING
        i_field          TYPE migo_fieldname
        i_global_counter TYPE migo_global_counter
      EXPORTING
        et_dynnr         TYPE ty_t_dynnr.

*-----------------------------------------------------------------------
* PRIVATE SECTION                                                      *
*----------------------------------------------------------------------*
PRIVATE SECTION.
  CLASS-DATA:
*   Field properties from screen
    t_generated TYPE SORTED TABLE OF ty_s_generated
                WITH UNIQUE KEY name.

ENHANCEMENT-POINT EHP605_LMIGOSM3_01 SPOTS ES_SAPLMIGO STATIC .

  CLASS-METHODS:
    fieldselection_sfac_read.
ENDCLASS.