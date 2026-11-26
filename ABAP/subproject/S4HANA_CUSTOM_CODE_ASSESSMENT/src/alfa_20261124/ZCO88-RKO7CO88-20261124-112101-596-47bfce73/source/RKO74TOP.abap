* Include RKO74TOP - Datenteil CO-Abrechnung ueber Report

* Abrechnungs-spezif. Teil
DATA: BEGIN OF IT_SELPA OCCURS 0.
        INCLUDE STRUCTURE KABA00.
DATA: END OF IT_SELPA.
DATA: TXT_VAART(30).
DATA: GD_TXTVAART LIKE DD07V-DDTEXT.
TABLES: LKO74.
DATA: GD_VAART_EXCL LIKE SY-MSGV1,
      GD_NO_LAST_VLINE TYPE C,                   "DUMMY-Variable
      GD_VAART_DTEL_ZUSATZ(4).
INCLUDE RKAWRTTP.

data: gb_list_changed type c,
      gb_tech_changed type c,
      gb_para_changed type c,
      gb_aufgr type c.
include <ICON>.