*----------------------------------------------------------------------*
*   INCLUDE LMIGOKU2                                                   *
*   include dealing with product units.                                *
*----------------------------------------------------------------------*

************************************************************************
*  send_quantity_to_class                                              *
************************************************************************
METHOD send_quantity_to_class.
*   send_quantity to classification buffer

* Local data
  DATA: ls_marm         TYPE marm,
        ls_change_batch TYPE ty_s_change_batch,
        l_line          TYPE sytabix,                    "455890
        ls_goitem       TYPE goitem,                     "455890
        l_factor        TYPE f.
  DATA: begin of ls_masterdata,
          matnr TYPE matnr,
          werks TYPE werks_d,
        end   of ls_masterdata.

* Avoid data loss and therefore preset the export
* structure
  MOVE-CORRESPONDING is_goitem TO es_batch_dark.

* only for goods receipt, never in cancel mode
  check s_action-cancel = abap_false.
  check is_goitem-shkzg = S.

* If the user has not entered a batch yet -> exit
* (no internal batch number allocation)
  CHECK NOT is_goitem-menge IS INITIAL.
  CHECK NOT is_goitem-erfmg IS INITIAL.
  CHECK NOT is_goitem-erfme IS INITIAL.

* Mapping for transfer fields
  IF s_action-migo_mode = 'GT' AND is_goitem-shkzg = h.
    ls_masterdata-matnr = is_goitem-ummat.
    ls_masterdata-werks = is_goitem-umwrk.
  ELSE.
    ls_masterdata-matnr = is_goitem-matnr.
    ls_masterdata-werks = is_goitem-werks.
  ENDIF.

* Get material master unit of measure data:
* atinn: which characteristic stores the conversion factor?
* msehi: which is the unit of measure in the characteristic?
  CALL FUNCTION 'MARM_SINGLE_READ'
       EXPORTING
            matnr      = ls_masterdata-matnr
            meinh      = is_goitem-erfme
       IMPORTING
            wmarm      = ls_marm
       EXCEPTIONS
            wrong_call = 1
            not_found  = 2
            OTHERS     = 3.

  IF sy-subrc <> 0.                                  "756079
    CALL FUNCTION 'VBWS_UNIT_CHECK_FOR_MATNR'
      EXPORTING
        I_MATNR                            = ls_masterdata-matnr
        I_MEINH                            = is_goitem-erfme
        WITH_UNITS_OF_SAME_DIMENSION       = abap_true
      EXCEPTIONS
        UNIT_NOT_FOUND                     = 1
        UNIT_NOT_ALLOWED                   = 2
        UNIT_NOT_ACTIVE                    = 3
        UNIT_NOT_CONSISTENT                = 4
        OTHERS                             = 5.
    IF SY-SUBRC <> 0.
*      ERFME is not a Product UoM
*      --> Factor can never be set
       MESSAGE S042(XU) WITH is_goitem-erfme.
*      Unit of measure & is not a product un. Qty stored is being
*      recalculated
    ELSE.
*      ERFME is of same dimension as a ProductUoM but not in MARM
*      Factor could be set - currently not implemented
       MESSAGE S060(XU).
    ENDIF.

  ENDIF.
  CHECK NOT ls_marm-atinn IS INITIAL.

* Create batch not too early
  ls_goitem = is_goitem.
  CALL METHOD unit_conversion CHANGING cs_goitem = ls_goitem.
* We have to avoid the creation of a batch at a too early stage
* while the uses has not entered a quantity yet
* After CHARG is filled we still need to call batch_maintain_dark
* to fill the export structure correctly
  IF ls_goitem-menge = is_goitem-menge AND
     is_goitem-charg IS INITIAL.
    RETURN.
  ENDIF.

* Calculate factor
  l_factor = is_goitem-menge / is_goitem-erfmg.

  CALL METHOD batch_maintain_dark
     EXPORTING is_goitem = is_goitem
     IMPORTING es_batch_dark = es_batch_dark.

  CHECK NOT es_batch_dark-charg IS INITIAL.

* Formate, check and write value into classification buffer
  CALL FUNCTION 'MURC_SET_VALUE_CHARACTERISTIC'
    EXPORTING
      i_matnr          = ls_masterdata-matnr
      i_charg          = es_batch_dark-charg
      i_werks          = ls_masterdata-werks
      i_atinn          = ls_marm-atinn
      i_msehi          = ls_marm-msehi
      i_char_f         = l_factor
"     I_KZDCH          =                     "temp sw bitte prüfen
      i_altme          = is_goitem-erfme
      i_meins          = is_goitem-meins
      i_round          = abap_true
      i_convert        = abap_true
      i_no_dialog      = abap_true
    EXCEPTIONS
      characteristic_format_error       = 7
      value_not_found                   = 8
      fract5_overflow                   = 11
      incomplete_inputdata              = 12
      foreign_lock                      = 13
      OTHERS                            = 14.

  CHECK sy-subrc EQ 0.

* create changing table for batch quantity units
  ls_change_batch-charg = es_batch_dark-charg.
  ls_change_batch-matnr = ls_masterdata-matnr.
  ls_change_batch-werks = ls_masterdata-werks.
  CALL METHOD change_quantity_later
      EXPORTING is_change_batch = ls_change_batch.


ENDMETHOD.



************************************************************************
*    GET_XPARALLEL                                                     *
************************************************************************
METHOD get_xparallel.
*   determine whether parallel entry in quantities in product unit of
*   measure and base unit of measure is allowed
  CLEAR e_xparallel.

* Local data
  DATA:       l_date_last_gr TYPE mcha-lwedt,
              lt_marm        TYPE STANDARD TABLE OF marm.
  CONSTANTS:  lc_batch_conversion_active TYPE tcuws-kzdws VALUE '1'.

  CHECK lcl_migo_globals=>batch_conversion = lc_batch_conversion_active.

* Get material master unit of measure data:
* Is parallel entry allowed for this material
  CALL FUNCTION 'VBWS_UNITS_OF_MATERIAL'
       EXPORTING
            i_matnr          = i_matnr
            leading_unit     = x
       TABLES
            ws_marm_tab      = lt_marm
       EXCEPTIONS
            wrong_call       = 1
            no_units         = 2
            units_not_active = 3
            OTHERS           = 4.
* At least one product uom is flagged as leading unit
  CHECK sy-subrc EQ 0.

* check whether change of classification is allowed
  CALL METHOD check_batch_posted
           EXPORTING
                 i_matnr = i_matnr
                 i_werks = i_werks
                 i_charg = i_charg
           IMPORTING
                 e_date_last_gr = l_date_last_gr.
ENHANCEMENT-POINT GET_XPARALLEL_01 SPOTS ES_SAPLMIGO STATIC.

ENHANCEMENT-SECTION     GET_XPARALLEL_02 SPOTS ES_SAPLMIGO.
  CHECK l_date_last_gr IS INITIAL.
END-ENHANCEMENT-SECTION.

* 582569 Evaluate KZCLA
  CHECK NOT i_kzcla IS INITIAL.

  e_xparallel = abap_true.

ENDMETHOD.
************************************************************************
*   Check_batch_posted                                                 *
************************************************************************
METHOD check_batch_posted.
*   check whether there has already been a goods receipt on this item

* Local Data
  DATA: ls_mbefu TYPE mbefu,
        ls_mtcom TYPE mtcom.
  CONSTANTS:  lc_batch_conversion_active TYPE tcuws-kzdws VALUE '1'.

  CHECK lcl_migo_globals=>batch_conversion = lc_batch_conversion_active.
  CLEAR e_date_last_gr.

* Read date of last goods receipt of this batch
  ls_mtcom-kenng = 'MBEFU'.
  ls_mtcom-matnr = i_matnr.
  ls_mtcom-charg = i_charg.
  ls_mtcom-werks = i_werks.

  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            schluessel = ls_mtcom
       IMPORTING
            matdaten   = ls_mbefu
       EXCEPTIONS
            OTHERS     = 4.
  CHECK sy-subrc EQ 0.
  e_date_last_gr = ls_mbefu-lwedt.

ENDMETHOD.