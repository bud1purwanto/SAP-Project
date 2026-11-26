***INCLUDE MV50AF0F_FCODE_LIST .
*---------------------------------------------------------------------*
*       FORM FCODE_LIST                                               *
*---------------------------------------------------------------------*
*       Ausgabe der druckaufbereiteten Lieferung auf dem Bildschirm   *
*---------------------------------------------------------------------*
FORM FCODE_LIST USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.

  CALL FUNCTION 'RV_MESSAGE_PREVIEW'
       EXPORTING
            MSG_KAPPL             = TVLK-KAPPL
            MSG_OBJKY             = XOBJKY
            MSG_KSCHL             = TVLK-KSCHL
       EXCEPTIONS
            CANCEL                = 1
            NO_MESSAGE            = 2
            MESSAGE_NOT_PRINTABLE = 2
            PRINT_ERROR           = 3.
  CASE SY-SUBRC.
    WHEN 0.
      MESSAGE S084.
      LEAVE.
    WHEN 1.
      LEAVE.
    WHEN 2.
      MESSAGE S085.
      LEAVE.
    WHEN 3.
      MESSAGE S086.
      LEAVE.
    WHEN OTHERS.
      LEAVE.
  ENDCASE.

ENDFORM.