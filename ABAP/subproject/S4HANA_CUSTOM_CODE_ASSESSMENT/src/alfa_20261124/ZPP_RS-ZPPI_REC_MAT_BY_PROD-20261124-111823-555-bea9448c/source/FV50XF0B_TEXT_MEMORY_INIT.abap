*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_TEXT_MEMORY_INIT                                  *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TEXT_MEMORY_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TEXT_MEMORY_INIT.

  LOCAL: SY-SUBRC.
  DATA: LT_TEXT_VBELN    TYPE LV70T_TY_APPL_TABLE.

  PERFORM FILL_LT_TEXT_VBELN USING LT_TEXT_VBELN[].

  CALL FUNCTION 'SD_DELETE_TEXT_FROM_CATALOG'
       EXPORTING
            FI_CALLER         = GC_TEXT_APPL_ID-DELIVERY
            FIT_VBELN         = LT_TEXT_VBELN[]
            FI_SALF           = v50agl-sammelgang             "n_1018017
       EXCEPTIONS
            OTHERS            = 1.


ENDFORM.                    " TEXT_MEMORY_INIT