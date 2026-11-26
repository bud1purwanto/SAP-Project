***INCLUDE PPCOWE01 .
************************************************************************
*        Übergabetabelle bei Mehrfachselektion für Wareneingang       *
************************************************************************

DATA: BEGIN OF COMMON PART PPCOWE01.

DATA: BEGIN OF FUEB OCCURS 0,
        AUFNR LIKE AUFK-AUFNR,
        POSNR LIKE AFPO-POSNR,
      END OF FUEB.

DATA: FUEB-NRCFD,
      FUEB-ID(10) TYPE C VALUE 'WE_AUFTRAG'.

DATA: END OF COMMON PART.