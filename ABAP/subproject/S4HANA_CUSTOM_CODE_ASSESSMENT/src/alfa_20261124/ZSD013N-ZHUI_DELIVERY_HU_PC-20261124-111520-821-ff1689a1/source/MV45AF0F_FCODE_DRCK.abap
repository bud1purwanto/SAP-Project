*---------------------------------------------------------------------*
*       FORM FCODE_DRCK                                               *
*---------------------------------------------------------------------*
*       Ausgabe auf Drucker                                           *
*---------------------------------------------------------------------*
FORM FCODE_DRCK USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.

  DATA: DA_MESSAGE_PRINTED(1) TYPE C,
        DA_PREVIEW_PROCESSED(1) TYPE C,
        DA_SUBRC LIKE SY-SUBRC.

  CALL FUNCTION 'SD_PUSH_ITEM'
       EXPORTING
            I_VBAK  = VBAK
       TABLES
            I_XVBAP = XVBAP
            I_XVBEP = XVBEP
            I_XVBFA = XVBFA
            I_XVBKD = XVBKD
            I_XVBPA = XVBPA
            I_XVBUP = XVBUP.

  CALL FUNCTION 'RV_PRICE_PRINT_GET_BUFFER'
       EXPORTING
            I_PRINT_FROM_BUFFER = CHARA.

* Ausgabe aufrufen
  CALL FUNCTION 'RV_MESSAGE_DIALOG'
       EXPORTING
            PI_KAPPL              = TVAK-KAPPL
            PI_OBJKY              = XOBJKY
            PI_KSCHL              = TVAK-KSCHL
            PI_DATA_FROM_BUFFER   = SPACE
            PI_QUICK_PREVIEW      = SPACE
            PI_FAXOUTPUT          = CHARX
       IMPORTING
            MESSAGE_PRINTED       = DA_MESSAGE_PRINTED
            PREVIEW_PROCESSED     = DA_PREVIEW_PROCESSED
       EXCEPTIONS
            CANCEL                = 1
            MESSAGE_NOT_PRINTABLE = 2
            NO_MESSAGE            = 2
            PRINT_ERROR           = 3
            OTHERS                = 4.
  DA_SUBRC = SY-SUBRC.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.

  CASE DA_SUBRC.
    WHEN 0.
      IF DA_MESSAGE_PRINTED EQ CHARX.
        COMMIT WORK.
        MESSAGE S103.
      ELSE.
        IF DA_PREVIEW_PROCESSED EQ CHARX.
          MESSAGE S103.
        ENDIF.
      ENDIF.
      LEAVE.
    WHEN 1.
      LEAVE.
    WHEN 2.
      MESSAGE S102.
      LEAVE.
    WHEN 3.
      IF DA_MESSAGE_PRINTED EQ CHARX.
        COMMIT WORK.
      ENDIF.
      MESSAGE S104.
      LEAVE.
    WHEN OTHERS.
      LEAVE.
  ENDCASE.

  PERFORM BELEG_INITIALISIEREN.

ENDFORM.