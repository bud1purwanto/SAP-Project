*-----------------------------------------------------------------------
*        Modulpool zur Kundenauftragsbearbeitung
*-----------------------------------------------------------------------

         INCLUDE MV45ATOP.

ENHANCEMENT-POINT SAPMV45A_03 SPOTS ES_SAPMV45A STATIC.
*-----------------------------------------------------------------------
*        U S E R - E X I T S
*        U S E R - E X I T S
*        U S E R - E X I T S
*-----------------------------------------------------------------------
*        INCLUDE MV45ATZZ.            " Data definitions in MV45ATOP
         INCLUDE MV45AOZZ.             " User-modules PBO
         INCLUDE MV45AIZZ.             " User-modules PAI
         INCLUDE MV45AFZA.             " User-forms < 3.0
         INCLUDE MV45AFZB.             " User-forms
         INCLUDE MV45AFZC.             " User-forms < 3.0D
         INCLUDE MV45AFZD.             " User-forms   3.0E
         INCLUDE MV45AFZF.             " User-forms   3.0F
*        include mv45afzg.             " User-forms   3.1G
         include mv45afzh.             " User-forms   4.6B
         INCLUDE MV45AFZZ.             " User-forms
         INCLUDE MV45AFZ4.             " User-forms   4.0
ENHANCEMENT-POINT SAPMV45A_01 SPOTS ES_SAPMV45A STATIC.

*-----------------------------------------------------------------------
*        Tabellen-spezifische Module PBO
*-----------------------------------------------------------------------
         INCLUDE MV45AOAK.             "Kopf
         INCLUDE MV45AOAP.             "Auftragspositionen
         INCLUDE MV45AOAT.             "Texte
         INCLUDE MV45AOEP.             "Einteilungen
         INCLUDE MV45AOSN.             "Änderungsstände
         INCLUDE MV45AOLB.             "Abrufe
         INCLUDE MV45AOKO.             "KOnditionen
         INCLUDE MV45AOUP.             "Positionsstatus

*-----------------------------------------------------------------------
*        Textverarbeitung     Module PBO
*-----------------------------------------------------------------------
         INCLUDE MV45AOTX.
*-----------------------------------------------------------------------
*        PBO - Module alphabetisch geordnet
*-----------------------------------------------------------------------
         INCLUDE MV45AO01.
         INCLUDE MV45AO0A.
         INCLUDE MV45AO0B.
         INCLUDE MV45AO0C.
         INCLUDE MV45AO0D.
         INCLUDE MV45AO0F.
         INCLUDE MV45AO0G.
         INCLUDE MV45AO0I.
         INCLUDE MV45AO0K.
         INCLUDE MV45AO0M.
         INCLUDE MV45AO0P.
         INCLUDE MV45AO0R.
         INCLUDE MV45AO0S.
         INCLUDE MV45AO0T.
         INCLUDE MV45AO0V.
         INCLUDE MV45AO0W.
         INCLUDE MV45AO0X.
         INCLUDE MV45AO0Z.

ENHANCEMENT-POINT SAPMV45A_07 SPOTS ES_SAPMV45A STATIC.
*-----------------------------------------------------------------------
*        FORM-Routinen alphabetisch geordnet (extern aufgerufen)
*-----------------------------------------------------------------------
         INCLUDE MV45AF0B.
         INCLUDE MV45AF0K.
         INCLUDE MV45AF0T.
         INCLUDE MV45AF1T.
*-----------------------------------------------------------------------
*        FORM-Routinen alphabetisch geordnet
*-----------------------------------------------------------------------
         INCLUDE MV45AF0A.
         INCLUDE MV45AF0C.
         INCLUDE MV45AF0D.
         INCLUDE MV45AF0E.
         INCLUDE MV45AF0F.
         INCLUDE MV45AF0G.
         INCLUDE MV45AF0H.


ENHANCEMENT-POINT SAPMV45A_04 SPOTS ES_SAPMV45A STATIC.

         INCLUDE MV45AF0I.
         INCLUDE MV45AF0J.
         INCLUDE MV45AF0L.
         INCLUDE MV45AF0M.
         INCLUDE MV45AF0N.
         INCLUDE MV45AF0O.
         INCLUDE MV45AF0P.
         INCLUDE MV45AF0Q.
         INCLUDE MV45AF0R.
         INCLUDE MV45AF0S.
         INCLUDE MV45AF0U.
         INCLUDE MV45AF0V.
         INCLUDE MV45AF0W.
         INCLUDE MV45AF0X.
         INCLUDE MV45AF0Y.
         INCLUDE MV45AF0Z.

*-----------------------------------------------------------------------
*        FORM-Routinen für interne Tabellen
*-----------------------------------------------------------------------

         INCLUDE MV45AFFE.             " Feldauswahl
         INCLUDE MV45AFPA.
         INCLUDE MV45AFUV.             " Fehlerprotokoll

*-----------------------------------------------------------------------
*        Zeitpunkte für Listprocessing
*-----------------------------------------------------------------------

         INCLUDE MV45AFLI.

*-----------------------------------------------------------------------
*        Routinen der Nachrichtensteuerung
*-----------------------------------------------------------------------

         INCLUDE FV61BF00.

*-----------------------------------------------------------------------
*        Routinen der Statistik-Fortschreibung
*-----------------------------------------------------------------------

         INCLUDE MV45AFST.

*-----------------------------------------------------------------------
*        FORM-Routinen für Datenbankzugriffe
*-----------------------------------------------------------------------
         INCLUDE MV45AFDB.
*-----------------------------------------------------------------------
*        Tabellen-spezifische Module PAI
*-----------------------------------------------------------------------
         INCLUDE MV45AIAK.             "Auftragskopf
         INCLUDE MV45AIAP.             "Auftragspositionen
         INCLUDE MV45AIEP.             "Einteilungen
         INCLUDE MV45AISN.             "Änderungsstände
         INCLUDE MV45AILB.             "Abrufe
         INCLUDE MV45AIKO.             "Konditionen
*-----------------------------------------------------------------------
*        Textverarbeitung     Module PAI
*-----------------------------------------------------------------------
         INCLUDE MV45AITX.
*-----------------------------------------------------------------------
*        PAI - Module alphabetisch geordnet
*-----------------------------------------------------------------------
         INCLUDE MV45AI0A.
         INCLUDE MV45AI0B.
         INCLUDE MV45AI0C.
         INCLUDE MV45AI0D.
         INCLUDE MV45AI0E.
         INCLUDE MV45AI0F.
         INCLUDE MV45AI0G.
         INCLUDE MV45AI0H.
         INCLUDE MV45AI0I.
         INCLUDE MV45AI0K.
         INCLUDE MV45AI0L.
         INCLUDE MV45AI0M.
         INCLUDE MV45AI0O.
         INCLUDE MV45AI0P.
         INCLUDE MV45AI0R.
         INCLUDE MV45AI0S.
         INCLUDE MV45AI0T.
         INCLUDE MV45AI0U.
         INCLUDE MV45AI0V.
         INCLUDE MV45AI1V.
         INCLUDE MV45AI0W.
         INCLUDE MV45AI0X.
         INCLUDE MV45AI0Z.
         INCLUDE MV45AI_IS_ENHANCEMENT.  "PAI modules industry solutions

ENHANCEMENT-POINT SAPMV45A_08 SPOTS ES_SAPMV45A STATIC.
*-----------------------------------------------------------------------
* Process On Value-Request
*-----------------------------------------------------------------------

         INCLUDE MV45AV0V.

ENHANCEMENT-POINT SAPMV45A_09 SPOTS ES_SAPMV45A STATIC.
*-----------------------------------------------------------------------
*        FORM-Routinen für Anschluss an CO-ABC (extern aufgerufen)
*-----------------------------------------------------------------------
         INCLUDE MV45AF_ABC_FUNKTIONEN.

         INCLUDE MV45AO0P_PRIC_SUBSCR_SET_DATA.

         INCLUDE MV45AI0P_PRIC_SUBSCR_GET_DATA.

         INCLUDE MV45AI0P_PRICING_PASS_FCODE.

         INCLUDE MV45AI0P_PRICING_FETCH_FCODE.

         INCLUDE MV45A_DPBP_SUBSCR_SETO01.

         INCLUDE MV45A_DPBP_SUBSCR_SETF01.


*IS2ERP IS-OIL START
* Global parameter needed for SAPMV45A 8030
*  DATA venture_data  LIKE  roiu_jva_ep_venture.
*IS2ERP IS-OIL END

ENHANCEMENT-POINT SAPMV45A_10 SPOTS ES_SAPMV45A STATIC.
ENHANCEMENT-POINT SAPMV45A_05 SPOTS ES_SAPMV45A STATIC.

INCLUDE MV45AF0F_FCODE_DMC.

INCLUDE MV45AF0F_FCODE_DSD.
ENHANCEMENT-POINT SAPMV45A_06 SPOTS ES_SAPMV45A STATIC.

INCLUDE MV45AOLO.
INCLUDE MV45AILO.

*INCLUDE MV45A_OIL_ESOA_FOR_LORD.

*-----------------------------------------------------------------------
*        Advanced Returns related includes
*-----------------------------------------------------------------------
INCLUDE MV45A_MSRF01.
INCLUDE MV45A_MSRF02.
INCLUDE MV45A_MSRF03.
INCLUDE MV45A_MSRF04.
INCLUDE MV45A_MSRF05.
INCLUDE MV45A_MSRI01.
INCLUDE MV45A_MSRO01.
INCLUDE MV45A_MSRV01.

*-----------------------------------------------------------------------
*        Predefined Price Elements
*-----------------------------------------------------------------------
INCLUDE MV45AO_PPE.
INCLUDE MV45AI_PPE.

*-----------------------------------------------------------------------
*        Includes for customer full text search
*-----------------------------------------------------------------------
INCLUDE MV45AICS_HANDLER_CLASS.
INCLUDE MV45A_SEARCH_CUSTOMERI01.
INCLUDE MV45A_SEARCH_CUSTOMERF01.
INCLUDE MV45A_DISPLAY_ALVO01.
INCLUDE MV45A_DISPLAY_ALVF01.
INCLUDE MV45A_CUSTOMER_SEARCH_EXITI01.
INCLUDE MV45A_CUSTOMER_SEARCH_AUSBLO02.
INCLUDE MV45A_CUSTOMER_SEARCH_AUSBLF01.
INCLUDE MV45A_CS_SET_NEW_KUAGV_KUNNF01.

INCLUDE MV45A_VBKD_VTREF_PRUEFENI01.

INCLUDE MV45A_VBKD_VTREF_VALUESI01.

INCLUDE MV45A_ACTIVATE_SCREEN_BADI_F01.

INCLUDE MV45A_CUSTOMER_HEAD_SET_DATO01.

INCLUDE MV45A_CUSTOMER_HEAD_PASS_FCI01.

INCLUDE MV45A_CUSTOMER_HEAD_GET_DATI01.

*INCLUDE MV45A_F01.

INCLUDE MV45A_INTERNAL_HEAD_SET_DATO01.

INCLUDE MV45A_CUSTOMER_HEAD_SET_DATF01.

INCLUDE MV45A_CUSTOMER_ITEM_SET_DATO01.

INCLUDE MV45A_CUSTOMER_ITEM_SET_DATF01.

INCLUDE MV45A_CUSTOMER_ITEM_PASS_FCI01.

INCLUDE MV45A_CUSTOMER_ITEM_PASS_FCF01.

INCLUDE MV45A_CUSTOMER_ITEM_GET_DATI01.

INCLUDE MV45A_CUSTOMER_ITEM_GET_DATF01.

INCLUDE MV45A_INTERNAL_HEAD_PASS_FCI01.

INCLUDE MV45A_INTERNAL_HEAD_SET_DATF01.

INCLUDE MV45A_INTERNAL_HEAD_PASS_FCF01.

INCLUDE MV45A_INTERNAL_HEAD_GET_DATI01.

INCLUDE MV45A_INTERNAL_HEAD_GET_DATF01.

INCLUDE MV45A_INTERNAL_ITEM_SET_DATO01.

INCLUDE MV45A_INTERNAL_ITEM_SET_DATF01.

INCLUDE MV45A_INTERNAL_ITEM_PASS_FCI01.

INCLUDE MV45A_INTERNAL_ITEM_PASS_FCF01.

INCLUDE MV45A_INTERNAL_ITEM_GET_DATI01.

INCLUDE MV45A_INTERNAL_ITEM_GET_DATF01.

INCLUDE MV45A_MSRF06.

INCLUDE MV45A_MSRF07.

INCLUDE MV45A_MSRF08.

INCLUDE MV45A_MSRF09.

INCLUDE MV45A_MSRF10.

INCLUDE MV45A_MSRF11.

INCLUDE MV45A_MSRF12.

INCLUDE MV45A_MSRF13.

INCLUDE MV45A_MSRF14.

INCLUDE MV45A_MSRF15.

* Includes for TM-ERP status/docflow UI
INCLUDE MV45A_TM_HANDLER_CLASS.
INCLUDE MV45A_TMF01.
INCLUDE MV45A_TM_PBO_4798.