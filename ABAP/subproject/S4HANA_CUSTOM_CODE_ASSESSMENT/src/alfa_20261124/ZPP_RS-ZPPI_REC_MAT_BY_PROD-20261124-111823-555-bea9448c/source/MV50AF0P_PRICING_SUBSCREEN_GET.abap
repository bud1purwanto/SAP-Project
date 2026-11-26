*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PRICING_SUBSCREEN_GET                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PRICING_SUBSCREEN_GET_DATA
*&---------------------------------------------------------------------*
FORM PRICING_SUBSCREEN_GET_DATA.

* CALCULATION_TYPE kann im PRICING_DIALOG geändert worden sein, wenn
* man auf das Kopfkonditionsbild verzweigt ist.

  CALL FUNCTION 'PRICING_SUBSCREEN_GET_DATA'
       IMPORTING
            COMM_HEAD_E      = TKOMK
            COMM_ITEM_E      = TKOMP
            CALCULATION_TYPE = GLOBAL_PRICING_TYPE
       TABLES
            TKOMV            = TKOMV
       EXCEPTIONS
            ERROR            = 1
            OTHERS           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                               " PRICING_SUBSCREEN_GET_DATA