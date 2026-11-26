***INCLUDE FV50XF0B_NACHRICHTEN_BUCHEN .
*---------------------------------------------------------------------*
*       FORM NACHRICHTEN_BUCHEN                                       *
*---------------------------------------------------------------------*
FORM NACHRICHTEN_BUCHEN.
* Die Verbuchung der Nachrichtensätze darf nur für Applikationen der
* Lieferung erfolgen. Andere Applikationen (z.B Warenausgang in der
* Bestandsführung) verbuchen ihre Sätze. Kommt zu mehreren Aufrufen
* des VB 'RV_MESSAGE(S)_UPDATE', so erhält jeder die gleiche interne
* Tabelle der Nachrichtensätze. Werden die VB's ohne Applikation
* aufgrufen, werden alle Sätze verbucht. Der nächste Aufruf des VB
* versucht die Sätze nocheinmal einzufügen, was zu einem Abbruch führt.
* Also: Jeder Bereich verbucht seine Nachrichtensätze!
* P30K092607:
* Falls die Lieferung aus dem Transport heraus verbucht wird, schreibt
* der Transport ALLE Versandelementnachrichten fort, auch die der VSE
* der Lieferung

  IF NO_MESSAGES_UPDATE = SPACE.

    CALL FUNCTION 'RV_MESSAGES_MAIL_REPLACE'
         EXPORTING
              MSG_KAPPL = TVLK-KAPPL
         EXCEPTIONS
              NO_MAIL_MESSAGE_FOUND = 01.

    CALL FUNCTION 'RV_MESSAGES_UPDATE'
         EXPORTING
              MSG_KAPPL = TVLK-KAPPL
              MSG_REPLACEMENT_DONE = CHARX.

    CALL FUNCTION 'RV_MESSAGES_UPDATE'
         EXPORTING
              MSG_KAPPL = 'V4'.

    IF AUFRUFER NE CHART AND            " P30K092607
       V50AGL-NO_MES_UPD_PACK IS INITIAL.                  "n_526239
* note_1147403 takes back changes of note 881470 (10 lines deleted)
        CALL FUNCTION 'RV_MESSAGES_UPDATE'
               EXPORTING
                  MSG_KAPPL = 'V6'.
* note_1147403 takes back changes of note 881470 (6 lines deleted)
    ENDIF.

    CALL FUNCTION 'WTAD_ADDIS_IN_DELIVERIES_POST'
         EXPORTING
              FI_POST_SYNCHRON = V50AGL-SYNCHRON
         TABLES
              FIT_LIKP         = XLIKP
              FIT_LIKP_OLD     = YLIKP
              FIT_LIPS         = XLIPS
              FIT_LIPS_OLD     = YLIPS
              FIT_VBUK         = XVBUK
              FIT_VBUK_OLD     = YVBUK
              FIT_VBUP         = XVBUP
              FIT_VBUP_OLD     = YVBUP
              FIT_VBPA         = XVBPA
              FIT_VBPA_OLD     = YVBPA
         EXCEPTIONS
              GENERAL_ERROR    = 1
              OTHERS           = 2.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.                               " P30K092607

ENDFORM.