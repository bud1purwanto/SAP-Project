*&---------------------------------------------------------------------*
*&  Include           MV45AI0V_VBAP_SKOPF_CHECK
*&  - check assortment module
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VBAP_SKOPF_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VBAP_SKOPF_CHECK INPUT.
* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBAP_SKOPF_CHECK(SAPFV45P).

ENDMODULE.                 " VBAP_SKOPF_CHECK  INPUT