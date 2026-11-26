*----------------------------------------------------------------------*
*   INCLUDE LMIGODA1                                                   *
*   Detail tabstrip account (CO-Interface)
*----------------------------------------------------------------------*

CLASS lcl_migo_detail_account DEFINITION
      INHERITING FROM lcl_migo_detailobject.

PUBLIC SECTION.
  METHODS:
    pbo REDEFINITION,
    pai REDEFINITION,
    pai_detail_account_receive.
PRIVATE SECTION.
  METHODS:
    account_send.
  DATA:
    gv_error TYPE c.
ENDCLASS.