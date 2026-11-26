*----------------------------------------------------------------------*
*   INCLUDE LMIGOKF1: Foreign trade                                    *
*----------------------------------------------------------------------*
* METHOD FTRADE_DETERMINE_ITEM
* Check if import data should be processed for an item (E_PROCESS) and
*       if import data should be copied from PO (E_COPY_FROM_PO)
* If one item needs import data, ps_gohead-exnum is set
*----------------------------------------------------------------------*
METHOD ftrade_determine_item.

  DATA: ls_itemdata       TYPE imp_s_mseg,
        l_import_process  TYPE abap_bool,
        l_copy_from_po    TYPE abap_bool,
        ls_156            TYPE got156,
        ls_goplant        TYPE goplant,
        ls_marc           TYPE marc,
        ls_mtcom          TYPE mtcom,
        ls_t001w          TYPE t001w.
* Clear before beginning...
  CLEAR: e_process.
* Import data only for items related to purchase orders
* or items with movement types that allow the creation of POs
  CALL METHOD lcl_migo_buffer=>move_type_get                     "355054
    EXPORTING i_move     = is_goitem-bwart                       "355054
    IMPORTING e_got156   = ls_156                                "355054
    EXCEPTIONS not_found = 1.                                    "355054
  CHECK is_goitem-xpoitem = abap_true  OR
        is_goitem-xpoitem = abap_false AND NOT ls_156-xnebe IS INITIAL.
* Import data not relevant for subsequent adjustment
  CHECK is_goitem-kzbew <> o.
* Mapping GOITEM - communication structure ----------------------------*
  ls_itemdata-bwart       = is_goitem-bwart.
  ls_itemdata-werks       = is_goitem-werks.
* Is there a supplier? (for items without PO)
  IF is_goitem-llief IS INITIAL AND
     is_goitem-lifnr IS INITIAL AND
     is_goitem-reswk IS INITIAL.
    EXIT.
  ENDIF.
* Who is the supplier?
  ls_itemdata-llief       = is_goitem-llief.    "Supplying vendor
  IF is_goitem-reswk IS INITIAL.
    ls_itemdata-lifnr     = is_goitem-lifnr.    "Normal vendor
  ELSE.
    ls_itemdata-umwrk     = is_goitem-reswk.    "Stock transfer PO
  ENDIF.
*
  IF is_goitem-xpoitem = abap_true.
    ls_itemdata-kzbew     = b.
  ENDIF.

* end of mapping ------------------------------------------------------*

  IF NOT is_goitem-xpoitem = abap_true.
    CLEAR: e_process.
    EXIT.
  ELSE.
    CALL FUNCTION 'IMPORT_DETERMINE'
         EXPORTING
              i_ahbas                = '1WE'
              i_mode                 =  h     "only in creation mode
*             I_FT_TRANSACT          = ' '
*             I_T001                 =
*             I_LFA1                 =
*             I_EKKO                 =
*             I_T160                 =
              i_s_mseg               = ls_itemdata
         IMPORTING
*             XEGIMP                 =
*             IMPORT                 =
*             EGIMP                  =
              e_import_process       = l_import_process    "X/SPACE
              e_data_determine       = l_copy_from_po      "A=copy/SPACE
         EXCEPTIONS
*             NO_WORKING_AREA        = 1
*             NO_IMPORT_ALLOWED      = 2
*             DIFFERENT_ORG_ENTITIES = 3
*             NO_IMPORT_COUNTRY      = 4
*             NO_EXPORT_COUNTRY      = 5
              OTHERS                 = 6
              .
    IF sy-subrc <> 0.
      CLEAR: e_process.
      EXIT.
    ENDIF.
    e_process = l_import_process.
  ENDIF.
* Import is needed?
  CHECK e_process = abap_true.
* Process header data if not already done...
  IF ps_gohead-exnum IS INITIAL.
*   Initialization
    CALL FUNCTION 'EXPIMP_TABLES_REFRESH'.
* Get a new gohead-exnum
* not for display of material document and not for delivery
    IF l_copy_from_po    EQ abap_true AND
       is_goitem-xpoitem EQ abap_true AND
       s_control-refdoc  <> 'R02'     AND     "matdoc
       s_control-refdoc  <> 'R03'.            "deliv.note
*     Copy header data from PO and get a new gohead-exnum
      CALL FUNCTION 'EXPIMP_GENERAL_DATA_COPY'
           EXPORTING
                i_ahbas        = '1WE'
                exnum_o        = ps_pohead-exnum
           IMPORTING
                exnum_n        = ps_gohead-exnum
           EXCEPTIONS
*             NO_EXPORT_DATA = 1
                OTHERS         = 2
                .
      IF sy-subrc <> 0.
        sy-subrc = sy-subrc.
      ENDIF.
*   no copy from po => data proposed from master data
    ELSEIF l_copy_from_po    EQ abap_false AND
           is_goitem-xpoitem EQ abap_true  AND
           s_control-refdoc  <> 'R02'      AND    "matdoc
           s_control-refdoc  <> 'R03'.            "deliv.note
      CALL FUNCTION 'IMPORT_GENERAL_DATA_PROPOSE'
           EXPORTING
                exnum         = ps_gohead-exnum
                hland         = ps_gohead-land1
                i_expvz       = ' '
                i_zolla       = '      '
                i_ausfu       = is_goitem-lifnr
                i_ausfu_werks = is_goitem-reswk
*               I_LFA1        = ' '
*               I_EKKO        = ' '
*               I_IMPLAND     = '  '
                i_ft_basis    = '1WE'
           IMPORTING
*               COMPLETE      =
                nexnum        = ps_gohead-exnum .

    ENDIF.
  ENDIF.
* Copy item data from PO if necessary
  IF is_goitem-xpoitem EQ abap_true AND
     l_copy_from_po    EQ abap_true AND
     s_control-refdoc  <> 'R02' AND     "matdoc
     s_control-refdoc  <> 'R03'.        "deliv.note
    CALL METHOD ftrade_copy_from_po
                EXPORTING is_goitem = is_goitem.
  ELSEIF l_copy_from_po    EQ abap_false AND
         is_goitem-xpoitem EQ abap_true  AND
         s_control-refdoc  <> 'R02'      AND    "matdoc
         s_control-refdoc  <> 'R03'.            "deliv.note
*  Fetch plant data
    CALL METHOD
    lcl_migo_buffer=>plant_get EXPORTING i_plant   = is_goitem-werks
                               RECEIVING e_goplant = ls_goplant.
    MOVE-CORRESPONDING: ls_goplant TO ls_t001w.

*  Fetch material data
    CLEAR: ls_marc,
           ls_mtcom.
    ls_mtcom-kenng = 'MARC'.
    ls_mtcom-matnr = is_goitem-matnr.
    ls_mtcom-werks = is_goitem-werks.
    ls_mtcom-spras = sy-langu.

    CALL FUNCTION 'MATERIAL_READ'
         EXPORTING
              schluessel           = ls_mtcom
         IMPORTING
              matdaten             = ls_marc
         EXCEPTIONS
              OTHERS               = 1.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.

*------- Default of Import data
    CALL FUNCTION 'IMPORT_ITEM_DATA_PROPOSE'
         EXPORTING
              exnum      = ps_gohead-exnum
              expos      = is_goitem-global_counter       "#EC DOM_EQUAL
              hland      = ps_gohead-land1
*             I_EXART    = ' '
*             I_EXPRF    = ' '
              i_herkl    = ls_marc-herkl
              i_herkr    = ls_marc-herkr
              i_stawn    = ls_marc-stawn
              i_t001w    = ls_t001w
*             I_EINA     = ' '
*             I_EINE     = ' '
*             I_EKPO     = ' '
*             I_EKKO     = ' '
              i_ft_basis = '1WE' .
*         IMPORTING
*             COMPLETE   =
*             NEXNUM     =
*             E_DATALOSS =

  ENDIF.

ENDMETHOD.                             "FTRADE_DETERMINE_ITEM

*----------------------------------------------------------------------*
* METHOD FTRADE_COPY_FROM_PO
*----------------------------------------------------------------------*
* Copies the foreign trade data from the purchase order EXNUM to the
* new material document EXNUM. The header data has already been copied
* in FTRADE_DETERMINE_ITEM.
* The item data is copied in the foreign trade function group memory.
*----------------------------------------------------------------------*
METHOD ftrade_copy_from_po.
  DATA: l_exist TYPE abap_bool,
        l_expos TYPE expos.            "convert ebelp in NUMC 6

  CALL FUNCTION 'EXPIMP_ITEM_DATA_READ'
       EXPORTING
          exnum              = ps_gohead-exnum
          expos              = is_goitem-global_counter "#EC DOM_EQUAL
       IMPORTING
*           IMPK               =
*           IMPP               =
*           E_HEADER_EXISTS    =
          e_line_item_exists = l_exist
            .
* No data maintained manually. Copy from PO still possible
  IF l_exist = abap_false.
    l_expos = is_goitem-ebelp.
    CALL FUNCTION 'EXPIMP_ITEM_DATA_COPY'
         EXPORTING
              i_ahbas         = '1WE'
              exnum_n         = ps_gohead-exnum
              exnum_o         = ps_pohead-exnum
             expos_n         = is_goitem-global_counter "#EC DOM_EQUAL
              expos_o         = l_expos"ebelp
         EXCEPTIONS
*             NO_EXPORT_DATA         = 1
*             NO_ITEM_IDENTIFICATION = 2
              OTHERS                 = 3
              .
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDIF.
ENDMETHOD.                             "FTRADE_COPY_FROM_PO
*----------------------------------------------------------------------*
* METHOD FTRADE_ITEM_REFRESH
*----------------------------------------------------------------------*
* If old_goitem has import and new_goitem has no import, refresh
* necessary.
* IMPORTING i_exnum
*           i_global_counter
*           i_home_country
*----------------------------------------------------------------------*
METHOD ftrade_item_refresh.

  CALL FUNCTION 'EXPIMP_ITEM_DATA_MAINTAIN'
       EXPORTING
*           ARKTX                     = ' '
*           CHARGE                    = ' '
            exnum                     = i_exnum
            expos                     = i_global_counter "#EC DOM_EQUAL
            hland                     = i_home_country
*           MATNR                     = ' '
            trtyp                     = d     "Delete
*           I_MFRNR                   = ' '
            i_ft_basis                = '1WE'
*           I_INTERNET                =
*           I_STAT_COMPLETE_MANDATORY = ' '
*      IMPORTING
*           COMPLETE                  =
*           NEXNUM                    =
*           P_FLAG                    =
*           E_DATALOSS                =
*           E_FCODE                   =
       EXCEPTIONS
*           NO_EXPORT_DATA            = 1
            OTHERS                    = 2
            .
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMETHOD.                             "FTRADE_ITEM_REFRESH
*----------------------------------------------------------------------*
* METHOD FTRADE_REFRESH_ALL
*----------------------------------------------------------------------*
* If no item has import, it is necessary to refresh header data
* IMPORTING i_exnum          TYPE gohead-exnum
*           i_home_country   TYPE gohead-land1,
*----------------------------------------------------------------------*
METHOD ftrade_refresh_all.

  CALL FUNCTION 'EXPIMP_GENERAL_DATA_MAINTAIN'
       EXPORTING
            exnum                     = i_exnum
            hland                     = i_home_country
*           LAND                      = ' '
*           NAME1                     = ' '
*           PARTNER                   = ' '
            trtyp                     = d      "delete
*           I_AUSFU                   = ' '
*           I_AUSFU_WERKS             = ' '
            i_ft_basis                = '1WE'
*           I_INTERNET                =
*           I_STAT_COMPLETE_MANDATORY = ' '
*      IMPORTING
*           COMPLETE                  =
*           K_FLAG                    =
*           NEXNUM                    =
*           E_DATALOSS                =
*           E_FCODE                   =
*      TABLES
*           I_T_XVBRP                 =
       EXCEPTIONS
*           NO_EXPORT_DATA            = 1
            OTHERS                    = 2
            .
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMETHOD.                             "FTRADE_REFRESH_ALL