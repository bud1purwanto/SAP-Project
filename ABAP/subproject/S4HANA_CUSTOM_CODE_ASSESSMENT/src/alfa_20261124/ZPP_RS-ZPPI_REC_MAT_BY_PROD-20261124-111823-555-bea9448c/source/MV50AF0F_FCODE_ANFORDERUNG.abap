*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_ANFORDERUNG                                 *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_ANFORDERUNG                                        *
*---------------------------------------------------------------------*
*       Aufruf des Funktionsbausteins 'ANFORDERUNGSBILD'              *
*       Einstiegsroutine zur Funktionscodebehandlung: beim ersten     *
*       Aufruf müssen die vollständigen Ortsinformationen aus T185    *
*       an den Funktionsbaustein übergeben werden.                    *
*---------------------------------------------------------------------*
FORM FCODE_ANFORDERUNG.

  DATA: FA_LINES TYPE P.

ENHANCEMENT-POINT FCODE_ANFORDERUNG_01 SPOTS ES_SAPMV50A.
* Routines for transforming function codes
  IF    T180-BLDGR EQ GC_NEW_DIALOG_OUTB
     OR T180-BLDGR EQ GC_NEW_DIALOG_INB.
    PERFORM TRANSFORM_DOUBLECLICK         CHANGING FCODE.
    PERFORM TAXI_FILTER_AND_CONVERT_FCODE CHANGING FCODE.
    PERFORM TRANSFORM_VIEW_FCODE          CHANGING FCODE.
    PERFORM TRANSFORM_TC_FCODE            CHANGING FCODE
                                                   GF_PUSHBUTTON_LINE.
  ENDIF.

*... Wurde bereits erfolgreich im MM gebucht?
  IF WA_ZAEHL > 0.                     "WA-Zaehler noch Null?
    MESSAGE A621.                      "wenn nein, Abbruch!!!
  ENDIF.

  CHECK FCODE(4) NE FCODE_ENDE.        "46A BEY

ENHANCEMENT-POINT FCODE_ANFORDERUNG_02 SPOTS ES_SAPMV50A.
  CALL FUNCTION 'SCREEN_SEQUENCE_CONTROL_INIT'
       EXPORTING
            PROGRAMM        = 'SAPMV50A'
            TYP             = T185F-TRTYP
            KOPFGRUPPE      = TVLK-KOPGR
            POSITIONSGRUPPE = TVLP-POSGR
            BILDGRUPPE      = T185-BLDGR
            BILD            = T185-PANEL
            FUNKTION        = FCODE
       IMPORTING
            AKTYP           = T185F-AKTYP
            CUA_STATUS      = T185V-STATUS
            CUA_TITEL       = T185V-CTITEL
            CUA_PARA1       = T185V-PARA1
            CUA_PARA2       = T185V-PARA2
            CUA_PARA3       = T185V-PARA3
            CUA_PARA4       = T185V-PARA4
            FOLGEFUNKTION   = T185F-FCODE
            DUNKEL          = T185-DUNKEL
            LEAVE           = FLAG-LEAVE
            DYNPROBAUSTEIN1 = TAXI_HEADER_SUBSCREEN  "46A BEY
            DYNPROBAUSTEIN2 = TAXI_BODY_SUBSCREEN.


  IF FLAG-LEAVE NE SPACE.
    LEAVE.
  ENDIF.

ENDFORM.