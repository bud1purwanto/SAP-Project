*----------------------------------------------------------------------*
*   INCLUDE LMIGOAR1                                                   *
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_migo_arch DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor.
  PRIVATE SECTION.
    METHODS:
      object_publish_general,
      object_publish_distinct
        IMPORTING
          i_matdoc_number TYPE mblnr
          i_matdoc_year   TYPE mjahr.
    DATA:
      go_matdoc TYPE REF TO cl_gos_manager.


ENDCLASS.