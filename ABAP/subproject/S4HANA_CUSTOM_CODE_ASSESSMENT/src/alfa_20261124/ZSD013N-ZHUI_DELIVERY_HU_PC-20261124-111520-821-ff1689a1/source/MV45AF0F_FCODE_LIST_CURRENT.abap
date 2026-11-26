*---------------------------------------------------------------------*
*       FORM FCODE_LIST_CURRENT
*---------------------------------------------------------------------*
*       Ausgabe des druckaufbereiteten Auftrags auf dem Bildschirm    *
*---------------------------------------------------------------------*
FORM FCODE_LIST_CURRENT.

  DATA: DA_XNAST LIKE VNAST OCCURS 0 WITH HEADER LINE,
        DA_YNAST LIKE NAST OCCURS 0 WITH HEADER LINE,
        DA_XVBFA LIKE VBFA OCCURS 0 WITH HEADER LINE,
        DA_PREVIEW_PROCESSED(1) TYPE C.

* Get data of objectkey for output
  MOVE VBAK-VBELN TO XOBJKY.

* Nachrichtenfindung durchführen
  DATA: BEGIN OF VBKD_KEY,
          MANDT LIKE VBKD-MANDT,
          VBELN LIKE VBKD-VBELN,
          POSNR LIKE VBKD-POSNR,
        END   OF VBKD_KEY.

  IF T185F-TRTYP NE 'A' OR
     XVBAK_UPDKZ EQ UPDKZ_NEW.
    VBKD_KEY-MANDT = SY-MANDT.
    VBKD_KEY-VBELN = VBAK-VBELN.
    VBKD_KEY-POSNR = 0.
    READ TABLE XVBKD WITH KEY VBKD_KEY.
    NA_VBKD = XVBKD.
* Kopfstatus ermitteln
    PERFORM XVBUK_UEBERSICHT_VORBEREITEN(SAPFV45K).

    CALL FUNCTION 'COMMUNICATION_AREA_KOMKBV1'
         EXPORTING
              MSG_VBAK  = VBAK
              MSG_VBKD  = NA_VBKD
              MSG_VBUK  = VBUK
              MSG_TRTYP = T180-TRTYP
         TABLES
              TAB_VBPA  = XVBPA
              TAB_VBAP  = XVBAP
              TAB_PART  = PART.

    CALL FUNCTION 'MESSAGING'
         EXPORTING
              APPLIKATION = TVAK-KAPPL
              MSG_OBJKY   = XOBJKY
              SCHEMA      = TVAK-KALSM
              PI_OBJTYPE  = BUSINESSOBJEKT
         TABLES
              MSG_PART    = PART.
  ENDIF.

  CALL FUNCTION 'RV_MESSAGES_GET'
       EXPORTING
            MSG_KAPPL      = TVAK-KAPPL
            MSG_OBJKY_FROM = XOBJKY
       TABLES
            TAB_XNAST      = DA_XNAST
            TAB_YNAST      = DA_YNAST.

* prüfen, ob überhaupt relevante Nachrichten zur Druckanzeige da sind
  LOOP AT DA_XNAST WHERE NACHA EQ CHAR1 OR
                         NACHA EQ CHAR5 OR
                         NACHA EQ CHAR2.

    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
* XVBFA in Struktur VBFA an SD_PUSH_ITEM übergeben
    LOOP AT XVBFA.
      MOVE-CORRESPONDING XVBFA TO DA_XVBFA.
      APPEND DA_XVBFA.
    ENDLOOP.

* aktuelle Daten an FUGR V45I übergeben
    CALL FUNCTION 'SD_PUSH_ITEM'
         EXPORTING
              I_VBAK  = VBAK
         TABLES
              I_XVBAP = XVBAP
              I_XVBEP = XVBEP
              I_XVBFA = DA_XVBFA
              I_XVBKD = XVBKD
              I_XVBPA = XVBPA
              I_XVBUP = XVBUP.

    CALL FUNCTION 'RV_PRICE_PRINT_GET_BUFFER'
         EXPORTING
              I_INIT              = SPACE
              I_VBELN             = VBAK-VBELN
              I_PRINT_FROM_BUFFER = SPACE
         TABLES
              T_KOMV              = XKOMV.


* Ausgabe aufrufen
    CALL FUNCTION 'RV_MESSAGE_DIALOG'
         EXPORTING
              PI_KAPPL              = TVAK-KAPPL
              PI_OBJKY              = XOBJKY
              PI_KSCHL              = TVAK-KSCHL
              PI_DATA_FROM_BUFFER   = CHARX
              PI_QUICK_PREVIEW      = SPACE
              PI_QUICK_PREVIEW_OPT  = CHARX
              PI_FAXOUTPUT          = CHARX
         IMPORTING
              PREVIEW_PROCESSED     = DA_PREVIEW_PROCESSED
         EXCEPTIONS
              CANCEL                = 1
              NO_MESSAGE            = 2
              MESSAGE_NOT_PRINTABLE = 2
              PRINT_ERROR           = 3
              OTHERS                = 4.


    CASE SY-SUBRC.
      WHEN 0.
        IF DA_PREVIEW_PROCESSED EQ CHARX.
          MESSAGE S103.
        ENDIF.
      WHEN 1.
      WHEN 2.
        MESSAGE S102.
      WHEN 3.
        MESSAGE S104.
      WHEN OTHERS.
        MESSAGE S104.
    ENDCASE.
  ELSE.
    MESSAGE S102.
  ENDIF.

  CALL FUNCTION 'RV_PRICE_PRINT_GET_BUFFER'
       EXPORTING
            I_INIT   = CHARX
            I_PRINT_FROM_BUFFER = SPACE.
ENDFORM.