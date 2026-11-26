*----------------------------------------------------------------------*
*   INCLUDE LMIGOKW1                                                   *
*----------------------------------------------------------------------*
* METHOD WM_ACTIVE_CHECK
* Check if WM is active for an item
*----------------------------------------------------------------------*
METHOD wm_active_check.
  DATA: ls_t320 TYPE t320,
        ls_t340d TYPE t340d.
  CALL FUNCTION 'L_LGORT_LGNUM_CHECK'
    EXPORTING
      i_werks                             = i_werks
      i_lgort                             = i_lgort
*     I_LGNUM                             =
      i_lgdat                             = abap_true
*     I_SPRAS                             = ' '
*     I_LODAT                             = ' '
    IMPORTING
      e_t320                              = ls_t320
      e_t340d                             = ls_t340d
*     E_LNUMT                             =
*     E_T001L                             =
    EXCEPTIONS
*     LGNUM_OR_LGORT_OBLIGATORY           = 1
*     LGORT_NOT_DETERMINED                = 2
*     LGNUM_OR_LGORT_WRONG                = 3
*     ENTRY_NOT_IN_T320                   = 4
*     WERKS_LGNUM_NOT_VALID               = 5
*     STANDARD_LGORT_NOT_DETERMINED       = 6
*     LGNUM_DATA_DOES_NOT_EXIST           = 7
*     LGNUM_TEXT_DOES_NOT_EXIST           = 8
      OTHERS                              = 9
            .
* in case of lean WM (obest is set) or decentral WM
* we do not need WM subscreen
  IF sy-subrc = 0 AND ls_t320-obest IS INITIAL AND
     ls_t340d-decsy IS INITIAL.
    e_lgnum = ls_t320-lgnum.
  ELSE.
    CLEAR e_lgnum.
  ENDIF.

ENDMETHOD.                    "wm_active_check

*----------------------------------------------------------------------*
* METHOD wm_data_prepare
* Send relevant data to WM
*----------------------------------------------------------------------*
*----------warehouse management----------------------------------------*
* An item has WM active if LGNUM is set.
* In creation mode, we send the item data to wm if active. Wm has
* an internal table with global_counter and checks whether the changed
* data is important for them. If a previously relevant item is not
* relevant anymore, it has to be deleted in wm memory.
* In display mode, we do not need to check anything here. We only
* transfer the data to WM in PBO of WM detail.
* Ties empties (XVGTYPE=C) are never relevant.
*----------------------------------------------------------------------*
* Even the tab strip WM is visible in all cases when in the RECEIVING
* storage location WM is active (LGNUM exists), the palletization
* data can be entered.
* But the palletization data will ONLY be displayed (and stored), when
* it is customized for WM-movement types (OLML)! If not, the
* palletization will always be displayed as empty!
*----------------------------------------------------------------------*
METHOD wm_data_prepare.
  DATA:
*     ls_goitem  TYPE goitem,
      ls_wmdata      TYPE wms_migo,  "WM pallets
      ls_wm_defaults TYPE wms_migo_sugg, "WM pallets
      l_werks       TYPE goitem-werks, "Check WM active
      l_lgort       TYPE goitem-lgort. "Check WM active

  IF s_action-display = abap_false AND cs_goitem-xvgtype <> c.
*   Check if WM active in receiving storage location
    CALL METHOD wm_active_check
      EXPORTING
        i_werks = cs_goitem-umwrk
        i_lgort = cs_goitem-umlgo
      IMPORTING
        e_lgnum = cs_goitem-umlgnum.
    CALL METHOD wm_active_check
      EXPORTING
        i_werks = cs_goitem-werks
        i_lgort = cs_goitem-lgort
      IMPORTING
        e_lgnum = cs_goitem-lgnum.
* GOITEM-LGNUM indicates that WM is active
   IF ( NOT cs_goitem-lgnum IS INITIAL AND s_action-migo_mode <> 'GT' )
      OR ( s_action-migo_mode = 'GT' AND cs_goitem-shkzg = 'S'
           AND NOT cs_goitem-lgnum IS INITIAL )
      OR ( s_action-migo_mode = 'GT' AND cs_goitem-shkzg = 'H'
           AND NOT cs_goitem-umlgnum IS INITIAL )
      OR ( s_action-migo_mode = 'GT' AND cs_goitem-shkzg = 'H'   "725025
           AND NOT cs_goitem-lgnum IS INITIAL
           AND cs_goitem-umlgnum IS INITIAL ).
*   Send WM defaults
      ls_wm_defaults-tbfkz = s_defaults-tbfkz.
      ls_wm_defaults-bsskz = s_defaults-bsskz.
      CALL FUNCTION 'SEND_SUGG_VALUES_TO_WM'
        EXPORTING
          i_wms_migo_sugg = ls_wm_defaults.
*   Transfer receiving item data to WM
      MOVE-CORRESPONDING cs_goitem TO ls_wmdata.
      IF s_action-migo_mode = 'GT' AND cs_goitem-shkzg = 'H'
        AND NOT cs_goitem-umlgnum IS INITIAL.                    "725025
        ls_wmdata-werks = cs_goitem-umwrk.
        ls_wmdata-lgort = cs_goitem-umlgo.
        ls_wmdata-matnr = cs_goitem-ummat.
        ls_wmdata-charg = cs_goitem-umcha.
        ls_wmdata-lgnum = cs_goitem-umlgnum.
      ENDIF.
      CALL FUNCTION 'SEND_LINE_DATA_TO_WM'
        EXPORTING
          i_action = s_control-action
          i_data = ls_wmdata.
      cs_goitem-wm_relevant = abap_true.
      IF ls_wmdata-global_counter <> goitem-global_counter      "1617602
        AND goitem-global_counter <> 0.                         "1617602
*       Send current line to WM to have the right line during   "1617602
*       the PAI of the function group LPAL                      "1617602
        CALL FUNCTION 'SEND_CURRENT_LINE_TO_WM'                 "1617602
          EXPORTING                                             "1617602
            i_global_counter = goitem-global_counter.           "1617602
      ENDIF.                                                    "1617602
    ELSE.
*     WM not relevant => Delete line
*     (always try to delete line in WM even if there was never a
*      LGNUM/UMLGNUM)
      CALL FUNCTION 'DELETE_SINGLE_LINE_WM'
        EXPORTING
           i_global_counter = cs_goitem-global_counter.
      cs_goitem-wm_relevant = abap_false.
    ENDIF.
  ENDIF.
ENDMETHOD.                    "wm_data_prepare