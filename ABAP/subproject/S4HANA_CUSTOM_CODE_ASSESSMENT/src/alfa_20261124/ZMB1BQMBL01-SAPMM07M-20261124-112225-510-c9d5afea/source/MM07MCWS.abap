*---------------------------------------------------------------------*
*        COMMON DATA                                                  *
*---------------------------------------------------------------------*

DATA:   BEGIN OF COMMON PART mm07mcws.

*---------------------------------------------------------------------*
*        Material-Werte-Sperrtabelle                                  *
*---------------------------------------------------------------------*
DATA: BEGIN OF xmbew_key,
        matnr LIKE smbew-matnr,
        bwkey LIKE smbew-bwkey,
        bwtar LIKE smbew-bwtar,
        curtp LIKE smbew-curtp,
      END OF xmbew_key.

DATA: BEGIN OF xebew_key,
        matnr LIKE sebew-matnr,
        bwkey LIKE sebew-bwkey,
        bwtar LIKE sebew-bwtar,
        sobkz LIKE sebew-sobkz,
        vbeln LIKE sebew-vbeln,
        posnr LIKE sebew-posnr,
        curtp LIKE sebew-curtp,
      END OF xebew_key.

DATA: BEGIN OF xqbew_key,
        matnr LIKE sqbew-matnr,
        bwkey LIKE sqbew-bwkey,
        bwtar LIKE sqbew-bwtar,
        sobkz LIKE sqbew-sobkz,
        pspnr LIKE sqbew-pspnr,
        curtp LIKE sqbew-curtp,
      END OF xqbew_key.

DATA: BEGIN OF xobew_key,
        matnr LIKE sobew-matnr,
        bwkey LIKE sobew-bwkey,
        bwtar LIKE sobew-bwtar,
        sobkz LIKE sobew-sobkz,
        lifnr LIKE sobew-lifnr,
        curtp LIKE sobew-curtp,
      END OF xobew_key.

*-------- Schnittstelle zum Materialledger ---------------------------*
DATA: BEGIN OF embew OCCURS 0.
        INCLUDE STRUCTURE cki_pr1_ml.
DATA: END OF embew.

DATA: BEGIN OF imbew OCCURS 0.
        INCLUDE STRUCTURE cki_prs_ml.
DATA: END OF imbew.

* Table of currency types
DATA: ycurtp TYPE curtp_t_mb WITH HEADER LINE.              "sdp462

*------- Schluessel zum direkten Lesen der Tabelle XEBEFU
DATA: BEGIN OF ebefu_key,
        ebeln LIKE mseg-ebeln,
        ebelp LIKE mseg-ebelp,
      END OF ebefu_key.

*------- Schluessel zum direkten Lesen der Tabelle MKPF
DATA: BEGIN OF mkpf_key,
        mandt LIKE mkpf-mandt,
        mblnr LIKE mkpf-mblnr,
        mjahr LIKE mkpf-mjahr,
      END OF mkpf_key.

*------- Schluessel zum direkten Lesen der Tabelle MSEG
DATA: BEGIN OF mseg_key,
        mandt LIKE mseg-mandt,
        mblnr LIKE mseg-mblnr,
        mjahr LIKE mseg-mjahr,
        zeile LIKE mseg-zeile,
      END OF mseg_key.

*----------- Schlüssel zum direkten Lesen der Tabelle XEKWS
DATA: BEGIN OF xekws_key,
        ebeln LIKE sekws-ebeln,
        ebelp LIKE sekws-ebelp,
        lfbja LIKE sekws-lfbja,
        lfbnr LIKE sekws-lfbnr,
        lfpos LIKE sekws-lfpos,
        curtp LIKE sekws-curtp,
      END OF xekws_key.

* MAA2 Begin

DATA: BEGIN OF xekws_key_maa,
        ebeln LIKE sekws-ebeln,
        ebelp LIKE sekws-ebelp,
        lfbja LIKE sekws-lfbja,
        lfbnr LIKE sekws-lfbnr,
        lfpos LIKE sekws-lfpos,
        curtp LIKE sekws-curtp,
        zekkn LIKE sekws-zekkn,
      END OF xekws_key_maa.

DATA: BEGIN OF xekbn_key_maa,
        ebeln LIKE sekbn-ebeln,
        ebelp LIKE sekbn-ebelp,
        stunr LIKE sekbn-stunr,
        zaehk LIKE sekbn-zaehk,
        curtp LIKE sekbn-curtp,
        zekkn LIKE sekbn-zekkn,
      END OF xekbn_key_maa.

DATA: BEGIN OF xekbv_key_maa,
        zeile LIKE sekbv-zeile,
        stunr LIKE sekbv-stunr,
        zaehk LIKE sekbv-zaehk,
        curtp LIKE sekbv-curtp,
        zekkn LIKE sekbn-zekkn,
      END OF xekbv_key_maa.

DATA: BEGIN OF xekwv_key_maa,
        zeile LIKE sekwv-zeile,
        curtp LIKE sekwv-curtp,
        zekkn LIKE sekwv-zekkn,
      END OF xekwv_key_maa.
* MAA2 End

*----------- Schlüssel zum direkten Lesen der Tabelle XEKBN
DATA: BEGIN OF xekbn_key,
        ebeln LIKE sekbn-ebeln,
        ebelp LIKE sekbn-ebelp,
        stunr LIKE sekbn-stunr,
        zaehk LIKE sekbn-zaehk,
        curtp LIKE sekbn-curtp,
      END OF xekbn_key.

*----------- Schlüssel zum direkten Lesen der Tabelle XEKBV
DATA: BEGIN OF xekbv_key,
        zeile LIKE sekbv-zeile,
        stunr LIKE sekbv-stunr,
        zaehk LIKE sekbv-zaehk,
        curtp LIKE sekbv-curtp,
      END OF xekbv_key.

DATA: BEGIN OF xekwv_key,
        zeile LIKE sekwv-zeile,
        curtp LIKE sekwv-curtp,
      END OF xekwv_key.

*----------- Schlüssel zum direkten Lesen der Tabelle XFAWS
DATA: BEGIN OF xfaws_key,
        aufnr LIKE sfaws-aufnr,
        aufps LIKE sfaws-aufps,
        curtp LIKE sfaws-curtp,
      END OF xfaws_key.

DATA: BEGIN OF xfawv_key,
        zeile LIKE sekwv-zeile,
        curtp LIKE sekwv-curtp,
      END OF xfawv_key.

DATA: BEGIN OF wrmod.
        INCLUDE STRUCTURE wrxmod.
DATA: END OF wrmod.

*------- Einzelfelder ------------------------------------------------*
DATA:    neuer_preis      LIKE mbew-verpr,    " Bestandswert-Simul.
         alter_preis      LIKE mbew-verpr,    " Bestandswert-Simul.
         wert1            TYPE f,             " Toleranzwertgrenze 1
         wert2            TYPE f,             " Toleranzwertgrenze 2
         proz1            TYPE f,             " Toleranzgrenze 1 in %
         proz2            TYPE f,             " Toleranzgrenze 2 in %
         xruem            LIKE mseg-xruem,    " KZ. Rückbuchen Monat
         xruej            LIKE mseg-xruej,    " KZ. Rückbuchen Jahr
         xrueb            LIKE mseg-xruej,    " Buchen in Vorperiode
         tab_index        LIKE sy-index.      " Schleifenindex

DATA: edit_anln1 LIKE mseg-anln1,         " Felder zum Editieren der
      edit_lifnr LIKE mseg-lifnr,         " Ausgabewerte (z. B. sollen
      edit_matnr LIKE mseg-matnr,         " führende Nullen nicht mit
      edit_saknr LIKE dm07m-konto.        " ausgegeben werden)

*---------------------------------------------------------------------*
*        Konstanten                                                   *
*---------------------------------------------------------------------*
CONSTANTS:bustw_bnkr LIKE t156sy-bustw VALUE 'BNKR', "Str BNK Rückstell
          bustw_bnkg LIKE t156sy-bustw VALUE 'BNKG', "Str BNK Gegenbuch
          bustw_mb07 LIKE t156sy-bustw VALUE 'MB07', "Str Nachbelast. LB
          bustw_mb08 LIKE t156sy-bustw VALUE 'MB08', "Str Nachbe Wirkstf
          bustw_wa04 LIKE t156sy-bustw VALUE 'WA04', "String Umbuchung
          bustw_wa01 LIKE t156sy-bustw VALUE 'WA01', "String Warenausg
          bustw_wa06 LIKE t156sy-bustw VALUE 'WA06', "Str Umbuch. Konsi
* begin note 409343
*         BUSTW_WE06 LIKE T156SY-BUSTW VALUE 'WE06'. "Str WE BE kontiert
          bustw_we06 LIKE t156sy-bustw VALUE 'WE06', "Str WE BE kontiert
          bustw_we01 LIKE t156sy-bustw VALUE 'WE01', "Str WE Bestellung
          bustw_txbr LIKE t156sy-bustw VALUE 'TXBR'. "Str tax WE Brasil
* end note 409343
CONSTANTS: vorsl_anl  LIKE t156w-vorsl VALUE 'ANL',  "Anlage
           vorsl_bsx  LIKE t156w-vorsl VALUE 'BSX',  "Bestandsbuchung
           vorsl_ein  LIKE t156w-vorsl VALUE 'EIN',  "Einkaufskonto
           vorsl_ekg  LIKE t156w-vorsl VALUE 'EKG',  "Einkaufsgegenkonto
           vorsl_frl  LIKE t156w-vorsl VALUE 'FRL',  "Fremdleistung
           vorsl_gbb  LIKE t156w-vorsl VALUE 'GBB',  "Gegenbuchung
           vorsl_kbs  LIKE t156w-vorsl VALUE 'KBS',  "Kontierte BE-Pos.
           vorsl_kon  LIKE t156w-vorsl VALUE 'KON',  "Konsignation
           vorsl_prd  LIKE t156w-vorsl VALUE 'PRD',  "Preisdifferenz
           vorsl_wrx  LIKE t156w-vorsl VALUE 'WRX',  "WE/RE Verrechnung
           vorsl_kdm  LIKE t156w-vorsl VALUE 'KDM',  "Kursdifferenz N980402
           buzid_p    LIKE t156w-buzid VALUE 'P',           "N980402
           gc_mulko_1  TYPE c VALUE '1',                    "MAA2
           gc_mulko_2  TYPE c VALUE '2',                    "MAA2
           gc_mulko_3  TYPE c VALUE '3'.                    "MAA2
DATA:    END OF COMMON PART.
*eject