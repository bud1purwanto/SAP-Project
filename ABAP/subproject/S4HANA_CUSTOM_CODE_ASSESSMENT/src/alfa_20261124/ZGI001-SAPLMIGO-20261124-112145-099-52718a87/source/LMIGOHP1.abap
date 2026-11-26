*----------------------------------------------------------------------*
*   INCLUDE LMIGOHP1                                                   *
*----------------------------------------------------------------------*
* Header tabstrip people definition
*----------------------------------------------------------------------*
CLASS lcl_migo_header_people DEFINITION
      INHERITING FROM lcl_migo_headerobject.

PUBLIC SECTION.
  METHODS:
    constructor,
* Set contact person from user settings
    pbo REDEFINITION,
* Search contact person on request
    pai_header_people_search.
PRIVATE SECTION.
   DATA: poref_people_default TYPE REF TO cl_mmim_userdefaults,
         p_usnam TYPE usnam.
ENDCLASS.