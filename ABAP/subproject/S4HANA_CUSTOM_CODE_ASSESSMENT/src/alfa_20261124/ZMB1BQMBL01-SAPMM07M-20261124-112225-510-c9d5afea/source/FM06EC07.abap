*eject
*--------------------------------------------------------------------*
*        COMMON DATA                                                 *
*--------------------------------------------------------------------*
*        Datenfelder fuer die Schnittstelle AG06/AG07                *
*--------------------------------------------------------------------*

TABLES:  KBEFU.

DATA: BEGIN OF COMMON PART FM06EC07.


DATA: BEGIN OF XEBEFU OCCURS 0.                             "0438401
        INCLUDE STRUCTURE EBEFU.
DATA: END OF XEBEFU.

DATA: XEBEFU_FLAG TYPE C.              " KZ, ob Refresh erfolgen soll

DATA: BEGIN OF XEBEFU_CR OCCURS 0.                          "0438401
        INCLUDE STRUCTURE EBEFU_CR.
DATA: END   OF XEBEFU_CR.

DATA: BEGIN OF XACCOUNTING OCCURS 0.
        INCLUDE STRUCTURE ACCOUNTING.
DATA: END   OF XACCOUNTING.

DATA: BEGIN OF XACCOUNTING_DC OCCURS 0.
        INCLUDE STRUCTURE ACCOUNTING.
DATA: END   OF XACCOUNTING_DC.

DATA: BEGIN OF XACCOUNTING_CR OCCURS 0.
        INCLUDE STRUCTURE ACCOUNTING_CR.
DATA: END   OF XACCOUNTING_CR.

DATA: BEGIN OF XACCOUNTING_DC_CR OCCURS 0.
        INCLUDE STRUCTURE ACCOUNTING_CR.
DATA: END   OF XACCOUNTING_DC_CR.

DATA: BEGIN OF XEBEFU_CR_KEY,
        EBELN  LIKE XEBEFU_CR-EBELN,
        EBELP  LIKE XEBEFU_CR-EBELP,
        LFBJA  LIKE XEBEFU_CR-LFBJA,
        LFBNR  LIKE XEBEFU_CR-LFBNR,
        LFPOS  LIKE XEBEFU_CR-LFPOS,
        CURTP  LIKE XEBEFU_CR-CURTP,
      END OF   XEBEFU_CR_KEY.

*- Tabelle der Bezugsnebenkosten ------------------------------------*
DATA: BEGIN OF XEKBNK_KEY,
        EBELN  LIKE EKBNK-EBELN,
        EBELP  LIKE EKBNK-EBELP,
        STUNR  LIKE EKBNK-STUNR,
        ZAEHK  LIKE EKBNK-ZAEHK,
      END OF   XEKBNK_KEY.

DATA: BEGIN OF XEKBNK_CR OCCURS 0.                          "0438401
        INCLUDE STRUCTURE EKBNK_CR.
DATA: END   OF XEKBNK_CR.

DATA: BEGIN OF XEKBNK_CR_KEY,
        EBELN  LIKE EKBNK_CR-EBELN,
        EBELP  LIKE EKBNK_CR-EBELP,
        STUNR  LIKE EKBNK_CR-STUNR,
        ZAEHK  LIKE EKBNK_CR-ZAEHK,
        CURTP  LIKE EKBNK_CR-CURTP,
      END OF   XEKBNK_CR_KEY.

DATA:    END OF COMMON PART.
data : go_mmim_maa_2 type ref to cl_mmim_maa_2,            "MAA2
       gv_flag_round type abap_bool.                       "MAA2