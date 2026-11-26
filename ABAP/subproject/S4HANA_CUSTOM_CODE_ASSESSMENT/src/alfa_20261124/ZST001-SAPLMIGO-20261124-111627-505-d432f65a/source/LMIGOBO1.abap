*----------------------------------------------------------------------*
*   INCLUDE LMIGOBO1                                                   *
*   Parameters for the BOM explosion                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_bom DEFINITION
                   INHERITING FROM lcl_migo_screenobject.

PUBLIC SECTION.
  DATA: s_gobom TYPE gobom.
  METHODS:
    constructor,
    exit_command,
    pbo REDEFINITION,
    pai REDEFINITION,
    gobom_popup IMPORTING i_werks TYPE werks_d,
    gobom_fill  IMPORTING i_werks TYPE werks_d.

PRIVATE SECTION.
  DATA:
    oref_settings TYPE REF TO cl_mmim_userdefaults.
  METHODS:
    gobom_update  IMPORTING i_werks TYPE werks_d.
ENDCLASS.