*----------------------------------------------------------------------*
*   INCLUDE LMIGOSR1                                                   *
*   Search functions (purchase orders, material documents, ...)
*----------------------------------------------------------------------*

CLASS lcl_migo_search DEFINITION INHERITING FROM lcl_migo_screenobject.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  TYPES:
*  Purchase orders
    BEGIN OF ty_s_purchase_order,
      ebeln TYPE ekko-ebeln,
      ebelp TYPE ekpo-ebelp,
      lifnr TYPE ekko-lifnr,
      name1 TYPE lfa1-name1,
      matnr TYPE ekpo-matnr,
      maktx TYPE ekpo-txz01,
      reswk TYPE ekko-reswk,
      namew TYPE t001w-name1,
      eindt TYPE eket-eindt,
      ernam TYPE ekko-ernam,
      menge TYPE ekpo-menge,
      meins TYPE ekpo-meins,
      wemng TYPE eket-wemng,
      idnlf TYPE ekpo-idnlf,
      ean11 TYPE ekpo-ean11,
      werks      TYPE ekpo-werks,                                "411519
      werks_name TYPE t001w-name1,                               "411519
      lgort      TYPE ekpo-lgort,                                "411519
      lgobe      TYPE t001l-lgobe,                               "411519
      matkl      TYPE ekpo-matkl,                                "411519
      wgbez      TYPE t023t-wgbez,                               "411519
      knttp      TYPE ekpo-knttp,                                "411519
      knttx      TYPE t163i-knttx,                               "411519
    END OF ty_s_purchase_order,
    ty_t_purchase_order TYPE STANDARD TABLE OF ty_s_purchase_order
                        WITH NON-UNIQUE KEY ebeln ebelp,
*   Material documents
*   Attention: This structure must be identical to the
*              one defined in report RM07DOCS!!!
    BEGIN OF ty_s_materialdocument,
        matnr TYPE mseg-matnr,
        maktx TYPE makt-maktx,
        werks TYPE mseg-werks,
        name1 TYPE t001w-name1,
        lgort TYPE mseg-lgort,
        charg TYPE mseg-charg,                                   "351455
        bwtar TYPE mseg-bwtar,                                   "351455
        bwart TYPE mseg-bwart,
        sobkz TYPE mseg-sobkz,
        btext TYPE t156t-btext,
        mblnr TYPE mseg-mblnr,
        mjahr TYPE mseg-mjahr,
        zeile TYPE mseg-zeile,
        budat TYPE mkpf-budat,
        erfmg TYPE mseg-erfmg,
        erfme TYPE mseg-erfme,
        lifnr TYPE mseg-lifnr,
        vgart TYPE mkpf-vgart,
    END OF ty_s_materialdocument,
    ty_t_materialdocument TYPE STANDARD TABLE OF ty_s_materialdocument
                          WITH NON-UNIQUE KEY mblnr mjahr zeile,
*   Production orders
    BEGIN OF ty_s_order,
      aufnr TYPE aufnr,
      posnr TYPE co_posnr,
      dglts TYPE afpo-dglts,
      gamng TYPE caufv-gamng,
      gmein TYPE caufv-gmein,
      wemng TYPE afpo-wemng,
      dwerk TYPE afpo-dwerk,
      sttxt TYPE caufvd-sttxt,
    END OF ty_s_order,
    ty_t_order TYPE STANDARD TABLE OF ty_s_order
               WITH NON-UNIQUE KEY aufnr posnr,
*   Reservations.
*   Attention: This structure must be identical to the one defined
*              in report RM07RESL.
    BEGIN OF ty_s_reservation,
      box TYPE xselp.
      INCLUDE TYPE:
        rkpf AS head RENAMING WITH SUFFIX _h,
        resb AS item RENAMING WITH SUFFIX _i.
      TYPES: rstyp TYPE rstyp,
      maktx TYPE makt-maktx,
      btext TYPE t156t-btext,
      accou TYPE res_account_d,
      color TYPE char3,
      diffmg TYPE difmg_res,
    END OF ty_s_reservation,
    ty_t_reservation TYPE STANDARD TABLE OF ty_s_reservation.

  METHODS:
    constructor,
    pbo REDEFINITION,
    pai REDEFINITION,
    pai_exit.

PRIVATE SECTION.
  METHODS:
    purchase_order_search_popup,
    purchase_order_search,
    materialdocument_search,
    order_search_popup,
    order_search,
    reservation_search_popup,
    reservation_search.



ENDCLASS.