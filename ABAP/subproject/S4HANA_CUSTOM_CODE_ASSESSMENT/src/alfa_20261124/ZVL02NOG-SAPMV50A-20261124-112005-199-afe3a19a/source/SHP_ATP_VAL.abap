*&---------------------------------------------------------------------*
*&  Include           SHP_ATP_VAL
*&---------------------------------------------------------------------*

 CONSTANTS BEGIN OF c_pg.
  CONSTANTS BEGIN OF char0.
   CONSTANTS o TYPE i VALUE 0.
   CONSTANTS l TYPE i VALUE 1.
  CONSTANTS END   OF char0.
  CONSTANTS BEGIN OF data0.
   CONSTANTS o TYPE i VALUE 1.
   CONSTANTS l TYPE i VALUE 21.
  CONSTANTS END   OF data0.
  CONSTANTS BEGIN OF apo_upd_no_req.
   CONSTANTS o TYPE i VALUE 1.
   CONSTANTS l TYPE i VALUE 1.
  CONSTANTS END   OF apo_upd_no_req.
 CONSTANTS END   OF c_pg.

 CONSTANTS c_omm_apo_upd_no_req LIKE bv03v-ommax VALUE -99.