*----------------------------------------------------------------------*
*   INCLUDE LMIGODI1                                                   *
*----------------------------------------------------------------------*
*   Detail tabstrip foreign trade                                      *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_import DEFINITION
      INHERITING FROM lcl_migo_detailobject.

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