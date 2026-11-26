*----------------------------------------------------------------------*
*   INCLUDE LMIGOPR1                                                   *
*   Predocument class.
*----------------------------------------------------------------------*

CLASS lcl_migo_predocument DEFINITION.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor,
    alv_callback_status CHANGING ct_extab    TYPE slis_t_extab,
    alv_callback_user   CHANGING cf_ucomm    TYPE syucomm
                                 cs_selfield TYPE slis_selfield.

PRIVATE SECTION.
    TYPES: BEGIN OF ty_s_doclist,
             select TYPE char1.
             INCLUDE TYPE mmim_predoc_org.
    TYPES: END OF ty_s_doclist.
    TYPES: ty_t_doclist TYPE STANDARD TABLE OF ty_s_doclist.

  DATA:
    p_last_document TYPE lcl_migo_kernel=>ty_s_refdockey,
    pt_doclist TYPE ty_t_doclist,
    p_selected_guid TYPE guid_22.
  METHODS:
    predoc_save,
    predoc_select,
    delete
      IMPORTING
        i_guid TYPE guid_22,
    load
      IMPORTING
        i_guid TYPE guid_22.


ENDCLASS.