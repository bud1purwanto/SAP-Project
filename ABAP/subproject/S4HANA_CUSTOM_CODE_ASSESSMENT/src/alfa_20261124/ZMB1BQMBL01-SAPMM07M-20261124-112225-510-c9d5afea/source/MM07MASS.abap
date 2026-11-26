*&---------------------------------------------------------------------*
*&  Include           MM07MASS
*&---------------------------------------------------------------------*


*---------------------------------------------------------------------*
*       CLASS lcl_sapmm07m_assertions DEFINITION
*---------------------------------------------------------------------*
*       class for handling assertions of internal tables
*       intention: enable recording in background/ update task,
*       especially for monitoring interfaces when MB_CREATE is
*       called in update task
*---------------------------------------------------------------------*
CLASS lcl_sapmm07m_assertions DEFINITION.

  PUBLIC SECTION.
    DATA: debug_auth TYPE xfeld.

    METHODS:
      constructor,
      as_me_read_item_goods_receipt
        IMPORTING
*         this is how ME_READ_ITEM... was called
          i_ebeln     TYPE ebeln
          i_werks     TYPE werks_d
          i_lfbnr     TYPE lfbnr
          i_lfbja     TYPE lfbja
          i_lfpos     TYPE lfpos
          i_shkzg     TYPE shkzg
*         and we want to trace the results
          i_ebefu     LIKE xebefu[]
          i_ebefu_cr  LIKE xebefu_cr[]
          i_ekbnk     LIKE xekbnk[]
          i_ekbnk_cr  LIKE xekbnk_cr[],
      as_co_sf_item_goods_receipt
        IMPORTING
          i_aufnr     TYPE afko-aufnr
          i_aufps     TYPE afpo-posnr
          i_fbefu     LIKE xfbefu[].


  PRIVATE SECTION.
    TYPES: pty_ebefu TYPE STANDARD TABLE OF ebefu.

ENDCLASS.                    "lcl_sapmm07m_assertions DEFINITION


*---------------------------------------------------------------------*
*       CLASS lcl_sapmm07m_assertions IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_sapmm07m_assertions IMPLEMENTATION.

  METHOD constructor.
*   Check that the current user has debug authorization, otherwise keep
*   away from assertions in loops (performance)
    AUTHORITY-CHECK OBJECT 'S_DEVELOP'
      ID 'DEVCLASS' DUMMY
      ID 'OBJTYPE'  FIELD 'DEBUG'
      ID 'OBJNAME'  DUMMY
      ID 'P_GROUP'  DUMMY
      ID 'ACTVT'    FIELD '03'.
    IF sy-subrc = 0.
      debug_auth = 'X'.
    ENDIF.
  ENDMETHOD.                    "constructor


*----------------------------------------------------------------------*
* Trace result of ME_READ_ITEM_GOODS_RECEIPT, only recommended for
* background (IDOC) processing
*----------------------------------------------------------------------*
  METHOD as_me_read_item_goods_receipt.

    FIELD-SYMBOLS: <lf_ebefu> TYPE ebefu,
                   <lf_ebefu_cr> TYPE ebefu_cr,
                   <lf_ekbnk> TYPE ekbnk,
                   <lf_ekbnk_cr> TYPE ekbnk_cr.
*   key to distinguish entries in SAAB
    DATA: l_subkey(200) TYPE c.

    LOOP AT xebefu ASSIGNING <lf_ebefu>.
*     EBELP is not always used for calling the function module, but it
*     is required to avoid that the ASSERT overwrites the entries;
*     therefore, EBELP from the result is used for the subkey.
      CONCATENATE i_ebeln <lf_ebefu>-ebelp i_werks
                  i_lfbnr i_lfbja i_lfpos i_shkzg
             INTO l_subkey
        SEPARATED BY '_'.
      ASSERT ID   mb_me_read_item_goods_receipt
           SUBKEY l_subkey
           FIELDS <lf_ebefu>
        CONDITION 1 = 2.

*     currency information for this PO item
      LOOP AT xebefu_cr ASSIGNING <lf_ebefu_cr>
                            WHERE ebeln = <lf_ebefu>-ebeln
                              AND ebelp = <lf_ebefu>-ebelp.
        CONCATENATE i_ebeln <lf_ebefu>-ebelp i_werks
                    i_lfbnr i_lfbja i_lfpos i_shkzg
                    <lf_ebefu_cr>-curtp
               INTO l_subkey
          SEPARATED BY '_'.
        ASSERT ID   mb_me_read_item_goods_receipt
             SUBKEY l_subkey
             FIELDS <lf_ebefu>
          CONDITION 1 = 2.
      ENDLOOP.

*     delivery costs for this item
      LOOP AT xekbnk ASSIGNING <lf_ekbnk>
                         WHERE ebeln = <lf_ebefu>-ebeln
                           AND ebelp = <lf_ebefu>-ebelp.
        CONCATENATE i_ebeln <lf_ebefu>-ebelp i_werks
                    i_lfbnr i_lfbja i_lfpos i_shkzg
                    <lf_ekbnk>-stunr <lf_ekbnk>-zaehk
               INTO l_subkey
          SEPARATED BY '_'.
        ASSERT ID   mb_me_read_item_goods_receipt
             SUBKEY l_subkey
             FIELDS <lf_ekbnk>
          CONDITION 1 = 2.

*       currency information fo delivery costs
        LOOP AT xekbnk_cr ASSIGNING <lf_ekbnk_cr>
                              WHERE ebeln = <lf_ekbnk>-ebeln
                                AND ebelp = <lf_ekbnk>-ebelp
                                AND stunr = <lf_ekbnk>-stunr
                                AND zaehk = <lf_ekbnk>-zaehk.
          CONCATENATE i_ebeln <lf_ebefu>-ebelp i_werks
                      i_lfbnr i_lfbja i_lfpos i_shkzg
                      <lf_ekbnk>-stunr <lf_ekbnk>-zaehk
                      <lf_ekbnk_cr>-curtp
                 INTO l_subkey
            SEPARATED BY '_'.
          ASSERT ID   mb_me_read_item_goods_receipt
               SUBKEY l_subkey
               FIELDS <lf_ekbnk_cr>
            CONDITION 1 = 2.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.                    "assert_me_read_item_goods_receipt


*----------------------------------------------------------------------*
* Trace result of CO_SF_ITEM_GOODS_RECEIPT, especially for background
* processing or when MB_CREATE is called in update task
*----------------------------------------------------------------------*
  METHOD as_co_sf_item_goods_receipt.

    FIELD-SYMBOLS: <lf_fbefu> TYPE fbefu.
*   key to distinguish entries in SAAB
    DATA: l_subkey(200) TYPE c.

    LOOP AT i_fbefu ASSIGNING <lf_fbefu>.
      CONCATENATE i_aufnr i_aufps <lf_fbefu>-posnr
             INTO l_subkey
        SEPARATED BY '_'.
      ASSERT ID   mb_co_sf_item_goods_receipt
           SUBKEY l_subkey
           FIELDS <lf_fbefu>
        CONDITION 1 = 2.
    ENDLOOP.

  ENDMETHOD.                    "as_co_sf_item_goods_receipt

ENDCLASS.                    "lcl_sapmm07m_assertions IMPLEMENTATION