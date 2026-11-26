*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_SHIP_INFO_TO_ATPFIELD                   *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form SHIP_INFO_TO_ATPFIELD
*&---------------------------------------------------------------------*
*& This FORM adds the TP/VS-relevant shipping information to the field *
*& catalogue. This information is later evaluated in APO and is needed *
*& there for planning.                                                 *
*& If any fields are added or removed here it has to made sure that    *
*& also the update trigger for deliveries is adjusted accordingly.     *
*& The update trigger can be found in                                  *
*& INCLUDE FV50XF0B_CHECK_APO_UPDTRIGGER                               *
*&---------------------------------------------------------------------*
FORM SHIP_INFO_TO_ATPFIELD
   TABLES   ET_SDFIELDS   STRUCTURE ATPFIELD
   USING    BELEG         TYPE      VBELN
            POSITION      TYPE      POSNR.

  DATA: ls_vbak TYPE vbak.

* TP/VS shipping information
  ET_SDFIELDS-DELNR = BELEG.
  ET_SDFIELDS-DELPS = POSITION.

  IF BELEG EQ LIKP-VBELN.
*   add TP/VS relevant data from delivery document

    ET_SDFIELDS-KFDNA = '/SHIP_INCOTERMS1'.
    ET_SDFIELDS-VALUE = LIKP-INCO1.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_INCOTERMS2'.
    ET_SDFIELDS-VALUE = LIKP-INCO2.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_SHIP_COND'.
    ET_SDFIELDS-VALUE = LIKP-VSBED.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_DLV_PRIO'.
    ET_SDFIELDS-VALUE = LIKP-LPRIO.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_SHIP_POINT'.
    ET_SDFIELDS-VALUE = LIKP-VSTEL.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_ROUTE'.
    ET_SDFIELDS-VALUE = LIKP-ROUTE.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_COMPL_DLV'.
    ET_SDFIELDS-VALUE = LIKP-AUTLF.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_LIFSP'.
    ET_SDFIELDS-VALUE = LIKP-LIFSK.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/UNTTO'.
    ET_SDFIELDS-VALUE = XLIPS-UNTTO.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/UEBTO'.
    ET_SDFIELDS-VALUE = XLIPS-UEBTO.
    APPEND ET_SDFIELDS.

    et_sdfields-kfdna = '/SHIP_BTGEW'.
    ET_SDFIELDS-VALUE = LIKP-BTGEW.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_GEWEI'.
    ET_SDFIELDS-VALUE = LIKP-GEWEI.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_VOLUM'.
    ET_SDFIELDS-VALUE = LIKP-VOLUM.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_VOLEH'.
    ET_SDFIELDS-VALUE = LIKP-VOLEH.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_TRSTA'.
    ET_SDFIELDS-VALUE = VBUK-TRSTA.
    APPEND ET_SDFIELDS.

  ELSE.
*   add TP/VS relevant data from predecessor: sales document
    IF vbak-vbeln = beleg.
      ls_vbak = vbak.
    ELSE.
      CALL FUNCTION 'SD_VBAK_SINGLE_READ'
        EXPORTING
          i_vbeln = beleg
        IMPORTING
          e_vbak  = ls_vbak
        EXCEPTIONS
          OTHERS  = 1.
      IF NOT sy-subrc IS INITIAL.
        RETURN.
      ENDIF.
    ENDIF.
    IF   NOT VBKD-VBELN = BELEG
      OR NOT VBKD-POSNR = POSITION.
      SELECT SINGLE * FROM VBKD
             WHERE  VBELN  = BELEG
             AND    POSNR  = POSITION.
      IF NOT SY-SUBRC IS INITIAL.
        SELECT SINGLE * FROM VBKD
               WHERE  VBELN  = BELEG
               AND    POSNR  = '000000'.
      ENDIF.
    ENDIF.
    READ TABLE XVBAP WITH KEY MANDT = LIKP-MANDT
                              VBELN = BELEG
                              POSNR = POSITION.
    CHECK SY-SUBRC = 0.

    ET_SDFIELDS-KFDNA = '/SHIP_INCOTERMS1'.
    ET_SDFIELDS-VALUE = VBKD-INCO1.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_INCOTERMS2'.
    ET_SDFIELDS-VALUE = VBKD-INCO2.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_SHIP_COND'.
    ET_SDFIELDS-VALUE = VBAK-VSBED.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_DLV_PRIO'.
    ET_SDFIELDS-VALUE = XVBAP-LPRIO.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_SHIP_POINT'.
    ET_SDFIELDS-VALUE = XVBAP-VSTEL.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_ROUTE'.
    ET_SDFIELDS-VALUE = XVBAP-ROUTE.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_COMPL_DLV'.
    et_sdfields-value = ls_vbak-autlf.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/SHIP_LIFSP'.
    et_sdfields-value = ls_vbak-lifsk.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = 'BSTNK'.
    et_sdfields-value = ls_vbak-bstnk.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/UNTTO'.
    ET_SDFIELDS-VALUE = XVBAP-UNTTO.
    APPEND ET_SDFIELDS.

    ET_SDFIELDS-KFDNA = '/UEBTO'.
    ET_SDFIELDS-VALUE = XVBAP-UEBTO.
    APPEND ET_SDFIELDS.

  ENDIF.

ENDFORM.                    "SHIP_INFO_TO_ATPFIELD