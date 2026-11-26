*----------------------------------------------------------------------*
*   INCLUDE LMIGOEQ1                                                   *
*   Enqueue management
*----------------------------------------------------------------------*

CLASS lcl_migo_enqueue DEFINITION.

PUBLIC SECTION.
  TYPES:
    ty_state_id TYPE char20.

  CLASS-METHODS:
    save    IMPORTING i_state_id TYPE ty_state_id,
    restore IMPORTING i_state_id TYPE ty_state_id.

PRIVATE SECTION.
  TYPES:
    BEGIN OF ty_s_enqueue,
      id      TYPE ty_state_id,
      failure TYPE abap_bool,
      tab     TYPE STANDARD TABLE OF seqg3 WITH DEFAULT KEY,
    END OF ty_s_enqueue,
    ty_t_enqueue TYPE HASHED TABLE OF ty_s_enqueue
                 WITH UNIQUE KEY id.

  CLASS-DATA:
    pt_enqueue          TYPE ty_t_enqueue.

ENDCLASS.