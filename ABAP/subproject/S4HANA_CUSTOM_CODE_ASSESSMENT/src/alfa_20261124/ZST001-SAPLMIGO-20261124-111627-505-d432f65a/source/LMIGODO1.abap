*----------------------------------------------------------------------*
*   INCLUDE LMIGODO1                                                   *
*   Abstract detailobject
*----------------------------------------------------------------------*

CLASS lcl_migo_detailobject DEFINITION
      INHERITING FROM lcl_migo_screenobject ABSTRACT.

PUBLIC SECTION.
  METHODS:
    pbo REDEFINITION,
    cursor_position_resolve REDEFINITION.

ENDCLASS.