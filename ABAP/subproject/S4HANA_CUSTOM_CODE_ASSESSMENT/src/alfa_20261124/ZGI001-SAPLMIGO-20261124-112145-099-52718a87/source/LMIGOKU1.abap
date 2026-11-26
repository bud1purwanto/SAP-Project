*----------------------------------------------------------------------*
*   INCLUDE LMIGOKU1 Unit conversions                                  *
*----------------------------------------------------------------------*

************************************************************************
* Conversion of unit measures
* MEINS => ERFME with conversion factors of material master.
* ERFME => MEINS with conversion factors of material master.
* ERFME => MEINS with conversion factors of purchase order, if a
*          variable BSTME is defined in purchase order.
************************************************************************
METHOD unit_conversion.
  DATA: l_conversion TYPE char1.
  DATA: BEGIN OF ls_unit_conversion,
          werks TYPE werks_d,
          matnr TYPE matnr,
          charg TYPE charg_d,
        END OF ls_unit_conversion.

  CHECK NOT ( cs_goitem-menge IS INITIAL AND
              cs_goitem-erfmg IS INITIAL ).
  CLEAR: cs_goitem-umrez,
         cs_goitem-umren.

  IF cs_goitem-erfmg IS INITIAL AND NOT cs_goitem-menge IS INITIAL
     AND i_called_by_reservation = abap_true.
* for manual reservations
    l_conversion = '1'.
  ELSEIF cs_goitem-bstme IS INITIAL OR
     cs_goitem-bstme <> cs_goitem-erfme.
*   No PO unit conversion. Take conversion factor of material master.
*   OR:
*   Unit defined in purchase order but a different ERFME was entered
*   in MIGO.
*   In this case, the conversion has to be done with conversion
*   factors of material master.
    l_conversion = '2'.
  ELSEIF cs_goitem-bstme =  cs_goitem-erfme AND
         cs_goitem-bstme <> cs_goitem-meins.
*   Unit defined in purchase order which differs from MEINS
    l_conversion = '3'.

  ENDIF.
  IF l_conversion = space.
*   This will happen, if BSTME = ERFME = MEINS the conversion is
*   also requested, because of processing serial numbers.
*   Conversion with conversion factor of material master.
   l_conversion = '2'.
  ENDIF.

  move-corresponding cs_goitem to ls_unit_conversion.
  IF i_transfer = abap_true.
    ls_unit_conversion-werks = cs_goitem-umwrk.
    ls_unit_conversion-matnr = cs_goitem-ummat.
    ls_unit_conversion-charg = cs_goitem-umcha.
  ENDIF.

  IF l_conversion = '1'.
* conversion from MEINS to ERFME with conversion factor of material
* mater, needed for manual reservations
    CALL FUNCTION 'MB_UNIT_CONVERSION'
         EXPORTING
              erfme                = cs_goitem-erfme
              erfmg                = cs_goitem-erfmg
              matnr                = ls_unit_conversion-matnr
              meins                = cs_goitem-meins
              menge                = cs_goitem-menge
              charg                = ls_unit_conversion-charg
              werks                = ls_unit_conversion-werks
         IMPORTING
              o_erfmg              = cs_goitem-erfmg
         EXCEPTIONS error_message  = 0.
  ELSEIF l_conversion = '2'.
*   conversion from ERFME to MEINS with conversion factor of material
*   master
    CALL FUNCTION 'MB_UNIT_CONVERSION'
         EXPORTING
              erfme                = cs_goitem-erfme
              erfmg                = cs_goitem-erfmg
              matnr                = ls_unit_conversion-matnr
              meins                = cs_goitem-meins
              charg                = ls_unit_conversion-charg
              werks                = ls_unit_conversion-werks
         IMPORTING
              o_menge              = cs_goitem-menge
              o_umren              = cs_goitem-umren
              o_umrez              = cs_goitem-umrez
         EXCEPTIONS error_message  = 0.
  ELSEIF l_conversion = '3'.
*   conversion from ERFME to MEINS with conversion factor of PO
    CALL FUNCTION 'MB_UNIT_CONVERSION'
         EXPORTING
              erfme                = cs_goitem-erfme
              erfmg                = cs_goitem-erfmg
              matnr                = ls_unit_conversion-matnr
              meins                = cs_goitem-meins
              charg                = ls_unit_conversion-charg
              werks                = ls_unit_conversion-werks
              umren                = cs_goitem-bumrn
              umrez                = cs_goitem-bumrz
         IMPORTING
              o_menge              = cs_goitem-menge
         EXCEPTIONS error_message  = 0.
  ENDIF.

* Conversion of ERFMG into BSTMG (quantity in order unit).
* Needed for resulution of subcontracting components.
  IF cs_goitem-erfme = cs_goitem-bstme.
    cs_goitem-bstmg = cs_goitem-erfmg.
  ELSE.
* For release of GR blocked stock referring to GR document,      "810565
* the PO was not read yet -> read conversion factors             "810565
    IF godynpro-action = 'A05' AND godynpro-refdoc = 'R02'       "810565
        AND cs_goitem-bumrn IS INITIAL                           "810565
        AND NOT cs_goitem-ebeln IS INITIAL.                      "810565
      SELECT SINGLE umren umrez                                  "810565
        INTO (cs_goitem-bumrn, cs_goitem-bumrz)                  "810565
        FROM  ekpo                                               "810565
        WHERE ebeln = cs_goitem-ebeln AND                        "810565
              ebelp = cs_goitem-ebelp.                           "810565
    ENDIF.                                                       "810565
    cs_goitem-bstmg = cs_goitem-menge * cs_goitem-bumrn /
                                        cs_goitem-bumrz.
  ENDIF.

ENHANCEMENT-POINT LMIGOKU1_01 SPOTS ES_SAPLMIGO STATIC.


ENHANCEMENT-POINT LMIGOKU1_02 SPOTS ES_SAPLMIGO.

ENDMETHOD.                  " UNIT_CONVERSION