*----------------------------------------------------------------------*
*   INCLUDE LMIGOHI1                                                   *
*----------------------------------------------------------------------*
*   Header tabstrip foreign trade definition
*----------------------------------------------------------------------*

CLASS lcl_migo_header_import DEFINITION
      INHERITING FROM lcl_migo_headerobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION,
      pbo_popup,
      pai_popup,
      pai_exit.
ENDCLASS.