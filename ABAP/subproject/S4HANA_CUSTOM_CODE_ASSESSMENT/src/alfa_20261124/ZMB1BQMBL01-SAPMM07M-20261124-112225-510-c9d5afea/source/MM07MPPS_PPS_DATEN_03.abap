*eject
*---------------------------------------------------------------------*
*       Die Daten des Auftrages werden übernommen.                    *
*---------------------------------------------------------------------*
FORM PPS_DATEN_03.
  IF NOT DM07M-PARWK IS INITIAL.
    DATA: BWKEY LIKE VM07M-BWKEY,
          XEINK LIKE DM07M-XEINK,
          XBKNG LIKE DM07M-XBKNG,
          XVKBW LIKE VM07M-XVKBW,
          BWMOD LIKE DM07M-BWMOD,
          FABKL LIKE DM07M-FABKL.
    PERFORM WERK_LESEN(SAPFM07M) USING X
                                   DM07M-PARWK
                                         BWKEY
                                         BWMOD
                                         XEINK
                                         XBKNG
                                         XVKBW
                                    MSEG-PARBU
                                   DM07M-UMKPL
                                   DM07M-UMPER
                                   DM07M-UMWAE
                                    MKPF-BUDAT
                                   DM07M-UMGJA
                                   DM07M-UMMON
                                         FABKL
                                   DM07M-UMKZXAB.
  ENDIF.
ENDFORM.