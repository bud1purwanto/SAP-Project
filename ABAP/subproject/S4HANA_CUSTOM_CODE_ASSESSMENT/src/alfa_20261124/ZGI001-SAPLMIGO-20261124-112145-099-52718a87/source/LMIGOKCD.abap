*&---------------------------------------------------------------------*
*&  Include           LMIGOKCD
*&  Process Cross Docking
*&---------------------------------------------------------------------*
METHOD purchase_order_fill_cd.
* Fill GOITEM-XCDTYPE = X in case of an item with cross docking
  DATA: l_trkey_gr    TYPE keytr VALUE '200',
        l_art_explode TYPE kzksn.

*Correction for Note: 1334789
*  IF NOT is_poitem-aurel IS INITIAL AND
*     ( ps_pohead-estak = 'E' OR ps_pohead-estak = 'S' ).
  IF NOT is_poitem-aurel IS INITIAL OR
     ( ps_pohead-estak = 'E' OR ps_pohead-estak = 'S' ).
*Correction end for Note: 1334789
    CHECK NOT cs_goitem IS INITIAL.
* not together with generic articles
    CHECK cs_goitem-xgatype IS INITIAL.
* not together with tied empties
    CHECK cs_goitem-xvgtype IS INITIAL.
* not together with SLS
    CHECK cs_goitem-xvastype IS INITIAL.
* not together with sub-items of a structured article, but possible
* together with the parent item
    CHECK cs_goitem-xsttype <> c.
*  check for BOM-explosion in GR
    IF NOT cs_goitem-xsttype IS INITIAL.
      CALL FUNCTION 'STRUC_ART_KEY_TODO'
        EXPORTING
          PI_MATNR           = is_poitem-matnr
          PI_WERKS           = is_poitem-werks
*         PI_LOCNR           =
          PI_ATTYP           = is_poitem-attyp
          PI_KEY             = l_trkey_gr
        IMPORTING
          PE_HEADFL          = l_art_explode
        EXCEPTIONS
          NO_TWZLA_FOUND     = 1
          OTHERS             = 99.
*   struct. art. not exploded in GR
      CHECK: sy-subrc <> 0 OR l_art_explode = 0.
    ENDIF.
    cs_goitem-xcdtype = x.
  ENDIF.
ENDMETHOD.                    "purchase_order_fill_cd


METHOD cd_lgort_distribution_get.
* Get the distribution frpm 'W_FRM_GR_ASSIGNMENT_SIMULATE'
* Split a CD-item of pt_goitem in 2 or more items taking the quantity
* and the storage location suggested by 'W_FRM_GR_ASSIGNMENT_SIMULATE'
* Clear flag XCDTYPE after 'W_FRM_GR_ASSIGNMENT_SIMULATE' was executed
  DATA: lt_cd_mseg      TYPE TABLE OF mseg,
        ls_cd_mseg      TYPE mseg,
        ls_goitem       TYPE goitem,
        l_current_tabix TYPE sytabix,
        l_lines         TYPE i,
        l_not_relevant  TYPE c.

  CHECK cs_goitem-take_it = abap_true.
  MOVE-CORRESPONDING cs_goitem TO ls_cd_mseg.
  APPEND ls_cd_mseg TO lt_cd_mseg.
  CALL FUNCTION 'W_FRM_GR_ASSIGNMENT_SIMULATE'
    EXPORTING
      no_relevance  = l_not_relevant
    TABLES
      t_mseg        = lt_cd_mseg
    EXCEPTIONS
      nothing_to_do = 1
      OTHERS        = 2.
  IF sy-subrc = 2.
    MESSAGE i418(w#) WITH ls_cd_mseg-matnr.
  ENDIF.
* Function 'W_FRM_GR_ASSIGNMENT_SIMULATE' must be executed once for each
* item with cross docking
  CLEAR cs_goitem-xcdtype.
* Extend pt_cd_mseg for export to cd_mseg_eingemischt
  READ TABLE lt_cd_mseg INTO ls_cd_mseg INDEX 1.
  APPEND ls_cd_mseg TO pt_cd_mseg.
* Modify
  DESCRIBE TABLE lt_cd_mseg LINES l_lines.
  CHECK l_lines > 1.
  READ TABLE lt_cd_mseg INTO ls_cd_mseg INDEX 1.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING ls_cd_mseg TO cs_goitem.
    READ TABLE pt_goitem
      WITH KEY global_counter = cs_goitem-global_counter
        TRANSPORTING NO FIELDS.
    l_current_tabix = sy-tabix.
    CALL METHOD line_modify
      EXPORTING
        i_tabix          = l_current_tabix
        i_status_delayed = abap_true
      CHANGING
        cs_goitem        = cs_goitem.
    DELETE lt_cd_mseg INDEX 1.
  ENDIF.

  CHECK NOT lt_cd_mseg IS INITIAL.
* Append
  DESCRIBE TABLE pt_goitem LINES l_current_tabix.
  LOOP AT lt_cd_mseg INTO ls_cd_mseg.
    l_current_tabix = l_current_tabix + 1.
    MOVE-CORRESPONDING cs_goitem TO ls_goitem.
    CLEAR: ls_goitem-global_counter, ls_goitem-xcdtype, ls_goitem-zeile.
    MOVE-CORRESPONDING ls_cd_mseg TO ls_goitem.
    CLEAR: ls_goitem-zeile.
    MESSAGE i070.
    CALL METHOD line_modify
      EXPORTING
        i_tabix          = l_current_tabix
        i_insert         = abap_true
        i_status_delayed = abap_true
      CHANGING
        cs_goitem        = ls_goitem.
*   Extend pt_cd_mseg for export to cd_mseg_eingemischt
    MOVE-CORRESPONDING ls_goitem TO ls_cd_mseg.
    APPEND ls_cd_mseg TO pt_cd_mseg.
  ENDLOOP.
  CALL METHOD status_derive.
ENDMETHOD.                    "cd_lgort_distribution_get


METHOD cd_lgort_distribution_check.
* Check all items with CD, if the user pushes "Post" without changing
* any item's quantity
  DATA: l_tabix  TYPE sytabix.
  FIELD-SYMBOLS <cd_goitem> TYPE goitem.
  LOOP AT pt_goitem ASSIGNING <cd_goitem>
    WHERE xcdtype = x
    AND   take_it = abap_true.
    CALL METHOD cd_lgort_distribution_get
      CHANGING
        cs_goitem = <cd_goitem>.
  ENDLOOP.
  SORT pt_cd_mseg BY zeile.
* IMPORT is done in MB_CREATE_GOODS_MOVEMENT, necessary for delta
* management
  EXPORT cd_mseg_eingemischt FROM pt_cd_mseg
    TO MEMORY ID 'CD_MSEG_EINGEMISCHT'.
ENDMETHOD.                    "cd_lgort_distribution_check