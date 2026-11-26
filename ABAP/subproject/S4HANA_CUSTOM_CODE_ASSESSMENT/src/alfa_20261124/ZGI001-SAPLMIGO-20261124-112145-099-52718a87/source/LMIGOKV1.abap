*&---------------------------------------------------------------------*
*&  Include           LMIGOKV1                                         *
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* METHOD VALUATION_TYPE_SET                                            *
*----------------------------------------------------------------------*
* Determination of UMBAR proposal according to the following sequence  *
* (high to low priority)                                               *
*  1. valuation type from batch                                        *
*  2. valuation type is batch in case of individual batch valuation    *
*  3. valuation type from material if unique                           *
*----------------------------------------------------------------------*
METHOD valuation_type_set.

  DATA: lt_xbwtar      TYPE STANDARD TABLE OF bwtar,
        ls_xbwtar      TYPE bwtar,
        ls_mtcom       TYPE mtcom,
        l_lines        TYPE sy-tabix,
        ls_mcha_buffer TYPE mcha.

* 1. Valuation type from batch if batch exists already and valuation
*    type is already fixed in batch
  IF NOT i_charg IS INITIAL.
    CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
      EXPORTING
        matnr            = i_matnr
        charg            = i_charg
        werks            = i_werks
        lgort            = i_lgort
        read_from_buffer = x
        read_from_db     = x
      IMPORTING
        batch_buffer     = ls_mcha_buffer
      EXCEPTIONS
        no_material      = 01
        no_batch         = 02
        no_plant         = 03.
    IF sy-subrc = 0.
      e_bwtar = ls_mcha_buffer-bwtar.
    ELSE.
      CLEAR e_bwtar.
    ENDIF.
  ENDIF.
* 2. Individual batch valuation -> valuation type = batch
  IF e_bwtar IS INITIAL AND i_kzbaa = x.
    e_bwtar = i_charg.
  ENDIF.
* 3. IF valuation type is still not filled, use valuation type of the
*    material if unique.
  IF e_bwtar IS INITIAL AND i_kzbaa IS INITIAL.
    ls_mtcom-kenng = 'BWTAR'.
    ls_mtcom-matnr = i_matnr.
    ls_mtcom-werks = i_werks.
    ls_mtcom-sobkz = i_sobkz.
    ls_mtcom-vbeln = i_mat_kdauf.
    ls_mtcom-posnr = i_mat_kdpos.
    ls_mtcom-pspnr = i_mat_pspnr.
    ls_mtcom-kzrfb = x.
    IF i_sobkz CA 'EQT'.                               "SIT: T
*     a) Is there an entry in EBEW/QBEW?
      ls_mtcom-kzbws = 'M'.
      CALL FUNCTION 'MATERIAL_READ'
        EXPORTING
          schluessel    = ls_mtcom
        TABLES
          seqmat01      = lt_xbwtar
        EXCEPTIONS
          error_message = 01
          OTHERS        = 02.
      IF sy-subrc <> 0.
        REFRESH lt_xbwtar.
      ENDIF.
    ENDIF.
*   b) SOBKZ is not E/Q or there was no entry in EBEW/QBEW (this means
*      that KZBWS is 'A' or not valuated). Now we have to search for
*      an entry in MBEW.
    IF lt_xbwtar IS INITIAL.
      CLEAR ls_mtcom-kzbws.
      CALL FUNCTION 'MATERIAL_READ'
        EXPORTING
          schluessel    = ls_mtcom
        TABLES
          seqmat01      = lt_xbwtar
        EXCEPTIONS
          error_message = 01
          OTHERS        = 02.
      IF sy-subrc <> 0.
        REFRESH lt_xbwtar.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE lt_xbwtar LINES l_lines.
    IF l_lines = 1.
      READ TABLE lt_xbwtar INTO ls_xbwtar INDEX 1.
      e_bwtar = ls_xbwtar-bwtar.
    ENDIF.
  ENDIF.

ENDMETHOD.