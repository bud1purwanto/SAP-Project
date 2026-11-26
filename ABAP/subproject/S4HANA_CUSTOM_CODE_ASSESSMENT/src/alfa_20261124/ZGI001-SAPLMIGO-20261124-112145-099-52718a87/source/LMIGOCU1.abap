*----------------------------------------------------------------------*
*   INCLUDE LMIGOCU1                                                   *
*   Cursor control
*----------------------------------------------------------------------*

CLASS lcl_migo_cursor DEFINITION.

PUBLIC SECTION.
  CLASS-DATA:
    oref_screenobject TYPE REF TO lcl_migo_screenobject READ-ONLY,
    stepl             TYPE systepl                      READ-ONLY,
    field             TYPE migo_fieldname               READ-ONLY,
    value             TYPE char50                       READ-ONLY,
    dynnr             TYPE sydynnr                      READ-ONLY.

  CLASS-METHODS:
    cursor_set
      IMPORTING
        i_field             TYPE migo_fieldname
        i_oref_screenobject TYPE REF TO lcl_migo_screenobject OPTIONAL
        i_stepl             TYPE systepl                      OPTIONAL
        i_dynnr             TYPE sydynnr                      OPTIONAL,
    pbo_cursor_set
      IMPORTING
        i_oref_screenobject TYPE REF TO lcl_migo_screenobject,
    pai_cursor_get
      IMPORTING
        i_oref_screenobject TYPE REF TO lcl_migo_screenobject,
    clear.


ENDCLASS.