*-----------------------------------------------------------------------
*        COMMON DATA
*-----------------------------------------------------------------------

TABLES:  SINVE,
         ISEGK,
         IKPF,
         T150F.
DATA:    BEGIN OF COMMON PART MM07ICOM.
*------- Belegzeilen der Inventurhistorie   - Unveraendert/Nachzaehlung
DATA:    BEGIN OF ZISEG OCCURS 0.
           INCLUDE STRUCTURE ISEG.
DATA:    END OF ZISEG.
*------- Kopf des Inventurbeleges zum Zeitpunkt des Einlesens
DATA:    BEGIN OF LIKPF OCCURS 0.
           INCLUDE STRUCTURE IKPF.
DATA:    END OF LIKPF.
*------- Kopf des neuen Inventurbeleges
DATA:    BEGIN OF XIKPF OCCURS 0.
           INCLUDE STRUCTURE IKPF.
DATA:    END OF XIKPF.
*------- Kopf des neuen Inventurbeleges  (bei Nachzaehlung)
DATA:    BEGIN OF YIKPF OCCURS 0.
           INCLUDE STRUCTURE IKPF.
DATA:    END OF YIKPF.
*------- Kopf des Inventurnachzaehlbeleges
DATA:    BEGIN OF ZIKPF OCCURS 0.
           INCLUDE STRUCTURE IKPF.
DATA:      XRUEM,
           XRUEJ.
DATA:    END OF ZIKPF.
*------- Kopf des des Inventurbeleg zur Übergabe an  den
*        MB_UPDATE_INVENTORY_DOKUMENT_V
DATA:    BEGIN OF LT_ZIKPF OCCURS 0.
           INCLUDE STRUCTURE IKPF.
DATA:    END OF LT_ZIKPF.
*------- Kontierung bei Sonderbestand in Inventurhistorie
DATA:    BEGIN OF YISEGK OCCURS 0.
           INCLUDE STRUCTURE ISEGK.
DATA:    END OF YISEGK.
*------- Belegzeilen des Inventurbeleges
DATA:    BEGIN OF YISEG OCCURS 0.
           INCLUDE STRUCTURE ISEG.
DATA:      UPDKZ.
DATA:    END OF YISEG.
*------- Belegzeilen der Inventurbeleges zum Zeitpunkt des Einlesens
DATA:    BEGIN OF LISEG OCCURS 0.
           INCLUDE STRUCTURE ISEG.
DATA:      UPDKZ.
DATA:    END OF LISEG.
*------- Structur für MARA- Satz
DATA:    BEGIN OF XMARA  OCCURS 0.
           INCLUDE STRUCTURE MARA.
DATA:    END OF XMARA.
*@001 begin Leergut-Abwicklung
*------- Belegzeilen der Inventurbelege für Leergut-Artikel
DATA:    BEGIN OF LGISEG OCCURS 0.
           INCLUDE STRUCTURE ISEG.
DATA:      UPDKZ.
DATA:    END OF LGISEG.
*------- Belegzeilen zur Verbuchungssteuerung  Leergut
DATA:    BEGIN OF LGVM07I OCCURS 0.
           INCLUDE STRUCTURE VM07I.
DATA:    END OF LGVM07I.
DATA:    BEGIN OF LGDM07I OCCURS 0.
           INCLUDE STRUCTURE DM07I.
DATA:    END OF LGDM07I.
*@001 end
*------- Belegzeilen zur Dialogsteuerung
DATA:    BEGIN OF YDM07I OCCURS 0.
           INCLUDE STRUCTURE DM07I.
DATA:    END OF YDM07I.
*------- Belegzeilen zur Verbuchungssteuerung
DATA:    BEGIN OF YVM07I OCCURS 0.
           INCLUDE STRUCTURE VM07I.
DATA:    END OF YVM07I.
*------- Materialstatusfelder zur Inventur
DATA:    BEGIN OF ISTATUS OCCURS 0.
           INCLUDE STRUCTURE SINVE.
DATA:    END OF ISTATUS.
*------- Konsichargen zum Lieferanten
DATA:    BEGIN OF XKONSI OCCURS 0.
           INCLUDE STRUCTURE KONSI.
DATA:    END OF XKONSI.
*------- LB-Chargen zum Lieferanten
DATA:    BEGIN OF XLIFBE OCCURS 0.
           INCLUDE STRUCTURE LIFBE.
DATA:    END OF XLIFBE.
*------- Kundenkommi/leergut zum Kunden
DATA:    BEGIN OF XKUNDE OCCURS 0.
           INCLUDE STRUCTURE KUNDE.
DATA:    END OF XKUNDE.
*------- Kundenauftrag
DATA:    BEGIN OF XKUAUF OCCURS 0.
           INCLUDE STRUCTURE KUAUF.
DATA:    END OF XKUAUF.
*------- Projektbestand
DATA:    BEGIN OF XPROBE OCCURS 0.
           INCLUDE STRUCTURE PROBE.
DATA:    END OF XPROBE.
ENHANCEMENT-POINT MM07ICOM_01 SPOTS ES_MM07ICOM STATIC INCLUDE BOUND.
*------- Indextabelle für zu löschende Zeilen
DATA:    BEGIN OF YIDEL OCCURS 0,
           ZEILI LIKE ISEG-ZEILI,
           XZAEL LIKE ISEG-XZAEL,
         END OF YIDEL.
*------- Chargenpositionen fuer Update auf D-Segment
DATA:    BEGIN OF XCM07I OCCURS 0.
           INCLUDE STRUCTURE CM07I.
DATA:    END OF XCM07I.
DATA:    BEGIN OF YCM07I OCCURS 0,
           MATNR LIKE ISEG-MATNR,
           BSTAR LIKE ISEG-BSTAR,
           ISTAT LIKE VM07I-ISTAT,
           SEGMN LIKE VM07I-SEGMN,
           XDIFF LIKE ISEG-XDIFF,
         END OF YCM07I.
DATA:    BEGIN OF C_KEY,
           MATNR LIKE ISEG-MATNR,
           BSTAR LIKE ISEG-BSTAR,
         END OF C_KEY.
*------- Chargen zum Material
DATA:    BEGIN OF XCHARG OCCURS 0.
           INCLUDE STRUCTURE CHARG.
DATA:    END OF XCHARG.
* PFF: begin: Matrixbearbeitung Sammelartikel
*------- varianten zum Sammelmaterial
DATA:    BEGIN OF VARIANT OCCURS 0.
           INCLUDE STRUCTURE IVARI.
DATA:    END OF VARIANT.
*------- Generierte ISEG für Varianten
DATA:    BEGIN OF VISEG OCCURS 0.
           INCLUDE STRUCTURE ISEG.
DATA:    END OF VISEG.
* PPF: end
*------- Steuerflags zum Funktionscode
DATA:    BEGIN OF FCAUSI.
           INCLUDE STRUCTURE T064F.
DATA:    END OF FCAUSI.
*------- Merken Steuerflags zum Funktionscode
DATA:    BEGIN OF OLD_FCAUSI.
           INCLUDE STRUCTURE T064F.
DATA:    END OF OLD_FCAUSI.
*------- Interne Tabelle der Bestandsfelder
DATA:    BEGIN OF Z150F OCCURS 0.
           INCLUDE STRUCTURE T150F.
DATA:    END OF Z150F.

*       Flag gibt an, ob der Aufruf ueber FB MB_PHYSICAL_INVENTORY
*       erfolgt ist.
DATA: X_AUFRUF_AUS_FB       TYPE C.

* Serialnumbers
DATA: sernr_export LIKE risa0-anzahl,   "number of serialnumbers
      sernr_import LIKE risa0-anzahl,   "number of serialnumbers
      serialno_obligatory(1),           "serialno. for a mat. obligatory
      serialno_active(1),               "working with serialno.
      temp_iblnr like iseg-iblnr value '$TEMP', "temporary inv.doc.nr.
      VW_SERIALNUMBERS(1).              "serialno were changed in MI05

*       gesperrt ist.
DATA: X_BELEG_SCHON_GELESEN TYPE C.

*       Wenn gesetzt, ist der Beleg bereits gelesen und gesperrt
DATA: X_SPERRE_GLOBAL       TYPE C.

*       last entered order number, relevant for derivation  "1143399
DATA: gv_order_push         TYPE aufnr.                     "1143399

*       Tabelle enthaelt die PosNr. aller Saetze in T_IISEG (FB!)
data: begin of g_t_pos_import occurs 0,
        zeili like iseg-zeili,
      end of g_t_pos_import.

DATA: INV_POST(1) TYPE C,
      T043I_MAXEB LIKE T043I-MAXEB.

DATA: X_CALLED_VIA_GROUP_ITEMS  TYPE C.            " note 855087

DATA:    END OF COMMON PART.
*eject