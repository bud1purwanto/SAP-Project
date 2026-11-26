*---------------------------------------------------------------------*
*       Tabellen / Feldleisten für Funktionsbaustein                  *
*       RV_DOCUMENT_COPY                                              *
*---------------------------------------------------------------------*


*---------------------------------------------------------------------*
*       interne Tabellen / Feldleisten                                *
*---------------------------------------------------------------------*

DATA: BEGIN OF COMMON PART COPYCOM.

DATA:   BEGIN OF CVBAK.
        INCLUDE STRUCTURE VBAK.
DATA:   END OF CVBAK.

DATA:   BEGIN OF CVBRK OCCURS 0.       " Verwendung als Dummytab.
        INCLUDE STRUCTURE VBRK.        " bei der Kontenfindung
DATA:   END OF CVBRK.

DATA:   BEGIN OF VVBRK.
        INCLUDE STRUCTURE VBRK.
DATA:   END OF VVBRK.

DATA:   BEGIN OF CVBAP OCCURS 10.
        INCLUDE STRUCTURE VBAPVB.
DATA:   END OF CVBAP.

DATA:   BEGIN OF CFPLA OCCURS 10.
        INCLUDE STRUCTURE FPLAVB.
DATA:   END OF CFPLA.

DATA:   BEGIN OF CFPLT OCCURS 10.
        INCLUDE STRUCTURE FPLTVB.
DATA:   END OF CFPLT.

DATA:   BEGIN OF CVBRP OCCURS 10.
        INCLUDE STRUCTURE VBRPVB.
DATA:     PSTYN LIKE VBAP-PSTYV.
DATA:     RKBEL LIKE VBRP-VBELN.
DATA:     RKPOS LIKE VBRP-POSNR.
DATA:   END OF CVBRP.

DATA:   BEGIN OF VVBRP OCCURS 10.
        INCLUDE STRUCTURE VBRPVB.
DATA:   END OF VVBRP.

DATA:   BEGIN OF CVBEP OCCURS 10.
        INCLUDE STRUCTURE VBEPVB.
DATA:   END OF CVBEP.

DATA:   BEGIN OF CVBFA OCCURS 0.
        INCLUDE STRUCTURE VBFAVB.
DATA:   END OF CVBFA.

DATA:   BEGIN OF CVBKD OCCURS 1.
        INCLUDE STRUCTURE VBKDVB.
DATA:   END OF CVBKD.

DATA:   BEGIN OF CVBPA OCCURS 4.
        INCLUDE STRUCTURE VBPAVB.
DATA:   END OF CVBPA.

DATA:   BEGIN OF CVBSN OCCURS 10.
        INCLUDE STRUCTURE VBSNVB.
DATA:   END OF CVBSN.

DATA:   BEGIN OF CVBUP OCCURS 10.
        INCLUDE STRUCTURE VBUPVB.
DATA:   END OF CVBUP.

DATA:   BEGIN OF CVBUK.
        INCLUDE STRUCTURE VBUK.
DATA:   END OF CVBUK.

DATA:   BEGIN OF CVEDA.
        INCLUDE STRUCTURE VEDA.
DATA:   END OF CVEDA.

DATA:   BEGIN OF STEUERUNG.
DATA:     PROGRAMM(18) VALUE 'BEDINGUNG_PRUEFEN_'.
DATA:     NUMMER(3) VALUE '001'.
DATA:   END OF STEUERUNG.

DATA:   BEGIN OF PTVCPA.
        INCLUDE STRUCTURE TVCPA.
DATA:   END OF PTVCPA.

data:   begin of tvcpa_main occurs 10.
        include structure tvcpa.
data:   posnr type posnr.
data:   end of tvcpa_main.

*---------------------------------------------------------------------*
*       Hilfstabellen                                                 *
*---------------------------------------------------------------------*

*ATA:   BEGIN OF HVBPA_TAB OCCURS 3.
*ATA:     GRGEP LIKE VBPA-GRGEP.
*ATA:   END OF HVBPA_TAB.

*---------------------------------------------------------------------*
*       Hilfsfelder                                                   *
*---------------------------------------------------------------------*

DATA:   BEGIN OF HVBAK.
        INCLUDE STRUCTURE VBAK.
DATA:   END OF HVBAK.

DATA:   BEGIN OF HVBPA.
        INCLUDE STRUCTURE VBPA.
DATA:   END OF HVBPA.

* Kennzeichen, Gewicht wurde auf Positionsebene kopiert (X)
DATA: GEWICHT_KOPIERT TYPE C.

* VBAP-KZFME, VBAP-POSNR merken für KOPIEREN bei MAT_AUF_HINWEIS_PRUEFEN
DATA: OLD_KZFME LIKE VBAP-KZFME,
      OLD_POSNR LIKE VBAP-POSNR.

* Meldungsnummer puffern beim Kopieren von Änderungsständen in
* Einzelaufträgen
DATA M_V1894(1) TYPE C.

ENHANCEMENT-POINT COPYDATA_11 SPOTS ES_COPYDATA STATIC INCLUDE BOUND.


DATA: END OF COMMON PART COPYCOM.
*---------------------------------------------------------------------*

DATA:   SAVE-SUBRC LIKE SY-SUBRC.
DATA:   POSNR_NULL(6) TYPE N VALUE '000000'.     "Positionsnummer 0
DATA:   FLAG_KRDAT(1).
DATA:   FLAG_PYKKB(1).

* Reorg PRCTR
DATA: BEGIN OF GT_FAGL_R_SD_LOG OCCURS 0.
        INCLUDE STRUCTURE FAGL_R_SDLOG_001.
DATA: END OF   GT_FAGL_R_SD_LOG.