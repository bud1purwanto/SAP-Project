*eject
*---------------------------------------------------------------------*
*       Die Daten des Auftrages werden übernommen.                    *
*---------------------------------------------------------------------*
FORM PPS_DATEN_02.
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
  DM07M-MAKTX = XFBEFU-KTEXT.
  DM07M-BSMNG = XFBEFU-PSMNG.
  MSEG-BSTME  = XFBEFU-AMEIN.
  IF XFBEFU-PSMNG IS INITIAL AND NOT XFBEFU-NETWR IS INITIAL.
    MESSAGE E186.
  ENDIF.
  IF XFBEFU-ERFMG IS INITIAL.
    IF MSEG-SHKZG = S.
      MSEG-ERFMG = XFBEFU-PSMNG - XFBEFU-WEMNG - XFBEFU-IAMNG.
    ELSE.
      MSEG-ERFMG = XFBEFU-WEMNG.
    ENDIF.
  ELSE.
    MSEG-ERFMG = XFBEFU-ERFMG.
  ENDIF.
  IF MSEG-ERFMG < 0.
    MSEG-ERFMG = 0.
  ENDIF.
  MSEG-ERFME = XFBEFU-AMEIN.

ENDFORM.