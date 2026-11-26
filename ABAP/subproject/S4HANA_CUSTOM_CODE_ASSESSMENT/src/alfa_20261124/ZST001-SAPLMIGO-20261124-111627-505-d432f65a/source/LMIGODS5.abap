*----------------------------------------------------------------------*
*   INCLUDE LMIGODS5                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_determine_stock DEFINITION.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor.

  PRIVATE SECTION.
    TYPES:
      ty_t_cdstock       type standard table of cdstock.

    METHODS:
      determine_single
        IMPORTING i_line     TYPE sytabix
                  i_massproc TYPE abap_bool DEFAULT abap_false
                  i_transdet TYPE abap_bool OPTIONAL,
      determine_all,
      update_model_det
        IMPORTING i_line             TYPE sytabix
                  i_massproc         TYPE abap_bool DEFAULT abap_false
                  i_umren            TYPE umren
                  i_umrez            TYPE umrez
                  i_transdet         TYPE abap_bool OPTIONAL
                  it_cdstock         TYPE ty_t_cdstock
                  is_goitem_original TYPE goitem
                  is_cdcom           TYPE cdcom,
*----------------------------------------------------------------------*
*     Determine INSMK according to movement type
      determine_insmk
        IMPORTING ls_goitem_original TYPE goitem                "650835
        CHANGING  ls_cdcom           TYPE cdcom.                "650835

ENDCLASS.