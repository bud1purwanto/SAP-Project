*&---------------------------------------------------------------------*
*&  Include           MSRDATA
*&---------------------------------------------------------------------*

DATA gv_next_plants_icon       TYPE char40.
DATA gv_vendor_address_icon    TYPE char40.
DATA gv_inspection_text_icon   TYPE char40.
DATA pb_cust_insp_text_icon    TYPE char40.
DATA gv_atp_icon_tl            TYPE char40.
DATA pb_atp_overview           TYPE char40.
DATA pb_atp_check              TYPE char40.
DATA gv_iconname_vendor        TYPE string.
DATA gv_iconname_nplant        TYPE string.
DATA gv_iconname_insp          TYPE string.
DATA gv_iconname_custinsp      TYPE string.
DATA gs_msr_sales_fastchange   TYPE msr_s_sales_fastchange.
DATA gs_item_default           TYPE msr_s_sd_item_defaults.
* Global table for MSR data related to items used by fastchange
DATA gt_msr_sales_fastchange   TYPE msr_t_sales_fastchange.