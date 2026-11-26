**&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class LCL_MIGO_DETAIL_EWM
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_ewm DEFINITION INHERITING FROM
lcl_migo_detailobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION.


ENDCLASS.               "LCL_MIGO_DETAIL_EWM
*&  Include           LMIGODX1
*&---------------------------------------------------------------------*