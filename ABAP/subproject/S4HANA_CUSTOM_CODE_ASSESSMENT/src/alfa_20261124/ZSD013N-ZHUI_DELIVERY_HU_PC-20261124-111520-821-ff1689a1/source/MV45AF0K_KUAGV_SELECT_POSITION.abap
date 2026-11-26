*---------------------------------------------------------------------*
*       FORM KUAGV_SELECT_POSITION                                     *
*---------------------------------------------------------------------*
*       Der Auftraggeber wird je Position nachgelesen, da sich die    *
*       Sparte in den Positionen ändern kann.                         *
*---------------------------------------------------------------------*
FORM KUAGV_SELECT_POSITION USING US_SPART US_WKLND
                                    VALUE(US_LLAND).       "eu-tax

* Wegen Aufwaertkompatib. soll nur dann mit dem 'Empfangsland' gelesen
* werden, falls das neue Feld tvko-xstceg gepflegt wurde (4.0).
* Bisher wurde stceg des AG immer aus der kna1 gelesen.
  IF TVKO-XSTCEG IS INITIAL.                               "eu-tax
    CLEAR US_LLAND.                                        "!
  ENDIF.                                                   "!
  IF KUAGV-KUNNR NE SPACE.
    IF VTCOMAG-KUNNR NE KUAGV-KUNNR OR
       VTCOMAG-VKORG NE VBAK-VKORG OR
       VTCOMAG-VTWEG NE VBAK-VTWEG OR
       VTCOMAG-ALAND NE US_WKLND OR
       VTCOMAG-LLAND NE US_LLAND OR                         "eu-tax
       VTCOMAG-SPART NE US_SPART.
      CLEAR VTCOMAG.
      VTCOMAG-KUNNR = KUAGV-KUNNR.
      VTCOMAG-VKORG = VBAK-VKORG.
      VTCOMAG-VTWEG = VBAK-VTWEG.
      VTCOMAG-SPART = US_SPART.
      VTCOMAG-ALAND = US_WKLND.
      VTCOMAG-LLAND = US_LLAND.                             "eu-tax

      CALL FUNCTION 'VIEW_KUAG2'
           EXPORTING
                COMWA      = VTCOMAG
                INIT_KUAGV = CHARX
           IMPORTING
                AGWA    = KUAGV
           EXCEPTIONS
                NO_KNVV = 1
                NO_TPAKD = 2.
      IF SY-SUBRC = 1.
        CLEAR VTCOMAG.
        MESSAGE E197(VP) WITH SY-MSGV1
                              SY-MSGV2
                              SY-MSGV3
                              SY-MSGV4.
      ELSEIF SY-SUBRC > 1.
      ENDIF.
      PERFORM XVBPA_LESEN(SAPFV45K) USING 'AG'
                                          POSNR_LOW
                                          XVBPA_AKTIND.
* Eventuell manueller Name für Anzeige
      IF NOT XVBPA-ADRNR IS INITIAL AND
         XVBPA-ADRNR = XVBADR-ADRNR.
        KUAGV-NAME1 = XVBADR-NAME1.
        KUAGV-ORT01 = XVBADR-ORT01.
        KUAGV-SPRAS = XVBADR-SPRAS.
        KUAGV-LAND1 = XVBADR-LAND1.
        KUAGV-ADRNR = XVBADR-ADRNR.
      ENDIF.
      PERFORM KUAGV-TXTPA_ERMITTELN.

    ENDIF.
  ENDIF.

ENDFORM.