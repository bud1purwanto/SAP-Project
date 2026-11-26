*&---------------------------------------------------------------------*
*&  Include           PARCHI02
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bild_2 WITH FRAME TITLE text-res.
SELECT-OPTIONS:  werks    FOR  caufv-werks,
                 dispo    FOR  caufv-dispo,
                 fevor    FOR  caufv-fevor.
PARAMETERS       selid    TYPE tj48-selid.
SELECT-OPTIONS:  gstrp    FOR  caufv-gstrp,
                 ltrmi    FOR  afpo-ltrmi.
PARAMETERS       interval TYPE coarch-gltint DEFAULT 90.
SELECTION-SCREEN COMMENT  40(8) text-day.
ENHANCEMENT-POINT PARCHI02_01 SPOTS ES_PARCHI02 STATIC INCLUDE BOUND .
SELECTION-SCREEN SKIP 1.
PARAMETERS       maxnum   TYPE coarch-ordnum DEFAULT 99999.
SELECTION-SCREEN END   OF BLOCK bild_2.
ENHANCEMENT-POINT PARCHI02_02 SPOTS ES_PARCHI02 STATIC INCLUDE BOUND .

* block actions
SELECTION-SCREEN BEGIN OF BLOCK action WITH FRAME TITLE  text-act.
PARAMETERS:      set_loev TYPE rc27x-flg_sel DEFAULT 'X',
                 set_loek TYPE rc27x-flg_sel.
SELECTION-SCREEN END OF BLOCK action.

INCLUDE arch_preproc_prg_standard2.