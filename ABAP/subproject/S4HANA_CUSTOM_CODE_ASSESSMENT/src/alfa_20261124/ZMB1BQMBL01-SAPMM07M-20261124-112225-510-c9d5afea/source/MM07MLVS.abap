*---------------------------------------------------------------------*
*       Modulpool SAPMM07M: Form-Routinen LVS                         *
*---------------------------------------------------------------------*
*       Inhalt:                                                       *
*                                                                     *
* perform GEWICHT_BERECHNEN.      Gewicht in WM-Gew.einheit berechnen *
* perform KOPIEREN_LEIT_TO_LEIT   Leit-MSEG  nach Leit-LK0*           *
* perform KOPIEREN_LEIT_TO_UM.    Leit-MSEG  nach Gegen-LK0*          *
* perform KOPIEREN_UM_TO_LEIT.    Gegen-MSEG  nach Leit-LK0*          *
* perform KOPIEREN_UM_TO_UM.      Gegen-MSEG nach Gegen-LK0*          *
* perform KOPIEREN_SOND_TO_LIPS.  Leit Sonderbest. nach Lips          *
* perform KOPIEREN_USOND_TO_LIPS. Gegen Sonderbest. nach Lips         *
* perform LAGERCONTROLLING_VORBEREITEN.Vorbereiten MC-Strukturen      *
* perform LK01_GENERIEREN.        Aufbauen LVS-Kommunikationssatz     *
* perform LK02_GENERIEREN.        Aufbauen LVS-Kommunikationssatz LK02*
* perform LVS_SEGMENTE_ERGAENZEN. Ergaenzen LVS-Kommunikationssätze    *
* perform LVS_SEGMENT_GENERIEREN. Aufbauen LVS-Kommunikationssätze    *
* perform LVS_SONDERBESTANDSNR.   Ermitteln LVS-Sonderbestandsnummer  *
* perform LVS_SONDERBESTANDSNR_UM. Ermitteln LVS-Sonderbest. Umlager.  *
* perform LVS_TBNUMMER_RUECKMELDEN_KANBAN. Rückmelden Kanban           *
* perform LVS_TBNUMMERN_VERGEBEN. Vergeben Transportbedarfsnummern    *
* perform QUANTNUMMER_BESORGEN.   Ermitteln Quantnummer LK01          *
* perform QUANTNUMMER_BESORGEN_UB.Ermitteln Quantnummern LK02         *
* perform TA_AUTOMATISCH.         Automatische TA-Erstellung          *
* perform TBPOS_LESEN.            Palettierungsdaten aus TB-lesen     *
* perform T300T_LESEN.            Lesen Tabelle T300T                 *
* perform T301T_LESEN.            Lesen Tabelle T301T                 *
* perform T333T_LESEN.            Lesen Tabelle T333T                 *
* perform T340D_LESEN.            Lesen eines T340D Eintrags
* perform WMS_LIEFERUNG_ERZEUGEN. Aufruf Fb zur Lieferungserstellung  *
* perform WMS_LIEFERUNG_INIT.     Reset der Felder Lieferung          *
* perform WMS_LIPS_GENERIEREN.    Aufbau Kommunikationssatz Lieferung *
* perform HU_LK01_GENERIEREN.     Aufbau HU-Kommunikationssatz LK01   *
* perform HU_LK02_GENERIEREN.     Aufbau HU-Kommunikationssatz LK02   *
* perform wms_HUs_bestimmen.      Ermitteln HUs zur Fertigung "HP_325415
*---------------------------------------------------------------------*

DATA: BEGIN OF QSPERR OCCURS 0.
        INCLUDE STRUCTURE LQUA.
DATA: END OF QSPERR.

DATA: CON_KEY_LK01(1)     TYPE C   VALUE '1',
      CON_KEY_LK02_1(1)   TYPE C   VALUE '2',
      CON_KEY_LK02_2(1)   TYPE C   VALUE '3',
      CON_X               TYPE C   VALUE 'X',
      CON_KZERZ_1         TYPE C   VALUE '1',
      CON_SHKZG_UM_1      LIKE LIPS-SHKZG_UM VALUE '1',
      CON_SHKZG_UM_2      LIKE LIPS-SHKZG_UM VALUE '2'.

DATA: CON_KZFME_WIRK      LIKE LTBP-KZFME VALUE 'A',
      CON_KZFME_PROD      LIKE LTBP-KZFME VALUE 'B'.

DATA: CON_VBTYP_ANLIEF    LIKE LIKP-VBTYP VALUE '7',  "Anlieferung
      CON_VBTYP_RETOURE   LIKE LIKP-VBTYP VALUE 'T'.  "Anlief/Retour

DATA: CON_RFC_CALL_WMIM   LIKE TRFCQOUT-QNAME VALUE 'WMIM'.

TABLES: LIKP.

TABLES: LQUA, T331, RLSOND.

DATA: INIT_PKNUM LIKE LK01-PKNUM,
      INIT_PKPOS LIKE LK01-PKPOS.
DATA: INIT_PKKEY LIKE LK01-PKKEY.      " Umstellung auf pkkey
DATA: HLP_MGEWI LIKE LK01-BRGEW.

*........Ersatzstrukturen für ON CHANGE OF bei TB-Erstellung............

DATA: BEGIN OF CHANGE_TB_1,
      LGNUM LIKE XLK01-LGNUM,
      DIRTA LIKE XLK01-DIRTA,
      BWLVS LIKE XLK01-BWLVS,
      BETYP LIKE XLK01-BETYP,
      BENUM LIKE XLK01-BENUM,
      VLTYP LIKE XLK01-VLTYP,
      VLPLA LIKE XLK01-VLPLA,
      NLTYP LIKE XLK01-NLTYP,
      NLPLA LIKE XLK01-NLPLA,
      END OF CHANGE_TB_1.

DATA: BEGIN OF CHANGE_TB_2,
      LGNUM LIKE XLK01-LGNUM,
      DIRTA LIKE XLK01-DIRTA,
      BWLVS LIKE XLK01-BWLVS,
      BETYP LIKE XLK01-BETYP,
      BENUM LIKE XLK01-BENUM,
      VLTYP LIKE XLK01-VLTYP,
      VLPLA LIKE XLK01-VLPLA,
      NLTYP LIKE XLK01-NLTYP,
      NLPLA LIKE XLK01-NLPLA,
      END OF CHANGE_TB_2.

*........ Sturkturen fürs Anlegen einer Lieferung

DATA: BEGIN OF XLK03 OCCURS 0.
        INCLUDE STRUCTURE KOMDLGN.
DATA: END OF XLK03.
DATA: GT_REHANG_HU TYPE HUM_REHANG_HU_T.                "<<<< HP_325415
DATA: BEGIN OF HLP_VBFS OCCURS 0.
        INCLUDE STRUCTURE VBFS.
DATA: END OF HLP_VBFS.


ENHANCEMENT-POINT MM07MLVS_02 SPOTS ES_SAPMM07M STATIC.

DATA: BEGIN OF HLP_VBLS OCCURS 0.
        INCLUDE STRUCTURE VBLS.
DATA: END OF HLP_VBLS.

DATA: BEGIN OF HLP_VBSK_E.
        INCLUDE STRUCTURE VBSK.
DATA: END OF HLP_VBSK_E.

DATA: BEGIN OF HLP_VBSK_I.
        INCLUDE STRUCTURE VBSK.
DATA: END OF HLP_VBSK_I.

DATA: PARID_VBELN(3)            TYPE C VALUE 'VL ',
      PARID_ANLIE(3)            TYPE C VALUE 'VLM'.
DATA: NUM_XLK03(4)              TYPE N,"Anzahl MB-Positionen
      NUM_VBLS(4)               TYPE N,"Anzahl LF-Positionen
      VBELN_FIRST               LIKE LIPS-VBELN.
DATA: CON_ERROR                 LIKE SY-MSGTY VALUE 'E',
      CON_ABBRUCH               LIKE SY-MSGTY VALUE 'A',
      FLG_ANLIEFERUNG,
      FLG_UMBUCHUNG.

DATA: SOBKZ_EINZELBESTAND    TYPE C  VALUE 'E',
      SOBKZ_PROJEKT          TYPE C  VALUE 'Q'.

*........ definitionen für hu's.......................................

DATA: BEGIN OF ITLHUQUA OCCURS 0.
        INCLUDE STRUCTURE LHUQUA_VB.
DATA: END OF ITLHUQUA.

DATA: HLP_ZEILE                 LIKE MSEG-ZEILE,
      HLP_SUMME                 LIKE MSEG-MENGE.

*SPE INB ST
*VL-MM consistencies vendor return with creation of outbound delivery
DATA: GS_BORGR_CONTROL TYPE BORGR_CONTROL.

*---------------------------------------------------------------------*
*       FORM GEWICHT_BERECHNEN                                        *
*---------------------------------------------------------------------*
*       Dieses Modul berechnet das Gewicht der Materialbelegpositionen*
*       in der Gewichtseinheit der Lagernummer                        *
*---------------------------------------------------------------------*
FORM GEWICHT_BERECHNEN USING P_LGNUM P_BRGEW P_GEWEI P_MENGE
                       CHANGING EP_BRGEW EP_GEWEI.
  PERFORM T340D_LESEN USING P_LGNUM.
  CLEAR HLP_MGEWI.
  HLP_MGEWI = P_BRGEW * P_MENGE / 1000.                    "n_v_1236721
  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      UNIT_IN  = P_GEWEI
      UNIT_OUT = T340D-GEWEI
      INPUT    = HLP_MGEWI
    IMPORTING
      OUTPUT   = EP_BRGEW.                                 "n_^_1236721
  EP_GEWEI = T340D-GEWEI.
ENDFORM.                    "gewicht_berechnen

*---------------------------------------------------------------------*
*       FORM Kopieren_LEIT_TO_LEIT                                    *
*---------------------------------------------------------------------*
*       Kopieren der Leitbuchung aus MSEG in Leitfelder XLK03         *
*---------------------------------------------------------------------*
FORM KOPIEREN_LEIT_TO_LEIT.

  DATA: LS_ISU_LVS_SONDERBESTANDSNR TYPE ISU_LVS_SONDERBESTANDSNR. "IS2ERP

  MOVE: XMSEG-MATNR TO XLK03-MATNR,
        XMSEG-WERKS TO XLK03-WERKS,
        XMSEG-LGORT TO XLK03-LGORT,
        XMSEG-CHARG TO XLK03-CHARG,
        XMSEG-BWTAR TO XLK03-BWTAR,
        XMSEG-BESTQ TO XLK03-BESTQ,
        XMSEG-SOBKZ TO XLK03-SOBKZ.
  IF XVM07M-XCHPF IS INITIAL.
    CLEAR XLK03-CHARG.
  ENDIF.
ENHANCEMENT-POINT KOPIEREN_LEIT_TO_LEIT SPOTS ES_SAPMM07M.
  PERFORM LVS_SONDERBESTANDSNR USING XMSEG-SOBKZ
                                     XLK03-SONUM
                                     LS_ISU_LVS_SONDERBESTANDSNR. "IS2ERP
ENDFORM.                    "kopieren_leit_to_leit

*---------------------------------------------------------------------*
*       FORM Kopieren_UM_TO_UM                                        *
*---------------------------------------------------------------------*
*       Kopieren der Gegenbuchung aus MSEG in UM-Felder XLK03
*---------------------------------------------------------------------*
FORM KOPIEREN_UM_TO_UM.

  MOVE: XMSEG-UMMAT TO XLK03-UMMAT,
        XMSEG-UMWRK TO XLK03-UMWRK,
        XMSEG-UMLGO TO XLK03-UMLGO,
        XMSEG-UMCHA TO XLK03-UMCHA,
        XMSEG-UMBAR TO XLK03-UMBAR,
       ZDM07M-UMBSQ TO XLK03-UMBSQ,
        XMSEG-UMSOK TO XLK03-UMSOK.
  IF ZDM07M-UMXCH IS INITIAL.
    CLEAR XLK03-UMCHA.
  ENDIF.
  PERFORM LVS_SONDERBESTANDSNR_UM USING XMSEG-UMSOK
                                        XLK03-USONU.
ENDFORM.                    "kopieren_um_to_um

*---------------------------------------------------------------------*
*       FORM Kopieren_LEIT_TO_UM                                      *
*---------------------------------------------------------------------*
*       Kopieren der Leitbuchung aus MSEG in UM-Felder XLK03
*---------------------------------------------------------------------*
FORM KOPIEREN_LEIT_TO_UM.

  DATA: LS_ISU_LVS_SONDERBESTANDSNR TYPE ISU_LVS_SONDERBESTANDSNR. "IS2ERP

  MOVE: XMSEG-MATNR TO XLK03-UMMAT,
        XMSEG-WERKS TO XLK03-UMWRK,
        XMSEG-LGORT TO XLK03-UMLGO,
        XMSEG-CHARG TO XLK03-UMCHA,
        XMSEG-BWTAR TO XLK03-UMBAR,
        XMSEG-BESTQ TO XLK03-UMBSQ,
        XMSEG-SOBKZ TO XLK03-UMSOK.
  IF XVM07M-XCHPF IS INITIAL.
    CLEAR XLK03-UMCHA.
  ENDIF.
ENHANCEMENT-POINT KOPIEREN_LEIT_TO_UM_01 SPOTS ES_SAPMM07M.

  PERFORM LVS_SONDERBESTANDSNR USING XMSEG-SOBKZ
                                      XLK03-USONU
                                      LS_ISU_LVS_SONDERBESTANDSNR. "IS2ERP
ENDFORM.                    "kopieren_leit_to_um
*---------------------------------------------------------------------*
*       FORM Kopieren_UM_TO_LEIT                                      *
*---------------------------------------------------------------------*
*       Kopieren der Gegenbuchung aus MSEG in Leit-Felder XLK03
*---------------------------------------------------------------------*
FORM KOPIEREN_UM_TO_LEIT.


  MOVE: XMSEG-UMMAT TO XLK03-MATNR,
        XMSEG-UMWRK TO XLK03-WERKS,
        XMSEG-UMLGO TO XLK03-LGORT,
        XMSEG-UMCHA TO XLK03-CHARG,
        XMSEG-UMBAR TO XLK03-BWTAR,
       ZDM07M-UMBSQ TO XLK03-BESTQ,
        XMSEG-UMSOK TO XLK03-SOBKZ.
  IF ZDM07M-UMXCH IS INITIAL.
    CLEAR XLK03-CHARG.
  ENDIF.

  PERFORM LVS_SONDERBESTANDSNR_UM USING XMSEG-UMSOK
                                     XLK03-SONUM.

ENDFORM.                    "kopieren_um_to_leit

*----------------------------------------------------------------------*
*       FORM Kopieren_SOND_TO_LIPS                                     *
*----------------------------------------------------------------------*
*       Kopieren der Sonderbestandsfelder aus der Leitbuchung in       *
*       entsprechenden Felder der Lips                                 *
*----------------------------------------------------------------------*
FORM KOPIEREN_SOND_TO_LIPS.

*  move: xmseg-sobkz to xlk03-sobkz.  "Muss immer vorher passieren
  CASE XMSEG-SOBKZ.
    WHEN SOBKZ_EINZELBESTAND.
      MOVE: XMSEG-MAT_KDAUF TO XLK03-VBELV,
            XMSEG-MAT_KDPOS TO XLK03-POSNV.
    WHEN SOBKZ_PROJEKT.
      MOVE XMSEG-MAT_PSPNR TO XLK03-PS_PSP_PNR.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "kopieren_sond_to_lips

*----------------------------------------------------------------------*
*       FORM Kopieren_USOND_TO_LIPS                                    *
*----------------------------------------------------------------------*
*       Kopieren der Sonderbestandsfelder aus der Gegenbuchung in      *
*       entsprechenden Felder der Lips                                 *
*----------------------------------------------------------------------*
FORM KOPIEREN_USOND_TO_LIPS.

*  move: xmseg-umsok to xlk03-umsok.     "Muss immer vorher passieren
  CASE XMSEG-UMSOK.
    WHEN SOBKZ_EINZELBESTAND.
*      move: xmseg-kdauf to xlk03-vbelv,
*            xmseg-kdpos to xlk03-posnv.
      MOVE: XMSEG-KDAUF TO XLK03-KDAUF,
            XMSEG-KDPOS TO XLK03-KDPOS.
    WHEN SOBKZ_PROJEKT.
*     move xmseg-ps_psp_pnr to xlk03-ps_psp_pnr.
      MOVE XMSEG-PS_PSP_PNR TO XLK03-UM_PS_PSP_PNR.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "kopieren_usond_to_lips

*---------------------------------------------------------------------*
*       FORM LAGERCONTROLLING_VORBEREITEN        (Ab 3.0A)            *
*---------------------------------------------------------------------*
*       Dieses Modul füllt aus der aufgebauten LK01-Struktur die      *
*       benötigten MC-Strukturen MCWMHD und MCWMIT.                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM LAGERCONTROLLING_VORBEREITEN TABLES XMCWMHD STRUCTURE MCWMHDB
                                         XMCWMIT STRUCTURE MCWMITB
                                         XLK01   STRUCTURE LK01
                                  USING  NEUAB   LIKE RLMC1-NEUAB.

  DATA: HLP_MBLNR_ALT LIKE XLK01-MBLNR,
        HLP_BWLVS_ALT LIKE XLK01-BWLVS,
        HLP_BRGEW     LIKE XLK01-BRGEW.

*........Existieren XLK01-Sätze?........................................
  READ TABLE XLK01 INDEX 1.
  IF NOT SY-SUBRC IS INITIAL.
    EXIT.
  ENDIF.

*........Initialisierung der MC-Strukturen Lagercontrolling.............
  REFRESH XMCWMHD.
  REFRESH XMCWMIT.

*........Initialisierung für Gruppenwechselsteuerung....................
  CLEAR HLP_MBLNR_ALT.
  CLEAR HLP_BWLVS_ALT.

*........Sortierung der Belegspositionen................................
  SORT XLK01 BY MBLNR BWLVS MBPOS.

*........Tabelle XLK01 übernehmen......................................
  LOOP AT XLK01.

*........Initialisierung................................................
    CLEAR XMCWMHD.
    CLEAR XMCWMIT.

*........Daten übertragen ..............................................
    MOVE-CORRESPONDING XLK01 TO XMCWMHD.

    MOVE XLK01-BRGEW TO HLP_BRGEW.
    CLEAR XLK01-BRGEW.
    MOVE-CORRESPONDING XLK01 TO XMCWMIT.
    MOVE HLP_BRGEW TO XLK01-BRGEW.

*........Bewegungsart im Feld rltyp der Position sichern, damit.........
*........später zum Kopf die entsprechenden Position gefunden werden....
    MOVE XLK01-BWLVS TO XMCWMIT-RLTYP.

*........Menge und Schlüssel übernehmen.................................
    IF ( XLK01-NSCHN =  CON_X    AND   "WA-Buchung
         XLK01-XSTBW <> CON_X   ).

      XMCWMIT-LGTYP = XLK01-NLTYP.
      XMCWMIT-LGPLA = XLK01-NLPLA.
      XMCWMIT-EXAMG = XLK01-MENGE.
      XMCWMIT-EXAGW = XLK01-BRGEW.
      XMCWMIT-EXAPC = 1.

    ELSEIF  ( XLK01-VSCHN =  CON_X AND "WA-Stornobuchung
              XLK01-XSTBW =  CON_X ).

      XMCWMIT-LGTYP = XLK01-VLTYP.
      XMCWMIT-LGPLA = XLK01-VLPLA.
      XMCWMIT-EXAMG = - XLK01-MENGE.
      XMCWMIT-EXAGW = - XLK01-BRGEW.
      XMCWMIT-EXAPC = 1.

    ELSEIF ( XLK01-VSCHN =  CON_X AND  "WE-Buchung
             XLK01-XSTBW <>  CON_X ).

      XMCWMIT-LGTYP = XLK01-VLTYP.
      XMCWMIT-LGPLA = XLK01-VLPLA.
      XMCWMIT-EXEMG = XLK01-MENGE.
      XMCWMIT-EXEGW = XLK01-BRGEW.
      XMCWMIT-EXEPC = 1.

    ELSEIF ( XLK01-NSCHN =  CON_X    AND    "WE-Stornobuchung
             XLK01-XSTBW =  CON_X ).

      XMCWMIT-LGTYP = XLK01-NLTYP.
      XMCWMIT-LGPLA = XLK01-NLPLA.
      XMCWMIT-EXEMG = - XLK01-MENGE.
      XMCWMIT-EXEGW = - XLK01-BRGEW.
      XMCWMIT-EXEPC = 1.

    ENDIF.

*........Sonstige Felder................................................
    IF NOT NEUAB IS INITIAL.           "-> Statistikneuaufbau
      XMCWMIT-MB_MBLNR = XLK01-MBLNR.
      XMCWMIT-MB_MJAHR = XLK01-MJAHR.
      XMCWMHD-TB_UNAME = XLK01-BNAME.  "USNAM aus XMKPF
      XMCWMHD-BDATU    = XLK01-PDATU.
    ELSE.                              "-> Normale IM-WM SChnittst.
      XMCWMHD-TB_UNAME = SY-UNAME.     "User-name
    ENDIF.
    XMCWMIT-BASME    = XMCWMIT-MEINS.  "Mengeneinheit

    IF XLK01-NKDYN IS INITIAL AND      "Dynamische Koordinate?
       XLK01-VKDYN IS INITIAL.

      SELECT SINGLE * FROM LAGP WHERE  "Lagerbereich aus LAGP
          LGNUM = XMCWMIT-LGNUM AND
          LGTYP = XMCWMIT-LGTYP AND
          LGPLA = XMCWMIT-LGPLA.

      IF SY-SUBRC = 0.
        XMCWMIT-LGBER = LAGP-LGBER.
      ELSE.
        XMCWMIT-LGBER = '001'.
      ENDIF.

    ELSE.

      XMCWMIT-LGBER = '001'.           "Lagerbereich dyn. Koo.

    ENDIF.

*........SUPKZ setzen...................................................
    XMCWMHD-SUPKZ = '2'.
    XMCWMIT-SUPKZ = '2'.

*........Buchungskreis lesen............................................
    SELECT SINGLE * FROM T001W WHERE
        WERKS = XMCWMIT-WERKS.

    IF SY-SUBRC = 0.

      SELECT SINGLE * FROM T001K WHERE
           BWKEY = T001W-BWKEY.

      IF SY-SUBRC = 0.
        XMCWMIT-BUKRS = T001K-BUKRS.
      ELSE.
        CLEAR T001K.
        CLEAR XMCWMIT-BUKRS .
      ENDIF.

    ELSE.
      CLEAR T001W.
    ENDIF.

*........Kopfdaten füllen...............................................
*........pro Materialbeleg und Bewegungsart wird ein Kopfsatz erzeugt...
    IF NEUAB IS INITIAL.
*      Online-Verbuchung
      IF XLK01-BWLVS <> HLP_BWLVS_ALT.
        APPEND XMCWMHD.
        HLP_BWLVS_ALT = XLK01-BWLVS.
      ENDIF.
    ELSE.
*      Statistikdatenneuaufbau
      IF     XLK01-MBLNR <> HLP_MBLNR_ALT
        OR ( XLK01-MBLNR = HLP_MBLNR_ALT
        AND  XLK01-BWLVS <> HLP_BWLVS_ALT ).
        APPEND XMCWMHD.
        HLP_MBLNR_ALT = XLK01-MBLNR.
        HLP_BWLVS_ALT = XLK01-BWLVS.
      ENDIF.
    ENDIF.

*........Positionsdaten anhängen........................................
    APPEND XMCWMIT.

  ENDLOOP.

ENDFORM.                    "lagercontrolling_vorbereiten

*---------------------------------------------------------------------*
*       FORM LK01_GENERIEREN                                          *
*---------------------------------------------------------------------*
*       Dieses Modul generiert für die Materialbelegpositionen        *
*       einen LVS-Kommunikationssatz für Ein/Auslagerungen.           *
*---------------------------------------------------------------------*
FORM LK01_GENERIEREN.

  DATA: LS_ISU_LVS_SONDERBESTANDSNR TYPE ISU_LVS_SONDERBESTANDSNR. "IS2ERP

  CHECK NOT XMSEG-MENGE IS INITIAL.
  CLEAR XLK01.

*........Daten aus XMSEG..............................................*

  MOVE: XMSEG-MANDT TO XLK01-MANDT,
        XMSEG-LGNUM TO XLK01-LGNUM,
        XMSEG-MATNR TO XLK01-MATNR,
        XMSEG-WERKS TO XLK01-WERKS,
        XMSEG-LGORT TO XLK01-LGORT,
        XMSEG-CHARG TO XLK01-CHARG,
        XMSEG-BESTQ TO XLK01-BESTQ,
        XMSEG-MENGE TO XLK01-MENGE,
        XMSEG-MEINS TO XLK01-MEINS,
        XMSEG-ERFMG TO XLK01-MENGA,
        XMSEG-ERFME TO XLK01-ALTME,
        XMSEG-WEMPF TO XLK01-WEMPF,
        XMSEG-ABLAD TO XLK01-ABLAD,
        XMSEG-MBLNR TO XLK01-MBLNR,
        XMSEG-MJAHR TO XLK01-MJAHR,
        XMSEG-ZEILE TO XLK01-MBPOS,
        XMSEG-BWART TO XLK01-BWART,
        XMSEG-BWLVS TO XLK01-BWLVS,
        XMSEG-TBPRI TO XLK01-TBPRI,
        XMSEG-VSCHN TO XLK01-VSCHN,
        XMSEG-NSCHN TO XLK01-NSCHN,
        XMSEG-SOBKZ TO XLK01-SOBKZ.

*........Setzen Lagertyp/Lagerplatz bei Einlagerung...................*

  IF NOT XMSEG-VSCHN IS INITIAL.
    MOVE: XMSEG-LGTYP TO XLK01-VLTYP,
          XMSEG-LGPLA TO XLK01-VLPLA,
          XMSEG-DYPLA TO XLK01-VKDYN.

*........Palettierungsdaten setzen
    MOVE: ZDM07M-ANZL1 TO XLK01-ANZL1,
          ZDM07M-ANZL2 TO XLK01-ANZL2,
          ZDM07M-LMEN1 TO XLK01-LMEN1,
          ZDM07M-LMEN2 TO XLK01-LMEN2,
          ZDM07M-LETY1 TO XLK01-LETY1,
          ZDM07M-LETY2 TO XLK01-LETY2.


*........Setzen Lagertyp/Lagerplatz bei Auslagerung...................*

  ELSE.
    MOVE: XMSEG-LGTYP TO XLK01-NLTYP,
          XMSEG-LGPLA TO XLK01-NLPLA,
          XMSEG-DYPLA TO XLK01-NKDYN.
  ENDIF.

*........Daten aus ZDM07M.............................................*

  MOVE: ZDM07M-UMREZ TO XLK01-UMREZ,
        ZDM07M-UMREN TO XLK01-UMREN,
        ZDM07M-XSTBW TO XLK01-XSTBW,
        ZDM07M-PKNUM TO XLK01-PKNUM,
        ZDM07M-PKPOS TO XLK01-PKPOS.
  IF LVS_TAFKZ EQ 'A'.
    MOVE ZDM07M-DIRTA TO XLK01-DIRTA.
  ENDIF.

*........Daten aus XVM07M.............................................*

  MOVE: XVM07M-BETYP TO XLK01-BETYP,
        XVM07M-BENUM TO XLK01-BENUM,
        XVM07M-AUTTA TO XLK01-AUTTA,
        XVM07M-TRART TO XLK01-TRART,
        XVM07M-TBFKZ TO XLK01-TBFKZ,
        XVM07M-QPLOS TO XLK01-QPLOS,                        "QM
        XVM07M-QPLOA TO XLK01-QPLOA,                        "QM
        XVM07M-VBELN TO XLK01-VBELN,   "Lieferung
        XVM07M-VBELP TO XLK01-POSNR,   "Lieferungsposition
        XVM07M-LGNTB TO XLK01-LGNTB,   "Lagerort des TB
        XVM07M-L2SKR TO XLK01-L2SKR,   "2-stufige Kommi
        XVM07M-PKKEY TO XLK01-PKKEY.   "Umstellung auf PKKEY (Kanban)

*........Benutzernamen übernehmen.....................................*

  MOVE: SY-UNAME     TO XLK01-BNAME.

*........Setzen Plantermine...........................................*

  MOVE SY-DATLO TO XLK01-PDATU.
  CLEAR            XLK01-PZEIT.

*........Setzen Wareneingangsdatum....................................*

  IF NOT XMSEG-VSCHN IS INITIAL.
    CASE XVM07M-WEDKZ.
      WHEN CON_TAGESDATUM.
        MOVE SY-DATLO TO XLK01-WDATU.
      WHEN CON_BELEGDATUM.
        MOVE MKPF-BLDAT TO XLK01-WDATU.
      WHEN CON_BUCHUNGSDATUM.
        MOVE MKPF-BUDAT TO XLK01-WDATU.
    ENDCASE.
  ENDIF.

*........Setzen Mindesthaltbarkeitsdatum.............................*

  IF NOT XMSEG-VSCHN IS INITIAL.
    MOVE XMSEG-VFDAT TO XLK01-VFDAT.
  ENDIF.

*........Setzen Sonderbestandsnummer..................................*

  MOVE XMSEG-SOBKZ TO XLK01-SOBKZ.
ENHANCEMENT-POINT LK01_GENERIEREN_01 SPOTS ES_SAPMM07M.
  PERFORM LVS_SONDERBESTANDSNR USING XMSEG-SOBKZ
                                     XLK01-SONUM
                                     LS_ISU_LVS_SONDERBESTANDSNR. "IS2ERP

*........Setzen Stornobelegnummer für TB-Stornierung....................
  IF NOT ZDM07M-TBBEL IS INITIAL.
    MOVE: ZDM07M-TBBEL TO XLK01-SMBLN,
          ZDM07M-TBBJR TO XLK01-SJAHR.
    IF NOT ZDM07M-TBBPO IS INITIAL.
      MOVE ZDM07M-TBBPO TO XLK01-SMBLP.
    ELSE.
      MOVE XMSEG-SMBLP TO XLK01-SMBLP.
    ENDIF.
  ENDIF.

*........Berechnen Gewicht............................................*

  PERFORM GEWICHT_BERECHNEN USING    XLK01-LGNUM
                                     XVM07M-BRGEW
                                     XVM07M-GEWEI
                                     XLK01-MENGE
                            CHANGING XLK01-BRGEW
                                     XLK01-GEWEI.


*........Setzen Info über Produktmengeneinheit

  IF ZDM07M-KZWSO = CON_KZFME_PROD.
    MOVE ZDM07M-KZWSO TO XLK01-KZFME.
  ENDIF.

*........Ermitteln Quantnummer........................................*

  PERFORM QUANTNUMMER_BESORGEN.

*........Aufnehmen Eintrag in Tabelle.................................*

  APPEND XLK01.

ENDFORM.                    "lk01_generieren
*---------------------------------------------------------------------*
*       FORM LK02_GENERIEREN                                          *
*---------------------------------------------------------------------*
*       Dieses Modul generiert für die Materialbelegpositionen        *
*       einen LVS-Kommunikationssatz für Umbuchungen.                 *
*---------------------------------------------------------------------*
FORM LK02_GENERIEREN.

  DATA: LS_ISU_LVS_SONDERBESTANDSNR TYPE ISU_LVS_SONDERBESTANDSNR. "IS2ERP

  CLEAR XLK02.

*........Daten aus XMSEG..............................................*

  MOVE: XMSEG-MANDT TO XLK02-MANDT,
        XMSEG-LGNUM TO XLK02-LGNUM,
        XMSEG-MBLNR TO XLK02-MBLNR,
        XMSEG-MJAHR TO XLK02-MJAHR,
        XMSEG-ZEILE TO XLK02-MBPOS,
        XMSEG-BWART TO XLK02-BWART,
        XMSEG-BWLVS TO XLK02-BWLVS,
        XMSEG-LGTYP TO XLK02-LGTYP,
        XMSEG-LGPLA TO XLK02-LGPLA.

*........Ermitteln Quantnummern.......................................*
  PERFORM QUANTNUMMER_BESORGEN_UB.

  IF XMSEG-SHKZG EQ H.
    MOVE: XMSEG-MATNR TO XLK02-MATN1,
          XMSEG-WERKS TO XLK02-WERK1,
          XMSEG-LGORT TO XLK02-LGOR1,
          XMSEG-CHARG TO XLK02-CHRG1,
          XMSEG-BESTQ TO XLK02-BSTQ1,
          XMSEG-SOBKZ TO XLK02-SOKZ1.
ENHANCEMENT-POINT LK02_GENERIEREN_01 SPOTS ES_SAPMM07M.
    PERFORM LVS_SONDERBESTANDSNR USING XMSEG-SOBKZ
                                       XLK02-SONR1
                                       LS_ISU_LVS_SONDERBESTANDSNR. "IS2ERP
    MOVE: XMSEG-UMMAT TO XLK02-MATN2,
          XMSEG-UMWRK TO XLK02-WERK2,
          XMSEG-UMLGO TO XLK02-LGOR2,
          XMSEG-UMCHA TO XLK02-CHRG2,
         ZDM07M-UMBSQ TO XLK02-BSTQ2,
          XMSEG-UMSOK TO XLK02-SOKZ2.
    PERFORM LVS_SONDERBESTANDSNR_UM USING XMSEG-UMSOK
                                          XLK02-SONR2.
  ELSE.
    MOVE: XMSEG-MATNR TO XLK02-MATN2,
          XMSEG-WERKS TO XLK02-WERK2,
          XMSEG-LGORT TO XLK02-LGOR2,
          XMSEG-CHARG TO XLK02-CHRG2,
          XMSEG-BESTQ TO XLK02-BSTQ2,
          XMSEG-SOBKZ TO XLK02-SOKZ2.
ENHANCEMENT-POINT LK02_GENERIEREN_02 SPOTS ES_SAPMM07M.
    PERFORM LVS_SONDERBESTANDSNR USING XMSEG-SOBKZ
                                       XLK02-SONR2
                                       LS_ISU_LVS_SONDERBESTANDSNR. "IS2ERP
    MOVE: XMSEG-UMMAT TO XLK02-MATN1,
          XMSEG-UMWRK TO XLK02-WERK1,
          XMSEG-UMLGO TO XLK02-LGOR1,
          XMSEG-UMCHA TO XLK02-CHRG1,
         ZDM07M-UMBSQ TO XLK02-BSTQ1,
          XMSEG-UMSOK TO XLK02-SOKZ1.
    PERFORM LVS_SONDERBESTANDSNR_UM USING XMSEG-UMSOK
                                          XLK02-SONR1.
  ENDIF.

  MOVE:     XMSEG-MENGE TO XLK02-MENGE,
            XMSEG-MEINS TO XLK02-MEINS,
            XMSEG-ERFMG TO XLK02-MNGA1,
            XMSEG-ERFME TO XLK02-ALTM1.

*........Daten aus ZDM07M.............................................*

  MOVE: ZDM07M-UMREZ TO XLK02-UMRZ1,
        ZDM07M-UMREN TO XLK02-UMRN1,
        ZDM07M-WENUM TO XLK02-WENUM,
        ZDM07M-UBFKZ TO XLK02-UBFKZ.
  IF LVS_TAFKZ EQ 'A'.
    MOVE ZDM07M-DIRTA TO XLK02-DIRTA.
  ENDIF.

*........Setzen Stornobelegnummer für TB-Stornierung....................
  IF NOT ZDM07M-TBBEL IS INITIAL.
    MOVE: ZDM07M-TBBEL TO XLK02-SMBLN,
          ZDM07M-TBBJR TO XLK02-SJAHR.
    IF NOT ZDM07M-TBBPO IS INITIAL.
      MOVE ZDM07M-TBBPO TO XLK02-SMBLP.                     "n_1066485
    ELSE.
      MOVE XMSEG-SMBLP TO XLK02-SMBLP.                      "n_1066485
    ENDIF.
  ENDIF.

*........Reset Mengeneinheiten bei Storno Material an Material
  IF XMSEG-SHKZG NE H AND                                   "KIRK010990
     XLK02-MATN1 NE XLK02-MATN2.                            "KIRK010990
    MOVE: XMSEG-MENGE TO XLK02-MNGA1,                       "KIRK010990
          XMSEG-MEINS TO XLK02-ALTM1.                       "KIRK010990
    XLK02-UMRZ1 = 1.                                        "KIRK010990
    XLK02-UMRN1 = 1.                                        "KIRK010990
  ENDIF.                                                    "KIRK010990


*........Daten aus XVM07M.............................................*

  MOVE: XVM07M-QPLOS TO XLK02-QPLOS,                        "QM
        XVM07M-QPLOA TO XLK02-QPLOA,                        "QM
        XVM07M-AUTTA TO XLK02-AUTTA.

*........Ermitteln Umbuchungsnummer...................................*

  IF NOT ZDM07M-UBFKZ IS INITIAL.      "nur wenn LUBU erstellt wird

    PERFORM T340D_LESEN USING XLK02-LGNUM.

    MOVE: T340D-NUKUB  TO NUMMERNKREIS,
          XLK02-LGNUM  TO SUBOBJEKT.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        NR_RANGE_NR        = NUMMERNKREIS
        OBJECT             = CON_UMBUCHUNGSNUMMER
        SUBOBJECT          = SUBOBJEKT
      IMPORTING
        NUMBER             = XLK02-UBNUM
        RETURNCODE         = NV-RETURNCODE
      EXCEPTIONS
        INTERVAL_NOT_FOUND = 1.

*........Nummernkreis nicht gepflegt....................................

    IF SY-SUBRC = 1.
      PERFORM NUMMERNKREIS_NICHT_DA(SAPFL000)
              USING CON_UMBUCHUNGSNUMMER NUMMERNKREIS.
    ENDIF.

*........Restteil des Nummernkreisintervalls erreicht...................

    IF NV-RETURNCODE = 1.
      PERFORM NUMMERNKREIS_ZU_ENDE(SAPFL000)
              USING CON_UMBUCHUNGSNUMMER NUMMERNKREIS.
    ENDIF.
  ENDIF.

*........Berechnen Gewicht............................................*
*........Das Gewicht wird immer aus dem Leitmaterial berechnet........*
  PERFORM GEWICHT_BERECHNEN USING    XLK02-LGNUM
                                     XVM07M-BRGEW
                                     XVM07M-GEWEI
                                     XLK02-MENGE
                            CHANGING XLK02-BRGW1
                                     XLK02-GWEI1.

  PERFORM GEWICHT_BERECHNEN USING    XLK02-LGNUM            "v_n_910880
                                     XVM07M-BRGEW
                                     XVM07M-GEWEI
                                     XLK02-MENGE
                            CHANGING XLK02-BRGW2
                                     XLK02-GWEI2.           "^_n_910880

*........Aufnehmen Eintrag in Tabelle.................................*

  APPEND XLK02.

  IF NOT XLK02-UBNUM IS INITIAL.

    CLEAR XLTBUB.
    XLTBUB-LGNUM = XLK02-LGNUM.
    XLTBUB-UBNUM = XLK02-UBNUM.
    APPEND XLTBUB.

  ENDIF.
*........Fortschreiben Materialsegment................................*

  MOVE XLK02-UBNUM TO XMSEG-UBNUM.
  MODIFY XMSEG.

ENDFORM.                    "lk02_generieren

*---------------------------------------------------------------------*
*       FORM LVS_SEGMENTE_ERGAENZEN                                   *
*---------------------------------------------------------------------*
*       Die LVS-Kommunikationssätze werden ergaenzt.                  *
*---------------------------------------------------------------------*
FORM LVS_SEGMENTE_ERGAENZEN.

*........Ermitteln Transportbedarfsnummern............................*

  PERFORM LVS_TBNUMMERN_VERGEBEN.

*........Rückmelden TB-Nummer bei Kanbanabwicklung....................*

  PERFORM LVS_TBNUM_RUECKMELDEN_KANBAN.

*........Lagercontrolling zur Datenfortschreibung aufrufen..............

  PERFORM LAGERCONTROLLING_VORBEREITEN TABLES XMCWMHD
                                              XMCWMIT
                                              XLK01
                                       USING  SPACE.

*........HU-Konsitenzcheck.............................................*

  CALL FUNCTION 'HU_CONSISTENZ_CHECK'
    EXPORTING
      IT_MSEG           = XMSEG[]
      IT_VM07M          = XVM07M[]    "Note 805186
    EXCEPTIONS
      HU_NOT_CONSISTENT = 1
      OTHERS            = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "lvs_segmente_ergaenzen

*---------------------------------------------------------------------*
*       FORM LVS_SEGMENT_GENERIEREN                                   *
*---------------------------------------------------------------------*
*       Dieses Modul generiert für die Materialbelegpositionen        *
*       LVS-Kommunikationssätze für die spätere Verbuchung.           *
*---------------------------------------------------------------------*
FORM LVS_SEGMENT_GENERIEREN.

  IF NOT XVM07M-XHUPF IS INITIAL OR
    NOT ZDM07M-UMXHUPF IS INITIAL.
  ENDIF.

  CHECK NOT XMSEG-XBLVS IS INITIAL.

*........Analyse, welcher Kommunikationsatz relevant ist..............*

  IF ZDM07M-UMBKZ IS INITIAL.
    IF XVM07M-XHUPF IS INITIAL.
      PERFORM LK01_GENERIEREN.
    ELSE.
      PERFORM HU_LK01_GENERIEREN.
    ENDIF.
  ELSE.
    IF XVM07M-XHUPF IS INITIAL AND
       ZDM07M-UMXHUPF IS INITIAL.
      PERFORM LK02_GENERIEREN.
    ELSE.
      PERFORM HU_LK02_GENERIEREN.
    ENDIF.
  ENDIF.

ENDFORM.                    "lvs_segment_generieren

*---------------------------------------------------------------------*
*       FORM LVS_SONDERBESTANDSNR                                     *
*---------------------------------------------------------------------*
*       Ermitteln LVS-Sonderbestandsnummer                            *
*---------------------------------------------------------------------*
FORM LVS_SONDERBESTANDSNR USING P_SOBKZ LIKE MSEG-SOBKZ
                                P_SONUM
                                IS_ENHANCEMENT TYPE
                                    ISU_LVS_SONDERBESTANDSNR.

  MOVE-CORRESPONDING XMSEG TO RLSOND.

ENHANCEMENT-SECTION     LVS_SONDERBESTANDSNR_01 SPOTS ES_SAPMM07M.
  CALL FUNCTION 'L_SONUM_DETERMINE'
       EXPORTING
            I_SOBKZ = P_SOBKZ
*            I_UMSOK =
            I_RLSOND = RLSOND
       IMPORTING
            E_SONUM = P_SONUM.
*            E_USONU =.
END-ENHANCEMENT-SECTION.

ENDFORM.                    "lvs_sonderbestandsnr

*---------------------------------------------------------------------*
*       FORM LVS_SONDERBESTANDSNR_UM                                  *
*---------------------------------------------------------------------*
*       Ermitteln LVS-Sonderbestandsnummer Umlagerung                 *
*---------------------------------------------------------------------*
FORM LVS_SONDERBESTANDSNR_UM USING P_UMSOK LIKE MSEG-UMSOK
                                   P_USONU.

  CALL FUNCTION 'L_SONUM_DETERMINE'
       EXPORTING
*            i_sobkz =
            I_UMSOK = P_UMSOK
            I_RLSOND = RLSOND
       IMPORTING
*            e_sonum = p_sonum.
            E_USONU = P_USONU.

ENDFORM.                    "lvs_sonderbestandsnr_um

*---------------------------------------------------------------------*
*       FORM LVS_TBNUMMER_RUECKMELDEN_KANBAN                          *
*---------------------------------------------------------------------*
*       Rückmelden der Transportbedarfsnummer zur Fortschreibung des  *
*       Regelkreises in der Kanbanabwicklung                          *
*---------------------------------------------------------------------*
FORM LVS_TBNUM_RUECKMELDEN_KANBAN.

*........Selektieren der Kanbanrelevanten Sätze.......................*
*-->     Umstellung von pknum/pkpos auf pkkey

* loop at xlk01 where pknum ne init_pknum and
* pkpos ne init_pkpos.
  LOOP AT XLK01 WHERE PKKEY NE INIT_PKKEY.

*   call function 'PK_WRITE_TRNS_REQ_NO_IN_PKPS'
*        exporting
*             pknum = xlk01-pknum
*             pkpos = xlk01-pkpos
*             tbnum = xlk01-tbnum
*             tbpos = xlk01-tbpos.
    CALL FUNCTION 'PK_WRITE_TRNS_REQ_NO_IN_PKPS'
      EXPORTING
        PKKEY = XLK01-PKKEY
        TBNUM = XLK01-TBNUM
        TBPOS = XLK01-TBPOS.
  ENDLOOP.
ENDFORM.                    "lvs_tbnum_rueckmelden_kanban

*---------------------------------------------------------------------*
*       FORM LVS_TBNUMMER_VERGEBEN                                    *
*---------------------------------------------------------------------*
*       Dieses Modu+ liest alle LVS-Kommunikationssätze und vergibt   *
*       Transportbedarfs- und Positionsnummern.                       *
*---------------------------------------------------------------------*
FORM LVS_TBNUMMERN_VERGEBEN.

  CLEAR LVS_TBNUM.
  CLEAR LVS_TBPOS.

*........Sortieren Kommunikationssätze................................*

  SORT XLK01 BY LGNUM DIRTA BWLVS BETYP BENUM VLTYP VLPLA NLTYP NLPLA
                MBPOS.

*........Vergeben TB-Nummer...........................................*

  CLEAR: CHANGE_TB_1, CHANGE_TB_2.
  LOOP AT XLK01 WHERE TBFKZ = 'X'.
    MOVE-CORRESPONDING XLK01 TO CHANGE_TB_1.

    PERFORM T340D_LESEN USING XLK01-LGNUM.

    IF CHANGE_TB_1 <> CHANGE_TB_2.

      MOVE: T340D-NUKTB  TO NUMMERNKREIS,
            XLK01-LGNUM  TO SUBOBJEKT.

      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          NR_RANGE_NR        = NUMMERNKREIS
          OBJECT             = CON_TRANSPORTBEDARF
          SUBOBJECT          = SUBOBJEKT
        IMPORTING
          NUMBER             = LVS_TBNUM
          RETURNCODE         = NV-RETURNCODE
        EXCEPTIONS
          INTERVAL_NOT_FOUND = 1.

*........Nummernkreis nicht gepflegt....................................

      IF SY-SUBRC = 1.
        PERFORM NUMMERNKREIS_NICHT_DA(SAPFL000)
                USING CON_TRANSPORTBEDARF NUMMERNKREIS.
      ENDIF.

*........Restteil des Nummernkreisintervalls erreicht...................

      IF NV-RETURNCODE = 1.
        PERFORM NUMMERNKREIS_ZU_ENDE(SAPFL000)
                USING CON_TRANSPORTBEDARF NUMMERNKREIS.
      ENDIF.

      CLEAR LVS_TBPOS.

      CLEAR XLTBUB.
      XLTBUB-LGNUM = XLK01-LGNUM.
      XLTBUB-TBNUM = LVS_TBNUM.
      APPEND XLTBUB.

    ENDIF.

*........Vergeben Positionsnummer.....................................*

    LVS_TBPOS = LVS_TBPOS + 1.
    MOVE: LVS_TBNUM TO XLK01-TBNUM,
          LVS_TBPOS TO XLK01-TBPOS.

*........Fortschreiben Kommunikationssatz.............................*

    MODIFY XLK01.

*........Fortschreiben Materialsegment................................*

    READ TABLE XMSEG INDEX XLK01-MBPOS.
    IF SY-SUBRC NE 0.
      MESSAGE E001 WITH 'XMSEG' XLK01-MBPOS.
    ENDIF.

    MOVE: XLK01-TBNUM TO XMSEG-TBNUM,
          XLK01-TBPOS TO XMSEG-TBPOS.

    MODIFY XMSEG INDEX XLK01-MBPOS.

    MOVE CHANGE_TB_1 TO CHANGE_TB_2.
  ENDLOOP.

ENDFORM.                    "lvs_tbnummern_vergeben

*---------------------------------------------------------------------*
*       FORM QUANTNUMMER BESORGEN                                     *
*---------------------------------------------------------------------*
*       Dieses Modul besorgt die Quantnummer zu einer Buchung.        *
*       die zuvor im LVS_COMMUNICATION_MB ermittelt wurde.            *
*---------------------------------------------------------------------*
FORM QUANTNUMMER_BESORGEN.

* Bei Buchungen auf den Von-Lagerplatz wird die Quantnummer aus Feld
* XVM07M-LQNUM gesetzt, bei Nach-Lagerplatz aus XVM07M-UMLQN
  IF NOT XMSEG-VSCHN IS INITIAL.
    MOVE XVM07M-LQNUM TO XLK01-LQNUM.
  ELSE.
    MOVE XVM07M-UMLQN TO XLK01-LQNUM.
  ENDIF.

  IF NOT XMSEG-LGPLA IS INITIAL AND
         XLK01-LQNUM IS INITIAL .
    MESSAGE E031(L9) WITH XMSEG-MATNR.
  ENDIF.

ENDFORM.                    "quantnummer_besorgen

*---------------------------------------------------------------------*
*       FORM QUANTNUMMER BESORGEN_UB                                  *
*---------------------------------------------------------------------*
*       Dieses Modul besorgt die Quantnummern der beiden               *
*       Umbuchquants                                                  *
*       Diese wurden zuvor im LVS_COMMUNICATION_MB ermittelt.         *
*---------------------------------------------------------------------*
FORM QUANTNUMMER_BESORGEN_UB.

* das einzulagernde Quant steht immer in LQNUM, das auszu-
* lagernde in UMLQN

  MOVE XVM07M-UMLQN TO XLK02-LQNR1.
  MOVE XVM07M-LQNUM TO XLK02-LQNR2.

ENDFORM.                    "quantnummer_besorgen_ub


*---------------------------------------------------------------------*
*       FORM TA_AUTOMATISCH                                           *
*---------------------------------------------------------------------*
*       Es wird gegebenenfalls die automatische TA-Erstellung ange-   *
*       stoßen.                                                       *
*---------------------------------------------------------------------*
FORM TA_AUTOMATISCH.

  DATA: LF_QNAME LIKE TRFCQOUT-QNAME.

* Export flag to memory for control of transaction MIGO
  EXPORT LVS_TAFKZ = LVS_TAFKZ TO MEMORY ID 'MIGO'.         "201156

  IF LVS_TAFKZ = 'A' AND                                    "v_n_681234
     ( NOT XLTBUB[] IS INITIAL OR
       NOT XLDILE[] IS INITIAL ).                           "^_n_681234

    CALL FUNCTION 'L_COM_TO_CREATE_PRE_ENQUEUE'
      TABLES
        T_LTBUB = XLTBUB
        T_LDILE = XLDILE.

    IF NOT XLTBUB-TBNUM IS INITIAL OR                       "v_n_595293
       NOT XLTBUB-UBNUM IS INITIAL.
      MOVE CON_RFC_CALL_WMIM TO LF_QNAME.
      MOVE XLTBUB-LGNUM      TO LF_QNAME+4.
      IF NOT XLTBUB-TBNUM IS INITIAL.
        MOVE XLTBUB-TBNUM    TO LF_QNAME+7.
      ELSE.
        MOVE XLTBUB-UBNUM    TO LF_QNAME+7.
      ENDIF.
    ELSE.
      IF NOT XLDILE-LENUM IS INITIAL.
        MOVE CON_RFC_CALL_WMIM TO LF_QNAME.
        MOVE XLDILE-LENUM      TO LF_QNAME+4.
      ELSE.
        CONCATENATE CON_RFC_CALL_WMIM '_' SY-UNAME INTO LF_QNAME.
      ENDIF.
    ENDIF.                                                  "^_n_595293

    CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
      EXPORTING
        QNAME = LF_QNAME.

    CALL FUNCTION 'L_COMMUNICATION_TO_CREATE' IN BACKGROUND TASK
      EXPORTING
        MBELEG  = XMKPF-MBLNR
        MJAHR   = XMKPF-MJAHR
        MAILK   = LVS_MAILK
        BUSER   = XMKPF-USNAM
        EXPRESS = SPACE
        LANGU   = SY-LANGU
      TABLES
        T_LTBUB = XLTBUB
        T_LDILE = XLDILE.


    REFRESH XLTBUB.
    REFRESH XLDILE.
  ENDIF.
ENDFORM.                    "ta_automatisch

*---------------------------------------------------------------------*
*       FORM TBPOS_LESEN                                              *
*---------------------------------------------------------------------*
*       Lesen der Palettierungsdaten aus Transportbedarfsposition     *
*---------------------------------------------------------------------*
FORM TBPOS_LESEN USING P_LGNUM P_TBNUM P_TBPOS.
  SELECT SINGLE * FROM LTBP WHERE
    LGNUM EQ P_LGNUM AND
    TBNUM EQ P_TBNUM AND
    TBPOS EQ P_TBPOS.
  DM07M-ANZL1 = LTBP-ANZL1.
  DM07M-ANZL2 = LTBP-ANZL2.
  DM07M-LMEN1 = LTBP-LMEN1.
  DM07M-LMEN2 = LTBP-LMEN2.
  DM07M-LETY1 = LTBP-LETY1.
  DM07M-LETY2 = LTBP-LETY2.


ENDFORM.                    "tbpos_lesen

*---------------------------------------------------------------------*
*       FORM T300T_LESEN                                              *
*---------------------------------------------------------------------*
*       Lesen Tabelle T300T                                           *
*---------------------------------------------------------------------*
FORM T300T_LESEN USING P_LGNUM.

  SELECT SINGLE * FROM T300T
  WHERE SPRAS = SY-LANGU   AND
        LGNUM = P_LGNUM.

ENDFORM.                    "t300t_lesen
*---------------------------------------------------------------------*
*       FORM T301T_LESEN                                              *
*---------------------------------------------------------------------*
*       Lesen Tabelle T301T                                           *
*---------------------------------------------------------------------*
FORM T301T_LESEN USING P_LGNUM
                       P_LGTYP.
  SELECT SINGLE * FROM T301T
  WHERE SPRAS = SY-LANGU   AND
        LGNUM = P_LGNUM    AND
        LGTYP = P_LGTYP.
ENDFORM.                    "t301t_lesen

*---------------------------------------------------------------------*
*       FORM T333T_LESEN                                              *
*---------------------------------------------------------------------*
*       Lesen Tabelle T333T                                           *
*---------------------------------------------------------------------*
FORM T333T_LESEN USING P_LGNUM
                       P_BWLVS.
  SELECT SINGLE * FROM T333T
  WHERE SPRAS = SY-LANGU   AND
        LGNUM = P_LGNUM    AND
        BWLVS = P_BWLVS.
ENDFORM.                    "t333t_lesen

*---------------------------------------------------------------------*
*       FORM T340D_LESEN                                              *
*---------------------------------------------------------------------*
*       Lesen eines T340D-Eintrages                                   *
*---------------------------------------------------------------------*
FORM T340D_LESEN USING P_LGNUM.
  CHECK P_LGNUM NE T340D-LGNUM.
  SELECT SINGLE * FROM T340D
  WHERE LGNUM = P_LGNUM.
  IF SY-SUBRC NE 0.
    MESSAGE A200 WITH P_LGNUM.
  ENDIF.
ENDFORM.                    "t340d_lesen

*---------------------------------------------------------------------*
*       FORM WMS_LIEFERUNG_COMMIT.                                     *
*---------------------------------------------------------------------*
*       Absetzten Commit und S-Message                                *
*---------------------------------------------------------------------*
FORM WMS_LIEFERUNG_COMMIT.

ENDFORM.                    "wms_lieferung_commit

*---------------------------------------------------------------------*
*       FORM WMS_LIEFERUNG_ERZEUGEN                                   *
*---------------------------------------------------------------------*
*       Erzeugen einer Lieferung                                      *
*---------------------------------------------------------------------*
FORM WMS_LIEFERUNG_ERZEUGEN.
  DATA: OPEN_QTY LIKE MSEG-MENGE,                           "589422
        DIFF_QTY LIKE MSEG-MENGE,                           "589422
        LF_QUANTITY_OUT(18) TYPE C,                         "589422
        LF_UNIT_OUT(3)      TYPE C,                         "589422
        L_TCODE  LIKE SY-TCODE.                             "589422

  DESCRIBE TABLE XLK03 LINES NUM_XLK03."wie viele sind drin

  IF NUM_XLK03 NE 0.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = 0
        TEXT       = TEXT-022.

    IF XDELIV = X.                                          "HUM
      PERFORM SD_FILL_VBSK CHANGING HLP_VBSK_I.             "HUM
      PERFORM SD_FEHLENDE_DATEN.                            "HUM
    ENDIF.                                                  "HUM

*... init of help fields                                   "925684
    CLEAR VBELN_FIRST.                                      "925684

*...Partner und Orgdaten werden nach neuer Regel bestimmt    "v_n_568108
    LOOP AT XLK03.
      PERFORM DETERMINE_ORG_PARTNER_NEW TABLES XLK03.
    ENDLOOP.                                                "^_n_568108

    def_break 'GN_DELIVERY_CREATE'.                         "#EC *

*   PASS GLOBAL TABLE WITH SERIAL NUMBERS TO DELIVERY INTERFACE:
    CALL FUNCTION 'GN_DELIVERY_CREATE'                      "v_n1031590
         EXPORTING
              IF_SYNCHRON    = ' '                          "646038
              VBSK_I         = HLP_VBSK_I
              NO_COMMIT      = CON_X
              VBLS_POS_RUECK = CON_X
*SPE INB ST
*VL-MM consistencies vendor return with creation of outbound delivery
              IS_BORGR_CONTROL = GS_BORGR_CONTROL
*              IF_CREATE_DEC  = ' '
              IF_NO_DEQUE    = 'X'
              IT_HANDLING_UNITS = GT_REHANG_HU
              IF_NO_PARTNER_DIALOG = ' '                    "n_628005
            IMPORTING
                 VBSK_E         = HLP_VBSK_E
         TABLES
              XKOMDLGN       = XLK03
              XVBFS          = HLP_VBFS"Fehlermeldungen
              XVBLS          = HLP_VBLS         "Erzeugte LF-Positionen
              IT_GN_SERNR    = T_SERNR.

    REFRESH: T_SERNR.                                       "^_n1031590

*  call function 'SAPGUI_PROGRESS_INDICATOR'.

    IF XDELIV = X.
      PERFORM SD_CREATE_BATCH.                              "624458
    ENDIF.


*........Tabelle der fehlerhaften abprüfen..............................
    LOOP AT HLP_VBFS.
      IF NOT HLP_VBFS-MSGNO IS INITIAL
         AND ( HLP_VBFS-MSGTY = CON_ERROR
         OR  HLP_VBFS-MSGTY = CON_ABBRUCH ) .
        ROLLBACK WORK.
        MESSAGE ID     HLP_VBFS-MSGID
                TYPE   HLP_VBFS-MSGTY
                NUMBER HLP_VBFS-MSGNO
                WITH   HLP_VBFS-MSGV1
                       HLP_VBFS-MSGV2
                       HLP_VBFS-MSGV3
                       HLP_VBFS-MSGV4.
      ENDIF.
    ENDLOOP.

    IF HLP_VBSK_E-VBNUM EQ 1.          " 1 Lieferung erstellt
      LOOP AT HLP_VBLS.
        IF HLP_VBLS-VBTYP = 'J'.       "XAN HUM
          SET PARAMETER ID PARID_VBELN FIELD HLP_VBLS-VBELN_LIF.
        ENDIF.                         "XAN HUM
        IF HLP_VBLS-VBTYP = '7'.       "XAN HUM
          SET PARAMETER ID PARID_ANLIE FIELD HLP_VBLS-VBELN_LIF.
        ENDIF.
        MESSAGE S514(L9) WITH HLP_VBLS-VBELN_LIF.
        IF XMBWL IS INITIAL.
          COMMIT WORK.
          IF SY-BINPT = 'X'.                                "938795
            SET SCREEN 0. LEAVE SCREEN.                     "938795
          ELSE.                                             "938795
            LEAVE TO TRANSACTION TCODE.
          ENDIF.                                            "938795
        ELSE.
          MESSAGE E514(L9) WITH HLP_VBLS-VBELN_LIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      LOOP AT HLP_VBLS.
        IF VBELN_FIRST IS INITIAL.
          MOVE HLP_VBLS-VBELN_LIF TO VBELN_FIRST.
        ENDIF.
      ENDLOOP.


      IF XMBWL IS INITIAL.             "Aufruf mb_create...?
        MESSAGE S515(L9) WITH HLP_VBSK_E-VBNUM
                              VBELN_FIRST
                              HLP_VBLS-VBELN_LIF.
        COMMIT WORK.
        LEAVE TO TRANSACTION TCODE.
      ELSE.
        MESSAGE E515(L9) WITH HLP_VBSK_E-VBNUM
                              VBELN_FIRST
                              HLP_VBLS-VBELN_LIF.
      ENDIF.
    ENDIF.
  ELSE.
* wenn kein satz in der internen Tabelle ist, gibt es später eine
* Meldung vom MM07M: Beleg enthält keine Positionen
  ENDIF.
ENDFORM.                    "wms_lieferung_erzeugen

*---------------------------------------------------------------------*
*       FORM WMS_LIEFERUNG_INIT                                       *
*---------------------------------------------------------------------*
*       Initialisieren intern Tabellen                                *
*---------------------------------------------------------------------*
FORM WMS_LIEFERUNG_INIT.
  CLEAR XLK03.
  REFRESH XLK03.
  CLEAR FLG_ANLIEFERUNG.
  CLEAR:   HLP_VBFS, HLP_VBLS.                              "336345
  REFRESH: HLP_VBFS, HLP_VBLS.                              "336345
ENDFORM.                    "wms_lieferung_init

*---------------------------------------------------------------------*
*       FORM WMS_LIPS_GENERIEREN                                      *
*---------------------------------------------------------------------*
*       Erzeugen einer internen Lieferungsposition                    *
*---------------------------------------------------------------------*
FORM WMS_LIPS_GENERIEREN.

  IF XDELIV = X.
    PERFORM WMS_LIPS_GENER_ALLG.
  ELSEIF MKPF-BFWMS = 1.

    CLEAR XLK03.
    CHECK NOT XMSEG-XBLVS IS INITIAL.
    CHECK NOT XMSEG-MENGE IS INITIAL.
*........ Allgemein gültige Felder füllen...............................
    MOVE: XMSEG-MANDT TO XLK03-MANDT,
          XMSEG-MEINS TO XLK03-MEINS,
          XMSEG-ERFMG TO XLK03-LFIMG,
          XMSEG-ERFME TO XLK03-VRKME,
          XMSEG-BWART TO XLK03-BWART,
          XMSEG-EXBWR TO XLK03-EXBWR,                       "848404
          XMSEG-KZBEW TO XLK03-KZBEW,
          XMSEG-INSMK TO XLK03-INSMK,                       "521622
          XMSEG-EMATN TO XLK03-EMATN.                       "n_732435


    IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) = abap_true.

     if xvm07m-msr_insp_guid is not initial.                       "n_1269580
      CALL FUNCTION 'GUID_CONVERT'
        EXPORTING
           IV_GUID_X16                  = xvm07m-msr_insp_guid
        IMPORTING
           EV_GUID_C32                  = xlk03-spe_inspout_guid
        EXCEPTIONS
           NO_UNICODE_SUPPORT_YET       = 1
           PARAMETERS_ERROR             = 2
           OTHERS                       = 3.

*      IF sy-subrc <> 0.                                          "n_del_1269580
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
     ENDIF.

*   Redesign of notes 512464 and 823881 for ELIKZ take over
    IF NOT DM07M-ELIKZ_INPUT IS INITIAL.                    "v_n_965214
*     ELIKZ was changed manually
      IF NOT XMSEG-ELIKZ IS INITIAL.
        XLK03-KZTLF = 'X'.
      ELSE.
        XLK03-KZTLF = 'Y'.   "Dummy to know about manual change to space
      ENDIF.
    ELSE.
*     ELIKZ was not changed, but should stay as before
      IF NOT XVM07M-ELIKZ_OLD IS INITIAL AND
         NOT XMSEG-ELIKZ IS INITIAL.
        XLK03-KZTLF = 'X'.
      ENDIF.
    ENDIF.                                                  "^_n_965214

ENHANCEMENT-POINT MM07MLVS_01 SPOTS ES_SAPMM07M.
* in case of different conversion factors in PO / material master,
* necessary to give the conversion factors to GN_DELIVERY_CREATE
    IF XMSEG-MEINS <> XMSEG-ERFME.                          "480232
      MOVE: ZDM07M-UMREZ TO XLK03-UMVKZ,                    "374499
            ZDM07M-UMREN TO XLK03-UMVKN.                    "374499
    ENDIF.                                                  "480232

*........Daten aus XVM07M.............................................*
    MOVE: XVM07M-KUNWE TO XLK03-KUNWE,
          XVM07M-LVS_LIFNR TO XLK03-LIFNR,
          XVM07M-ETENS TO XLK03-ETENS,                      "353043
          XVM07M-LFART TO XLK03-LFART,
          XVM07M-VKORG TO XLK03-VKORG,
          XVM07M-VSTEL TO XLK03-VSTEL,
          XVM07M-VTWEG TO XLK03-VTWEG,
          XVM07M-SPART TO XLK03-SPART,
          XVM07M-QPLOS TO XLK03-QPLOS.


*... Advanced Returns Management II (EhP 6)
*... Indicator for LFE document (Valuation posting)
    IF cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true.
      move: XVM07M-msr_valuation TO XLK03-msr_valuation.
      IF xvm07m-msr_id IS NOT INITIAL.
* Set indicator for MSR process
        xlk03-msr_active = abap_true.
      ENDIF.
    endif.


ENHANCEMENT-POINT EHP603_WMS_LIPS_GENERIEREN_01 SPOTS ES_SAPMM07M.

*........Daten aus ZDM07M.............................................*
    MOVE: ZDM07M-RBLVS TO XLK03-RBLVS,
          ZDM07M-KZUML TO XLK03-KZUML.
    IF CL_EWM_SWITCH_CHECK=>LE_SFWS_SC_EWM_MAN( ) = ABAP_TRUE."v_n_1370175
* Production supply area is needed for consumption posting
      XLK03-PRVBE = ZDM07M-PRVBE.
    ENDIF.                                                    "^_n_1370175
*........Kontierungsfelder in die Lieferung übernehmen
    MOVE: XMSEG-KOSTL      TO XLK03-KOSTL,
          XMSEG-GSBER      TO XLK03-GSBER,
          XMSEG-PS_PSP_PNR TO XLK03-PS_PSP_PNR,
          XMSEG-PAOBJNR    TO XLK03-PAOBJNR,
          XMSEG-FIPOS      TO XLK03-FIPOS,
          XMSEG-FISTL      TO XLK03-FISTL,
          XMSEG-GEBER      TO XLK03-GEBER,
          XMSEG-GRANT_NBR  TO XLK03-GRANT_NBR,
          XMSEG-FKBER      TO XLK03-FKBER,
          XMSEG-AUFNR      TO XLK03-AUFNR,
          XMSEG-AUFPS      TO XLK03-POSNR_PP,
          XMSEG-KDAUF      TO XLK03-KDAUF,
          XMSEG-KDPOS      TO XLK03-KDPOS.

* Take over Budget Period if the switch is on:
    IF cl_psm_core_switch_check=>PSM_FM_CORE_BUD_PER_REV_1( ) IS NOT INITIAL.
      MOVE ZDM07M-budget_pd TO XLK03-budget_pd.
    ENDIF.

    IF ZDM07M-XKMAN <> SPACE.                              "v_n_1069460
* The G/L account needs only to be copied to the delivery if it has
* been entered manually
      XLK03-KONTO = ZDM07M-KONTO.                           "n_843089
    ENDIF.                                                 "^_n_1069460

    IF XLK03-DLVTP IS INITIAL.                              "v_n_804650
      SELECT SINGLE DLVTP FROM  T156Q INTO XLK03-DLVTP
                          WHERE BWART   EQ XMSEG-BWART
                          AND   SOBKZ   EQ XMSEG-SOBKZ
                          AND   KZBEW   EQ XMSEG-KZBEW
                          AND   KZZUG   EQ XMSEG-KZZUG
                          AND   KZVBR   EQ XMSEG-KZVBR.
    ENDIF.                                                  "^_n_804650


*SPE INB ST
*VL-MM consistencies vendor return with creation of outbound delivery
    IF /SPE/CL_CUST=>IS_VL_MM_ACTIVE( ) = 'X'.
      IF XLK03-DLVTP = 'RL' .
        GS_BORGR_CONTROL-SPE_JOIN_IASN_OASN = 'X'.
        XLK03-LFBNR   = MSEG-MBLNR.
        XLK03-LFPOS   = MSEG-ZEILE.
        XLK03-LFGJA   = MSEG-MJAHR.
        XLK03-R_VBELN = ZDM07M-VBELN_VL.
        XLK03-R_VBELP = ZDM07M-VBELP_VL.
        DESCRIBE TABLE XLK03 LINES XLK03-VUPOS.
        ADD 1 TO XLK03-VUPOS.
      ENDIF.
    ENDIF.

*........Lieferung zu Reservierung, ATP-Check in der Lieferung wird.....
*........ausgeschaltet
    IF NOT XMSEG-RSNUM IS INITIAL.
      MOVE XMSEG-RSNUM TO XLK03-RSNUM.
      MOVE XMSEG-RSPOS TO XLK03-RSPOS.
*     lines of note 790375 deleted                             "n_828895
      MOVE XMSEG-RSART TO XLK03-RSART.                      "n_790375
      MOVE CON_X TO XLK03-NOATP.
    ENDIF.

*........Sonstige Daten.................................................
    MOVE: SY-DATLO     TO XLK03-LFDAT,
          SY-DATLO     TO XLK03-WADAT,
          XMSEG-GRUND  TO XLK03-GRUND,
          MKPF-XBLNR   TO XLK03-LIFEX,                      "v_n_1672509
          MKPF-XABLN   TO XLK03-XABLN,
          MKPF-FRBNR   TO XLK03-BOLNR,
          MKPF-BLDAT   TO XLK03-BLDAT,                      "^_n_1672509
          MKPF-BUDAT   TO XLK03-WADAT_IST.
* if xblnr_avis has been populated:                         "v_n_1672509
*  -> take it over as external delivery note number in likp
    IF NOT XMBWL IS INITIAL AND NOT XVM07M-XBLNR_AVIS IS INITIAL.
      MOVE XVM07M-XBLNR_AVIS TO XLK03-LIFEX.
    ENDIF.                                                  "^_n_1672509

*........Felder abhängig von der Art der Buchung füllen.................
    CLEAR FLG_UMBUCHUNG.
    IF ZDM07M-KZUML IS INITIAL.        "Keine IM-Umbuchung
      PERFORM KOPIEREN_LEIT_TO_LEIT.
      MOVE CON_SHKZG_UM_1 TO XLK03-SHKZG_UM.
      IF XMSEG-SHKZG EQ H.             "Auslieferung
        PERFORM KOPIEREN_SOND_TO_LIPS.
        CLEAR XLK03-LIFNR.
      ELSE.                            "Anlieferung
        MOVE  CON_X       TO XLK03-SHKZG.
        MOVE  CON_X       TO FLG_ANLIEFERUNG.
        MOVE XMSEG-VFDAT  TO XLK03-VFDAT.
        MOVE XMSEG-HSDAT  TO XLK03-HSDAT.                   "n_619807
        CLEAR: XLK03-VKORG,
               XLK03-VTWEG,
               XLK03-SPART,
               XLK03-KUNWE.
        PERFORM WMS_HUS_BESTIMMEN.     "<<<< HP_325415
      ENDIF.
    ELSE.                              "IM-Umbuchung
*........Es ist eine Umlagerung in der Bestandsführung................*
      IF NOT XVM07M-EXWMS IS INITIAL AND
         NOT XVM07M-UMEXW IS INITIAL.
*........Es ist eine Umbuchung für das externe Lager....................
*          CLEAR: XLK03-LIFNR,
*               XLK03-VKORG,
*               XLK03-VTWEG,
*               XLK03-SPART,
*               XLK03-KUNWE.

        MOVE ZDM07M-UMRBU TO XLK03-RBLVS.

        IF XMSEG-SHKZG EQ H.
          FLG_UMBUCHUNG = CON_X.
          PERFORM KOPIEREN_LEIT_TO_LEIT.
          PERFORM KOPIEREN_UM_TO_UM.
          PERFORM KOPIEREN_SOND_TO_LIPS.
          MOVE CON_SHKZG_UM_1 TO XLK03-SHKZG_UM.

        ELSE.
          PERFORM KOPIEREN_LEIT_TO_UM.
          PERFORM KOPIEREN_UM_TO_LEIT.
          PERFORM KOPIEREN_USOND_TO_LIPS.
          MOVE CON_SHKZG_UM_2 TO XLK03-SHKZG_UM.
        ENDIF.
      ELSE.
*........Es ist eine Ein- oder Auslagerung für das externe Lager........
        IF NOT XVM07M-EXWMS IS INITIAL."Die Leitbuchung ist relevant
          PERFORM KOPIEREN_LEIT_TO_LEIT.
          PERFORM KOPIEREN_UM_TO_UM.
          MOVE CON_SHKZG_UM_1 TO XLK03-SHKZG_UM.
          IF XMSEG-SHKZG EQ H.         "Auslieferung
            CLEAR XLK03-LIFNR.
            PERFORM KOPIEREN_SOND_TO_LIPS.
          ELSE.                        "Anlieferung
            MOVE  CON_X       TO XLK03-SHKZG.
            MOVE  CON_X       TO FLG_ANLIEFERUNG.
            CLEAR: XLK03-VKORG,
                   XLK03-VTWEG,
                   XLK03-SPART,
                   XLK03-KUNWE.
          ENDIF.
        ELSE.                          "Die Gegenbuchung ist relevant
          PERFORM KOPIEREN_LEIT_TO_UM.
          PERFORM KOPIEREN_UM_TO_LEIT.
          MOVE CON_SHKZG_UM_2 TO XLK03-SHKZG_UM.
          MOVE ZDM07M-UMRBL TO XLK03-RBLVS.
          IF XMSEG-SHKZG EQ S.         "Auslieferung
            CLEAR XLK03-LIFNR.
            PERFORM KOPIEREN_USOND_TO_LIPS.
          ELSE.                        "Anlieferung
            CLEAR: XLK03-VKORG,
                   XLK03-VTWEG,
                   XLK03-SPART,
                   XLK03-KUNWE.
            MOVE  CON_X       TO XLK03-SHKZG.
            MOVE  CON_X       TO FLG_ANLIEFERUNG.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    PERFORM FILL_PREDECESSOR_DOCUMENT USING    MKPF         "v_n_655641
                                               XVM07M
                                               XMSEG
                                               ZDM07M
                                      CHANGING XLK03.       "^_n_655641

*  Scrapping: Get Return Material Authorization Data and
*             fill the corresponding fields in xlk03
    DATA: LS_RMA_DATA TYPE /SPE/BAPI2017_RET_AUTH_DATA.

    CALL FUNCTION '/SPE/RMA_DATA_GET'
      EXPORTING
        IV_MSEG_LINE_ID = XMSEG-LINE_ID
      IMPORTING
        ES_RMA_DATA     = LS_RMA_DATA.

    IF ( LS_RMA_DATA IS NOT INITIAL ).
      XLK03-SPE_AUTH_NUMBER       = LS_RMA_DATA-RET_AUTH_NUMBER.
      XLK03-SPE_LIFEXPOS2(10)     = LS_RMA_DATA-DELIV_NUMBER.
      XLK03-SPE_LIFEXPOS2+10(20)  = LS_RMA_DATA-HU_NUMBER.
      XLK03-SPE_INSPOUT_GUID      = LS_RMA_DATA-INSPOUT_GUID.
    ENDIF.

* Scrapping: Get Scrap indicators from /SPE/IM_GENERIC_FUNCTIONS
    DATA: LS_SCRAP_INDICATORS TYPE /SPE/BAPI2017_SCRAP_IND.

    CALL FUNCTION '/SPE/SCRAP_INDICATORS_GET'
      EXPORTING
        IV_MSEG_LINE_ID    = XMSEG-LINE_ID
      IMPORTING
        ES_SCRAP_INDICATOR = LS_SCRAP_INDICATORS.

    IF LS_SCRAP_INDICATORS IS NOT INITIAL.
      XLK03-SPE_SCRAP_IND  = LS_SCRAP_INDICATORS-SCRAP_INDICATOR.
      XLK03-SPE_KEEP_QTY   = LS_SCRAP_INDICATORS-KEEP_QUANTITY.
    ENDIF.
* Take over serial numbers from IM into global table for dec. WMS
* SERIAL NUMBER TABLE PREPARATION:

  DATA: LT_SERNR TYPE TABLE OF S_SERNR,              "v_n1031590
        LS_SERNR TYPE S_SERNR,
        LS_RSEROB   TYPE RSEROB,
        LT_SERNOS   TYPE TABLE OF RSEROB,
        LS_SERNOS   TYPE RSEROB.

  IF NOT ZDM07M-SERNP IS INITIAL.
    PERFORM SERIALPFLICHT_ERMITTELN.
    IF I_T377-SERPFLICHT CA '23'.

      XLK03-RFPOS = ZDM07M-ZEILD.

      LS_RSEROB-TASER = 'SER03'.
      LS_RSEROB-MBLNR = SMBLNR.
      LS_RSEROB-MJAHR = XMSEG-MJAHR.
      LS_RSEROB-ZEILE = ZDM07M-ZEILD.

      CALL FUNCTION 'GET_SERNOS_OF_DOCUMENT'
           EXPORTING
                KEY_DATA            = LS_RSEROB
           TABLES
                SERNOS              = LT_SERNOS
           EXCEPTIONS
                KEY_PARAMETER_ERROR = 1
                NO_SUPPORTED_ACCESS = 2
                NO_DATA_FOUND       = 3
                OTHERS              = 4.

      IF SY-SUBRC <> 0.
*     No Serial Numbers maintained
      ELSE.
        SORT LT_SERNOS.                              "n1692715
        DELETE ADJACENT DUPLICATES FROM LT_SERNOS.
        LOOP AT LT_SERNOS INTO LS_SERNOS.
          LS_SERNR-RFPOS = LS_SERNOS-ZEILE.
          LS_SERNR-SERNR = LS_SERNOS-SERNR.
          APPEND LS_SERNR TO T_SERNR.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.                                             "^_n1031590

* EHP6 Advanced Returns Management
* Set scenario and initiator process for MSR deliveries
    IF xlk03-msr_active = abap_true.
      CALL METHOD cl_msr_ewm_int=>get_le_scenario_by_line_id
        EXPORTING
          iv_line_id     = xmseg-line_id
        RECEIVING
          rv_le_scenario = xlk03-spe_le_scenario.

      CALL METHOD cl_msr_ewm_int=>get_initiator_process
        EXPORTING
          iv_scrap_ind         = xlk03-spe_scrap_ind
          iv_le_scenario       = xlk03-spe_le_scenario
        RECEIVING
          rv_initiator_process = xlk03-spe_initiator_process.
    ENDIF.

*........Aufnehmen Eintrag in Tabelle.................................*
    APPEND XLK03.
  ENDIF.

ENDFORM.                    "wms_lips_generieren





*---------------------------------------------------------------------*
*       FORM WMS_LIPS_GENER_ALLG                                      *
*---------------------------------------------------------------------*
*       Erzeugen einer Lieferungsposition HU'S und Rücklieferung      *
*---------------------------------------------------------------------*
FORM WMS_LIPS_GENER_ALLG.

*SPE INB ST
*VL-MM consistencies vendor return with creation of outbound delivery
  DATA:
    LS_MSEG    TYPE  LINE OF TY_T_MSEG,
    LO_MAT_DOC TYPE REF TO /SPE/CL_INB_MAT_DOC,
    LF_DIALOG  TYPE ISAUTO_ACTION_INFO.                     "1019137

  CLEAR XLK03.
  CHECK NOT XMSEG-XAUTO = X.                                "HUM

* kein Sammelartikel (Kopf) in der Lieferung nur Varianten "note 677206
* des Sammelartikels                                       "note 677206
  CHECK NOT XVM07M-ATTYP = '01'.                           "note 677206

* Varianten des Sammelartikels (attyp = 02 & satnr gefüllt)"note 677206
  IF NOT XVM07M-ATTYP = '02' AND XVM07M-SATNR IS INITIAL.  "note 677206
* Only first hierarchy level for delivery                        "397627
    CHECK XMSEG-LINE_DEPTH = 0.                             "397627
  ENDIF.                                                   "note 677206

* without matnr allow return deliveries (note 849409)           "1077598
  IF xmseg-matnr IS INITIAL AND vm07m-xstor = '1'.          "1077598
    CHECK NOT xmseg-erfmg IS INITIAL.                       "1077598
  ELSE.                                                     "1077598
    CHECK NOT xmseg-menge IS INITIAL.
  ENDIF.                                                    "1077598
*........IM-Buchung.....................................................
  PERFORM SD_LIEFERUNG_ERGAENZEN CHANGING XLK03.            "HUM
* Release 4.7: First step is to determine delivery type, to know    "HUM
* if it's an inbound delivery. (important information for form      "HUM
* sd_lieferung_ergaenzen_im).                                       "HUM
  PERFORM SD_LIEFERTYP_ERMITTELN CHANGING XLK03 XMSEG.      "HUM
  PERFORM SD_LIEFERUNG_ERGAENZEN_IM CHANGING XLK03.         "HUM
  PERFORM SD_FOLGEBEWEGUNGSART_ERMITTELN CHANGING XLK03.    "HUM
  IF NOT XVM07M-LBBSA IS INITIAL.                           "HUM
    PERFORM SD_BESTANDSART_ERMITTELN CHANGING XVM07M-LBBSA  "HUM
                                              XMSEG-BESTQ.  "HUM
  ENDIF.                                                    "HUM
  IF NOT ZDM07M-UMLBB IS INITIAL.                           "HUM
    PERFORM SD_BESTANDSART_ERMITTELN CHANGING ZDM07M-UMLBB  "HUM
                                              ZDM07M-UMBSQ. "HUM
  ENDIF.                                                    "HUM

*........Felder abhängig von der Art der Buchung füllen.................
  PERFORM KOPIEREN_LEIT_TO_LEIT.
  PERFORM KOPIEREN_UM_TO_UM.
  MOVE: XMSEG-SHKZG TO XLK03-SHKZG.
  PERFORM KOPIEREN_SOND_TO_LIPS.
  PERFORM KOPIEREN_USOND_TO_LIPS.

*SPE INB ST
*VL-MM consistencies vendor return with creation of outbound delivery
  IF /SPE/CL_CUST=>IS_VL_MM_ACTIVE( ) = 'X'.
    IF XLK03-DLVTP IS INITIAL.
      SELECT SINGLE DLVTP FROM T156Q INTO XLK03-DLVTP
                          WHERE BWART EQ XMSEG-BWART
                          AND SOBKZ EQ XMSEG-SOBKZ
                          AND KZBEW EQ XMSEG-KZBEW
                          AND KZZUG EQ XMSEG-KZZUG
                          AND KZVBR EQ XMSEG-KZVBR.
    ENDIF.
    IF XLK03-DLVTP = 'RL'.
      CALL METHOD /SPE/CL_INB_ACTION_INFO=>GET_INFO         "1019137
           IMPORTING E_DIALOG = LF_DIALOG.
      IF XMIGO = 'X'.
        LO_MAT_DOC ?= /SPE/CL_INB_ACTION_INFO=>GET_OBJECT(
              I_NAME = /SPE/CL_INB_ACTION_INFO=>C_OBJ_MAT_DOC ).
        READ TABLE LO_MAT_DOC->AT_MSEG INTO LS_MSEG WITH KEY ZEILE = XMSEG-LFPOS.
        IF SY-SUBRC = 0.
          LS_MSEG-MATNR = XLK03-MATNR.
ENHANCEMENT-SECTION     MM07MLVS_03 SPOTS ES_SAPMM07M.
          XLK03-LFBNR   = LS_MSEG-LFBNR.
END-ENHANCEMENT-SECTION.
          XLK03-LFPOS   = LS_MSEG-ZEILE.
          XLK03-LFGJA   = LS_MSEG-MJAHR.
        ENDIF.
      ELSEIF XLK03-LFBNR IS INITIAL.                        "1019137
        IF T158-TCODE = 'MBRL' OR
           LF_DIALOG  = /SPE/CL_INB_ACTION_INFO=>C_DIALOG_MBRL OR
        ( XMIGO IS INITIAL AND XBAPI IS INITIAL AND XMBWL = 'X' ) .    "For QM transactions
          XLK03-LFBNR   = XMSEG-LFBNR.                      "AP773479
          XLK03-LFPOS   = XMSEG-LFPOS.
          XLK03-LFGJA   = XMSEG-LFBJA.
        ELSE.
          XLK03-LFBNR   = XMSEG-MBLNR.
          XLK03-LFPOS   = XMSEG-ZEILE.
          XLK03-LFGJA   = XMSEG-MJAHR.
        ENDIF.                                              "1019137
      ENDIF.
      GS_BORGR_CONTROL-SPE_JOIN_IASN_OASN = 'X'.
      XLK03-R_VBELN = ZDM07M-VBELN_VL.
      XLK03-R_VBELP = ZDM07M-VBELP_VL.
      DESCRIBE TABLE XLK03 LINES XLK03-VUPOS.
      ADD 1 TO XLK03-VUPOS.
    ENDIF.
  ENDIF.


  PERFORM FILL_PREDECESSOR_DOCUMENT USING    MKPF           "v_n_655641
                                             XVM07M
                                             XMSEG
                                             ZDM07M
                                    CHANGING XLK03.         "^_n_655641

* Scrapping: Get Return Material Authorization Data and
*            fill the corresponding fields in xlk03
  DATA: LS_RMA_DATA TYPE /SPE/BAPI2017_RET_AUTH_DATA.

  CALL FUNCTION '/SPE/RMA_DATA_GET'
    EXPORTING
      IV_MSEG_LINE_ID = XMSEG-LINE_ID
    IMPORTING
      ES_RMA_DATA     = LS_RMA_DATA.

  IF ( LS_RMA_DATA IS NOT INITIAL ).
    XLK03-SPE_AUTH_NUMBER   = LS_RMA_DATA-RET_AUTH_NUMBER.
*   XLK03-SPE_SRC_DLV_NO   = LS_RMA_DATA-DELIV_NUMBER.
*    XLK03-SPE_SRC_DLV_ITEM = LS_RMA_DATA-DELIV_ITEM.
*    XLK03-SPE_SRC_EXIDV    = LS_RMA_DATA-HU_NUMBER.
    XLK03-SPE_INSPOUT_GUID = LS_RMA_DATA-INSPOUT_GUID.
  ENDIF.
* Scrapping: Get Scrap indicators from
*/SPE/IM_GENERIC_FUNCTIONS
  DATA: LS_SCRAP_INDICATORS TYPE /SPE/BAPI2017_SCRAP_IND.

  CALL FUNCTION '/SPE/SCRAP_INDICATORS_GET'
    EXPORTING
      IV_MSEG_LINE_ID    = XMSEG-LINE_ID
    IMPORTING
      ES_SCRAP_INDICATOR = LS_SCRAP_INDICATORS.

  IF cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true.
    IF ls_scrap_indicators IS NOT INITIAL.
      xlk03-spe_scrap_ind = ls_scrap_indicators-scrap_indicator.
      xlk03-spe_keep_qty  = ls_scrap_indicators-keep_quantity.
    ENDIF.
    IF xlk03-msr_active = abap_true.
* Fill scenario and initiator process
      CALL METHOD cl_msr_ewm_int=>get_le_scenario_by_line_id
        EXPORTING
          iv_line_id     = xmseg-line_id
        RECEIVING
          rv_le_scenario = xlk03-spe_le_scenario.

      CALL METHOD cl_msr_ewm_int=>get_initiator_process
        EXPORTING
          iv_scrap_ind         = xlk03-spe_scrap_ind
          iv_le_scenario       = xlk03-spe_le_scenario
        RECEIVING
          rv_initiator_process = xlk03-spe_initiator_process.
    ENDIF.
  ENDIF.

* Take over serial numbers from IM into global table for HUM
* SERIAL NUMBER TABLE PREPARATION:

  DATA: LT_SERNR TYPE TABLE OF S_SERNR,              "v_n1031590
        LS_SERNR TYPE S_SERNR,
        LS_RSEROB   TYPE RSEROB,
        LT_SERNOS   TYPE TABLE OF RSEROB,
        LS_SERNOS   TYPE RSEROB.

  IF NOT ZDM07M-SERNP IS INITIAL.
    PERFORM SERIALPFLICHT_ERMITTELN.
    IF I_T377-SERPFLICHT CA '23'.

      XLK03-RFPOS = ZDM07M-ZEILD.

      LS_RSEROB-TASER = 'SER03'.
      LS_RSEROB-MBLNR = SMBLNR.
      LS_RSEROB-MJAHR = XMSEG-MJAHR.
      LS_RSEROB-ZEILE = ZDM07M-ZEILD.

      CALL FUNCTION 'GET_SERNOS_OF_DOCUMENT'
           EXPORTING
                KEY_DATA            = LS_RSEROB
           TABLES
                SERNOS              = LT_SERNOS
           EXCEPTIONS
                KEY_PARAMETER_ERROR = 1
                NO_SUPPORTED_ACCESS = 2
                NO_DATA_FOUND       = 3
                OTHERS              = 4.

      IF SY-SUBRC <> 0.
*     No Serial Numbers maintained
      ELSE.
        SORT LT_SERNOS.                              "n1692715
        DELETE ADJACENT DUPLICATES FROM LT_SERNOS.
        LOOP AT LT_SERNOS INTO LS_SERNOS.
          LS_SERNR-RFPOS = LS_SERNOS-ZEILE.
          LS_SERNR-SERNR = LS_SERNOS-SERNR.
          APPEND LS_SERNR TO T_SERNR.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.                                             "^_n1031590

*........Aufnehmen Eintrag in Tabelle.................................*
  APPEND XLK03.

ENDFORM.                    "wms_lips_gener_allg

*&---------------------------------------------------------------------*
*&      Form  HU_LK01_GENERIEREN
*&---------------------------------------------------------------------*
*       Generieren der Lk01-Sätze wenn HU's im Spiel sind              *
*----------------------------------------------------------------------*
FORM HU_LK01_GENERIEREN.

  DATA: LF_DIFF TYPE  HUM_EPSILON,
        LF_EPSILON TYPE HUM_EPSILON,
        LF_ITEM_NR TYPE SYTABIX.
  DATA: LS_ISU_LVS_SONDERBESTANDSNR TYPE ISU_LVS_SONDERBESTANDSNR. "IS2ERP

  CALL FUNCTION 'HU_GET_CALC_TYPE'                          "HP_714874
    IMPORTING
      EF_EPSILON         = LF_EPSILON.

* Begin of Note 1624277                                       "v_1624277
* Outsoruced Manufacturing via deliveries & HU/WM
  IF gv_mm_om1_sfws_sc_active EQ 'X' AND zdm07m-co_order EQ 'X'
    AND xmseg-kzbew = L AND xmseg-aufnr IS NOT INITIAL
    AND xmseg-line_id IS NOT INITIAL AND xmseg-parent_id IS NOT INITIAL
    AND vm07m-xstor NE '2'.
    HLP_ZEILE = xmseg-line_id. "original pos in delivery
  ELSE.
    MOVE ZDM07M-IMSEG_ORIGINAL TO HLP_ZEILE.
  ENDIF.
* End of Note 1624277                                         "^_1624277

  CHECK NOT XMSEG-MENGE IS INITIAL.
  CLEAR XLK01.

  CALL FUNCTION 'L_GET_HUQUA_ZEILE'
    EXPORTING
      I_ZEILE        = HLP_ZEILE
    TABLES
      ET_LHUQUA      = ITLHUQUA
    EXCEPTIONS
      NO_ENTRY_FOUND = 1
      OTHERS         = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CLEAR HLP_SUMME.

  LOOP AT ITLHUQUA.

    CHECK ITLHUQUA-VSCHN = XMSEG-VSCHN AND
          ITLHUQUA-NSCHN = XMSEG-NSCHN.
    HLP_SUMME = HLP_SUMME + ITLHUQUA-MENGE.

    MOVE: ITLHUQUA-MENGE TO XLK01-MENGE,
          ITLHUQUA-MEINS TO XLK01-MEINS,
          ITLHUQUA-LGTYP TO XMSEG-LGTYP,
          ITLHUQUA-LGPLA TO XMSEG-LGPLA,
          ITLHUQUA-LQNUM TO XVM07M-LQNUM,
          ITLHUQUA-UMLQN TO XVM07M-UMLQN,
          ITLHUQUA-LENUM TO XLK01-LENUM,
          ITLHUQUA-LDUMM TO XLK01-LDUMM,
          CON_X          TO XLK01-XHUPF,
          ITLHUQUA-LETYP TO XLK01-LETYP,
          ITLHUQUA-QKAPV TO XLK01-QKAPV,
          ITLHUQUA-KKAPV TO XLK01-KKAPV,
          ITLHUQUA-LKAPA TO XLK01-LKAPA,
          ITLHUQUA-MAXLE TO XLK01-MAXLE,
          ITLHUQUA-PLPOS TO XLK01-PLPOS,
          ITLHUQUA-STEIN TO XLK01-STEIN,
          ITLHUQUA-PLAUF TO XLK01-PLAUF,
          ITLHUQUA-SUMME TO XLK01-SUMME.


*........Daten aus XMSEG.......................................

    MOVE: XMSEG-MANDT TO XLK01-MANDT,
          XMSEG-LGNUM TO XLK01-LGNUM,
          XMSEG-MATNR TO XLK01-MATNR,
          XMSEG-WERKS TO XLK01-WERKS,
          XMSEG-LGORT TO XLK01-LGORT,
          XMSEG-CHARG TO XLK01-CHARG,
          XMSEG-BESTQ TO XLK01-BESTQ,
*       xmseg-menge to xlk01-menge,
*       xmseg-meins to xlk01-meins,
*       xmseg-erfmg to xlk01-menga,
*       xmseg-erfme to xlk01-altme,
          XMSEG-WEMPF TO XLK01-WEMPF,
          XMSEG-ABLAD TO XLK01-ABLAD,
          XMSEG-MBLNR TO XLK01-MBLNR,
          XMSEG-MJAHR TO XLK01-MJAHR,
          XMSEG-ZEILE TO XLK01-MBPOS,
          XMSEG-BWART TO XLK01-BWART,
          XMSEG-BWLVS TO XLK01-BWLVS,
          XMSEG-TBPRI TO XLK01-TBPRI,
          XMSEG-VSCHN TO XLK01-VSCHN,
          XMSEG-NSCHN TO XLK01-NSCHN,
          XMSEG-SOBKZ TO XLK01-SOBKZ.

*........Setzen Lagertyp/Lagerplatz bei Einlagerung...................*

    IF NOT XMSEG-VSCHN IS INITIAL.
      MOVE: XMSEG-LGTYP TO XLK01-VLTYP,
            XMSEG-LGPLA TO XLK01-VLPLA,
            XMSEG-DYPLA TO XLK01-VKDYN.

*........Setzen Lagertyp/Lagerplatz bei Auslagerung...................*

    ELSE.
      MOVE: XMSEG-LGTYP TO XLK01-NLTYP,
            XMSEG-LGPLA TO XLK01-NLPLA,
            XMSEG-DYPLA TO XLK01-NKDYN.
    ENDIF.

*........Daten aus ZDM07M.............................................*

    MOVE: ZDM07M-UMREZ TO XLK01-UMREZ,
          ZDM07M-UMREN TO XLK01-UMREN,
          ZDM07M-XSTBW TO XLK01-XSTBW,
          ZDM07M-PKNUM TO XLK01-PKNUM,
          ZDM07M-PKPOS TO XLK01-PKPOS.
    IF LVS_TAFKZ EQ 'A'.
      MOVE ZDM07M-DIRTA TO XLK01-DIRTA.
    ENDIF.

*........Daten aus XVM07M.............................................*

    MOVE: XVM07M-BETYP TO XLK01-BETYP,
          XVM07M-BENUM TO XLK01-BENUM,
          XVM07M-AUTTA TO XLK01-AUTTA,
          XVM07M-TRART TO XLK01-TRART,
          XVM07M-TBFKZ TO XLK01-TBFKZ,
          XVM07M-QPLOS TO XLK01-QPLOS,                      "QM
          XVM07M-QPLOA TO XLK01-QPLOA,                      "QM
          XVM07M-LGNTB TO XLK01-LGNTB, "Lagerort des TB
          XVM07M-L2SKR TO XLK01-L2SKR. "2-stufige Kommi

*........Bei Anlieferung und Retoure Lieferungsnummer übernehmen......*

    IF NOT XVM07M-VBELN IS INITIAL.
      DATA: LV_VBTYP LIKE LIKP-VBTYP.
      SELECT SINGLE VBTYP FROM LIKP INTO LV_VBTYP WHERE
        VBELN = XVM07M-VBELN.
      IF SY-SUBRC IS INITIAL AND
        ( LV_VBTYP = CON_VBTYP_ANLIEF OR
          LV_VBTYP = CON_VBTYP_RETOURE ).
        MOVE: XVM07M-VBELN TO XLK01-VBELN,                "HU
              XVM07M-VBELP TO XLK01-POSNR.      "Lieferungsposition
      ENDIF.
    ENDIF.
*........Benutzernamen übernehmen.....................................*

    MOVE: SY-UNAME     TO XLK01-BNAME.

*........Setzen Plantermine...........................................*

    MOVE SY-DATLO TO XLK01-PDATU.
    CLEAR            XLK01-PZEIT.

*........Setzen Wareneingangsdatum....................................*

    IF NOT XMSEG-VSCHN IS INITIAL.
      CASE XVM07M-WEDKZ.
        WHEN CON_TAGESDATUM.
          MOVE SY-DATLO TO XLK01-WDATU.
        WHEN CON_BELEGDATUM.
          MOVE MKPF-BLDAT TO XLK01-WDATU.
        WHEN CON_BUCHUNGSDATUM.
          MOVE MKPF-BUDAT TO XLK01-WDATU.
      ENDCASE.
    ENDIF.

*........Setzen Mindesthaltbarkeitsdatum.............................*

    IF NOT XMSEG-VSCHN IS INITIAL.
      MOVE XMSEG-VFDAT TO XLK01-VFDAT.
    ENDIF.

*........Sonderabwicklung bei Initialdatenuebernahme für
*........Wareneindangsdatum, MHD und Zeugnisnummer

    IF NOT ITLHUQUA-WDATU_BSUEB IS INITIAL.
      MOVE ITLHUQUA-WDATU_BSUEB TO XLK01-WDATU.
    ENDIF.
    IF NOT ITLHUQUA-VFDAT_BSUEB IS INITIAL.
      MOVE ITLHUQUA-VFDAT_BSUEB TO XLK01-VFDAT.
    ENDIF.
    IF NOT ITLHUQUA-ZEUGN_BSUEB IS INITIAL.
      MOVE ITLHUQUA-ZEUGN_BSUEB TO XLK01-ZEUGN.
    ENDIF.

*........Setzen Sonderbestandsnummer..................................*

    MOVE XMSEG-SOBKZ TO XLK01-SOBKZ.
ENHANCEMENT-POINT HU_LK01_GENERIEREN_01 SPOTS ES_SAPMM07M.
    PERFORM LVS_SONDERBESTANDSNR USING XMSEG-SOBKZ
                                       XLK01-SONUM
                                       LS_ISU_LVS_SONDERBESTANDSNR. "IS2ERP

*........Setzen Stornobelegnummer für TB-Stornierung....................
    IF NOT ZDM07M-TBBEL IS INITIAL.
      MOVE: ZDM07M-TBBEL TO XLK01-SMBLN,
            ZDM07M-TBBJR TO XLK01-SJAHR,
            ZDM07M-TBBPO TO XLK01-SMBLP.
    ENDIF.

*........Berechnen Gewicht............................................*

    IF ITLHUQUA-UBRGW NE 0 AND
       ITLHUQUA-BRGEW EQ 0.                                 "note 811505
      PERFORM GEWICHT_BERECHNEN USING  XLK01-LGNUM
                                       ITLHUQUA-UBRGW
                                       ITLHUQUA-UGWEI
                                       ITLHUQUA-MENGE
                             CHANGING  XLK01-BRGEW
                                       XLK01-GEWEI.
    ELSE.
      PERFORM GEWICHT_BERECHNEN USING  XLK01-LGNUM
                                       ITLHUQUA-BRGEW
                                       ITLHUQUA-GEWEI
                                       ITLHUQUA-MENGE
                              CHANGING XLK01-BRGEW
                                       XLK01-GEWEI.
    ENDIF.

*........Ermitteln Quantnummer........................................*

    PERFORM QUANTNUMMER_BESORGEN.

*     if Inspection Lot number is still empty use value from ITLHUQUA
    IF ( ( XLK01-QPLOS IS INITIAL ) AND
         ( NOT ITLHUQUA-QPLOS IS INITIAL ) ).
      MOVE ITLHUQUA-QPLOS TO XLK01-QPLOS.
    ENDIF.

*........Aufnehmen Eintrag in Tabelle.................................*

    APPEND XLK01.

*.......Fuellen XLDILE für TA-Erstellung zur HU.......................*

    IF ZDM07M-DIRTA = CON_X AND
       XMSEG-VSCHN  = CON_X.    "only movement type 312 is relevant

      CLEAR XLDILE.
      READ TABLE XLDILE WITH KEY LGNUM = XLK01-LGNUM
                                 LENUM = ITLHUQUA-LENUM BINARY SEARCH.
      IF NOT SY-SUBRC IS INITIAL.
        XLDILE-LGNUM = XLK01-LGNUM.
        XLDILE-LENUM = ITLHUQUA-LENUM.
        XLDILE-BWLVS = XLK01-BWLVS.
        INSERT XLDILE INDEX SY-TABIX.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF HLP_SUMME NE XMSEG-MENGE.
    LF_DIFF = ABS( HLP_SUMME - XMSEG-MENGE ) * 10.          "HP_714874
    DESCRIBE TABLE ITLHUQUA LINES LF_ITEM_NR.
    LF_EPSILON = LF_EPSILON * LF_ITEM_NR.
    IF LF_DIFF > LF_EPSILON.
      MESSAGE E606(L9) WITH XMSEG-MATNR XMSEG-WERKS XMSEG-LGORT.
    ENDIF.
  ENDIF.

ENDFORM.                             " HU_LK01_GENERIEREN
*---------------------------------------------------------------------*
*       FORM HU_LK02_GENERIEREN                                       *
*---------------------------------------------------------------------*
*       Dieses Modul generiert für die Materialbelegpositionen        *
*       einen LVS-Kommunikationssatz für Umbuchungen.                 *
*---------------------------------------------------------------------*
FORM HU_LK02_GENERIEREN.

  DATA: LS_ISU_LVS_SONDERBESTANDSNR TYPE ISU_LVS_SONDERBESTANDSNR. "IS2ERP
  DATA: lf_diff TYPE hum_epsilon,                           "n_1113076
        lf_epsilon TYPE hum_epsilon,
        lf_item_nr TYPE sytabix.

  CALL FUNCTION 'HU_GET_CALC_TYPE'
    IMPORTING
      ef_epsilon = lf_epsilon.

  CHECK NOT XMSEG-MENGE IS INITIAL.
  CLEAR XLK02.

* Begin of Note 1624277                                       "v_1624277
* Outsoruced Manufacturing via deliveries & HU/WM
  IF gv_mm_om1_sfws_sc_active EQ 'X' AND zdm07m-co_order EQ 'X'
    AND xmseg-kzbew = L AND xmseg-aufnr IS NOT INITIAL
    AND xmseg-line_id IS NOT INITIAL AND xmseg-parent_id IS NOT INITIAL
    AND zvm07m-xstor NE '2'.
    HLP_ZEILE = xmseg-line_id. "original pos in delivery
  ELSE.
    MOVE ZDM07M-IMSEG_ORIGINAL TO HLP_ZEILE.
  ENDIF.
* End of Note 1624277                                         "^_1624277

  CALL FUNCTION 'L_GET_HUQUA_ZEILE'
    EXPORTING
      I_ZEILE        = HLP_ZEILE
    TABLES
      ET_LHUQUA      = ITLHUQUA
    EXCEPTIONS
      NO_ENTRY_FOUND = 1
      OTHERS         = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CLEAR HLP_SUMME.

  LOOP AT ITLHUQUA.

    HLP_SUMME = HLP_SUMME + ITLHUQUA-MENGE.

    MOVE: ITLHUQUA-MENGE TO XLK02-MENGE,
          ITLHUQUA-MEINS TO XLK02-MEINS,
          ITLHUQUA-LGTYP TO XMSEG-LGTYP,
          ITLHUQUA-LGPLA TO XMSEG-LGPLA,
          ITLHUQUA-LQNUM TO XVM07M-LQNUM,
          ITLHUQUA-UMLQN TO XVM07M-UMLQN,
          ITLHUQUA-LENUM TO XLK02-LENUM,
          ITLHUQUA-LDUMM TO XLK02-LDUMM,
          ITLHUQUA-LETYP TO XLK02-LETYP,
          ITLHUQUA-KKAPV TO XLK02-KKAPV,
          ITLHUQUA-LKAPA TO XLK02-LKAPA,
          ITLHUQUA-MAXLE TO XLK02-MAXLE,
          ITLHUQUA-PLPOS TO XLK02-PLPOS,
          ITLHUQUA-STEIN TO XLK02-STEIN,
          ITLHUQUA-PLAUF TO XLK02-PLAUF,
          ITLHUQUA-SUMME TO XLK02-SUMME.

*........Daten aus XMSEG..............................................*

    MOVE: XMSEG-MANDT TO XLK02-MANDT,
          XMSEG-LGNUM TO XLK02-LGNUM,
          XMSEG-MBLNR TO XLK02-MBLNR,
          XMSEG-MJAHR TO XLK02-MJAHR,
          XMSEG-ZEILE TO XLK02-MBPOS,
          XMSEG-BWART TO XLK02-BWART,
          XMSEG-BWLVS TO XLK02-BWLVS,
          XMSEG-LGTYP TO XLK02-LGTYP,
          XMSEG-LGPLA TO XLK02-LGPLA.

*........Ermitteln Quantnummern.......................................*
    PERFORM QUANTNUMMER_BESORGEN_UB.

    IF XMSEG-SHKZG EQ H.

      MOVE: XMSEG-MATNR TO XLK02-MATN1,
            XMSEG-WERKS TO XLK02-WERK1,
            XMSEG-LGORT TO XLK02-LGOR1,
            XMSEG-CHARG TO XLK02-CHRG1,
            XMSEG-BESTQ TO XLK02-BSTQ1,
            XMSEG-SOBKZ TO XLK02-SOKZ1.
ENHANCEMENT-POINT HU_LK02_GENERIEREN_01 SPOTS ES_SAPMM07M.
      PERFORM LVS_SONDERBESTANDSNR USING XMSEG-SOBKZ
                                         XLK02-SONR1
                                         LS_ISU_LVS_SONDERBESTANDSNR. "IS2ERP
      MOVE: XMSEG-UMMAT TO XLK02-MATN2,
            XMSEG-UMWRK TO XLK02-WERK2,
            XMSEG-UMLGO TO XLK02-LGOR2,
            XMSEG-UMCHA TO XLK02-CHRG2,
           ZDM07M-UMBSQ TO XLK02-BSTQ2,
            XMSEG-UMSOK TO XLK02-SOKZ2.
      PERFORM LVS_SONDERBESTANDSNR_UM USING XMSEG-UMSOK
                                            XLK02-SONR2.
      IF NOT XVM07M-XHUPF IS INITIAL.
        MOVE CON_X TO XLK02-HUPF1.
      ENDIF.

      IF NOT ZDM07M-UMXHUPF IS INITIAL.
        MOVE CON_X TO XLK02-HUPF2.
      ENDIF.

*........Berechnen Gewicht............................................*

      PERFORM GEWICHT_BERECHNEN USING    XMSEG-LGNUM
                                         ITLHUQUA-BRGEW
                                         ITLHUQUA-GEWEI
                                         ITLHUQUA-MENGE
                                CHANGING XLK02-BRGW1
                                         XLK02-GWEI1.

      PERFORM GEWICHT_BERECHNEN USING    XMSEG-LGNUM
                                         ITLHUQUA-UBRGW
                                         ITLHUQUA-UGWEI
                                         ITLHUQUA-MENGE
                                CHANGING XLK02-BRGW2
                                         XLK02-GWEI2.

      MOVE: ITLHUQUA-QKAPV TO XLK02-QKAP1,
            ITLHUQUA-UQKPV TO XLK02-QKAP2.

    ELSE.
      MOVE: XMSEG-MATNR TO XLK02-MATN2,
            XMSEG-WERKS TO XLK02-WERK2,
            XMSEG-LGORT TO XLK02-LGOR2,
            XMSEG-CHARG TO XLK02-CHRG2,
            XMSEG-BESTQ TO XLK02-BSTQ2,
            XMSEG-SOBKZ TO XLK02-SOKZ2.
ENHANCEMENT-POINT HU_LK02_GENERIEREN_02 SPOTS ES_SAPMM07M.
      PERFORM LVS_SONDERBESTANDSNR USING XMSEG-SOBKZ
                                         XLK02-SONR2
                                         LS_ISU_LVS_SONDERBESTANDSNR. "IS2ERP
      MOVE: XMSEG-UMMAT TO XLK02-MATN1,
            XMSEG-UMWRK TO XLK02-WERK1,
            XMSEG-UMLGO TO XLK02-LGOR1,
            XMSEG-UMCHA TO XLK02-CHRG1,
           ZDM07M-UMBSQ TO XLK02-BSTQ1,
            XMSEG-UMSOK TO XLK02-SOKZ1.
      PERFORM LVS_SONDERBESTANDSNR_UM USING XMSEG-UMSOK
                                            XLK02-SONR1.
      IF NOT XVM07M-XHUPF IS INITIAL.
        MOVE CON_X TO XLK02-HUPF2.
      ENDIF.

      IF NOT ZDM07M-UMXHUPF IS INITIAL.
        MOVE CON_X TO XLK02-HUPF1.
      ENDIF.

      PERFORM GEWICHT_BERECHNEN USING    XMSEG-LGNUM
                                        ITLHUQUA-BRGEW
                                        ITLHUQUA-GEWEI
                                        ITLHUQUA-MENGE
                               CHANGING XLK02-BRGW2
                                        XLK02-GWEI2.

      PERFORM GEWICHT_BERECHNEN USING    XMSEG-LGNUM
                                         ITLHUQUA-UBRGW
                                         ITLHUQUA-UGWEI
                                         ITLHUQUA-MENGE
                                CHANGING XLK02-BRGW1
                                         XLK02-GWEI1.

      MOVE: ITLHUQUA-QKAPV TO XLK02-QKAP2,
            ITLHUQUA-UQKPV TO XLK02-QKAP1.

    ENDIF.

*  move:     xmseg-menge to xlk02-menge,
*            xmseg-meins to xlk02-meins,
*            xmseg-erfmg to xlk02-mnga1,
*            xmseg-erfme to xlk02-altm1.

*........Daten aus ZDM07M.............................................*

    MOVE: ZDM07M-UMREZ TO XLK02-UMRZ1,
          ZDM07M-UMREN TO XLK02-UMRN1,
          ZDM07M-WENUM TO XLK02-WENUM.
    IF LVS_TAFKZ EQ 'A'.
      MOVE ZDM07M-DIRTA TO XLK02-DIRTA.
    ENDIF.

*........Setzen Wareneingangsdatum....................................*
* eventuell muss dieses Coding auch in LK02_GENERIEREN eingebaut werden
    IF NOT XMSEG-VSCHN IS INITIAL.
      CASE XVM07M-WEDKZ.
        WHEN CON_TAGESDATUM.
          MOVE SY-DATLO TO XLK02-WDATU.
        WHEN CON_BELEGDATUM.
          MOVE MKPF-BLDAT TO XLK02-WDATU.
        WHEN CON_BUCHUNGSDATUM.
          MOVE MKPF-BUDAT TO XLK02-WDATU.
      ENDCASE.
    ENDIF.

    IF NOT ITLHUQUA-WDATU_BSUEB IS INITIAL.                 "n_v_1356915
      MOVE ITLHUQUA-WDATU_BSUEB TO XLK02-WDATU.
    ENDIF.
    IF NOT ITLHUQUA-VFDAT_BSUEB IS INITIAL.
      MOVE ITLHUQUA-VFDAT_BSUEB TO XLK02-VFDAT_UMB.
    ENDIF.                                                  "n_^_1356915

*........Setzen Stornobelegnummer für TB-Stornierung....................
    IF NOT ZDM07M-TBBEL IS INITIAL.
      MOVE: ZDM07M-TBBEL TO XLK02-SMBLN,
            ZDM07M-TBBJR TO XLK02-SJAHR,
            ZDM07M-TBBPO TO XLK02-SMBLP.
    ENDIF.

*........Reset Mengeneinheiten bei Storno Material an Material
*  if xmseg-shkzg ne h and                                   "KIRK010990
*     xlk02-matn1 ne xlk02-matn2.                            "KIRK010990
*    move: xmseg-menge to xlk02-mnga1,                       "KIRK010990
*          xmseg-meins to xlk02-altm1.                       "KIRK010990
*    xlk02-umrz1 = 1.                                        "KIRK010990
*    xlk02-umrn1 = 1.                                        "KIRK010990
*  endif.                                                    "KIRK010990

*   On batch change we must fill addtional fields        "v_n_582739
    IF ( ( NOT XMSEG-UMCHA IS INITIAL ) AND
         ( XMSEG-UMCHA <> XMSEG-CHARG ) ).
      XLK02-VFDAT_UMB = ZDM07M-UMVFDAT.
    ENDIF.                                                  "^_n_582739

*........Daten aus XVM07M.............................................*

    MOVE: XVM07M-QPLOS TO XLK02-QPLOS,                      "QM
          XVM07M-QPLOA TO XLK02-QPLOA,                      "QM
          XVM07M-AUTTA TO XLK02-AUTTA.

*.......if Inspection Lot number is still empty use value from ITLHUQUA
    IF ( ( XLK02-QPLOS IS INITIAL ) AND                     "n_998910
         ( NOT ITLHUQUA-QPLOS IS INITIAL ) ).
      MOVE ITLHUQUA-QPLOS TO XLK02-QPLOS.
    ENDIF.

*........Aufnehmen Eintrag in Tabelle.................................*

    APPEND XLK02.
  ENDLOOP.

  IF HLP_SUMME NE XMSEG-MENGE.
    lf_diff = ABS( hlp_summe - xmseg-menge ) * 10.          "n_1113076
    DESCRIBE TABLE itlhuqua LINES lf_item_nr.
    lf_epsilon = lf_epsilon * lf_item_nr.
    IF lf_diff > lf_epsilon.
      MESSAGE E606(L9) WITH XMSEG-MATNR XMSEG-WERKS XMSEG-LGORT.
    ENDIF.
  ENDIF.


ENDFORM.                               " HU_LK02_GENERIEREN
*<<<<<<< begin of insert HP_325415 >>>>>>>>>>>>>>>>>>>>>>
FORM WMS_HUS_BESTIMMEN.
  DATA: LT_HU_IMSEG TYPE HUMSEG_HU_T.
  DATA: LS_REHANG_HU TYPE HUM_REHANG_HU.
  DATA: LF_TABIX TYPE SYTABIX.
  FIELD-SYMBOLS: <HU_IMSEG> TYPE HUMSEG_HU.

  CHECK NOT XMSEG-MENGE IS INITIAL.
  LF_TABIX = ZDM07M-IMSEG_ORIGINAL.
  CALL FUNCTION 'HU_GET_HUMSEG'
    EXPORTING
      IMSEG_TABIX     = LF_TABIX
    IMPORTING
      ET_HU_IMSEG     = LT_HU_IMSEG
    EXCEPTIONS
      NO_HU_DATA      = 1
      NO_HU_MSEG_DATA = 2
      OTHERS          = 99.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  LOOP AT LT_HU_IMSEG ASSIGNING <HU_IMSEG>.
    CLEAR LS_REHANG_HU.
    LS_REHANG_HU-TOP_HU_EXTERNAL = <HU_IMSEG>-EXIDV_OB.
    LS_REHANG_HU-VENUM           = <HU_IMSEG>-VENUM.
    LS_REHANG_HU-VEPOS           = <HU_IMSEG>-VEPOS.
    LS_REHANG_HU-RFBEL           = '1'.
    LS_REHANG_HU-RFPOS           = ZDM07M-IMSEG_ORIGINAL.
    APPEND LS_REHANG_HU TO GT_REHANG_HU.
  ENDLOOP.
  IF SY-SUBRC IS INITIAL.
    XLK03-RFPOS = ZDM07M-IMSEG_ORIGINAL.
    XLK03-RFBEL = '1'.
  ENDIF.
ENDFORM.                    "wms_hus_bestimmen

                                                            "v_n_568108
*&---------------------------------------------------------------------*
*&      Form  determine_org_partner_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LEMOVPOS  text
*----------------------------------------------------------------------*

FORM  DETERMINE_ORG_PARTNER_NEW TABLES XLK03 STRUCTURE KOMDLGN.

  DATA: ES_LEMOVPOS TYPE LEMOVPOS.
  DATA: IS_KOMDLGN  TYPE KOMDLGN.
  DATA: LF_TABIX TYPE SY-TABIX.

  DATA: LS_LIPS TYPE LIPSVB.                                "v_n_568965
  DATA: LS_LEMOVDAT TYPE LEMOVDAT.

  DATA: CF_NO_NEW_DET TYPE XFELD,                          "v_n_1012818
        CS_XLK03 TYPE KOMDLGN.

  CLEAR: CS_XLK03, CF_NO_NEW_DET.                          "^_n_1012818

  CLEAR: LS_LIPS, LS_LEMOVDAT.                              "^_n_568965

  CLEAR: ES_LEMOVPOS, IS_KOMDLGN.

  LF_TABIX = SY-TABIX.

* New determination makes only sense in case of real stock transfers
* Otherwise, external partners are involved and can not be determined
* from T001L or T001W
  IF XLK03-UMWRK IS INITIAL AND                            "v_n_1012818
     XLK03-UMLGO IS INITIAL AND
     XLK03-UMMAT IS INITIAL AND
     XLK03-UMCHA IS INITIAL AND
     XLK03-UMBAR IS INITIAL AND
     XLK03-UMSOK IS INITIAL.
    CF_NO_NEW_DET = 'X'.
  ENDIF.

  CS_XLK03 = XLK03.

  IF NOT CF_NO_NEW_DET IS INITIAL.
    IF CS_XLK03-LIFNR NE XLK03-LIFNR OR
       CS_XLK03-KUNWE NE XLK03-KUNWE.
      XLK03-KUNWE = CS_XLK03-KUNWE.
      XLK03-LIFNR = CS_XLK03-LIFNR.
      MODIFY XLK03 INDEX LF_TABIX TRANSPORTING KUNWE LIFNR.
    ENDIF.
*   No re-determination is desired => jump out
    CHECK 1 = 2.
  ENDIF.                                                   "^_n_1012818

  ES_LEMOVPOS-WERKS = XLK03-WERKS.
  ES_LEMOVPOS-LGORT = XLK03-LGORT.
  ES_LEMOVPOS-UMWRK = XLK03-UMWRK.
  ES_LEMOVPOS-UMLGO = XLK03-UMLGO.
  ES_LEMOVPOS-SHKZG = XLK03-SHKZG.


  IF ES_LEMOVPOS-SHKZG NA 'SH'.                             "v_n_568965

    LS_LIPS-BWART = XLK03-BWART.

    CALL FUNCTION 'LE_MOVEMENT_DATA_DETERMINE_TAB'
      EXPORTING
        IF_SELECT_T156 = 'X'
        IS_LIPS        = LS_LIPS
      IMPORTING
        ES_LEMOVDAT    = LS_LEMOVDAT
      EXCEPTIONS
        NO_ENTRY_T156  = 4
        OTHERS         = 11.

    ES_LEMOVPOS-SHKZG = LS_LEMOVDAT-SHKZG.

  ENDIF.                                                    "^_n_568965


  PERFORM DETERMINE_ORG_DATA CHANGING ES_LEMOVPOS
                                      IS_KOMDLGN.

*...keine neue Ermittlung bei Rücklieferung zum Lieferant     v_n_638415

  IF XLK03-DLVTP <> 'RL' AND                                "^_n_638415
     XLK03-DLVTP <> 'LB'.                                   "n_706142

*...Versandstelle übernehmen
    IF NOT IS_KOMDLGN-VSTEL IS INITIAL.
      XLK03-VSTEL = IS_KOMDLGN-VSTEL.
    ENDIF.
*...Verkaufsorganisation
    IF NOT IS_KOMDLGN-VKORG IS INITIAL.
      XLK03-VKORG = IS_KOMDLGN-VKORG.
    ENDIF.
*...Sparte
    IF NOT IS_KOMDLGN-SPART IS INITIAL.
      XLK03-SPART = IS_KOMDLGN-SPART.
    ENDIF.
*...Vertriebsweg
    IF NOT IS_KOMDLGN-VTWEG IS INITIAL.
      XLK03-VTWEG = IS_KOMDLGN-VTWEG.
    ENDIF.
*...Kunde
ENHANCEMENT-SECTION     DETERMINE_ORG_PARTNER_NEW_01 SPOTS ES_SAPMM07M.
    IF NOT IS_KOMDLGN-KUNWE IS INITIAL.
      XLK03-KUNWE = IS_KOMDLGN-KUNWE.
    ENDIF.
END-ENHANCEMENT-SECTION.
*...Lieferant
    IF NOT IS_KOMDLGN-LIFNR IS INITIAL.
      XLK03-LIFNR = IS_KOMDLGN-LIFNR.
    ENDIF.

    MODIFY XLK03 INDEX LF_TABIX TRANSPORTING VSTEL
                                             VKORG
                                             SPART
                                             VTWEG
                                             KUNWE
                                             LIFNR.

  ELSEIF XLK03-DLVTP = 'LB' AND NOT XMSEG-WEMPF IS INITIAL. "v_n_706142

*...Bei Lohnbearbeitung wird der Warenempfänger und Lieferant nach
*...Eingabe in der MM-Transaktion übernommen.
    XLK03-KUNWE = XMSEG-WEMPF.
    TRANSLATE XLK03-KUNWE TO UPPER CASE.                 "#EC TRANSLANG
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'             "v_n_813362
      EXPORTING
        INPUT         = XLK03-KUNWE
      IMPORTING
        OUTPUT        = XLK03-KUNWE.
    IF XLK03-LIFNR IS INITIAL.
      XLK03-LIFNR = XMSEG-LIFNR.
    ENDIF.
    MODIFY XLK03 INDEX LF_TABIX TRANSPORTING
                                KUNWE LIFNR.      "^_n_706142 "^_n_813362

  ENDIF.                                                    "n_638415

ENDFORM.                    "determine_org_partner_new

*&---------------------------------------------------------------------*
*&      Form  determine_org_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LEMOVPOS  text
*----------------------------------------------------------------------*
FORM DETERMINE_ORG_DATA  CHANGING IS_LEMOVPOS STRUCTURE LEMOVPOS
                                  ES_KOMDLGN STRUCTURE KOMDLGN.


  DATA: LS_LIPS LIKE LIPSVB.
  DATA: LS_LEMOVDAT_SOURCE LIKE LEMOVDAT.
  DATA: LS_LEMOVDAT_TARGET LIKE LEMOVDAT.

*...Initialisierung aller Felder und Strukturen die neu ermittelt werden

  CLEAR: IS_LEMOVPOS-W_VSTEL,
         IS_LEMOVPOS-W_VKORG,
         IS_LEMOVPOS-W_VTWEG,
         IS_LEMOVPOS-W_SPART,
         IS_LEMOVPOS-W_LIFNR,
         IS_LEMOVPOS-W_KUNNR,
         IS_LEMOVPOS-L_VSTEL,
         IS_LEMOVPOS-L_VKORG,
         IS_LEMOVPOS-L_VTWEG,
         IS_LEMOVPOS-L_SPART,
         IS_LEMOVPOS-L_LIFNR,
         IS_LEMOVPOS-L_KUNNR.

  CLEAR: LS_LEMOVDAT_SOURCE,
         LS_LEMOVDAT_TARGET.

*...Ermittlung der Organisationsdaten mit Werk und Lagerort
  MOVE IS_LEMOVPOS-WERKS TO LS_LIPS-WERKS.
  MOVE IS_LEMOVPOS-LGORT TO LS_LIPS-LGORT.

  CALL FUNCTION 'LE_MOVEMENT_DATA_DETERMINE_TAB'
    EXPORTING
      IS_LIPS         = LS_LIPS
      IF_SELECT_T001W = 'X'
      IF_SELECT_T001L = 'X'
    IMPORTING
      ES_LEMOVDAT     = LS_LEMOVDAT_SOURCE
    EXCEPTIONS
      NO_ENTRY_T001W  = 1
      NO_ENTRY_T001L  = 2
      OTHERS          = 11.

  IF SY-SUBRC <> 0.

  ENDIF.


*...Ermittlung der Organisationsdaten mit Werk und Lagerort
  MOVE IS_LEMOVPOS-UMWRK TO LS_LIPS-WERKS.
  MOVE IS_LEMOVPOS-UMLGO TO LS_LIPS-LGORT.

  CALL FUNCTION 'LE_MOVEMENT_DATA_DETERMINE_TAB'
    EXPORTING
      IS_LIPS         = LS_LIPS
      IF_SELECT_T001W = 'X'
      IF_SELECT_T001L = 'X'
    IMPORTING
      ES_LEMOVDAT     = LS_LEMOVDAT_TARGET
    EXCEPTIONS
      NO_ENTRY_T001W  = 1
      NO_ENTRY_T001L  = 2
      OTHERS          = 11.

  IF SY-SUBRC <> 0.

  ENDIF.

*...Fuellen der gt_lemovpos mit den Daten gemäß der Durchfalllogik
*   Daten zuerst von T001l falls leer dann von T001W. Direkt ein-
*   gegebene Daten im Dialog haben Vorang

*...lemovdat_target ist nur bei Umlagervorgängen gefüllt     "v_n_676481
  IF NOT XLK03-KZUML IS INITIAL.                            "^_n_676481
*...Struktur lemovdat_source ist Quelle
*   Struktur lemovdat_target ist Ziel
*   LIFNR aus lemovdat_source
*   KUNNR aus lemovdat_target
    IF ( IS_LEMOVPOS-SHKZG = 'H' AND xlk03-shkzg_um <> '2' ) OR "n_1110851
       ( IS_LEMOVPOS-SHKZG = 'S' AND xlk03-shkzg_um =  '2' ) .

*...Kunde und Lieferant aus T001W, T001L
      IS_LEMOVPOS-W_LIFNR = LS_LEMOVDAT_SOURCE-W_LIFNR.
      IS_LEMOVPOS-L_LIFNR = LS_LEMOVDAT_SOURCE-L_LIFNR.
      IS_LEMOVPOS-W_KUNNR = LS_LEMOVDAT_TARGET-W_KUNNR.
      IS_LEMOVPOS-L_KUNNR = LS_LEMOVDAT_TARGET-L_KUNNR.

*...Orgdaten aus dem Werk T001W (Quelle)
      IS_LEMOVPOS-W_VSTEL = LS_LEMOVDAT_SOURCE-W_VSTEL.
      IS_LEMOVPOS-W_VKORG = LS_LEMOVDAT_SOURCE-W_VKORG.
      IS_LEMOVPOS-W_VTWEG = LS_LEMOVDAT_SOURCE-W_VTWEG.
      IS_LEMOVPOS-W_SPART = LS_LEMOVDAT_SOURCE-W_SPART.

*...Orgdaten aus dem Werk T001L (Quelle)
      IS_LEMOVPOS-L_VSTEL = LS_LEMOVDAT_SOURCE-L_VSTEL.
      IS_LEMOVPOS-L_VKORG = LS_LEMOVDAT_SOURCE-L_VKORG.
      IS_LEMOVPOS-L_VTWEG = LS_LEMOVDAT_SOURCE-L_VTWEG.
      IS_LEMOVPOS-L_SPART = LS_LEMOVDAT_SOURCE-L_SPART.
    ENDIF.

*...Struktur lemovdat_target ist Quelle
*   Struktur lemovdat_source ist Ziel
*   LIFNR aus lemovdat_target
*   KUNNR aus lemovdat_source
    IF ( IS_LEMOVPOS-SHKZG = 'S' AND xlk03-shkzg_um <> '2' ) OR "n_1110851
       ( IS_LEMOVPOS-SHKZG = 'H' AND xlk03-shkzg_um =  '2' ) .

*...Kunde und Lieferant aus T001W, T001L
      IS_LEMOVPOS-W_LIFNR = LS_LEMOVDAT_TARGET-W_LIFNR.
      IS_LEMOVPOS-L_LIFNR = LS_LEMOVDAT_TARGET-L_LIFNR.
      IS_LEMOVPOS-W_KUNNR = LS_LEMOVDAT_SOURCE-W_KUNNR.
      IS_LEMOVPOS-L_KUNNR = LS_LEMOVDAT_SOURCE-L_KUNNR.

*...Orgdaten aus dem Werk T001W (Quelle)
      IS_LEMOVPOS-W_VSTEL = LS_LEMOVDAT_TARGET-W_VSTEL.
      IS_LEMOVPOS-W_VKORG = LS_LEMOVDAT_TARGET-W_VKORG.
      IS_LEMOVPOS-W_VTWEG = LS_LEMOVDAT_TARGET-W_VTWEG.
      IS_LEMOVPOS-W_SPART = LS_LEMOVDAT_TARGET-W_SPART.

*...Orgdaten aus dem Werk T001L (Quelle)
      IS_LEMOVPOS-L_VSTEL = LS_LEMOVDAT_TARGET-L_VSTEL.
      IS_LEMOVPOS-L_VKORG = LS_LEMOVDAT_TARGET-L_VKORG.
      IS_LEMOVPOS-L_VTWEG = LS_LEMOVDAT_TARGET-L_VTWEG.
      IS_LEMOVPOS-L_SPART = LS_LEMOVDAT_TARGET-L_SPART.
    ENDIF.
*...kein Umlagervorgang -> nur ls_lemovdat_source benuzten   "v_n_676481
  ELSE.
    IF IS_LEMOVPOS-SHKZG CA 'SH'.

*...Kunde und Lieferant aus T001W, T001L
      IS_LEMOVPOS-W_LIFNR = LS_LEMOVDAT_SOURCE-W_LIFNR.
      IS_LEMOVPOS-L_LIFNR = LS_LEMOVDAT_SOURCE-L_LIFNR.
      IS_LEMOVPOS-W_KUNNR = LS_LEMOVDAT_SOURCE-W_KUNNR.
      IS_LEMOVPOS-L_KUNNR = LS_LEMOVDAT_SOURCE-L_KUNNR.

*...Orgdaten aus dem Werk T001W (Quelle)
      IS_LEMOVPOS-W_VSTEL = LS_LEMOVDAT_SOURCE-W_VSTEL.
      IS_LEMOVPOS-W_VKORG = LS_LEMOVDAT_SOURCE-W_VKORG.
      IS_LEMOVPOS-W_VTWEG = LS_LEMOVDAT_SOURCE-W_VTWEG.
      IS_LEMOVPOS-W_SPART = LS_LEMOVDAT_SOURCE-W_SPART.

*...Orgdaten aus dem Werk T001L (Quelle)
      IS_LEMOVPOS-L_VSTEL = LS_LEMOVDAT_SOURCE-L_VSTEL.
      IS_LEMOVPOS-L_VKORG = LS_LEMOVDAT_SOURCE-L_VKORG.
      IS_LEMOVPOS-L_VTWEG = LS_LEMOVDAT_SOURCE-L_VTWEG.
      IS_LEMOVPOS-L_SPART = LS_LEMOVDAT_SOURCE-L_SPART.

    ENDIF.
  ENDIF.                                                    "^_n_676481

*... ERMITTLUNG DUMMY-WARENEMPFÄNGER FÜR KOMDLGN
  IF NOT IS_LEMOVPOS-L_KUNNR IS INITIAL.
    ES_KOMDLGN-KUNWE = IS_LEMOVPOS-L_KUNNR.
  ELSEIF NOT IS_LEMOVPOS-W_KUNNR IS INITIAL.
    ES_KOMDLGN-KUNWE = IS_LEMOVPOS-W_KUNNR.
  ELSE.
*... ERROR
  ENDIF.

*... ERMITTLUNG DUMMY-LIEFERANT FÜR KOMDLGN, WENN KEIN BESTELLBEZUG UND
*... KEINE MANUELLE EINGABE VORLIEGT
  IF NOT XMSEG-LIFNR IS INITIAL.                            "v_n_731039
    ES_KOMDLGN-LIFNR = XMSEG-LIFNR.
  ELSE.
    IF NOT IS_LEMOVPOS-L_LIFNR IS INITIAL.
      ES_KOMDLGN-LIFNR = IS_LEMOVPOS-L_LIFNR.
    ELSEIF NOT IS_LEMOVPOS-W_LIFNR IS INITIAL.
      ES_KOMDLGN-LIFNR = IS_LEMOVPOS-W_LIFNR.
    ELSE.
*... ERROR
    ENDIF.
  ENDIF.                                                    "^_n_731039

*... ERMITTLUNG VERSANDSTELLE FÜR KOMDLGN
  IF NOT IS_LEMOVPOS-L_VSTEL IS INITIAL.
    ES_KOMDLGN-VSTEL = IS_LEMOVPOS-L_VSTEL.
  ELSEIF NOT IS_LEMOVPOS-W_VSTEL IS INITIAL.
    ES_KOMDLGN-VSTEL = IS_LEMOVPOS-W_VSTEL.
  ELSE.
*... ERROR
  ENDIF.

*... ERMITTLUNG VERTRIEBSORGANISATION FÜR KOMDLGN
  IF NOT IS_LEMOVPOS-L_VKORG IS INITIAL.
    ES_KOMDLGN-VKORG = IS_LEMOVPOS-L_VKORG.
  ELSEIF NOT IS_LEMOVPOS-W_VKORG IS INITIAL.
    ES_KOMDLGN-VKORG = IS_LEMOVPOS-W_VKORG.
  ELSE.
*... ERROR
  ENDIF.

*... ERMITTLUNG VERTRIEBSWEG FÜR KOMDLGN
  IF NOT IS_LEMOVPOS-L_VTWEG IS INITIAL.
    ES_KOMDLGN-VTWEG = IS_LEMOVPOS-L_VTWEG.
  ELSEIF NOT IS_LEMOVPOS-W_VTWEG IS INITIAL.
    ES_KOMDLGN-VTWEG = IS_LEMOVPOS-W_VTWEG.
  ELSE.
*... ERROR
  ENDIF.

*... ERMITTLUNG SPARTE FÜR KOMDLGN
  IF NOT IS_LEMOVPOS-L_SPART IS INITIAL.
    ES_KOMDLGN-SPART = IS_LEMOVPOS-L_SPART.
  ELSEIF NOT IS_LEMOVPOS-W_SPART IS INITIAL.
    ES_KOMDLGN-SPART = IS_LEMOVPOS-W_SPART.
  ELSE.
*... ERROR
  ENDIF.

ENDFORM.                    " determine_org_data             "^_n_568108

*&----------------------------------------------------------*"v_n_655641
*&      Form  fill_predecessor_document
*&---------------------------------------------------------------------*
*       this routine will determine the predecessor document
*       to store this information in the delivery document.
*       The fields are relevant to select the correct ekes records
*       with the FM me_read_item_goods_receipt
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM  FILL_PREDECESSOR_DOCUMENT USING    MKPF   STRUCTURE MKPF
                                         XVM07M STRUCTURE VM07M
                                         XMSEG  STRUCTURE MSEG
                                         ZDM07M STRUCTURE DM07M
                                CHANGING XLK03  STRUCTURE KOMDLGN.

*...Return deliveries must fill PRE_VL_ETENS for EKES update "v_n_785969
  IF XLK03-DLVTP = 'RL'.
    XLK03-PRE_VL_ETENS = XLK03-ETENS.
  ENDIF.                                                    "^_n_785969

*...only relevant for PO/STO scenario
  CHECK NOT MKPF-XBLNR IS INITIAL AND
        NOT XLK03-VGBEL IS INITIAL AND
        NOT XLK03-VGPOS IS INITIAL AND
        NOT XLK03-ETENS IS INITIAL AND
            XLK03-VGTYP = 'V'.

  XLK03-PRE_VL_ETENS = XLK03-ETENS.

ENDFORM.                                                    "^_n_655641