*-----------------------------------------------------------------------
*        COMMON DATA
*-----------------------------------------------------------------------

DATA:    BEGIN OF COMMON PART MM07MCMS.

*-----------------------------------------------------------------------
*        Datenbanktabellen
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Datenfelder fuer die Programme SAPMM07*
*
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*       Teil 3 :  Einzelfelder  ( variabel )
*       Teil 4 :  Konstanten
*       Teil 5 :  Field-Symbols
*
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*-----------------------------------------------------------------------
DATA: ATPDT  LIKE ATPDT.
*-----------------------------------------------------------------------
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*-----------------------------------------------------------------------

DATA: BEGIN OF XEKPO_KEY,
        EBELN LIKE SEKPO-EBELN,
        EBELP LIKE SEKPO-EBELP,
        LFBJA LIKE SEKPO-LFBJA,
        LFBNR LIKE SEKPO-LFBNR,
        LFPOS LIKE SEKPO-LFPOS,
        KZZUG LIKE SEKPO-KZZUG,
        MATNR LIKE SEKPO-MATNR,
        WERKS LIKE SEKPO-WERKS,
      END OF XEKPO_KEY.

* PPF: begin 4.0C
DATA: BEGIN OF XEKPK_KEY,
        EBELN LIKE SEKPK-EBELN,
        EBELP LIKE SEKPK-EBELP,
      END OF XEKPK_KEY.
* PPF: end   4.0c

DATA: BEGIN OF XMARC_KEY,
        MATNR LIKE SMARC-MATNR,
        WERKS LIKE SMARC-WERKS,
      END OF XMARC_KEY.

DATA: BEGIN OF XMSTB_KEY,               "SIT
        MATNR LIKE SMSTB-MATNR,
        WERKS LIKE SMSTB-WERKS,
        CHARG LIKE SMSTB-CHARG,
        SOBKZ LIKE SMSTB-SOBKZ,
      END OF XMSTB_KEY.

DATA: BEGIN OF XMARD_KEY,
        MATNR LIKE SMARD-MATNR,
        WERKS LIKE SMARD-WERKS,
        LGORT LIKE SMARD-LGORT,
      END OF XMARD_KEY.

DATA: BEGIN OF XMCHA_KEY,
        MATNR LIKE SMCHA-MATNR,
        WERKS LIKE SMCHA-WERKS,
        CHARG LIKE SMCHA-CHARG,
      END OF XMCHA_KEY.

DATA: BEGIN OF XMCH1_KEY,
        MATNR LIKE SMCH1-MATNR,
        CHARG LIKE SMCH1-CHARG,
      END OF XMCH1_KEY.

DATA: BEGIN OF XMCHB_KEY,
        MATNR LIKE SMCHB-MATNR,
        WERKS LIKE SMCHB-WERKS,
        LGORT LIKE SMCHB-LGORT,
        CHARG LIKE SMCHB-CHARG,
      END OF XMCHB_KEY.

DATA: BEGIN OF XMKOL_KEY,
        MATNR LIKE SMKOL-MATNR,
        WERKS LIKE SMKOL-WERKS,
        LGORT LIKE SMKOL-LGORT,
        CHARG LIKE SMKOL-CHARG,
        LIFNR LIKE SMKOL-LIFNR,
        SOBKZ LIKE SMKOL-SOBKZ,
      END OF XMKOL_KEY.

DATA: BEGIN OF XMSKU_KEY,
        MATNR LIKE SMSKU-MATNR,
        WERKS LIKE SMSKU-WERKS,
        CHARG LIKE SMSKU-CHARG,
        SOBKZ LIKE SMSKU-SOBKZ,
        KUNNR LIKE SMSKU-KUNNR,
      END OF XMSKU_KEY.

DATA: BEGIN OF XMSLB_KEY,
        MATNR LIKE SMSLB-MATNR,
        WERKS LIKE SMSLB-WERKS,
        CHARG LIKE SMSLB-CHARG,
        SOBKZ LIKE SMSLB-SOBKZ,
        LIFNR LIKE SMSLB-LIFNR,
      END OF XMSLB_KEY.

DATA: BEGIN OF XMSSL_KEY,
        MATNR LIKE SMSSL-MATNR,
        WERKS LIKE SMSSL-WERKS,
        SOBKZ LIKE SMSSL-SOBKZ,
        LIFNR LIKE SMSSL-LIFNR,
      END OF XMSSL_KEY.

DATA: BEGIN OF XMSKA_KEY,
        MATNR LIKE SMSKA-MATNR,
        WERKS LIKE SMSKA-WERKS,
        LGORT LIKE SMSKA-LGORT,
        CHARG LIKE SMSKA-CHARG,
        SOBKZ LIKE SMSKA-SOBKZ,
        VBELN LIKE SMSKA-VBELN,
        POSNR LIKE SMSKA-POSNR,
      END OF XMSKA_KEY.

DATA: BEGIN OF XMSTE_KEY,                       "SIT
        MATNR LIKE SMSTE-MATNR,
        WERKS LIKE SMSTE-WERKS,
        CHARG LIKE SMSTE-CHARG,
        SOBKZ LIKE SMSTE-SOBKZ,
        VBELN LIKE SMSTE-VBELN,
        POSNR LIKE SMSTE-POSNR,
      END OF XMSTE_KEY.

DATA: BEGIN OF XMSSA_KEY,
        MATNR LIKE SMSSA-MATNR,
        WERKS LIKE SMSSA-WERKS,
        SOBKZ LIKE SMSSA-SOBKZ,
        VBELN LIKE SMSSA-VBELN,
        POSNR LIKE SMSSA-POSNR,
      END OF XMSSA_KEY.





ENHANCEMENT-POINT MM07MCMS_01 SPOTS ES_MM07MCMS STATIC INCLUDE BOUND.
DATA: BEGIN OF XMSPR_KEY,
        MATNR LIKE SMSPR-MATNR,
        WERKS LIKE SMSPR-WERKS,
        LGORT LIKE SMSPR-LGORT,
        CHARG LIKE SMSPR-CHARG,
        SOBKZ LIKE SMSPR-SOBKZ,
        PSPNR LIKE SMSPR-PSPNR,
      END OF XMSPR_KEY.

DATA: BEGIN OF XMSTQ_KEY,            "SIT
        MATNR LIKE SMSTQ-MATNR,
        WERKS LIKE SMSTQ-WERKS,
        CHARG LIKE SMSTQ-CHARG,
        SOBKZ LIKE SMSTQ-SOBKZ,
        PSPNR LIKE SMSTQ-PSPNR,
      END OF XMSTQ_KEY.

DATA: BEGIN OF XMSSQ_KEY,
        MATNR LIKE SMSSQ-MATNR,
        WERKS LIKE SMSSQ-WERKS,
        SOBKZ LIKE SMSSQ-SOBKZ,
        PSPNR LIKE SMSSQ-PSPNR,
      END OF XMSSQ_KEY.

DATA: BEGIN OF XMRES_KEY,
         RSNUM LIKE SMRES-RSNUM,
         RSPOS LIKE SMRES-RSPOS,
         RSART LIKE SMRES-RSART,
      END OF XMRES_KEY.

DATA: BEGIN OF XFAUP_KEY,
         AUFNR LIKE SFAUP-AUFNR,
         AUFPS LIKE SFAUP-AUFPS,
      END OF XFAUP_KEY.

DATA:    BEGIN OF SEGAUSW,
            SEGM(4)  TYPE C,           "Segmentname
            XAME(1)  TYPE C,           "Kz. Segment in AME
            XNEU(1)  TYPE C,           "Kz. Neues Segment zulässig
            XCHA(1)  TYPE C,           "Kz. Chargenpflicht
            LAUS(1)  TYPE C,           "Kz. Lagerortauswahl
            XRES(1)  TYPE C,           "Kz. Reservierung
            XNEG(1)  TYPE C,           "Kz. negativer Bestand zulässig
            XEQU(1)  TYPE C,           "Kz. Enqueue notwendig
            XMEN(1)  TYPE C,           "Kz. Nur bei Mengenmäßiger Befu
         END OF SEGAUSW.

DATA:    BEGIN OF RNAME,               "Name der Leseroutine
           KENN(1) VALUE 'R',          "Kennung
           NAME(4) VALUE '    ',       "Name
         END OF RNAME.

DATA:    BEGIN OF VNAME,
           PREF(6) VALUE '      ',     "Name Praefix
           KENN(1) VALUE ' ',          "Name Kennung S/U
           SUFF(4) VALUE '    ',       "Name Suffix
         END OF VNAME.

*------- Typ für Retail Kopf-Zeilenstruktur                "note 356129
  TYPES: BEGIN OF T_RSTRUCT,                               "note 356129
            MATNR      LIKE MSEG-MATNR ,                   "note 356129
            BSTME      LIKE MSEG-BSTME ,                   "note 356129
            ERFME      LIKE MSEG-ERFME ,                   "note 356129
            MATNRVOR   LIKE MSEG-MATNR ,                   "note 356129
            BSTMEVOR   LIKE MSEG-BSTME ,                   "note 356129
            ERFMEVOR   LIKE MSEG-ERFME ,                   "note 356129
            XAUTO      LIKE MSEG-XAUTO ,                   "note 356129
            UPTYP      LIKE DM07M-UPTYP,                   "note 356129
            UPVOR      LIKE DM07M-UPVOR,                   "note 356129
            ATTYP      LIKE VM07M-ATTYP,                   "note 356129
            SHKZG      like mseg-shkzg,                    "note 443478
         END OF T_RSTRUCT.                                 "note 356129
  TYPES: T_IT_RSTRUCT                                      "note 356129
         TYPE STANDARD TABLE OF T_RSTRUCT                  "note 356129
                       WITH DEFAULT KEY.                   "note 356129

*------- Typ für Retail XYMSEG                             "note 356129
  TYPES: BEGIN OF T_XYMSEG,                                "note 356129
               MATNR  LIKE MSEG-MATNR ,                    "note 356129
               BSTME  LIKE MSEG-BSTME ,                    "note 356129
               ERFME  LIKE MSEG-ERFME ,                    "note 356129
               XAUTO  LIKE MSEG-XAUTO ,                    "note 356129
               EBELN  LIKE MSEG-EBELN ,                    "note 356129
               EBELP  LIKE MSEG-EBELP ,                    "note 356129
               LFBNR  LIKE MSEG-LFBNR ,                    "note 356129
               ZEILE  LIKE MSEG-ZEILE ,                    "note 356129
               URZEI  LIKE MSEG-URZEI ,                    "note 356129
               ERFMG  LIKE MSEG-ERFMG ,                    "note 356129
               KZOK   TYPE C          ,                    "note 356129
               shkzg  like mseg-shkzg ,                    "note 443478
               ATTYP  LIKE MARA-ATTYP ,                    "note 454005
         END OF T_XYMSEG.                                  "note 356129
  TYPES: T_IT_XYMSEG                                       "note 356129
         TYPE STANDARD TABLE OF T_XYMSEG                   "note 356129
                       WITH DEFAULT KEY.                   "note 356129

*---- structure for the collection of Retail-structures    "note 356129
DATA: IT_RSTRUCT TYPE T_IT_RSTRUCT.                        "note 356129
*---- a temporary duplicated structure of ymseg or xmseg   "note 356129
DATA: IT_XYMSEG  TYPE T_IT_XYMSEG.                         "note 356129

*-----------------------------------------------------------------------
*       Teil 3 :  Einzelfelder
*-----------------------------------------------------------------------

DATA:    ANZ-SEGM(2)  TYPE P VALUE 23. "Anzahl erwarteter Segmente

"$$
"$$
"$$


*-----------------------------------------------------------------------
*       Teil 4 :  Konstanten
*-----------------------------------------------------------------------
CONSTANTS:    CHARGE_AUF_WERK LIKE TCUCH-KZDCH VALUE '0',
              CHARGE_AUF_MAND LIKE TCUCH-KZDCH VALUE '2',
              CHARGE_ZUSTVERW LIKE TCUCH-KZDZV VALUE '1',
              CHARGE_AUTO     LIKE TCUCH-AUTBN VALUE '1'.

CONSTANTS:    PREFD(6) VALUE 'DM07M-',     "Name Praefix
              PREFV(6) VALUE 'VM07M-'.     "Name Praefix

DATA:    BEGIN OF SEGM,                " Segmente
           MKOL(12) TYPE C VALUE 'MKOL X   XXX',     " Tabelle MKOL
           MSKA(12) TYPE C VALUE 'MSKA X   XXX',     " Tabelle MSKA
* Neue Segmente bitte nach dieser Zeile aufnehmen (wg. DO - Schleifen)
           MSKU(12) TYPE C VALUE 'MSKU X   XXX',     " Tabelle MSKU
           MSLB(12) TYPE C VALUE 'MSLB X   XXX',     " Tabelle MSLB
           MSPR(12) TYPE C VALUE 'MSPR X   XXX',     " Tabelle MSPR
           MSSA(12) TYPE C VALUE 'MSSA X   X X',     " Tabelle MSSA
           MSSL(12) TYPE C VALUE 'MSSL X   X X'.     " Tabelle MSSL
ENHANCEMENT-POINT MM07MCMS_02 SPOTS ES_MM07MCMS STATIC INCLUDE BOUND.

data:
           MSSQ(12) TYPE C VALUE 'MSSQ X   X X',     " Tabelle MSSQ
           MCHB(12) TYPE C VALUE 'MCHB XXX XXX',     " Tabelle MCHB
           MSTB(12) TYPE C VALUE 'MSTB XXX XXX',     " Tabelle MSTB    "SIT
           MSTE(12) TYPE C VALUE 'MSTE XXX XXX',     " Tabelle MSTE    "SIT
           MSTQ(12) TYPE C VALUE 'MSTQ XXX XXX',     " Tabelle MSTQ    "SIT
           MARD(12) TYPE C VALUE 'MARD X X XXX',     " Tabelle MARD
           MARC(12) TYPE C VALUE 'MARC     XXX',     " Tabelle MARC

           EKLA(12) TYPE C VALUE 'EKLAX       ',     " Tabelle EKLA
           EKPO(12) TYPE C VALUE 'EKPOX       ',     " Tabelle EKPO
           EKPK(12) TYPE C VALUE 'EKPKX       ',     " Tabelle EKPK
           ISEG(12) TYPE C VALUE 'ISEG     X X',     " Tabelle ISEG
                                                         " PPF Rel. 4.6
           FAUP(12) TYPE C VALUE 'FAUPX       ',     " Tabelle FAUP
           MRES(12) TYPE C VALUE 'MRES    X  X',     " Tabelle MRES
           END$(12) TYPE C VALUE 'ZZZZZZZZZZZZ',     " Endemarke 1
           ENDZ(12) TYPE C VALUE '$$$$$$$$$$$$',     " Endemarke 2
         END OF SEGM.

*------ Kennzeichnung der Bewegungsart     ----------------------------*
CONSTANTS: BEGIN OF KZBWA,
             01 LIKE T156-KZBWA VALUE '01',   "Umlagerbestellung
             02 LIKE T156-KZBWA VALUE '02',   "Stückliste WA
             03 LIKE T156-KZBWA VALUE '03',   "Cross Company
             04 LIKE T156-KZBWA VALUE '04',   "Cross Company 1 Schritt
             05 LIKE T156-KZBWA VALUE '05',   "Umlagerbestell. 1 Schritt
             06 LIKE T156-KZBWA VALUE '06',   "Umlagerbestell. 2 Schritt
                                              "über BAPI
             07 LIKE T156-KZBWA VALUE '07',   "Umbewertung Charge
             B3 LIKE T156-KZBWA VALUE 'B3',   "3rd party Brazil
             SZ LIKE T156-KZBWA VALUE 'SZ',   "strukt Material zerlegen
             K3 LIKE T156-KZBWA VALUE 'K3'.   "Cross Company Consignment
                                              "Transfer
                                              "ST-PO-consignment
ENHANCEMENT-POINT MM07MCMS_03 SPOTS ES_MM07MCMS STATIC INCLUDE BOUND.
CONSTANTS:
           END OF KZBWA.

*------- Artikeltypen
CONSTANTS: BEGIN OF ATTYP,
            SAM LIKE MARA-ATTYP VALUE '01',        "Sammelmaterial
            VAR LIKE MARA-ATTYP VALUE '02',        "Variante
            VKS LIKE MARA-ATTYP VALUE '10',        "VK-Set
            LOT LIKE MARA-ATTYP VALUE '11',        "Lot
            DIS LIKE MARA-ATTYP VALUE '12',        "Display
            WGR LIKE MARA-ATTYP VALUE '20',        "Warengruppen-Wertmat
            WGH LIKE MARA-ATTYP VALUE '21',        "Warengruppen-Hierarc
            GWM LIKE MARA-ATTYP VALUE '22',        "Gruppen-Wertmaterial
           END OF ATTYP.
*------- Unterpositionstypen
CONSTANTS: UPTYP_VAR LIKE  EKPO-UPTYP VALUE '1', " Unterpos.typ Variante
           UPTYP_NRE LIKE  EKPO-UPTYP VALUE '2', " Unterpos.typ Nat.Rab.
           UPTYP_LG  LIKE  EKPO-UPTYP VALUE '3', " Unterpos.typ Leergut
           UPTYP_NRA LIKE  EKPO-UPTYP VALUE '4', " Unterpos.typ Nat.Rab.
           UPTYP_LGNAT                VALUE '2', " Leergut/Natrab.
           UPTYP_LOT LIKE  EKPO-UPTYP VALUE '5', " Unterpos.typ Lot
           UPTYP_DIS LIKE  EKPO-UPTYP VALUE '6', " Unterpos.typ Display
           UPTYP_SET LIKE  EKPO-UPTYP VALUE '7', " Unterpos.typ VK-SET
           UPTYP_VAS LIKE  EKPO-UPTYP VALUE '9'. " Upos. value add. serv
CONSTANTS: C_MEKOR                    VALUE '3'. " Unterps.mit Mengenkor
*------- Zustände Hauptposition value added service
constants: xvash_passed type xvash value '1'. "bereits verarbeitet

DATA:    END OF COMMON PART.



*eject