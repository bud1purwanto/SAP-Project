*&---------------------------------------------------------------------*
*&  Include           LMIGODA3
*   Detail tabstrip MAA-DEV
*&---------------------------------------------------------------------*
CLASS lcl_migo_detail_maa DEFINITION
      INHERITING FROM lcl_migo_detailobject.

  PUBLIC SECTION.

    METHODS:
      pbo REDEFINITION,
      pai REDEFINITION,
      reset_acc,
      po_data_get
            IMPORTING
               i_ebeln  TYPE ebeln
               i_ebelp  TYPE ebelp
               i_lfbnr  TYPE lfbnr
               i_lfbja  TYPE lfbja
               i_lfpos  TYPE lfpos
               i_acctb  TYPE accounting_t
               i_poitem TYPE ebefu_t,

      get_xaccounting                                       "MAA2
        EXPORTING                                           "MAA2
           et_xaccounting    TYPE  accounting_t,            "MAA2

      maa_disp_acc
          CHANGING
               cs_goitem    TYPE goitem.

  PRIVATE SECTION.
    METHODS:
      maa_send.

    CLASS-DATA:
      pt_accounting   TYPE accounting_t,
      pt_poitem       TYPE ebefu_t.

ENDCLASS.                    "lcl_migo_detail_maa  DEFINITIO