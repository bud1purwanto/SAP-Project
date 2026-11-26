***INCLUDE COPYLISA .
*---------------------------------------------------------------------*
*       Tabellen mit den Daten der Aufträge, für die im               *
*       Sammelgang Lieferungen erstellt werden sollen                 *
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       interne Tabellen / Feldleisten                                *
*---------------------------------------------------------------------*

DATA: BEGIN OF COMMON PART COPYLISA.

DATA:   BEGIN OF CVBAK OCCURS 10.
          INCLUDE STRUCTURE VBAK.
DATA:   END OF CVBAK.

DATA:   BEGIN OF CVBAP OCCURS 50.
          INCLUDE STRUCTURE VBAPVB.
DATA:   END OF CVBAP.

DATA:   BEGIN OF CVBEP OCCURS 100.
          INCLUDE STRUCTURE VBEPVB.
DATA:   END OF CVBEP.

DATA:   BEGIN OF CVBFA OCCURS 0.
          INCLUDE STRUCTURE VBFAVB.
DATA:   END OF CVBFA.

DATA:   BEGIN OF CVBKD OCCURS 15.
          INCLUDE STRUCTURE VBKDVB.
DATA:   END OF CVBKD.

DATA:   BEGIN OF CVBPA OCCURS 30.
          INCLUDE STRUCTURE VBPAVB.
DATA:   END OF CVBPA.

DATA:   BEGIN OF CVBUP OCCURS 0.
          INCLUDE STRUCTURE VBUPVB.
DATA:   END OF CVBUP.

DATA:   BEGIN OF CVBUK OCCURS 10.
          INCLUDE STRUCTURE VBUK.
DATA:   END OF CVBUK.

DATA:   BEGIN OF CFPLA OCCURS 5.                        "CCARD
          INCLUDE STRUCTURE FPLAVB.                     "CCARD
DATA:   END OF CFPLA.                                   "CCARD

DATA:   BEGIN OF CFPLT OCCURS 10.                       "CCARD
          INCLUDE STRUCTURE FPLTVB.                     "CCARD
DATA:   END OF CFPLT.                                   "CCARD


DATA: END OF COMMON PART COPYLISA.
*---------------------------------------------------------------------*