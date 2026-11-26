* The following DATA Has to be included in all delivery
* programs which use the functions of LE_ATP_CHECK function group
DATA:   ls_shp_atp_item_control TYPE les_shp_atp_item_control,
        ls_shp_atp_item TYPE les_shp_atp_item,
        ls_shp_atp_item_old TYPE les_shp_atp_item,
        ls_shp_atp_citem TYPE les_shp_atp_item,
        ls_shp_atp_vbak TYPE les_shp_atp_vbak,
        ls_shp_atp_vbapf TYPE les_shp_atp_vbapf,
        ls_shp_atp_mat TYPE les_shp_atp_mat,
        lt_shp_atp_mat TYPE STANDARD TABLE OF les_shp_atp_mat INITIAL
        SIZE 1 WITH HEADER LINE,
        ls_shp_atp_check_outdata type LES_SHP_ATP_ITEM_OUTDATA,
        lt_shp_atp_ekpo type standard table of ekpo
        initial size 1 with header line,
        lt_shp_atp_eket type standard table of eket
        initial size 1 with header line.

DATA: lf_besta LIKE vbup-besta,
      lf_besta_old LIKE vbup-besta.
*eject