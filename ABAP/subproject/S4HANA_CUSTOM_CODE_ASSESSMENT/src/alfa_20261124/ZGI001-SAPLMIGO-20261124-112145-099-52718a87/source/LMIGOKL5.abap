*&---------------------------------------------------------------------*
*&  Include           LMIGOKL5                                         *
*&---------------------------------------------------------------------*
METHOD line_check_transfer.

  DATA: ls_change_batch      TYPE ty_s_change_batch,
        ls_batch_dark TYPE ty_s_batch_dark.


* Fill UM-fields (Special stock IDs, plant, material, storage loc.,
* batch and valuation type)
  CALL METHOD um_fields_fill
    CHANGING
      cs_goitem     = cs_goitem.
ENHANCEMENT-POINT LINE_CHECK_TRANSFER_01 SPOTS ES_SAPLMIGO STATIC.

ENHANCEMENT-POINT LINE_CHECK_TRANSFER_02 SPOTS ES_SAPLMIGO.

* XUMDETERMINATION______________________________________________________
* Set flag XUMDETERMINATION (flag for determination in case of a
* transfer)
  cs_goitem-xumdetermination = abap_false.
* For batch managed materials, if either UMLGO or UMCHA not filled yet.
* Exception: Stock types which do not have a storage location.
  IF cs_goitem-umxchpf = abap_true AND
     (
       cs_goitem-umcha IS INITIAL OR
       (
         cs_goitem-umlgo IS INITIAL AND
         cs_goitem-umsok NA 'OVW'
       )
     ).
    cs_goitem-xumdetermination = abap_true.
  ENDIF.
* For split valuated materials, if either UMLGO or UMBAR not filled yet.
* Exception: Stock types which do not have a storage location.
  IF NOT cs_goitem-umbwtty IS INITIAL AND
     (
       cs_goitem-umbar IS INITIAL OR
       (
         cs_goitem-umlgo IS INITIAL AND
         cs_goitem-umsok NA 'OVW'
       )
     ).
    cs_goitem-xumdetermination = abap_true.
  ENDIF.
* For other materials, if UMLGO not filled
  IF cs_goitem-umxchpf = abap_false AND cs_goitem-umbwtty IS INITIAL AND
     (
       cs_goitem-umlgo IS INITIAL AND
       cs_goitem-umsok NA 'OVW'
     ).
    cs_goitem-xumdetermination = abap_true.
  ENDIF.
* Need plant, material, not for headers of BOMs,...
  IF     cs_goitem-umwrk IS INITIAL   OR
         cs_goitem-xbomtype = p       OR
         cs_goitem-ummat IS INITIAL   OR
    cs_goitem-xumdetermination = abap_false.
  ENDIF.

* Product quantity unit_________________________________________________
* Check if material is product quantity managed and the batch is new.
* Only if the batch is new, the field UMXPARALLEL/XPARALLEL will be set
* to ABAP_TRUE and the fieldselection for MENGE to 'input'.
  CLEAR cs_goitem-umxparallel.
  IF cs_goitem-umkzwsm = b.            "temp sw
    CALL METHOD get_xparallel
      EXPORTING
        i_matnr     = cs_goitem-ummat
        i_werks     = cs_goitem-umwrk
        i_charg     = cs_goitem-umcha
        i_kzcla     = cs_goitem-kzcla
      IMPORTING
        e_xparallel = cs_goitem-umxparallel.
  ENDIF.

* Unit conversion for MENGE was done in method LINE_CHECK. This was
* wrong, if the the receiving material is 'product quantity managed'
* and it's a new batch (-> UMXPARALLEL = 'X'). Then we have to take
* MENGE as it was entered on the screen (-> from structure
* ls_unit_conversion).
  IF cs_goitem-shkzg = h AND cs_goitem-umxparallel = abap_true AND
     NOT is_unit_conversion-menge IS INITIAL.
    cs_goitem-menge = is_unit_conversion-menge.
    cs_goitem-umren = is_unit_conversion-umren.
    cs_goitem-umrez = is_unit_conversion-umrez.
  ENDIF.
* If the receiving material is 'product quantity managed' and the batch
* already exists, a unit conversion is necessary to display the correct
* value for MENGE
  IF cs_goitem-shkzg = h AND cs_goitem-umkzwsm = b AND
     cs_goitem-umxparallel = abap_false.
    CALL METHOD unit_conversion
          EXPORTING
            i_transfer = abap_true
          CHANGING
            cs_goitem  = cs_goitem.
  ENDIF.
* To maintain field MENGE (for product quantity managed materials) is
* only possible for the receiving side. It's not supported in case of
* issuing and receiving material are both 'product quantity managed
* materials'.
  IF cs_goitem-shkzg = s and cs_goitem-xparallel = abap_true AND
                             cs_goitem-umkzwsm <> b.
    IF NOT ( is_old_goitem-charg IS INITIAL AND
             is_old_goitem-menge EQ cs_goitem-menge AND
             is_old_goitem-erfmg EQ cs_goitem-erfmg AND
             is_old_goitem-erfme EQ cs_goitem-erfme ).
      CALL METHOD send_quantity_to_class
        EXPORTING
          is_goitem        = cs_goitem
        IMPORTING
          es_batch_dark    = ls_batch_dark.
      move-corresponding ls_batch_dark to cs_goitem.
      ls_change_batch-charg = cs_goitem-charg.
      ls_change_batch-matnr = cs_goitem-matnr.
      ls_change_batch-werks = cs_goitem-werks.
      CALL METHOD change_quantity_later
        EXPORTING
          is_change_batch = ls_change_batch.
    ENDIF.
  ENDIF.
  IF cs_goitem-shkzg = h AND cs_goitem-umxparallel = abap_true AND
                             cs_goitem-kzwsm <> b.
    IF NOT ( is_old_goitem-umcha IS INITIAL AND
             is_old_goitem-menge EQ cs_goitem-menge AND
             is_old_goitem-erfmg EQ cs_goitem-erfmg AND
             is_old_goitem-erfme EQ cs_goitem-erfme ).
      CALL METHOD send_quantity_to_class
        EXPORTING
          is_goitem        = cs_goitem
        IMPORTING
          es_batch_dark    = ls_batch_dark.
      move ls_batch_dark-charg to cs_goitem-umcha.
      move ls_batch_dark-bwtar to cs_goitem-umbar.
      move ls_batch_dark-hsdat to cs_goitem-umhsdat.
      move ls_batch_dark-vfdat to cs_goitem-umvfdat.
      move ls_batch_dark-zustd to cs_goitem-umzst.

      ls_change_batch-charg = cs_goitem-umcha.
      ls_change_batch-matnr = cs_goitem-ummat.
      ls_change_batch-werks = cs_goitem-umwrk.
      CALL METHOD change_quantity_later
        EXPORTING
          is_change_batch = ls_change_batch.
    ENDIF.
  ENDIF.
ENDMETHOD.