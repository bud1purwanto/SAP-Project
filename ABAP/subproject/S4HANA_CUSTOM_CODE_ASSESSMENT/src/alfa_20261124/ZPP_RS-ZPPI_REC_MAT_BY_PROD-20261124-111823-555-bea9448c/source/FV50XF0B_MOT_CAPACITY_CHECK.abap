*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_MOT_CAPACITY_CHECK                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MOT_CAPACITY_CHECK
*&---------------------------------------------------------------------*
*       Checks whether wheight and volume of the delivery exceeds the
*       maximum capacity of the assigned means of transport. In case of
*       overcapacity a warning is written to the message log. The
*       delivery may then be splitted before assigning it to a
*       transport.
*       This capacity check is preliminary solution until a delivery
*       split according to capacity is possible.
*----------------------------------------------------------------------*
FORM mot_capacity_check USING ls_xlikp TYPE likpvb.

  DATA: lf_matnr_txt LIKE sy-msgv1,
        lf_subrc     LIKE sy-subrc.

* Is there anything to check?
  CHECK NOT ls_xlikp-trmtyp IS INITIAL.
  CHECK NOT ( ls_xlikp-btgew IS INITIAL AND
              ls_xlikp-ntgew IS INITIAL AND
              ls_xlikp-volum IS INITIAL ).

  CALL FUNCTION 'SD_SHIPMENT_MOT_TYPE_CAPCHECK'
    EXPORTING
      i_btgew              = ls_xlikp-btgew
      i_ntgew              = ls_xlikp-ntgew
      i_gewei              = ls_xlikp-gewei
      i_volum              = ls_xlikp-volum
      i_voleh              = ls_xlikp-voleh
      i_trmtyp             = ls_xlikp-trmtyp
    EXCEPTIONS
      input_missing        = 1
      over_capacity_weight = 2
      over_capacity_volume = 3
      OTHERS               = 4.
  IF sy-subrc NE 0.
    lf_subrc = sy-subrc.
    write ls_xlikp-trmtyp to lf_matnr_txt.
    CASE lf_subrc.
      WHEN 1.
      WHEN 2.
        PERFORM message_handling IN PROGRAM sapmv50a
                                 USING posnr_low
                                       '288'
                                       'W'
                                       'VL'
                                       lf_matnr_txt
                                       space
                                       space
                                       space.
      WHEN 3.
        PERFORM message_handling IN PROGRAM sapmv50a
                                 USING posnr_low
                                       '289'
                                       'W'
                                       'VL'
                                       lf_matnr_txt
                                       space
                                       space
                                       space.
      WHEN 4.
    ENDCASE.
  ENDIF.

ENDFORM.                               " MOT_CAPACITY_CHECK