***INCLUDE MV50AFZ2 .


************************************************************************
*                                                                      *
* This include is reserved for user modifications                      *
*                                                                      *
* Forms for delivery processing                                        *
*                                                                      *
* The name of modification modules should begin with 'ZZ'.             *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*       FORM USEREXIT_BATCH_QUAN_ALLOCATION                           *
*---------------------------------------------------------------------*
*       Userexit zur Verteilung der offnen Menge auf die              *
*       selektierten Chargen.                                         *
*       Zur Verfügung stehen:                                         *
*       interne Tabelle SEL_CHARGEN (Tabelle der selektierten Chargen)*
*  Feld SAVE_CLIPS-LGMNG            (offene, keiner Charge zugeordnete*
*                                    Menge)                           *
*       Dieses Beispiel zeigt die Verteilung gemäß Sortierung.        *
*       Charge für Charge wird die gesamte verfügbare Menge der       *
*       Charge als Liefermenge gesetzt, bis keine Menge mehr zu       *
*       verteilen ist.                                                *
*---------------------------------------------------------------------*
FORM USEREXIT_BATCH_QUAN_ALLOCATION.

  DATA: UBQA_SUBRC  LIKE SY-SUBRC VALUE 0.     "eigener subrc


* Beispiel einer Verteilung
* die Chargen werden der Reihe nach genommen und ihre verfügbare
* menge als Lieferistmenge gesetzt bis die gesamte offene Menge verteilt
* ist

   IF SEL_CHARGEN-MENGE > SAVE_CLIPS-LGMNG.
      LIPS-LFIMG = SAVE_CLIPS-LGMNG.
      SAVE_CLIPS-LGMNG = 0.
   ELSE.
      LIPS-LFIMG = SEL_CHARGEN-MENGE.
      SAVE_CLIPS-LGMNG = SAVE_CLIPS-LGMNG - SEL_CHARGEN-MENGE.
   ENDIF.
   LIPS-VRKME = SEL_CHARGEN-MEINS.

ENDFORM.
*eject

