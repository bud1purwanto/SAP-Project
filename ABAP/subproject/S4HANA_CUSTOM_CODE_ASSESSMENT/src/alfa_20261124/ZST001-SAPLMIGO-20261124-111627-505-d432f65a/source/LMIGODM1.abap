*----------------------------------------------------------------------*
*   INCLUDE LMIGODM1                                                   *
*   Detail tabstrip material definition                                *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_material DEFINITION
      INHERITING FROM lcl_migo_detailobject.
  PUBLIC SECTION.
    METHODS:
      pbo REDEFINITION,
      subscreen_set.
ENDCLASS.