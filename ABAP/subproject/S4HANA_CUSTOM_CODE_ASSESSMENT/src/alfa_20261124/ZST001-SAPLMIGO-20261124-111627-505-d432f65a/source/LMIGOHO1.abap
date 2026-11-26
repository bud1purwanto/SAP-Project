*----------------------------------------------------------------------*
*   INCLUDE LMIGOHO1                                                   *
*   Abstract superclass for subscreens in the header area
*----------------------------------------------------------------------*

CLASS lcl_migo_headerobject DEFINITION
      INHERITING FROM lcl_migo_screenobject ABSTRACT.

PUBLIC SECTION.
  METHODS:
    pbo REDEFINITION,
    cursor_position_resolve REDEFINITION.

ENDCLASS.