*&---------------------------------------------------------------------*
*& Report  Z_CR_LOOKUP
*&---------------------------------------------------------------------*
*& Purpose : Find CR number for program ZMMI_WMS
*&---------------------------------------------------------------------*
REPORT z_cr_lookup.

DATA: lt_cr TYPE TABLE OF e070,
      ls_cr TYPE e070,
      lt_dev TYPE TABLE OF e071,
      ls_dev TYPE e071.

SELECT * INTO TABLE lt_cr FROM e070
  WHERE tartn LIKE '%ZMMI_WMS%'.

IF sy-subrc = 0.
  WRITE: 'CR Number for ZMMI_WMS:'.
  LOOP AT lt_cr INTO ls_cr.
    WRITE: / ls_cr-trkorr, ls_cr-as4text.
  ENDLOOP.
ELSE.
  WRITE: 'No CR found in E070. Checking local objects...'.

  SELECT * INTO TABLE lt_dev FROM e071
    WHERE tartn LIKE '%ZMMI_WMS%' OR tadir LIKE '%ZMMI_WMS%'.

  IF sy-subrc = 0.
    WRITE: 'Found in E071 (local objects):'.
    LOOP AT lt_dev INTO ls_dev.
      WRITE: / ls_dev-trkorr, ls_dev-tartn.
    ENDLOOP.
  ELSE.
    WRITE: 'No CR found at all for ZMMI_WMS'.
  ENDIF.
ENDIF.
