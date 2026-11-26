*----------------------------------------------------------------------*
*   INCLUDE LMIGOHC1                                                   *
*   Header carrier
*----------------------------------------------------------------------*
CLASS lcl_migo_header DEFINITION
      INHERITING FROM lcl_migo_screenobject.
  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION.
  PRIVATE SECTION.
    DATA:
      poref_settings TYPE REF TO cl_mmim_userdefaults.
    METHODS:
      screen_modify_local,
      subscreen_select.
ENDCLASS.