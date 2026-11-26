*---------------------------------------------------------------------*
*       FORM PBED_ABBAU_GENERIEREN                                    *
*---------------------------------------------------------------------*
*       Die Schnittstelle zum Abbauen des Primärbedarfes wird         *
*       aufgebaut.                                                    *
*---------------------------------------------------------------------*
FORM PBED_ABBAU_GENERIEREN.

  CHECK NOT XVM07M-KZWES = S.
  CHECK MKPF-VGART NE VGART_WS.

* Background part of cross-system movements. The plant of this
* line if not known here.
* The automatic line is the
* complementary posting in this system. It can pass, although I do not
* know whether transit stock is relevant here.
  CHECK NOT ( cl_mmim_cross_system=>kzdir_get( xmseg-bwart ) = r "sdp462
              AND xmseg-xauto IS INITIAL ).                      "sdp462

* kein Bedarfsabbau beim Wareneingang in die Bestandsart "GESPERRT"
  CHECK NOT XMSEG-INSMK = S. "              >>>>>>>>> INSERT NOTE 97864
  CLEAR XPBAT .                        ">>>>>>>>>INSERT NOTE 0103925
*-- Sofern bei Umlagerungsbewegungsarten das Kz. in der T156 sitzt, --*
*-- wird nur ein Satz aufgebaut, sofern es sich um eine Umlagerung  --*
*-- zwischen Werken handelt und dann nur für das abgebende Werk     --*
  IF NOT XMSEG-UMWRK IS INITIAL.
*   check xmseg-werks ne xmseg-umwrk.                 DELETE NOTE 71158
*   zweiter Ansprung (automatisch generierte Position )
*   bei Umlagerung innerhalb Werk ignorieren
    IF ( XMSEG-WERKS EQ XMSEG-UMWRK AND"insert note 71158-1
          XMSEG-MATNR EQ XMSEG-UMMAT ) .           "insert note 71158-1
      IF XMSEG-XAUTO = X.              "insert note 71158-1
        EXIT.                          "insert note 71158-1
      ELSE.                            "insert note 71158-1

*   Falls bei Umlagerung innerhalb Werk von disponiertem Lagerort
*   auf nicht disponiertem entnommen wird => Bedarfsabbau.
        IF  XVM07M-DISKZ EQ ' ' AND    "insert note 71158-1
           (  ZDM07M-UMDIS EQ '1'   OR "insert note 71158-1
              ZDM07M-UMDIS EQ '2' ) .  "insert note 71158-1
*       Case: stock transfer within a plant from sloc to sloc with
*             different MRP areas (note 691513)
        ELSEIF NOT ZDM07M-BERID   IS INITIAL AND                 "691513
               NOT ZDM07M-UMBERID IS INITIAL AND                 "691513
                   ZDM07M-UMBERID NE ZDM07M-BERID.               "691513
        ELSE.                          "insert note 71158-1
          IF XMSEG-SOBKZ = XMSEG-UMSOK.">>>>>>>>>INSERT NOTE 95036
* >>>>>>>> start of deletion 550457 OvS 2002 <<<<<<<<
*           EXIT.                      "insert note 71158-1
* >>>>>>>>> end of deletion 550457 OvS 2002 <<<<<<<<<
* >>>>>>>> start of insertion 550457 OvS 2002 <<<<<<<<
            IF XMSEG-SOBKZ NE 'Q' AND XMSEG-SOBKZ NE 'E'.
              EXIT.
            ENDIF.
            IF XMSEG-SOBKZ EQ 'Q'
               AND XMSEG-PS_PSP_PNR EQ XMSEG-MAT_PSPNR.
              EXIT. "kein Abbau, falls Projektabschnitt unverändert
            ENDIF.
            IF XMSEG-SOBKZ EQ 'E'
               AND XMSEG-KDAUF EQ XMSEG-MAT_KDAUF
               AND XMSEG-KDPOS EQ XMSEG-MAT_KDPOS.
              EXIT. "kein Abbau innerhalb eines Kundeneinzelabschnitts
            ENDIF.
* >>>>>>>>> end of insertion 550457 OvS 2002 <<<<<<<<<
          ENDIF.                       ">>>>>>>>>INSERT NOTE 95036
        ENDIF.                         "insert note 71158-1
      ENDIF.                           "insert note 71158-1
    ELSE.                              "insert note 71158-1
      IF NOT DM07M-XSTBW IS INITIAL.                        "note330759
        CHECK XMSEG-SHKZG = S.                              "note330759
      ELSE.                                                 "note330759
        CHECK XMSEG-SHKZG = H.
      ENDIF.                                                "note330759
    ENDIF.                             "insert note 71158-1
  ENDIF.

* Kein Abbau bei nicht disponierten Lagerorten
  IF xmseg-kdauf is initial.                       "insert note 71158-2
    IF XVM07M-DISKZ = '1'.                         "insert note 71158-1
      EXIT.                                        "insert note 71158-1
    ENDIF.                                         "insert note 71158-1
  ENDIF.                                           "insert note 71158-2

  XPBAT-DAT01 = MKPF-BUDAT.
  IF NOT XMSEG-RSNUM IS INITIAL.
    XPBAT-DAT01 = XVM07M-BDTER.
  ENDIF.
*-- Weitere Prüfungen, ob ein Bedarfsabbau zu erfolgen hat, finden  --*
*-- im Funktionsbaustein 'REQUIREMENTS_REDUCTION' statt.            --*
  MOVE-CORRESPONDING XVM07M TO XPBAT.
  MOVE-CORRESPONDING XMSEG  TO XPBAT.
  XPBAT-SHKZO = XMSEG-SHKZG .   " original shkz  >>>INSERT NOTE 0103925
  XPBAT-BDART = ZDM07M-BDART.   " man reservierung >>>INSERT NOTE 83706
  XPBAT-XSTBW = ZDM07M-XSTBW.   " kz storno bwart  >>>INSERT NOTE 95036

  IF XMSEG-XAUTO = X.
    XPBAT-MATNR = XMSEG-UMMAT.
    XPBAT-WERKS = XMSEG-UMWRK.
    XPBAT-LGORT = XMSEG-UMLGO.
    XPBAT-SOBKZ = XMSEG-UMSOK.
    XPBAT-SHKZG = S.
    IF XMSEG-SHKZG = S.
      XPBAT-SHKZG = H.
    ENDIF.
    IF XMSEG-SHKZG = S.
      XPBAT-SHKZO = H.
    ELSE.
      XPBAT-SHKZO = S.
    ENDIF.
  ELSE.
    IF NOT XMSEG-SOBKZ IS INITIAL
    AND XPBAT-KZBEW NE B                                    "note 691590
    AND XPBAT-KZBEW NE F.                                   "note 691590
      IF ZDM07M-XSTBW = X.             " Stornobewegungsart ?
        XPBAT-SHKZG = S.               " ja, dann zwangsweise setzen
      ELSE.
        XPBAT-SHKZG = H.
      ENDIF.
    ENDIF.
  ENDIF.

  XPBAT-VBELN = XMSEG-KDAUF.
  XPBAT-POSNR = XMSEG-KDPOS.
  XPBAT-PSPEL = XMSEG-PS_PSP_PNR.

* XPBAT-DIBER = MBEFU-DIBER.                    "note  356380
  xpbat-diber = zdm07m-diber.                   "422539
  xpbat-lbear = xmseg-lifnr.                    "note  373152

******** begin of insertion note 320032
  IF ZDM07M-XSTBW = X.       " Stornobewegungsart ?
    IF XPBAT-VBELN IS INITIAL.
      XPBAT-VBELN = XMSEG-MAT_KDAUF.
    ENDIF.
    IF XPBAT-POSNR IS INITIAL.
      XPBAT-POSNR = XMSEG-MAT_KDPOS.
    ENDIF.
    IF XPBAT-PSPEL IS INITIAL.
      XPBAT-PSPEL = XMSEG-MAT_PSPNR.
    ENDIF.
  ENDIF.
******** end of insertion note 320032

  IF XMSEG-SOBKZ = Q.
    XPBAT-PSPEL = XMSEG-MAT_PSPNR.
  ELSEIF XMSEG-SOBKZ = E.
    XPBAT-VBELN = XMSEG-MAT_KDAUF.
    XPBAT-POSNR = XMSEG-MAT_KDPOS.
  ENDIF.

  APPEND XPBAT.

* >>>>>>>BEGIN OF INSERTION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>NOTE 0103925
* Bei Umlagerung in einem Schritt von Werk an Werk wird eine
* Zeile in der Schnittstelle XPBAT zusätzlich generiert
* für den Bruttobedarfsabbau im empfangenden Werk
  IF NOT XMSEG-UMWRK IS INITIAL AND    " werksumlagerung...
    NOT ( DM07M-UMARD IS INITIAL ).    " ... in 1 Schritt
* nur bei BWART 301 / 302
    IF NOT ( XMSEG-WERKS EQ XMSEG-UMWRK AND  " lagerortumlagerung ?
          XMSEG-MATNR EQ XMSEG-UMMAT ) .
      IF ZDM07M-UMMIS = '2' .          " Bruttobedarf ?

        IF XPBAT-SHKZG = S.            " vorgängereintrag spiegeln
          XPBAT-SHKZG = H.
        ELSE.
          XPBAT-SHKZG = S.
        ENDIF.

        IF XMSEG-XAUTO = X.            " Storno umlagerung ?
*          XPBAT-miskz hier ok
          XPBAT-WERKS = XMSEG-WERKS.
          XPBAT-SHKZO = H.

        ELSE.
          XPBAT-MISKZ = ZDM07M-UMMIS . " MISKZ des Zielwerks
          IF XMSEG-SHKZG = S.
            XPBAT-SHKZO = H.
          ELSE.
            XPBAT-SHKZO = S.
          ENDIF.
          XPBAT-WERKS = XMSEG-UMWRK.
        ENDIF.

        APPEND XPBAT.
      ENDIF.
    ENDIF.
  ENDIF.
* >>>>>>>END   OF INSERTION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>NOTE 0103925

ENDFORM.