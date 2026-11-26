*-----------------------------------------------------------------------
*        COMMON DATA
*-----------------------------------------------------------------------
TABLES:  tbsl,                         " Buchungsschluessel
         t001w,                        " Werke/Niederlassungen
         t003,                         " Belegarten
         t003t,                        " Belegartentexte
         t030,                         " Fixkontentabelle
         t063,                         " Dynproauswahl Bestandsfuehrung
         t063c,                        " Call-Dynpro Codes Bestandsfueh
         t063f,                        " Funktionscodes Bestandsfuehrung
         t063o,                        " Ok-Codes
         t063t,                        " Transaktionen
         t134,                         " Materialart
         t134m,                        " Materialart/Bewertungskreis
         t148,                         " Sonderbestandsarten
         t156,                         " Bewegungsart
         t156b,                        " Bewegungsart Bildauswahl
         t156m,                        " Mengenstring
         t156n,                        " Nächste Bewegungsart
         t156t,                        " Bewegungsartentext
         t156v,                        " Verfügbarkeitstabelle
         t156x,                        " Vorgangsschluessel-Modifikation
         t157r,                        " Regel für Verfügbarkeitsanz.
         t157n,                        " Felder in Verfügbarkeitsanz.
         t157t,                        " Texte der Felder in Verfuegb.
         t158,                         " Transaktionen Bestandfuehrung
         t158i,                        " Transaktionen Inventur
         t159l,                        " Defaultwerte Bestandsführung
         t185,                         " Bildsteuerung Nachrichten
         t185f,                        "           "
         t185v,                        "           "
         t377,                         " Serialnummernpflicht ermitteln
         t064b,                        " Bestandsartentext Inventur
         tcurx,                        " Dezimalstellen der Währungen
         t460a.                        " Sonderbeschaffungsschlüssel

TABLES:  mkpf,                         " Belegkopf Material
         mseg,                         " Belegzeile Material
         dm07m,                        " Dialog-Tabelle
         vm07m,                        " Verbuchungstabelle
         rm07m,                        " E/A-Tabelle
         am07m,                        " Eingabedaten Bestandsführung
         ska1,                         " Sachkonten
         skb1,                         " Sachkonten-Firmenstamm
         dbefu,                        " Daten für neue Bestellung
         mbefu,                        " Material Bestandsfuehrungsview
         rbefu,                        " Reserv.  Bestandsfuehrungsview
         lgort,                        " Material Lagerortauswahlview
         smbew,                        " Material-Werte-Sperrtabelle
         smarc,                        " Sperrtabelle MARC
         smard,                        " Sperrtabelle MARD
         smcha,                        " Sperrtabelle MCHA
         smch1,                        " Sperrtabelle MCH1
         smchb,                        " Sperrtabelle MCHB
         smkol,                        " Sperrtabelle MKOL
         sekpo,                        " Sperrtabelle EKPO
         smres,                        " Sperrtabelle MRES
         tm07i,                        " Steuerungsdaten Inventur
         km07r,                        " Kopf Reservierung im Dialog
         vstat,                        " Verbräuche Materialstamm
         zcxcm,                        " Output SAPLMBGB
         mbew,                         " Materialbewertung
         chvw,                         " Struktur Chargenverwendungsn.
         knvv,                         " Kundenstamm (SD-Lieferung)
         tvsa,                         " Sammelgang  (SD-Lieferung)
* start insert note 159512
         tvta.                         " Vertr.bereiche (SD-Lieferung)
* end insert note 159512

TABLES:  matvp.                        " Materialdaten Verfügbakeit.

TABLES:  bkdf,                         " Belegkopf Dauerbuchung
         uf05a.                        " BSEG-Ergaenzung

TABLES:  b074.                         " Fehlteile: Konditionssätze

TABLES: ekbnk.

TABLES: meico, meprck, bqpim, bqpex,   "Orderbuch-Tabellen (Pipeline)
        eina, eine, meicr, mepro, mepri. "Pipeline-Infosatz

DATA:    BEGIN OF COMMON PART mm07mcom.

*-----------------------------------------------------------------------
*        Datenbanktabellen
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Datenfelder fuer die Programme SAPMM07*

*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*       Teil 3 :  Einzelfelder  ( variabel )
*       Teil 4 :  Konstanten
*       Teil 5 :  Ranges
*-----------------------------------------------------------------------

INCLUDE is01ad00.                      "RWIN-Interface

ENHANCEMENT-POINT MM07MCOM_05 SPOTS ES_MM07MCOM STATIC INCLUDE BOUND.
*eject
*-----------------------------------------------------------------------
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*-----------------------------------------------------------------------

* Items to be canceled with MB_CANCEL_GOODS_MOVEMENT             "406146
TYPES: ty_t_mblpo TYPE STANDARD TABLE OF mblpo.             "406146

TYPES: BEGIN OF ty_subcon_parent,                           "734758
         line_id        TYPE mb_line_id,                    "734758
         global_counter TYPE migo_global_counter,           "734758
         kzbew          TYPE kzbew,                         "734758
         serial_glc     TYPE serial_glc,                    "734758
       END OF ty_subcon_parent.                             "734758

TYPES: ty_t_mbuz TYPE STANDARD TABLE OF mbuz.               "734758

* test jkr
TYPES: BEGIN OF s_mtq,
         meins TYPE meins,
         menge TYPE menge,
       END OF s_mtq.
TYPES: t_mtq TYPE HASHED TABLE OF s_mtq
                  WITH UNIQUE KEY meins.

TYPES: BEGIN OF ty_s_autyp.                                 "755728_v
TYPES:   aufnr TYPE aufnr.
TYPES:   autyp TYPE auftyp.
TYPES: END OF ty_s_autyp.

DATA gt_order_type_buffer TYPE ty_s_autyp OCCURS 0.         "755728_^

*------- Sperrtabelle MARV
DATA: BEGIN OF xmarv OCCURS 8.
        INCLUDE STRUCTURE smarv.
DATA: END OF xmarv.

*------- Sperrtabelle MARC
DATA: BEGIN OF xmarc OCCURS 8.
        INCLUDE STRUCTURE smarc.
DATA: END OF xmarc.

*------- Sperrtabelle MSTB
DATA: BEGIN OF xmstb OCCURS 8.            "SIT
        INCLUDE STRUCTURE smstb.
DATA: END OF xmstb.

ENHANCEMENT-POINT MM07MCOM_01 SPOTS ES_MM07MCOM STATIC INCLUDE BOUND.
*------- Sperrtabelle MARD
DATA: BEGIN OF xmard OCCURS 8.
        INCLUDE STRUCTURE smard.
DATA: END OF xmard.

*------- Sperrtabelle MCHA
DATA: BEGIN OF xmcha OCCURS 8.
        INCLUDE STRUCTURE smcha.
DATA: END OF xmcha.

*------- Sperrtabelle MCH1
DATA: BEGIN OF xmch1 OCCURS 8.
        INCLUDE STRUCTURE smch1.
DATA: END OF xmch1.

*------- Sperrtabelle MCHB
DATA: BEGIN OF xmchb OCCURS 8.
        INCLUDE STRUCTURE smchb.
DATA: END OF xmchb.

*------- Sperrtabelle MKOL
DATA: BEGIN OF xmkol OCCURS 8.
        INCLUDE STRUCTURE smkol.
DATA: END OF xmkol.

*------- Sperrtabelle MSKU
DATA: BEGIN OF xmsku OCCURS 8.
        INCLUDE STRUCTURE smsku.
DATA: END OF xmsku.

*------- Sperrtabelle MSLB
DATA: BEGIN OF xmslb OCCURS 8.
        INCLUDE STRUCTURE smslb.
DATA: END OF xmslb.

*------- Sperrtabelle MSSL
DATA: BEGIN OF xmssl OCCURS 8.
        INCLUDE STRUCTURE smssl.
DATA: END OF xmssl.

*------- Sperrtabelle MSKA
DATA: BEGIN OF xmska OCCURS 8.
        INCLUDE STRUCTURE smska.
DATA: END OF xmska.

*------- Sperrtabelle MSTE
DATA: BEGIN OF xmste OCCURS 8.           "SIT
        INCLUDE STRUCTURE smste.
DATA: END OF xmste.

*------- Sperrtabelle MSSA
DATA: BEGIN OF xmssa OCCURS 8.
        INCLUDE STRUCTURE smssa.
DATA: END OF xmssa.

ENHANCEMENT-POINT MM07MCOM_03 SPOTS ES_MM07MCOM STATIC INCLUDE BOUND.
*------- Sperrtabelle MSPR
DATA: BEGIN OF xmspr OCCURS 8.
        INCLUDE STRUCTURE smspr.
DATA: END OF xmspr.

*------- Sperrtabelle MSTQ
DATA: BEGIN OF xmstq OCCURS 8.          "SIT
        INCLUDE STRUCTURE smstq.
DATA: END OF xmstq.

*------- Sperrtabelle MSSQ
DATA: BEGIN OF xmssq OCCURS 8.
        INCLUDE STRUCTURE smssq.
DATA: END OF xmssq.

*------- Sperrtabelle EKPO
DATA: BEGIN OF xekpo OCCURS 8.
        INCLUDE STRUCTURE sekpo.
DATA: END OF xekpo.

*------- Sperrtabelle EKPK
DATA: BEGIN OF xekpk OCCURS 8.
        INCLUDE STRUCTURE sekpk.
DATA: END OF xekpk.

*------- Sperrtabelle EKLA
DATA: BEGIN OF xekla OCCURS 8.
        INCLUDE STRUCTURE sekla.
DATA: END OF xekla.
DATA: BEGIN OF tekls OCCURS 8.                                "1356935
       INCLUDE STRUCTURE sekls.                               "1356935
DATA: END OF tekls.                                           "1356935
DATA: EBLGN TYPE MSEG-EBELN,                                  "1356935
      EBLGP TYPE MSEG-EBELP.                                  "1356935

* PPF Rel. 4.6
*------- Sperrtabelle ISEG
DATA: BEGIN OF xxiseg OCCURS 8.
        INCLUDE STRUCTURE siseg.
DATA: END OF xxiseg.

DATA: BEGIN OF xtiseg OCCURS 0.
        INCLUDE STRUCTURE siseg.
*DATA:   IBPOI LIKE VM07M-IBPOI.
*DATA:   XAEBL LIKE T159L-XAEBL.
DATA: END OF xtiseg.

* PPF Rel. 4.6

*------- Sperrtabelle FAUP
DATA: BEGIN OF xfaup OCCURS 8.
        INCLUDE STRUCTURE sfaup.
DATA: END OF xfaup.

*------- Sperrtabelle MRES
DATA: BEGIN OF xmres OCCURS 8.
        INCLUDE STRUCTURE smres.
DATA: END OF xmres.

*------- Hilfstabelle für XMRES wegen PERFORM ON COMMIT
DATA: BEGIN OF zmres OCCURS 8.
        INCLUDE STRUCTURE smres.
DATA: END OF zmres.

*------- Sperrtabelle MBEW
DATA: BEGIN OF xmbew OCCURS 50.
        INCLUDE STRUCTURE smbew.
DATA: END OF xmbew.

*------- Sperrtabelle EBEW
DATA: BEGIN OF xebew OCCURS 50.
        INCLUDE STRUCTURE sebew.
DATA: END OF xebew.

*------- Sperrtabelle QBEW
DATA: BEGIN OF xqbew OCCURS 50.
        INCLUDE STRUCTURE sqbew.
DATA: END OF xqbew.

*------- Sperrtabelle OBEW                                          "kaz
DATA: BEGIN OF xobew OCCURS 50.                                     "kaz
        INCLUDE STRUCTURE sobew.                                    "kaz
DATA: END OF xobew.                                                 "kaz

*------- Sperrtabelle EKWS
DATA: BEGIN OF xekws OCCURS 0.
        INCLUDE STRUCTURE sekws.
DATA: END OF xekws.

*------- Sperrtabelle EKBN
DATA: BEGIN OF xekbn OCCURS 0.
        INCLUDE STRUCTURE sekbn.
DATA: END OF xekbn.

*------- Sperrtabelle EKLB
DATA: BEGIN OF xeklb OCCURS 0.
        INCLUDE STRUCTURE seklb.
DATA: END OF xeklb.

*------- Sperrtabelle EKLS
DATA: BEGIN OF xekls OCCURS 0.
        INCLUDE STRUCTURE sekls.
DATA: END OF xekls.

*------- Sperrtabelle FAWS
DATA: BEGIN OF xfaws OCCURS 1.
        INCLUDE STRUCTURE sfaws.
DATA: END OF xfaws.
DATA: BEGIN OF xfawv OCCURS 0.
        INCLUDE STRUCTURE sfawv.
DATA: END OF xfawv.
DATA: BEGIN OF xfbefu OCCURS 1.
        INCLUDE STRUCTURE fbefu.
DATA: END OF xfbefu.

DATA: BEGIN OF yfbefu_cr OCCURS 3.
        INCLUDE STRUCTURE fbefu_cr.
DATA: END   OF yfbefu_cr.

DATA: BEGIN OF yfbefu_cr_key,
        ebeln  LIKE yfbefu_cr-aufnr,
        ebelp  LIKE yfbefu_cr-posnr,
        curtp  LIKE yfbefu_cr-curtp,
      END OF   yfbefu_cr_key.
*------- I-Beleg Zeilenzuordnung
DATA: BEGIN OF yibuz OCCURS 20,
        zeili LIKE mseg-zeile,
        zeile LIKE mseg-zeile,
      END OF yibuz.

*------- MAA DEV -------
* error F5 704 during posting goods receipt                 "n1391053
* enlarge the lines of the lock tables XEKWS_OLD and        "n1391053
* XEKBN_OLD with field LINE_ID                              "n1391053
*------- gemerkte Sperrtabelle EKWS  MAA-DEV
DATA : xekws_old             TYPE  maa_t_ekws.              "n1391053

*------- gemerkte Sperrtabelle EKBN  MAA-DEV
DATA: xekbn_old              TYPE  maa_t_ekbn.              "n1391053

* global table type definition for JFMIP - MAA-DEV
TYPES : stab_xekws_old       TYPE  maa_t_ekws.              "n1391053

* global table type definition for JFMIP - MAA-DEV
TYPES : stab_xekbn_old       TYPE  maa_t_ekbn.              "n1391053

DATA: xaccounting_srv    TYPE accounting OCCURS 0,    "MAA-DEV
      xaccounting_srv_cr TYPE accounting_cr OCCURS 0.
*------- MAA DEV -------

*------- Lagerortauswahl ---------------------------------------------*
DATA: BEGIN OF ylgort OCCURS 5.
DATA:   zeile LIKE mseg-zeile.
        INCLUDE STRUCTURE lgort.
DATA:   cuobj_ch LIKE bdcom-cuobj.
DATA:   kzech    TYPE kzech.
DATA:   umsok    LIKE mseg-umsok.
DATA: END OF ylgort.

*------- Materialbelegzeilen, die zu löschen sind --------------------*
DATA: BEGIN OF ymdel OCCURS 5,
        zeile LIKE mseg-zeile,
        yzeil LIKE mseg-zeile,
        zeilx LIKE mseg-zeile,
      END OF ymdel.

*------- Belegzeilen des Materialbeleges -----------------------------*
DATA: BEGIN OF ymseg OCCURS 5.
        INCLUDE STRUCTURE mseg.
DATA: END OF ymseg.

*------- Kontierungsfelder zur Belegzeile im Materialbeleg -----------*
DATA: BEGIN OF ymsegk OCCURS 3.
        INCLUDE STRUCTURE msegk.
DATA: END OF ymsegk.

*------- Belegzeilen zur Verbuchungssteuerung ------------------------*
DATA: BEGIN OF yvm07m OCCURS 5.
        INCLUDE STRUCTURE vm07m.
DATA: END OF yvm07m.

*------- Belegzeilen zur Dialogsteuerung -----------------------------*
DATA: BEGIN OF ydm07m OCCURS 5.
        INCLUDE STRUCTURE dm07m.
DATA: END OF ydm07m.

*------- Reservierungsdaten ------------------------------------------*
DATA: BEGIN OF xrbefu OCCURS 1.
        INCLUDE STRUCTURE rbefu.
DATA: END OF xrbefu.

*------- Daten für neue Bestellung -----------------------------------*
DATA: BEGIN OF xdbefu OCCURS 1.
        INCLUDE STRUCTURE dbefu.
DATA: END OF xdbefu.

*------- Daten für Lieferbelegfluß -----------------------------------*
DATA: BEGIN OF xvbfa OCCURS 1.
        INCLUDE STRUCTURE vbfa.
DATA: END OF xvbfa.
*------ Tabellen für Lohnbearbeitung ---------------------------------*
DATA: BEGIN OF omseg OCCURS 5.
        INCLUDE STRUCTURE mseg.
DATA: END OF omseg.

DATA: BEGIN OF ovm07m OCCURS 5.
        INCLUDE STRUCTURE vm07m.
DATA: END OF ovm07m.

DATA: BEGIN OF odm07m OCCURS 5.
        INCLUDE STRUCTURE dm07m.
DATA: END OF odm07m.

DATA: BEGIN OF gt_gocomp OCCURS 0.
        INCLUDE STRUCTURE gocomp.
DATA: shkzg LIKE mseg-shkzg.                                  "1356935
DATA: END OF gt_gocomp.

DATA: gt_subcon_parent TYPE TABLE OF ty_subcon_parent.      "734758

*------- Bezugsnebenkosten und Währungen -----------------------------*
DATA: BEGIN OF yekbnk OCCURS 0.
        INCLUDE STRUCTURE ekbnk.
DATA: END OF yekbnk.

DATA: BEGIN OF yekbnk_cr OCCURS 0.
        INCLUDE STRUCTURE ekbnk_cr.
DATA: END OF yekbnk_cr.

* global table type definition for JFMIP - MAA-DEV
TYPES : stab_yekbnk_cr       TYPE  STANDARD TABLE OF ekbnk_cr.

DATA: BEGIN OF yebefu_cr OCCURS 0.
        INCLUDE STRUCTURE ebefu_cr.
DATA: END OF yebefu_cr.

*------- Tabelle mit Bezugsnebenkosten für Dialog --------------------*
DATA: BEGIN OF xekbnk OCCURS 20.
        INCLUDE STRUCTURE ekbnk.
DATA: END OF xekbnk.

DATA: BEGIN OF xekbnk_kdm OCCURS 20.                        "N1027899
        INCLUDE STRUCTURE ekbnk_kdm.                        "N1027899
DATA: END OF xekbnk_kdm.                                    "N1027899

DATA: BEGIN OF yekbnk_kdm OCCURS 20.                        "N1520698
        INCLUDE STRUCTURE ekbnk_kdm.
DATA: END OF yekbnk_kdm.

DATA: BEGIN OF dekbnk OCCURS 0.
        INCLUDE STRUCTURE ekbnk.
DATA: zeile LIKE sy-tabix.
DATA: END OF dekbnk.

DATA: BEGIN OF d_ekbnk OCCURS 0.
        INCLUDE STRUCTURE ekbnk.
DATA: zeile LIKE sy-tabix.
DATA: END OF d_ekbnk.

DATA: BEGIN OF flindex OCCURS 10,
        stepl LIKE sy-stepl,
        zeile LIKE sy-tabix,
      END OF flindex.

DATA: BEGIN OF ekbe_sel OCCURS 0.
        INCLUDE STRUCTURE ekbel.
DATA: END OF ekbe_sel.

DATA: BEGIN OF i_ekbz OCCURS 20.
        INCLUDE STRUCTURE ekbz.
DATA: END OF i_ekbz.

*------ Frachlieferant, der in ENJOY-MMIM erfaßt wurde
DATA: BEGIN OF t_freight OCCURS 0.
        INCLUDE STRUCTURE gofreight.
DATA: END OF t_freight.

*------- Werteanhangtabelle.
DATA: BEGIN OF xekwv OCCURS 0.
        INCLUDE STRUCTURE sekwv.
DATA: END OF xekwv.

DATA: BEGIN OF xekbv OCCURS 0.
        INCLUDE STRUCTURE sekbv.
DATA: END OF xekbv.

*------- Tabelle der Positionen einer Umlagerungsbestellung   --------*
DATA: BEGIN OF xbbefu OCCURS 5.
        INCLUDE STRUCTURE bbefu.
DATA: END OF xbbefu.

*------- Tabelle der Positionen einer Lohnbearbeiterbestellung -------*
DATA: BEGIN OF xmdgi OCCURS 5.
        INCLUDE STRUCTURE mdgi.
DATA: END OF xmdgi.

*------- Gepufferte T156W                                     --------*
DATA: BEGIN OF x156w OCCURS 20.
        INCLUDE STRUCTURE t156w.
DATA: END OF x156w.

*------- Gepufferte T156M                                     --------*
DATA: BEGIN OF x156m OCCURS 2.
        INCLUDE STRUCTURE t156m.
DATA: END OF x156m.

*------- Gepufferte T156M                                     --------*
DATA: BEGIN OF x063t OCCURS 2.
        INCLUDE STRUCTURE t063t.
DATA: END OF x063t.

*------- Tabelle der bei Feldmodifikation zu prüfenden Felder --------*
DATA: BEGIN OF tab156k OCCURS 1,
        cnt02 LIKE t156k-cnt02,
        xfehl LIKE t156k-xfehl,
        fmode LIKE t156k-fmode,
        fmodl LIKE t156k-fmodl,
        fmodr LIKE t156k-fmodr,
      END OF tab156k.

*------- Tabelle Prefetch Materialstamm                       --------*
DATA: BEGIN OF prefetch01 OCCURS 20.
        INCLUDE STRUCTURE pre01.
DATA: END OF prefetch01.

DATA: BEGIN OF prefetch02 OCCURS 20.
        INCLUDE STRUCTURE pre02.
DATA: END OF prefetch02.

DATA: BEGIN OF prefetch03 OCCURS 20.
        INCLUDE STRUCTURE pre03.
DATA: END OF prefetch03.

DATA: BEGIN OF prefetch04 OCCURS 20.
        INCLUDE STRUCTURE pre04.
DATA: END OF prefetch04.

DATA: BEGIN OF prefetch11 OCCURS 20.                        " 213091
        INCLUDE STRUCTURE pre11.                            " 213091
DATA: END OF prefetch11.                                    " 213091

DATA: BEGIN OF prefetch21 OCCURS 20.
        INCLUDE STRUCTURE pre21.
DATA: END OF prefetch21.

DATA: BEGIN OF prefetch22 OCCURS 20.
        INCLUDE STRUCTURE pre22.
DATA: END OF prefetch22.

DATA: BEGIN OF prefetch29 OCCURS 20.                                "kaz
        INCLUDE STRUCTURE pre29.                                    "kaz
DATA: END OF prefetch29.                                            "kaz

DATA: BEGIN OF prefetch34 OCCURS 20.
        INCLUDE STRUCTURE pre34.
DATA: END OF prefetch34.

*------- Simulationstabelle für Verfügbarkeitsprüfung
DATA: BEGIN OF atpcsx OCCURS 1.
        INCLUDE STRUCTURE atpcs.
DATA: END OF atpcsx.

DATA: l_atpca LIKE atpca,
      l_atpcb LIKE atpcb,
      l_atpcc LIKE atpcc.

*------- Simulationstabelle für Verfügbarkeitsprüfung
DATA: BEGIN OF mdva OCCURS 1.
        INCLUDE STRUCTURE mdva.
DATA:   berid TYPE berid.                                   "454320
DATA: END OF mdva.

DATA: BEGIN OF rsnr OCCURS 1.
        INCLUDE STRUCTURE rsnr.
DATA: END OF rsnr.

*------- Simulationstabelle für Verfügbarkeitsprüfung
DATA: BEGIN OF mdvps OCCURS 1.
        INCLUDE STRUCTURE mdvs.
DATA: END OF mdvps.

*------- Table used to save the posguids            "start of    648152
*        which have been created during batch determination
*        -> needed e.g.in case of batch splits,to transfer
*           the posguids via atpcsx to the
*           APO ATP-check AVAILABILITY_CHECK_CONTROLLER
DATA: BEGIN OF e_atpcsx OCCURS 0.
        INCLUDE STRUCTURE atpcs.
DATA: END OF e_atpcsx.                              "end of note 648152

*------- Korrekturtabelle bei Verfügbarkeitsprüfung
DATA: BEGIN OF mdvpk OCCURS 20.
        INCLUDE STRUCTURE mdvp.
DATA: END OF mdvpk.

*------- Ergebnistabelle der Verfügbarkeitsprüfung
DATA: BEGIN OF mdver OCCURS 5.
        INCLUDE STRUCTURE mdve.
DATA: END OF mdver.

*------- Tabellen für Nachrichtensteuerung ----------------------------*
DATA: BEGIN OF xnast OCCURS 50.        " Tabelle der Nachrichten (akt.)
        INCLUDE STRUCTURE vnast.
DATA: END OF xnast.

DATA: BEGIN OF ynast OCCURS 50.        " Tabelle der Nachrichten (alt)
        INCLUDE STRUCTURE nast.
DATA: END OF ynast.

DATA: BEGIN OF nmseg.
        INCLUDE STRUCTURE mseg.
DATA: END OF nmseg.

DATA: BEGIN OF nmkpf.
        INCLUDE STRUCTURE mkpf.
DATA: END OF nmkpf.

DATA: BEGIN OF nvm07m.
        INCLUDE STRUCTURE vm07m.
DATA: END OF nvm07m.

*------  Tabelle der zustandsverwalteten Werke
DATA: BEGIN OF wrkzv OCCURS 10.
        INCLUDE STRUCTURE iwrkz.
DATA: END OF wrkzv.

*------  Hilfstab. fuer cross-docking; Pos. mit korrekten Zeilenindizes
DATA: BEGIN OF cd_mseg_eingemischt OCCURS 0.
        INCLUDE STRUCTURE mseg.
DATA: END OF cd_mseg_eingemischt.

*------  Hilfstabelle fuer Vollgutabwicklung
DATA: BEGIN OF vgmseg OCCURS 6,
        matnr    LIKE mseg-matnr,
        zeile    LIKE mseg-zeile,
        ebeln    LIKE mseg-ebeln,
        ebelp    LIKE mseg-ebelp,
        matbf    LIKE mseg-matbf,
        mengu    LIKE mseg-mengu,
        wertu    LIKE mseg-wertu,
        werks    LIKE mseg-werks,
        umwrk    LIKE mseg-umwrk,
        ummatbf  LIKE mseg-matbf,
      END OF vgmseg.

*------  Hilfstab. fuer value added services: Unterpositionen allgemein
DATA: BEGIN OF vas_mseg OCCURS 0.
        INCLUDE STRUCTURE rfrmmseg.
DATA: END OF vas_mseg.
*------ value added services: U.positionen, die in WE eingemischt sind
DATA: BEGIN OF vas_mseg_eingemischt OCCURS 0.
        INCLUDE STRUCTURE rfrmmseg.
DATA: END OF vas_mseg_eingemischt.
*------ value added services: Bestellentwicklung der Unterpositionen
DATA: BEGIN OF vas_ekbe OCCURS 0.
        INCLUDE STRUCTURE ekbe.
DATA: END OF vas_ekbe.

*---------------------------------------------------------------------*
*        Ausgabetabelle                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF xzcxcm OCCURS 10.
        INCLUDE STRUCTURE zcxcm.
DATA: END   OF xzcxcm.

DATA: BEGIN OF xzcxcb OCCURS 0.
        INCLUDE STRUCTURE zcxcb.
DATA: END   OF xzcxcb.

DATA: BEGIN OF zekbe_cr OCCURS 0.
        INCLUDE STRUCTURE cki_ekbecr.
DATA: END OF zekbe_cr.

DATA: BEGIN OF xstru OCCURS 0.
        INCLUDE STRUCTURE wsos_stuli.
DATA: END OF xstru.

*---------------------------------------------------------------------*
*        Tabellen für Fehlteile                                       *
*---------------------------------------------------------------------*
DATA: BEGIN OF xtfmat OCCURS 20,       " Fehlteilmaterialien alle Pos.
        werks LIKE mseg-werks,
        matnr LIKE mseg-matnr,
        maktx LIKE dm07m-maktx,
        detail LIKE vm07m-xfmat,
        duser LIKE vm07m-duser,
      END OF xtfmat.

DATA: BEGIN OF ytfmat OCCURS 20,       " Fehlteilmaterialien pro Werk
        werks LIKE mseg-werks,
        matnr LIKE mseg-matnr,
        maktx LIKE dm07m-maktx,
        detail LIKE vm07m-xfmat,
        duser LIKE vm07m-duser,
      END OF ytfmat.

DATA: BEGIN OF xtfehl OCCURS 10.       " Fehlteilsätze (Belege) pro MSEG
        INCLUDE STRUCTURE atpsl.
DATA: END   OF xtfehl.

DATA: BEGIN OF ytfehl OCCURS 50,     " Fehlteilsätze (Belege) alle Pos.
        werks LIKE mseg-werks,
        matnr LIKE mseg-matnr.
        INCLUDE STRUCTURE mdfw.
DATA: END OF ytfehl.

DATA: BEGIN OF xisseq OCCURS 4.     " Entnahmereihenfolge Konsi/Pipeline
        INCLUDE STRUCTURE isseq.
DATA: END   OF xisseq.

*---- Originaltabellen für Chargen
DATA: BEGIN OF omcha OCCURS 0.
        INCLUDE STRUCTURE mcha.
DATA: END OF omcha.

DATA: BEGIN OF omch1 OCCURS 0.
        INCLUDE STRUCTURE mch1.
DATA: END OF omch1.

*---- Tabellen zum Anlegen einer Lieferung + x_lips SIT 601T 1660570
DATA: x_komdlgn LIKE komdlgn OCCURS 0 WITH HEADER LINE,
      x_vbsk    LIKE vbsk    OCCURS 0 WITH HEADER LINE,
      e_vbsk    LIKE vbsk    OCCURS 0 WITH HEADER LINE,
      x_vbfs    LIKE vbfs    OCCURS 0 WITH HEADER LINE,
      x_vbls    LIKE vbls    OCCURS 0 WITH HEADER LINE,
      x_lips    LIKE lips    OCCURS 0 WITH HEADER LINE.
*eject
*-----------------------------------------------------------------------
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*-----------------------------------------------------------------------

*------- Bewegungsart über Action Bar
DATA: BEGIN OF bcode,
        bwart LIKE t156-bwart,
        sobkz LIKE t156b-sobkz.
DATA: END OF bcode.

*------- Arbeitsfelder zur FCODE-Steuerung
DATA: BEGIN OF fcausw.
        INCLUDE STRUCTURE t063f.
DATA: END OF fcausw.

DATA: BEGIN OF old_fcausw.
        INCLUDE STRUCTURE t063f.
DATA: END OF old_fcausw.

*----------------- Key für NAST ---------------------------------------*
DATA: BEGIN OF nast_key,
        mblnr LIKE mkpf-mblnr,
        mjahr LIKE mkpf-mjahr,
        zeile LIKE mseg-zeile,
      END OF nast_key.

DATA: BEGIN OF nast_key_to,
        mblnr LIKE mkpf-mblnr,
        mjahr LIKE mkpf-mjahr,
        zeile LIKE mseg-zeile,
      END OF nast_key_to.

DATA: BEGIN OF new_nast_key,
        mblnr LIKE mkpf-mblnr,
        mjahr LIKE mkpf-mjahr,
        zeile LIKE mseg-zeile,
      END OF new_nast_key.

DATA: msg_objky_new LIKE nast-objky.

*------- structure to keep relevant information from MKPF in MB_CANCEL
DATA: BEGIN OF gs_mkpf_keep,                                " 573578
        vgart TYPE mkpf-vgart,                              " 573578
        blart TYPE mkpf-blart,                              " 573578
        blaum TYPE mkpf-blaum,                              " 573578
        bla2d TYPE mkpf-bla2d,                              " 573578
      END OF gs_mkpf_keep.                                  " 573578

*------- Arbeitsfelder für TCODE-Aufruf
DATA: BEGIN OF paramid,
        belnr LIKE bkpf-belnr,
        gjahr LIKE mseg-gjahr,
        bukrs LIKE mseg-bukrs,
        zeile LIKE mseg-zeile,
        ebeln LIKE mseg-ebeln,
        ebelp LIKE mseg-ebelp,
        lifnr LIKE mseg-lifnr,
        ekorg LIKE vm07m-ekorg,
        matnr LIKE mseg-matnr,
        werks LIKE mseg-werks,
        lgort LIKE mseg-lgort,
        charg LIKE mseg-charg,
      END OF paramid.

*---- Struktur für Umlagerungstexte
DATA: BEGIN OF utext,
        matnr(1) TYPE c,
        werks(1) TYPE c,
        lgort(1) TYPE c,
        charg(1) TYPE c,
      END OF utext.

*---- Struktur für Pipeline-Orderbuch
DATA: BEGIN OF ord OCCURS 10.
        INCLUDE STRUCTURE eord.
DATA: END OF ord.

*---- Kommunikationsstruktur für Chargenfindung
DATA: xbdcom LIKE bdcom.
DATA: xbncom LIKE bncom.

*---- Kommunikationsstruktur für Bestandsfindung
DATA: xbfcom LIKE bfcom.

*---- Kommunikationsstruktur für DELTA-Management
DATA: e_atpdi LIKE atpdi.

*---- Struktur für Verbuchungssteuerung Bewegungsarten
DATA: s156s LIKE st156s.
*eject
*-----------------------------------------------------------------------
*       Teil 3 :  Einzelfelder
*-----------------------------------------------------------------------

DATA:    aktyp      LIKE t063-aktyp,   " Aktivitaetstyp
         actvt      LIKE tact-actvt,   " Aktivitaet
         auth04     TYPE c,            " Berechtigung 04
         auth04_wrk LIKE mseg-werks,   " Keine Druckber für WERKS
         auth04_bwa LIKE mseg-bwart,   " Keine Druckber für BWART
         bwart_res  LIKE mseg-bwart,   " Reserv. der BwA
         vgart      LIKE t158-vgart,   " Vorgangsart
         vgart_old  LIKE t158-vgart,   " alte Vorgangsart
         tcode      LIKE t063-fcode,   " TK-Code Rett.Feld
         ccode      LIKE t063-fcode,   " Call-Dynpro-Code
         ccode_next LIKE t063-fcode,   " Call-Dynpro-Code
         ecode      LIKE t063-fcode,   " Exit-Code
         fcode      LIKE t063-fcode,   " Funktionscode
         fcode_next LIKE t063-fcode,   " naechster Funktionscode
         pcode      LIKE t063-fcode,   " Blaettercode
         pcode_next LIKE t063-fcode.   " naechster Blaettercode

DATA:    max_zeile  LIKE mseg-zeile VALUE 999, "max. Zeilen pro Beleg
         max_anzpo  LIKE mseg-zeile.   "max. Zeilen pro Seite

DATA:    a_zeile    LIKE mseg-zeile,   "aktuelle Buchungszeile
         b_zeile    LIKE mseg-zeile,   "ab dieser Zeile
         f_zeile    LIKE mseg-zeile,   "maximale FUSS-ZEILE
         l_zeile    LIKE mseg-zeile,   "letzte Buchungszeile
         m_zeile    LIKE mseg-zeile,   "maximale Buchungszeile
         o_zeile    LIKE mseg-zeile,   "LB-Nachbelastungszeilen
         s_zeile    LIKE mseg-zeile,   "Zeile sofort zu bearbeiten
         y_zeile    LIKE mseg-zeile.   "maximale YFUSS-ZEILE

DATA:    anf_bild    TYPE c VALUE ' ', "Anforderungsbild
         anzpos(6)   TYPE c,           "Dynpro mit Anzahl Step-Loop-Z.
         bwart_sl    TYPE c VALUE ' ', "BewArt selektiert in PopUp
         dialog      TYPE c VALUE 'X', "im Dialog buchen
         dyn_24xx    TYPE c VALUE ' ', "Dynpro 2421 / 2422
         int_xlisu   TYPE c VALUE 'X', "Aufruf Auftragsstatistik
         joint_venture,                "Joint Venture
         exponent    TYPE i,           "Exponent für Umrechnung
         hell        TYPE c VALUE 'X', "Dynproablauf hell
         gv_badi_scr TYPE xfeld,       "Screen BAdI durchlaufen
         matrix      TYPE c,           "Aufruf Variantenmatrix
         vareac      TYPE c,           "Aufruf Neue Varianten    " PPF
         neue_pos    TYPE c,           "Kennzeichen neue Position
         pr_uname    LIKE sy-uname,    "Username für Drucksteuerung
         pr_print    LIKE imkpf-pr_print, "Drucken aus MB_CREATE
         slash       TYPE c,           "Schräger für Pos. im Titel
         xauthority  TYPE c VALUE ' ', "Keine Berechtigungspr. bei MBWL
         xback       TYPE c VALUE ' ', "F3 gedrückt
         xbprm       TYPE c VALUE ' ', "BPMNG manuell eingegeben
         xconfirm    TYPE c VALUE ' ', "Kontrollabfrage erforderlich
         xfuss       TYPE c VALUE ' ',
         xfull       TYPE c VALUE ' ', "FullScreen des Kontierungsblocks
         xkzbew      TYPE c VALUE ' ', "WA-Pos. im WE-Beleg manuell erf.
         xnebe       TYPE c VALUE ' ', "Pos. mit Best. anlegen enthalten
         xmate       TYPE c VALUE ' ', "mind. eine gefüllte Zeile
         xlaus       TYPE c VALUE ' ', "Lagerortauswahl
         xumla       TYPE c VALUE ' ', "Lgort+Werk für Umlagerung lesen
         xumtx       TYPE c VALUE ' '. "Kennzeichen für Umlagerungstext

* globale Steuerung

DATA:    f_lagerort_pruefen_trtyp LIKE t158-trtyp.          "162405
DATA:    abbruch    TYPE c VALUE ' '.

DATA:    xcanc       TYPE c VALUE ' ', "Aufruf über MB_CANCEL
         xmbwl       TYPE c VALUE ' ', "Aufruf über MB_CREATE
         xlock_allp  TYPE c VALUE ' ', "Array-Lock
         xbapi       TYPE c VALUE ' ', "Aufruf über BAPI
         xsimu       TYPE c VALUE ' ', "Aufruf über MB_SIMULATE
         xsimu_values TYPE c VALUE ' ', "MB_SIMULATE with values
         xmigo       TYPE c VALUE ' ', "Aufruf über MIGO
         im_process  LIKE sy-tcode,    "type of IM-process: L=delivery
         read_for_cancel TYPE c VALUE ' '. " called by mb_cancel before
" mb_create      "note357305

DATA:    save_mblnr  LIKE mkpf-mblnr,  "MBLNR-Merker bei mehrmaligen
                                       "MB_CREATE.. Aufruf
         save_xabln  LIKE mkpf-xabln.  "XABLN-Merker bei mehrmaligen
"MB_CREATE.. Aufruf
DATA:    status(1).                                         "510574

DATA:    call_fcode  LIKE t063f-fcode, "Fcode beim Aufruf
         t_index     LIKE sy-index,    "Index
         cattaktiv   TYPE c.           "Kennzeichen CATT aktiv

DATA:    rw_vorgang  LIKE bkpf-glvor.  "Vorgang für Rechnungswesen
DATA:    upd_um03b   TYPE c.           "Fortschreiben Werte im MatStamm

DATA:    qss_aufruf  TYPE c.           "Aufruf über USAGE_DECISION

DATA:    fwdif   LIKE bseg-dmbtr,      "Fremdwährungsdifferenz
         shfwdif LIKE bseg-shkzg.      "SHKZG Fremdwährungdifferenz

DATA:    upd_nast TYPE c,              "Updateflag Nachrichten
         print_uname LIKE sy-uname.    "Benutzername für den Druck

DATA     x_mulko TYPE c.               "Multikontierung in Bestellung

DATA     upd_seri TYPE c.              "Updateflag Serialnummer


DATA:    b074_ok  TYPE c,              "Fehlteile: Konditionssatz vorh.
         brazil TYPE c,                "Brasilienabwicklung
         xt437e_check TYPE c.          "Entnahmeprio aus T437E pruefen

DATA:    barcode TYPE saebarcode.      "Feld zur Barcode Eingabe

DATA:    g_debug TYPE c.    " debug authorization, for assertions (perf)

*------- Felder bei WE zum Lieferavis
DATA:    bolnr LIKE likp-bolnr,
         verur LIKE likp-verur,
         multi_frbnr TYPE c,
         multi_xblnr TYPE c,
         auto_frbnr  TYPE c,
         auto_xblnr  TYPE c.

** C5024641 VL-MM Konsistenz 10.01.2000
DATA:
  g_vbtyp_v LIKE vbfa-vbtyp_v,
  gt_lips TYPE lipsvb OCCURS 10 WITH HEADER LINE,
  gt_likp TYPE likpvb OCCURS 0 WITH HEADER LINE.
* Take over serial numbers from IM into delivery for dec. WMS
* GLOBAL DEFINITIONS:
  TYPES: BEGIN OF S_SERNR,                         "n1031590
           RFBEL LIKE KOMDLGN-RFBEL,
           RFPOS LIKE KOMDLGN-RFPOS,
           VBELN LIKE LIPS-VBELN,
           POSNR LIKE LIPS-POSNR,
           SERNR TYPE GERNR,
           UII   TYPE UII_CHAR72,           "EHP603 IUID
         END  OF S_SERNR.
  DATA: T_SERNR TYPE TABLE OF S_SERNR.             "n1031590

DATA:    h_liefk LIKE rm07m-vlief.                         "note 136483

DATA:    usnam LIKE sy-uname,          "User für NAST aus LMBWL
         xdeliv LIKE rm07m-xdeliv,     "Lieferung über SD
         upd_fralief(1) TYPE c,      "Frachtlief. nicht unterstützt "HUM
                                     "bei autom.lieferung anlegen   "HUM
         upd_anlief(1)  TYPE c.      "zu einer Anlieferung wird erneut
"eine Anlieferung erzeugt.     "HUM

*----- Trennung der Wertbildung Steuerungsparameter
DATA:   mbval LIKE tcurm-mbval,
        xwert LIKE tcurm-mbval,
        xower LIKE tcurm-mbval,
        xmseg_lines TYPE i,
        sperrversuche_mat TYPE i,
        wait_mat TYPE f,
        mw_cpudt LIKE mkpf-cpudt,
        mw_cputm LIKE mkpf-cputm.
ENHANCEMENT-POINT MM07MCOM_06 SPOTS ES_MM07MCOM STATIC INCLUDE BOUND.



*------- Steuerung Prefetch Materialstamm
DATA:    maktx       LIKE makt-maktx.

*------- LVS Daten
DATA: lvs_tafkz  LIKE t321-tafkz.      " TA-Fortschreibung

ENHANCEMENT-POINT MM07MCOM_02 SPOTS ES_MM07MCOM STATIC INCLUDE BOUND.
ENHANCEMENT-POINT MM07MCOM_04 SPOTS ES_MM07MCOM STATIC INCLUDE BOUND.

*------- work fields
DATA:    cuobj_refdoc LIKE dm07m-cuobj_refdoc,              "630576
         bdart LIKE dm07m-bdart.                            "1101922

*------- OM Switch active - EhP 604
DATA: gv_mm_om1_sfws_sc_active type xfeld.

*----------------------------------------------------------------------*
*   Hilfsfelder für Chargensteuerung                                   *
*----------------------------------------------------------------------*
*   KZDCH : Definitionsebene Charge 0->MCHA 1->MCH1 2->MCH2
*   KZDWS : Anteils-/variable Mengenumr. auf Charge 0->inaktiv 1->aktiv
*   KZDZV : Zustandsverwaltung 0->inaktiv 1->aktiv
*   AUTBN : Automatische Chargennummernveragebe 0->inaktiv 1->aktiv
DATA: kzdch           LIKE tcuch-kzdch,
      kzdws           LIKE tcuws-kzdws,
      kzdzv           LIKE tcuch-kzdzv,
      autbn           LIKE tcuch-autbn,
      last_auto_batch LIKE mcha-charg,
      autbn_dialog    LIKE am07m-xselk,
*     documentary batch active in system? only used for MIGO
      g_docubatch_active TYPE docubatch_active.

DATA: gv_wipbatch_active TYPE wipbatch_active.

*----------------------------------------------------------------------*
*    Hilfsfelder u. -strukturen für Serialnummernvergabe               *
*----------------------------------------------------------------------*
DATA: op_mmsl LIKE t377x-beleg VALUE 'MMSL',
      op_mmup LIKE t377x-beleg VALUE 'MMUP',
      op_mmdl LIKE t377x-beleg VALUE 'MMDL',
      op_mmrn LIKE t377x-beleg VALUE 'MMRN',
      op_mmcc LIKE t377x-beleg VALUE 'MMCC',
      op_mmmc LIKE t377x-beleg VALUE 'MMMC',
      op_mmc1 LIKE t377x-beleg VALUE 'MMC1',                      "SIT
      op_sdc3 LIKE t377x-beleg VALUE 'SDC3',
      op_sdc6 LIKE t377x-beleg VALUE 'SDC6',
      op_ppc2 LIKE t377x-beleg VALUE 'PPC2',
      op_ppsf LIKE t377x-beleg VALUE 'PPSF',
      xanzsn LIKE risa0-anzahl,
      imenge LIKE mseg-menge,
      operation LIKE t377x-beleg,
      index_bustm LIKE sy-tabix,
      smblnr LIKE mkpf-mblnr,
      strtyp LIKE t158-trtyp,
      dmblnr LIKE mkpf-mblnr  VALUE '$'.

DATA: BEGIN OF bstch.
        INCLUDE STRUCTURE bsinf.
DATA: END OF bstch.

DATA: BEGIN OF bstup.
        INCLUDE STRUCTURE bsinf.
DATA: END OF bstup.

DATA: BEGIN OF y156m OCCURS 0050.
        INCLUDE STRUCTURE t156m.
DATA: END OF y156m.

DATA: BEGIN OF i_t377.
        INCLUDE STRUCTURE t377.
DATA: END OF i_t377.

CONSTANTS: bwart_340 LIKE   t156-bwart VALUE '340',
           bwart_341 LIKE   t156-bwart VALUE '341',
           bwart_342 LIKE   t156-bwart VALUE '342',
           bwart_351 LIKE   t156-bwart VALUE '351',         "P45K052066
           bwart_641 LIKE   t156-bwart VALUE '641',         "P45K052066
           bwart_643 LIKE   t156-bwart VALUE '643',         "P45K052066
           bwart_647 LIKE   t156-bwart VALUE '647',         "162335
           bwart_141 LIKE   t156-bwart VALUE '141',
           bwart_142 LIKE   t156-bwart VALUE '142',
           bwart_541 LIKE   t156-bwart VALUE '541',         " OM EhP 604
           bustr_30a LIKE   t156-bustr VALUE '30A',         " OM EhP 604
           bustr_30c LIKE   t156-bustr VALUE '30C',         " OM EhP 604
           bustr_63A LIKE   t156-bustr VALUE '63A',         " OM EhP 604
           bustr_63c LIKE   t156-bustr VALUE '63C',         " OM EhP 604
           bustr_64a LIKE   t156-bustr VALUE '64A',         " OM EhP 604
           bustr_107 LIKE   t156-bustr VALUE '107',         " MAA-DEV
           bustr_109 LIKE   t156-bustr VALUE '109',         " MAA-DEV
           bustr_101 like   t156-bustr value '101',         "MAA2
           bustr_105 like   t156-bustr value '105',         "MAA2
           bustr_141 like   t156-bustr value '141',         "MAA2
           bustr_161 like   t156-bustr value '161',         "MAA2
           c_kzbew_b type   kzbew      value 'B'.           "MAA2

*----------------------------------------------------------------------*
*          Hilfsfelder für XAB-Nummernvergabe                          *
*          sonstige laenderspezifische Nummern                         *
*----------------------------------------------------------------------*
DATA: xnumke LIKE t159z-numke,
      xnumki LIKE t159z-numki,
      flag1  LIKE inri-returncode,  "Hilfsfeld bei Nummernvergabe extern
      pre_werks LIKE t001w-werks,
      pre_kzxab LIKE t159l-kzxab.

DATA: BEGIN OF e_fin1_param.
        INCLUDE STRUCTURE fin1_param.
DATA: END OF e_fin1_param.
*eject

* begin note 63537 - Fashion
DATA: g_init_done    TYPE xfeld VALUE ' '.
DATA: g_badi         TYPE REF TO if_ex_mb_me_csgmt_badi_sap.
DATA: g_badi_active  TYPE xfeld.
* end note 63537 - Fashion

DATA: g_save_measure TYPE fm_measure.   "Note 1513119
*-----------------------------------------------------------------------
*       Teil 4 :  Konstanten
*-----------------------------------------------------------------------

CONSTANTS: rs_bdart LIKE resb-bdart  VALUE 'MR',
           ar_bdart LIKE resb-bdart  VALUE 'AR',
           mb_bdart LIKE resb-bdart  VALUE 'MB',
           vgart_wa LIKE t158-vgart  VALUE 'WA',
           vgart_we LIKE t158-vgart  VALUE 'WE',
           vgart_wf LIKE t158-vgart  VALUE 'WF',
           vgart_wi LIKE t158-vgart  VALUE 'WI',
           vgart_wl LIKE t158-vgart  VALUE 'WL',
           vgart_wo LIKE t158-vgart  VALUE 'WO',
           vgart_wq LIKE t158-vgart  VALUE 'WQ',
           vgart_wr LIKE t158-vgart  VALUE 'WR',
           vgart_ws LIKE t158-vgart  VALUE 'WS',
           vgart_wz LIKE t158-vgart  VALUE 'WZ',
           vgart_xa LIKE t158-vgart  VALUE 'XA',
           vgart_rm LIKE t158-vgart  VALUE 'RM',
           vgart_wh LIKE t158-vgart  VALUE 'WH'.                    "HUM
CONSTANTS: sa_autyp LIKE cobl-autyp VALUE '05'.
*------- Callcodes
CONSTANTS: BEGIN OF ccod,
            arch(4) TYPE c VALUE 'ARCH',        "Optisch archiv. Beleg
            arzu(4) TYPE c VALUE 'ARZU',        "ZUordnen Optisch. Beleg
            clas(4) TYPE c VALUE 'CLAS',        "Klassifizierung
            datu(4) TYPE c VALUE 'DATU',        "Datum bei Reservierung
            fb03(4) TYPE c VALUE 'FB03',        "Buchhaltungsbeleg
            konb(4) TYPE c VALUE 'KONB',        "Kontierung Bestellpos.
            kont(4) TYPE c VALUE 'KONT',        "Kontierung bei Reserv.
            lvs0(4) TYPE c VALUE 'LVS0',        "LVS-Parameter
*##ngr-saanf
            matr(4) TYPE c VALUE 'MATR',        "Variantenmatrix
*##ngr-saend
            reac(4) TYPE c VALUE 'REAC',        "Neue Varianten    " PPF
            vku3(4) TYPE c VALUE 'VKU3',        "Anzeige VK-Beleg  " PPF
*14884 SW begin
            mgum(4) TYPE c VALUE 'MGUM',        "Alt.-Mengenumrechnung
*14884 SW end
            nach(4) TYPE c VALUE 'NACH',        "Nachrichtenpflege
            nebe(4) TYPE c VALUE 'NEBE',        "Neue Positionen WE
            nser(4) TYPE c VALUE 'NSER',        "Serialnummernpflege
            nfbl(4) TYPE c VALUE 'NFBL',        "Bestellung...
            nfbs(4) TYPE c VALUE 'NFBS',        "Stornieren Bestellung..
            nfbu(4) TYPE c VALUE 'NFBU',        "Warenausgang...
            nfnl(4) TYPE c VALUE 'NFNL',        "Vorschlagswerte
            nfml(4) TYPE c VALUE 'NFML',        "Materialbeleg...
            nfms(4) TYPE c VALUE 'NFMS',        "Stornieren Materialblg
            nfsl(4) TYPE c VALUE 'NFSL',        "WA zur Stückliste...
            nful(4) TYPE c VALUE 'NFUL',        "Bestellung... WA-UB
            pack(4) TYPE c VALUE 'PACK',        "Versandelemente
            qins(4) TYPE c VALUE 'QINS',        "Prüflos anzeigen
            rsnl(4) TYPE c VALUE 'RSNL',        "Vorschlagswerte Res.
            rsst(4) TYPE c VALUE 'RSST',        "Vorschlagswerte Stüli.
            verf(4) TYPE c VALUE 'VERF',        "Verfuegbarkeit
            vers(4) TYPE c VALUE 'VERS',        "Verfuegbarkeit
            vl03(4) TYPE c VALUE 'VL03',        "Lieferung
            wmbe(4) TYPE c VALUE 'WMBE',        " Bestandsü. Wertartikel
            mmbe(4) TYPE c VALUE 'MMBE',        " Bestandsü. Lagermat.
           END OF ccod.

*------- Funktionscodes
CONSTANTS: BEGIN OF fcod,
           ab(20) TYPE c VALUE 'AB  ', "Übersicht
          aba(20) TYPE c VALUE 'ABA ', "Positionieren...
         abbr(20) TYPE c VALUE 'ABBR', "Abbrechen Pop-Up
           ah(20) TYPE c VALUE 'AH  ', "Inventurhistorie
           ak(20) TYPE c VALUE 'AK  ', "Kopf anzeigen
           ap(20) TYPE c VALUE 'AP  ', "Position anzeigen
           bu(20) TYPE c VALUE 'BU  ', "Buchen
         ccwe(20) TYPE c VALUE 'CCWE', "CC-WE-Position
         ccws(20) TYPE c VALUE 'CCWS', "CC-WE-Position Storno
     ccwe_sit(20) TYPE c VALUE 'CCWE_SIT', "CC-SIT-WE-Position             "SIT
     ccws_sit(20) TYPE c VALUE 'CCWS_SIT', "CC-SIT-WE-Position Storno      "SIT
           dl(20) TYPE c VALUE 'DL  ', "Inventurbeleg löschen
           dp(20) TYPE c VALUE 'DP  ', "InvPosition löschen
           en(20) TYPE c VALUE 'EN  ', "Ende der Transaktion
         ent2(20) TYPE c VALUE 'ENT2', "Verl. Pop-Up + weiter
           kl(20) TYPE c VALUE 'KL  ', "Sammelbearbeitung
          kla(20) TYPE c VALUE 'KLA ', "Positionieren...
           kk(20) TYPE c VALUE 'KK  ', "Kopf ändern
           kp(20) TYPE c VALUE 'KP  ', "Position ändern
         lbmb(20) TYPE c VALUE 'LBMB', "LB-Materialbelastung
         lbna(20) TYPE c VALUE 'LBNA', "LB-WA-Position negativ
         lbns(20) TYPE c VALUE 'LBNS', "LB-WA-Position neg Stor
         lbwa(20) TYPE c VALUE 'LBWA', "LB-WA-Position
         lbws(20) TYPE c VALUE 'LBWS', "LB-WA-Position Storno
         matr(20) TYPE c VALUE 'MATR', "Variantenmatrix
         reac(20) TYPE c VALUE 'REAC', "Neue Varianten   " PPF
         vku3(20) TYPE c VALUE 'VKU3', "Anzeige VK-Beleg " PPF
         msth(20) TYPE c VALUE 'MSTH', "MatStruktur zerlegen
         msts(20) TYPE c VALUE 'MSTS', "MatStruktur zusfügen
         mssh(20) TYPE c VALUE 'MSSH', "MatStruktur zerlegen ST
         msss(20) TYPE c VALUE 'MSSS', "MatStruktur zusfügen ST
           nb(20) TYPE c VALUE 'NB  ', "Nächster Beleg
           ng(20) TYPE c VALUE 'NG  ', "Bestellung automatisch
           nl(20) TYPE c VALUE 'NL  ', "Neuer Liste
           nu(20) TYPE c VALUE 'NU  ', "Nullzählung setzen
           np(20) TYPE c VALUE 'NP  ', "Neue Position
           rl(20) TYPE c VALUE 'RL  ', "Rücklieferung
           sa(20) TYPE c VALUE 'SA  ', "Statistikdaten Inventur
         sekl(20) TYPE c VALUE 'SEKL', "Übernehmen auf Auswahl
           sf(20) TYPE c VALUE 'SF  ', "Sperrbestand freigeben
           sl(20) TYPE c VALUE 'SL  ', "Auswahlbild
          sla(20) TYPE c VALUE 'SLA ', "Selektieren ab
         slnv(20) TYPE c VALUE 'SLNV', "Selektieren Nachverrech
           sn(20) TYPE c VALUE 'SN  ', "Nachlieferung
           st(20) TYPE c VALUE 'ST  ', "Selektion Liste Storno
           su(20) TYPE c VALUE 'SU  ', "Selektion Liste Umbuch.
           sp(20) TYPE c VALUE 'SP  ', "Übernehmen+Detail
           ss(20) TYPE c VALUE 'SS  ', "Übernehmen+Detail
          ssf(20) TYPE c VALUE 'SSF ', "Übernehmen+Detail
          ssr(20) TYPE c VALUE 'SSR ', "Übernehmen+Detail
          suu(20) TYPE c VALUE 'SUU ', "Übernehmen+Detail
         umwe(20) TYPE c VALUE 'UMWE', "UB-WE-Position
         umws(20) TYPE c VALUE 'UMWS', "UB-WE-Position Storno
         were(20) TYPE c VALUE 'WERE', "WE-Position Retoure
           cd(20) TYPE c VALUE 'I12 ', "Änderungsbeleg anzeigen
         serc(20) TYPE c VALUE 'SERC', "erfaßte Serialnr. ändern
         END OF fcod.

*------- Blätterfunktionen
CONSTANTS:    BEGIN OF pcod,
               anfa(4) TYPE c VALUE 'P-- ',        "an den Anfang
               ende(4) TYPE c VALUE 'P++ ',        "ans Ende
               minu(4) TYPE c VALUE 'P-  ',        "eine Seite zurück
               plus(4) TYPE c VALUE 'P+  ',        "eine Seite vor
               pmin(4) TYPE c VALUE 'PMIN',        "eine Pos zurück
               pplu(4) TYPE c VALUE 'PPLU',        "eine Pos vor
               sele(4) TYPE c VALUE 'SELE',        "alles markieren
              END OF pcod.

*------- Transaktionen
CONSTANTS:    BEGIN OF tcod,
               mb00(4)   TYPE c VALUE 'MB00',
               mb02(4)   TYPE c VALUE 'MB02',
               mb03(4)   TYPE c VALUE 'MB03',
               mb21(4)   TYPE c VALUE 'MB21',
               mb1b(4)   TYPE c VALUE 'MB1B',               "423743
               mi00(4)   TYPE c VALUE 'MI00',
               lb12(4)   TYPE c VALUE 'LB12',
               vl32n(5)  TYPE c VALUE 'VL32N',
               vl02n(5)  TYPE c VALUE 'VL02N',
               vl09(4)   TYPE c VALUE 'VL09',
               hucanc(6) TYPE c VALUE 'HUCANC',
               cowbhuwa(8) TYPE c VALUE 'COWBHUWA',
              END OF tcod.

*------- value added services aktiv
*CONSTANTS: VAS_SWITCH  TYPE C VALUE 'X'.               " P9CK166739

*-----------------------------------------------------------------------
*       Teil 5 :  Ranges
*-----------------------------------------------------------------------
RANGES rwerks FOR rm07m-werks.
RANGES rmatnr FOR rm07m-matnr.
RANGES rbdter FOR rm07m-bdter.
RANGES reindt FOR rm07m-eindt.
RANGES rlifnr FOR am07m-lifnr.
RANGES rreswk FOR am07m-reswk.
RANGES rean11 FOR rm07m-ean11.
RANGES ridnlf FOR rm07m-idnlf.
RANGES rmatnv FOR am07m-matnv.
RANGES rpstyp FOR vm07m-pstyp.
RANGES: rtknum FOR rm07m-tknum,        "WE zum Transport
        rvlief FOR rm07m-vlief.
DATA:    END OF COMMON PART.
*eject