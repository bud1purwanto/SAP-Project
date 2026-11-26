*----------------------------------------------------------------------*
*   INCLUDE LMIGOKN2                                                   *
*   Insert a new position from WUEB
*----------------------------------------------------------------------*

METHOD new_position_from_wueb.
  DATA: ls_goitem TYPE goitem.
  DATA: lt_goserial        TYPE ty_t_goserial,                   "458004
        ls_goserial_kernel TYPE ty_s_goserial_kernel.            "458004

* Copy data
  MOVE-CORRESPONDING is_wueb TO ls_goitem.
  ls_goitem-posnr = is_wueb-vbelp.
* If called via shipping unit, some data from there have right of way.
  IF NOT is_vepwe IS INITIAL.
    ls_goitem-erfmg = ls_goitem-lsmng = is_vepwe-vemng.
    ls_goitem-erfme = ls_goitem-lsmeh = is_vepwe-vemeh.
    ls_goitem-lgort =                   is_vepwe-lgort.
  ENDIF.
* Merge default values
  CALL METHOD defaults_merge CHANGING cs_goitem = ls_goitem.
* Set indicator for "position from delivery"
  IF i_delivery = abap_true.
    ls_goitem-xdelivitem = x.
  ENDIF.
* Insert the line to the model
  CALL METHOD line_modify
    EXPORTING
      i_line    = 0
    CHANGING
      cs_goitem = ls_goitem.
* Read serial number data                                        "458004
  IF NOT ls_goitem-sernp IS INITIAL.                             "458004
    CALL METHOD serialnumbers_read                               "458004
         EXPORTING is_goitem   = ls_goitem                       "458004
                   is_vepwe    = is_vepwe                        "731711
         IMPORTING et_goserial = lt_goserial.                    "458004
    ls_goserial_kernel-global_counter = ls_goitem-global_counter."458004
    ls_goserial_kernel-t_goserial     = lt_goserial.             "458004
    INSERT ls_goserial_kernel INTO TABLE pt_goserial_kernel.     "458004
  ENDIF.                                                         "458004

ENDMETHOD.