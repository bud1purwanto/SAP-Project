*&---------------------------------------------------------------------*
*&      Form  J_1BAGT_SELECT                                           *
*&---------------------------------------------------------------------*
*       Text zu Bewegungsschluessel lesen                              *
*----------------------------------------------------------------------*
*  -->  US_J_1BCFOP: Bewegungsschluessel (CFOP in Brasilien)           *
*  <--  CH_SUBRC   : Returncode                                        *
*----------------------------------------------------------------------*
form j_1bagt_select using us_j_1bcfop  like vbap-j_1bcfop
                          ch_subrc     like sy-subrc.

 data: lv_land1 like t005-land1,
       lv_region like t005s-bland,
       ls_j_1bagnt type j_1bagnt.

  clear: ch_subrc.

  if    us_j_1bcfop is initial.
    clear: j_1bagt.
    exit.
  endif.

* CFOP Legal Change 2003: texts now from table J_1BAGNT!

* >>> Start of Deletion
*  SELECT SINGLE * FROM J_1BAGT WHERE SPRAS    EQ SY-LANGU
*                               AND   CFOP     EQ US_J_1BCFOP.
*
*  IF NOT ( SY-SUBRC IS INITIAL ).
*    CLEAR: J_1BAGT.
*    CH_SUBRC = 4.
*  ENDIF.
* <<< End of Deletion

* 1. Determine Branch Parameters via Plant
call function 'J_1B_BRANCH_DETERMINE'
  exporting
    plant                          = vbap-werks
  importing
    land1                          = lv_land1
    regio                          = lv_region
  exceptions
    branch_not_found               = 1
    plant_not_found                = 2
    valuation_area_not_found       = 3
    company_not_found              = 4
    others                         = 5.
clear sy-subrc.

* 2. Get text from versioned table
call function 'J_1B_CFOP_GET_TEXT'
  exporting
    iv_cfop           = us_j_1bcfop
    iv_land1          = lv_land1
    iv_region         = lv_region
    iv_date           = vbkd-fkdat
  importing
    es_j_1bagnt       = ls_j_1bagnt.

* 3. If found, overwrite j_1bagt
if ls_j_1bagnt is initial.
  clear: j_1bagt.
  ch_subrc = 4.
else.
  move-corresponding ls_j_1bagnt to j_1bagt.
endif.

endform.                               " J_1BAGT_SELECT