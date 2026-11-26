*&---------------------------------------------------------------------*
*&  Include           LMIGODT7                                         *
*&---------------------------------------------------------------------*
CLASS lcl_migo_detail_trans DEFINITION
                            INHERITING FROM lcl_migo_detailobject.
  PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor,
    pbo_frame_text_set,
    pbo_stock_identifier_set.

ENDCLASS.                    "lcl_migo_detail_trans  DEFINITIO