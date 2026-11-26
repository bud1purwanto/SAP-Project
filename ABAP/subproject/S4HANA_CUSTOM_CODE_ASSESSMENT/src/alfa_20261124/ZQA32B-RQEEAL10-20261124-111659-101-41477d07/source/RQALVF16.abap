***INCLUDE RQALVF16 .

*---------------------------------------------------------------------*
*       FORM CREATE_MONITOR_TAB_F16                                   *
*---------------------------------------------------------------------*
*       Possible reference fields for monitor function (general)      *
*---------------------------------------------------------------------*
FORM CREATE_MONITOR_TAB_F16.

  G_MONITOR_TAB-COUNTER   = 1.
  G_MONITOR_TAB-FIELDNAME = 'PASTRTERM'.
  G_MONITOR_TAB-TEXTLINE  = TEXT-MO1.
  APPEND G_MONITOR_TAB.

  G_MONITOR_TAB-COUNTER = 2.
  G_MONITOR_TAB-FIELDNAME = 'PAENDTERM'.
  G_MONITOR_TAB-TEXTLINE  = TEXT-MO2.
  APPEND G_MONITOR_TAB.

  G_MONITOR_TAB-COUNTER = 3.
  G_MONITOR_TAB-FIELDNAME = 'STTXT'.
  G_MONITOR_TAB-TEXTLINE  = TEXT-MO3.
  APPEND G_MONITOR_TAB.

  G_MONITOR_TAB-COUNTER   = 4.
  G_MONITOR_TAB-FIELDNAME = 'OFFENNLZMK'.
  G_MONITOR_TAB-TEXTLINE  = TEXT-MO4.
  APPEND G_MONITOR_TAB.

  G_MONITOR_TAB-COUNTER   = 5.
  G_MONITOR_TAB-FIELDNAME = 'LMENGEZUB'.
  G_MONITOR_TAB-TEXTLINE  = TEXT-MO5.
  APPEND G_MONITOR_TAB.

ENDFORM.                               "CREATE_MONITOR_TAB_F16
*---------------------------------------------------------------------*
*       FORM MONITOR_INPUTHELP_f16                                  *
*---------------------------------------------------------------------*
*       Bezugfeld für Ampelfunktion in Liste auswählen                *
*---------------------------------------------------------------------*
*  -->  P_MONITOR                                                     *
*---------------------------------------------------------------------*
FORM MONITOR_INPUTHELP_F16 USING P_MONITOR TYPE C.

* Deklaration für Unicode-fähigen FBS F4IF_INT_TABLE_VALUES_GET
  DATA: L_RETURN_TAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF L_MONITOR_TAB OCCURS 0,
          SLKNZ LIKE RIHEA-SLKNZ,
          PM_REFFIELD LIKE RIHEA-PM_REFFIELD,
        END OF L_MONITOR_TAB.

  L_MONITOR_TAB[] = G_MONITOR_TAB[].

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SLKNZ'
      WINDOW_TITLE    = TEXT-F05
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = L_MONITOR_TAB
      RETURN_TAB      = L_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE L_RETURN_TAB INDEX 1.
  IF SY-SUBRC IS INITIAL.
    IF NOT L_RETURN_TAB-FIELDVAL IS INITIAL.
      P_MONITOR = L_RETURN_TAB-FIELDVAL.
    ENDIF.
  ENDIF.
  REFRESH L_MONITOR_TAB.
  REFRESH G_MONITOR_TAB.
ENDFORM.                               " MONITOR_INPUTHELP_F16

*&---------------------------------------------------------------------*
*&      Form  SET_MONITOR_F16
*&---------------------------------------------------------------------*
*       set traffic lights according to inspection start date + status
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_MONITOR_F16.

  CASE MONITOR.                        "g_monitor_tab-counter.
    WHEN '1'.                          " Starttermin
      IF QALS-PASTRTERM LT SY-DATLO.
        OBJECT_TAB-LIGHTS = '1'.                            "rot
      ELSE.
        IF QALS-PASTRTERM EQ SY-DATLO.
          OBJECT_TAB-LIGHTS = '2'.     "gelb
        ELSE.
          OBJECT_TAB-LIGHTS = '3'.     "grün
        ENDIF.
      ENDIF.

    WHEN '2'.                          " Endtermin
      IF QALS-PAENDTERM LT SY-DATLO.
        OBJECT_TAB-LIGHTS = '1'.
      ELSE.
        IF QALS-PAENDTERM EQ SY-DATLO.
          OBJECT_TAB-LIGHTS = '2'.
        ELSE.
          OBJECT_TAB-LIGHTS = '3'.
        ENDIF.
      ENDIF.

    WHEN '3'.                          " Bearbeitungsstatus des Loses
      IF QALS-STAT35 EQ G_X.
        OBJECT_TAB-LIGHTS = '3'.       "VE getroffen, alles i.O.
      ELSE.
        IF QALS-PAENDTERM LE SY-DATLO.
          OBJECT_TAB-LIGHTS = '1'.     "rot, da VE bereits benötigt
        ELSE.
         OBJECT_TAB-LIGHTS = '2'.   "gelb: kein VE, Endtermin in Zukunft
        ENDIF.
      ENDIF.

    WHEN '4'.                          " Offene Merkmale

      IF QALS-OFFENNLZMK GT 0.
        OBJECT_TAB-LIGHTS = '1'.
      ELSE.
        IF QALS-OFFEN_LZMK GT 0 AND QALS-OFFENNLZMK EQ 0.
          OBJECT_TAB-LIGHTS = '2'.
        ELSE.
          OBJECT_TAB-LIGHTS = '3'.
        ENDIF.
      ENDIF.

    WHEN '5'.                          " Offene Mengen

      IF qals-herkunft EQ '09'.
*       Recurring inspection: Check status SPRQ
        CALL FUNCTION 'STATUS_CHECK'
          EXPORTING
            objnr                   = qals-objnr
            status                  = 'I0203'
          EXCEPTIONS
            status_not_active       = 1.
        IF not sy-subrc IS INITIAL.
*         Lot not stock-relevant
          object_tab-lights = '3'.
        ELSEIF qals-lmengezub GT 0.
*         Lot stock-relevant, not all quantities posted
          object_tab-lights = '1'.
        ELSE.
*         Lot stock-relevant, all quantities posted
          object_tab-lights = '3'.
        ENDIF.                         " status / lmengezub

      ELSE.
*       All other lots
        IF qals-lmengezub GT 0.
          object_tab-lights = '1'.
        ELSE.
          object_tab-lights = '3'.
        ENDIF.

      ENDIF.                           " origin 09

  ENDCASE.
ENDFORM.                               " SET_MONITOR_F16
*&---------------------------------------------------------------------*
*&      Form  SELECT_FIELDS_MANIPULIEREN2_F16
*&---------------------------------------------------------------------*
*       Fields to be output are determined, and then read
*----------------------------------------------------------------------*
*       Used in QA32 for structure QALS_D02                            *
*----------------------------------------------------------------------*
FORM SELECT_FIELDS_MANIP2_F16  USING
                            P_FIELDCAT_TAB TYPE SLIS_T_FIELDCAT_ALV .
  DATA:    L_FIELDCAT     LIKE LINE OF G_FIELDCAT_TAB,
           L_TABLE_QALS   TYPE RSFS_TAB_FIELDS,
           L_TABIX_QALS   LIKE SY-TABIX,
           L_TABLE_QAVE   TYPE RSFS_TAB_FIELDS,
           L_TABIX_QAVE   LIKE SY-TABIX.

  READ TABLE SELECT_FIELDS WITH KEY TABLENAME = 'QALS'
                                        INTO L_TABLE_QALS.
  MOVE SY-TABIX TO L_TABIX_QALS.

  IF G_REPID EQ 'RQEEAL10'.
    READ TABLE SELECT_FIELDS WITH KEY TABLENAME = 'QAVP'
                                          INTO L_TABLE_QAVE.
  ELSE.
    READ TABLE SELECT_FIELDS WITH KEY TABLENAME = 'QAVE'
                                          INTO L_TABLE_QAVE.
  ENDIF.

  MOVE SY-TABIX TO L_TABIX_QAVE.

* Zu selektierende Felder festlegen
*   nur Felder die angezeigt werden
  LOOP AT P_FIELDCAT_TAB INTO L_FIELDCAT
       WHERE NO_OUT EQ SPACE.
*   Auswerten der Felder
    IF    L_FIELDCAT-FIELDNAME EQ 'LIGHTS'
       OR L_FIELDCAT-FIELDNAME EQ 'VIEWED'
       OR L_FIELDCAT-FIELDNAME EQ 'STTXT'
       OR L_FIELDCAT-FIELDNAME EQ 'USTXT'
       OR L_FIELDCAT-FIELDNAME EQ 'VORNR'
       OR L_FIELDCAT-FIELDNAME EQ 'VORGLFNR'
       OR L_FIELDCAT-FIELDNAME EQ 'VORKTXT'
       OR L_FIELDCAT-FIELDNAME EQ 'PRPLATZ'
       OR L_FIELDCAT-FIELDNAME EQ 'PRPLATZWRK'
       OR L_FIELDCAT-FIELDNAME EQ 'PRPLATZTXT'.

* nichts zu tun.

* Felder der QAVP
    ELSEIF L_FIELDCAT-FIELDNAME EQ 'QKENNZAHL'
        OR L_FIELDCAT-FIELDNAME EQ 'VBEWERTUNG'
        OR L_FIELDCAT-FIELDNAME EQ 'KZART'
        OR L_FIELDCAT-FIELDNAME EQ 'VKATART'
        OR L_FIELDCAT-FIELDNAME EQ 'VAUSWAHLMG'
        OR L_FIELDCAT-FIELDNAME EQ 'VCODEGRP'
        OR L_FIELDCAT-FIELDNAME EQ 'VCODE'
        OR L_FIELDCAT-FIELDNAME EQ 'DBEWERTUNG'
        OR L_FIELDCAT-FIELDNAME EQ 'VAENAME'
        OR L_FIELDCAT-FIELDNAME EQ 'VNAME'
        OR L_FIELDCAT-FIELDNAME EQ 'VDATUM'
        OR L_FIELDCAT-FIELDNAME EQ 'VEZEITERF'
        OR L_FIELDCAT-FIELDNAME EQ 'VEZEITAEN'
        OR L_FIELDCAT-FIELDNAME EQ 'VFOLGEAKTI'
* IS2ERP
* CWM CWEK001511 OK 19.07.2004
* add additional fields for CWM
       OR L_FIELDCAT-FIELDNAME EQ '/CWM/LOSMENGE'
       OR L_FIELDCAT-FIELDNAME EQ '/CWM/MENGEINH2Q'
        OR L_FIELDCAT-FIELDNAME EQ 'VAEDATUM'.
* above fields are not contained in QALS- therefore they cannot be read.
*     indicator for UD
      MOVE G_X TO G_QAVE_FLAG.
*     Positioniert auf Tabellenzeile
      READ TABLE L_TABLE_QAVE-FIELDS
                 WITH KEY LINE = L_FIELDCAT-FIELDNAME
                 BINARY SEARCH TRANSPORTING NO FIELDS.
      IF NOT SY-SUBRC IS INITIAL.
*       Feld noch nicht in Tabelle
        INSERT L_FIELDCAT-FIELDNAME
               INTO L_TABLE_QAVE-FIELDS INDEX SY-TABIX.
      ENDIF.
*
    ELSE.
*     Positioniert auf Tabellenzeile
      READ TABLE L_TABLE_QALS-FIELDS
                 WITH KEY LINE = L_FIELDCAT-FIELDNAME
                 BINARY SEARCH TRANSPORTING NO FIELDS.
      IF NOT SY-SUBRC IS INITIAL.
*       Feld noch nicht in Tabelle
        INSERT L_FIELDCAT-FIELDNAME
              INTO L_TABLE_QALS-FIELDS INDEX SY-TABIX.
      ENDIF.
    ENDIF.
  ENDLOOP.
*
  MODIFY SELECT_FIELDS FROM L_TABLE_QAVE INDEX L_TABIX_QAVE.
  MODIFY SELECT_FIELDS FROM L_TABLE_QALS INDEX L_TABIX_QALS.
ENDFORM.                               " SELECT_FIELDS_MANIPULIEREN2_F16

*&---------------------------------------------------------------------*
*&      Form  SELECT_FIELDS_MANIPULIEREN_F16
*&---------------------------------------------------------------------*
*       Fields to be output are determined, and then read
*----------------------------------------------------------------------*
*       Used for structure QALS_D01                                    *
*----------------------------------------------------------------------*
FORM SELECT_FIELDS_MANIPULIEREN_F16   USING
                            P_FIELDCAT_TAB TYPE SLIS_T_FIELDCAT_ALV .
  DATA:    L_FIELDCAT     LIKE LINE OF G_FIELDCAT_TAB,
           L_TABLE_QALS   TYPE RSFS_TAB_FIELDS,
           L_TABIX_QALS   LIKE SY-TABIX.

  READ TABLE SELECT_FIELDS WITH KEY TABLENAME = 'QALS'
                                        INTO L_TABLE_QALS.
  MOVE SY-TABIX TO L_TABIX_QALS.
* Zu selektierende Felder festlegen
*   nur Felder die angezeigt werden
  LOOP AT P_FIELDCAT_TAB INTO L_FIELDCAT
       WHERE NO_OUT EQ SPACE.
*   Auswerten der Felder
    IF    L_FIELDCAT-FIELDNAME EQ 'LIGHTS'
       OR L_FIELDCAT-FIELDNAME EQ 'VIEWED'
       OR L_FIELDCAT-FIELDNAME EQ 'STTXT'
       OR L_FIELDCAT-FIELDNAME EQ 'USTXT'
       OR L_FIELDCAT-FIELDNAME EQ 'VBEWERTUNG'
       OR L_FIELDCAT-FIELDNAME EQ 'QKENNZAHL'
       OR L_FIELDCAT-FIELDNAME EQ 'KZART'
       OR L_FIELDCAT-FIELDNAME EQ 'VKATART'
       OR L_FIELDCAT-FIELDNAME EQ 'VAUSWAHLMG'
       OR L_FIELDCAT-FIELDNAME EQ 'VCODEGRP'
       OR L_FIELDCAT-FIELDNAME EQ 'VCODE'
       OR L_FIELDCAT-FIELDNAME EQ 'DBEWERTUNG'
       OR L_FIELDCAT-FIELDNAME EQ 'VFOLGEAKTI'
       OR L_FIELDCAT-FIELDNAME EQ 'VNAME'
       OR L_FIELDCAT-FIELDNAME EQ 'VDATUM'
       OR L_FIELDCAT-FIELDNAME EQ 'VEZEITERF'
       OR L_FIELDCAT-FIELDNAME EQ 'VAENAME'
       OR L_FIELDCAT-FIELDNAME EQ 'VAEDATUM'
* IS2ERP
* CWM CWEK001511 OK 12.07.2004
* add additional fields for CWM
       OR L_FIELDCAT-FIELDNAME EQ '/CWM/LOSMENGE'
       OR L_FIELDCAT-FIELDNAME EQ '/CWM/MENGEINH2Q'
       OR L_FIELDCAT-FIELDNAME EQ 'VEZEITAEN'.
* above fields are not contained in QALS- therefore they cannot be read.
    ELSE.

*     Positioniert auf Tabellenzeile
      READ TABLE L_TABLE_QALS-FIELDS
                 WITH KEY LINE = L_FIELDCAT-FIELDNAME
                 BINARY SEARCH TRANSPORTING NO FIELDS.
      IF NOT SY-SUBRC IS INITIAL.
*       Feld noch nicht in Tabelle
        INSERT L_FIELDCAT-FIELDNAME
              INTO L_TABLE_QALS-FIELDS INDEX SY-TABIX.
      ENDIF.
    ENDIF.
  ENDLOOP.
*
  MODIFY SELECT_FIELDS FROM L_TABLE_QALS INDEX L_TABIX_QALS.
ENDFORM.                               " SELECT_FIELDS_MANIPULIEREN_F16

*&---------------------------------------------------------------------*
*&      Form  FILL_LAYOUT_F16
*&---------------------------------------------------------------------*
*       defines how the list is going to look
*----------------------------------------------------------------------*
*       This form contains a traffic light icon in the list
*----------------------------------------------------------------------*
FORM FILL_LAYOUT_F16.
* G_LAYOUT-F2CODE               = 'PICK'.
  G_LAYOUT-BOX_FIELDNAME        = 'SELECTED'.  "field for checkbox
* Lights are only set if a criterion is selected.
  IF NOT MONITOR IS INITIAL.
    G_LAYOUT-LIGHTS_FIELDNAME     = 'LIGHTS'.  "field for lights
    G_LAYOUT-LIGHTS_ROLLNAME      = 'QVLOTSLIGHTS'.  "F1 help for lights
  ENDIF.
  G_LAYOUT-GET_SELINFOS         = G_X. "show selection screen criteria
  G_LAYOUT-DETAIL_POPUP         = G_X. "show detail via popup
  G_LAYOUT-GROUP_CHANGE_EDIT    = G_X. "allows data to be grouped
  G_LAYOUT-ZEBRA                = G_X. "striped pattern
*  G_LAYOUT-COLWIDTH_OPTIMIZE    = G_X. "optimize column width


ENDFORM.                               " FILL_LAYOUT_F16
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCAT_ACTUAL_F16
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_FIELDCAT_ACTUAL_F16.

  DATA: H_CHANGE LIKE SY-UCOMM.

  DATA H_FIELDCAT_TAB LIKE G_FIELDCAT_TAB.
  DATA H_FIELDCAT_WA1 TYPE SLIS_FIELDCAT_ALV.
  DATA H_FIELDCAT_WA2 TYPE SLIS_FIELDCAT_ALV.
  DATA H_INDEX LIKE SY-TABIX.

  H_FIELDCAT_TAB[] = G_FIELDCAT_TAB[].

  CLEAR H_CHANGE.
  GET PARAMETER ID 'Q_ALV_GRID_INACTIVE' FIELD G_GRID.
  IF G_GRID IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
      IMPORTING
        ET_FIELDCAT   = G_FIELDCAT_TAB[]
      EXCEPTIONS
        NO_INFOS      = 1
        PROGRAM_ERROR = 2
        OTHERS        = 3.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
      IMPORTING
        ET_FIELDCAT   = G_FIELDCAT_TAB[]
      EXCEPTIONS
        NO_INFOS      = 1
        PROGRAM_ERROR = 2
        OTHERS        = 3.
  ENDIF.

  IF SY-SUBRC IS INITIAL.
    SORT H_FIELDCAT_TAB BY FIELDNAME.
    SORT G_FIELDCAT_TAB BY NO_OUT ASCENDING.
    H_INDEX = 1.
    DO.
      READ TABLE G_FIELDCAT_TAB INTO H_FIELDCAT_WA1 INDEX H_INDEX.
      IF SY-SUBRC IS INITIAL AND H_FIELDCAT_WA1-NO_OUT = SPACE.
        READ TABLE H_FIELDCAT_TAB INTO H_FIELDCAT_WA2 WITH KEY
                     FIELDNAME = H_FIELDCAT_WA1-FIELDNAME BINARY SEARCH.
        IF H_FIELDCAT_WA1-NO_OUT <> H_FIELDCAT_WA2-NO_OUT.
          H_CHANGE = YES.
        ENDIF.
        H_INDEX = H_INDEX + 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
    IF H_CHANGE = YES.
*--- rebuild itab for dynamic select ----------------------------------
      PERFORM CREATE_G_SELFIELDS_TAB_F14.
    ENDIF.
  ENDIF.

ENDFORM.                               " GET_FIELDCAT_ACTUAL_F16

*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDGROUPS_F16
*&---------------------------------------------------------------------*
*       define fieldgroups
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_FIELDGROUPS_F16.

  DATA H_FIELDGROUPS TYPE SLIS_SP_GROUP_ALV.
  DATA H_FIELDCAT_WA TYPE SLIS_FIELDCAT_ALV.

  H_FIELDGROUPS-SP_GROUP = 'B'.        "Bewegungsdaten
  H_FIELDGROUPS-TEXT     = TEXT-GPB .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'K'.        "Kontierung
  H_FIELDGROUPS-TEXT     = TEXT-GPK .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'M'.        "Mengen
  H_FIELDGROUPS-TEXT     = TEXT-GPM .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'P'.        "Prüflos
  H_FIELDGROUPS-TEXT     = TEXT-GPP .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'Q'.        "Prüfplan
  H_FIELDGROUPS-TEXT     = TEXT-GPQ.
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'R'.        "Stammdaten
  H_FIELDGROUPS-TEXT     = TEXT-GPR .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'S'.        "Stichprobe
  H_FIELDGROUPS-TEXT     = TEXT-GPS .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'U'.        "Verwendungsentscheid
  H_FIELDGROUPS-TEXT     = TEXT-GPU .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'V'.        "Verwaltung
  H_FIELDGROUPS-TEXT     = TEXT-GPV .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  H_FIELDGROUPS-SP_GROUP = 'Z'.        "Zaehler
  H_FIELDGROUPS-TEXT     = TEXT-GPZ .
  APPEND H_FIELDGROUPS TO G_FIELDGROUPS_TAB.

  LOOP AT G_FIELDCAT_TAB INTO H_FIELDCAT_WA.
    CLEAR H_FIELDCAT_WA-SP_GROUP.
    CASE H_FIELDCAT_WA-FIELDNAME.

      WHEN 'AUFNR'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'VERID'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'SA_AUFNR'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'EBELN'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'EBELP'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'BLART'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'MJAHR'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'ZEILE'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'BUDAT'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'BWART'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'LS_KDAUF'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'LS_KDPOS'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'LS_VBELN'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'LS_POSNR'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'LS_ABRVW'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'LS_ROUTE'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'LS_LLAND'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'LS_KUNAG'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'LS_VKORG'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.
      WHEN 'LS_KDMAT'.
        H_FIELDCAT_WA-SP_GROUP = 'B'.

      WHEN 'STAT06'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'AUFNR_CO'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'KZVBR'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'KNTTP'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'KOSTL'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'AUFPS'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'ANLN1'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'ANLN2'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'PS_PSP_PNR'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'NPLNR'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'APLZL'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'KDAUF'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'KDPOS'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'PAOBJNR'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'PRCTR'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'GSBER'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'KONTO'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'KOKRS'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'BUKRS'.
        H_FIELDCAT_WA-SP_GROUP = 'K'.
      WHEN 'KONT_PSPNR'.
        h_fieldcat_wa-sp_group = 'K'.
      WHEN 'KONT_KDAUF'.
        h_fieldcat_wa-sp_group = 'K'.
      WHEN 'KONT_KDPOS'.
        h_fieldcat_wa-sp_group = 'K'.

      WHEN 'SOBKZ'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'WERKVORG'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LAGORTVORG'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LGNUM'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LGTYP'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LGPLA'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE01'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE02'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE03'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE04'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE05'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE06'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE07'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE08'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGE09'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'MATNRNEU'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'CHARGNEU'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'LMENGEZUB'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGELZ'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGEPR'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGEZER'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGEIST'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.
      WHEN 'LMENGESCH'.
        H_FIELDCAT_WA-SP_GROUP = 'M'.

      WHEN 'PRUEFLOS'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'WERK'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'ART'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'HERKUNFT'.
*      H_FIELDCAT_WA-TECH = G_X.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'HERKUNFT_TEXT'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'OBTYP'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STSMA'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'QMATAUTH'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STAT11'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'INSMK'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STAT09'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STAT19'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STAT23'.
*        H_FIELDCAT_WA-TECH = G_X.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STAT23_TEXT'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STAT24'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STAT25'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'DYNHEAD'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
*     H_FIELDCAT_WA-TECH = G_X.
      WHEN 'DYNHEAD_TEXT'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'STPRVER'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'SPRACHE'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'KTEXTLOS'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'KTEXTMAT'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'LOSMENGE'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'MENGENEINH'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'ANZGEB'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'GEBEH'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'SERNP'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'INSP_DOC_NUMBER'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.
      WHEN 'PRIO_PUNKTE'.
        H_FIELDCAT_WA-SP_GROUP = 'P'.

      WHEN 'PLNTY'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'PLNNR'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'PPLVERW'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'PLNAL'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'SLWBEZ'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'STAT13'.
*        H_FIELDCAT_WA-TECH = G_X.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'STAT13_TEXT'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'SELMATNR'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'SELREVLV'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'SELWERK'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'SELLIFNR'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'SELHERST'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'SELKUNNR'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'SELPPLVERW'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.
      WHEN 'GUELTIGAB'.
        H_FIELDCAT_WA-SP_GROUP = 'Q'.

      WHEN 'KUNNR'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'LIFNR'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'HERSTELLER'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.
      WHEN 'EMATNR'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.
      WHEN 'MATNR'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'REVLV'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.
      WHEN 'CHARG'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.
        H_FIELDCAT_WA-HOTSPOT  = G_X.
      WHEN 'LAGORTCHRG'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.
      WHEN 'EKORG'.
        H_FIELDCAT_WA-SP_GROUP = 'R'.

      WHEN 'GESSTICHPR'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'EINHPROBE'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'DYNREGEL'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'STAT44'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'PRSTUFE'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'PRSCHAERFE'.
*      H_FIELDCAT_WA-TECH = G_X.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'PRSCHAERFE_TEXT'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'STAT12'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'PRBNAVERF'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.
      WHEN 'PRBNAVV'.
        H_FIELDCAT_WA-SP_GROUP = 'S'.

      WHEN 'VBEWERTUNG'.
*     H_FIELDCAT_WA-TECH = G_X.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VBEWERTUNG_TEXT'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'QKENNZAHL'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'DBEWERTUNG'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VFOLGEAKTI'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VNAME'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VDATUM'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VEZEITERF'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VAENAME'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VAEDATUM'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VEZEITAEN'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'KZART'.
        H_FIELDCAT_WA-TECH = G_X.
      WHEN 'KZART_TEXT'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VKATART'.
*      H_FIELDCAT_WA-TECH = G_X.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VKATART_TEXT'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VAUSWAHLMG'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VCODEGRP'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.
      WHEN 'VCODE'.
        H_FIELDCAT_WA-SP_GROUP = 'U'.

      WHEN 'ENSTEHDAT'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'ENTSTEZEIT'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'ERSTELLER'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'ERSTELDAT'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'ERSTELZEIT'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'AENDERER'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'AENDERDAT'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'AENDERZEIT'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'PASTRTERM'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'PASTRZEIT'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'PAENDTERM'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.
      WHEN 'PAENDZEIT'.
        H_FIELDCAT_WA-SP_GROUP = 'V'.

      WHEN 'ZUSMKZAEHL'.
        H_FIELDCAT_WA-SP_GROUP = 'Z'.
      WHEN 'OFFENNLZMK'.
        H_FIELDCAT_WA-SP_GROUP = 'Z'.
      WHEN 'OFFEN_LZMK'.
        H_FIELDCAT_WA-SP_GROUP = 'Z'.
      WHEN 'ANTEIL'.
        H_FIELDCAT_WA-SP_GROUP = 'Z'.
      WHEN 'QPMATLOS'.
        H_FIELDCAT_WA-SP_GROUP = 'Z'.

* Fields that need not be displayed
      WHEN 'OBJNR'.
        H_FIELDCAT_WA-TECH = G_X.
      WHEN 'STAT05'.                   " Field has no name
        H_FIELDCAT_WA-TECH = G_X.
      WHEN 'STAT16'.                   " Field has no name
        H_FIELDCAT_WA-TECH = G_X.

* Additional fields to be displayed as hotspots
      WHEN 'MBLNR'.
        H_FIELDCAT_WA-HOTSPOT = G_X.

      WHEN OTHERS.

ENHANCEMENT-POINT RQALVF16_01 SPOTS ES_RQALVF16 INCLUDE BOUND.

    ENDCASE.
    MODIFY G_FIELDCAT_TAB FROM H_FIELDCAT_WA.
  ENDLOOP.
ENDFORM.                               " FILL_FIELDGROUPS_F16

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_F16
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_F16 USING  P_UCOMM TYPE SY-UCOMM
                             P_SELFIELD TYPE SLIS_SELFIELD.

* need to note column and row position for return to list
  P_SELFIELD-COL_STABLE = G_X.
  P_SELFIELD-ROW_STABLE = G_X.
  P_SELFIELD-REFRESH    = G_X.


  DATA: OBJECT_TAB_WA LIKE OBJECT_TAB,
        L_NO_ENTRY LIKE QM00-QKZ,

        L_FIELD(30).                   "TYPE SLIS_FIELDNAME.

  CASE P_UCOMM(4).      "All QM codes have 4 digits. Grid can have more.

    WHEN '&IC1'.
      CHECK P_SELFIELD-TABINDEX > 0.
* Here, if certain fields are double-clicked, different transactions
* are called, e.g. click on insp.lot, QA03 is called. Tables T354T/S.
      READ TABLE OBJECT_TAB INDEX P_SELFIELD-TABINDEX.
      MOVE-CORRESPONDING OBJECT_TAB TO QALS_QAVE.
      CONCATENATE 'QALS_QAVE-' P_SELFIELD-FIELDNAME INTO L_FIELD.
      CALL FUNCTION 'MASTER_DATA'
           EXPORTING
                DATENFELD       = L_FIELD
*               PROGRAM         = ' '
*               FIELDVALUE      = ' '
           IMPORTING
                ENTRY_NOT_FOUND = L_NO_ENTRY
           EXCEPTIONS
                ERROR_MESSAGE = 4.
      IF L_NO_ENTRY IS INITIAL
        AND SY-SUBRC IS INITIAL.
        CLEAR P_UCOMM.
        MOVE OBJECT_TAB TO OBJECT_TAB_WA.
        OBJECT_TAB_WA-VIEWED = SYM_CHECK_MARK.
        MODIFY OBJECT_TAB FROM OBJECT_TAB_WA INDEX P_SELFIELD-TABINDEX
        TRANSPORTING VIEWED.
*     ELSE.
*       MOVE '&ETA' TO P_UCOMM.
      ENDIF.

* need to get cursor position for return to list
    WHEN '&OLX'.                       "Select fields in variant
      PERFORM AKTUALISIEREN_F14.
    WHEN '&OAD'.                       "Select variant
      PERFORM AKTUALISIEREN_F14.
    WHEN '&OL0'.                       "Create variant
      PERFORM AKTUALISIEREN_F14.

    WHEN 'AKTU'.                       "Refresh
      PERFORM AKTUALISIEREN_F14.

    WHEN 'DOKU'.

      DATA: G_DOCU_NAME LIKE DOKHL-OBJECT,
            L_ID LIKE DOKHL-ID VALUE 'RE'.
      G_DOCU_NAME = SY-REPID.

      CALL FUNCTION 'DOCU_CALL'
        EXPORTING
          DISPL      = 'X'
          DISPL_MODE = '2'
          ID         = L_ID
          LANGU      = SY-LANGU
          OBJECT     = G_DOCU_NAME.

    WHEN 'GRAF'.
*--- aktuelle Feldkatalog aus Liste holen --------------------------
      PERFORM GET_FIELDCAT_ACTUAL_INFO_F14.
      PERFORM GRAPHICS_F16 USING P_SELFIELD.


    WHEN 'PLOS' OR 'QAMV' OR 'VEAZ' OR 'QMEL' OR 'PRLS' OR 'PRZG' OR
         'WORK' OR 'WRK2' OR 'QFER'.

      P_SELFIELD-REFRESH = G_S.        "rebuild list to set checkmark


*--- user has marked item(s) using checkbox
      LOOP AT OBJECT_TAB WHERE SELECTED = G_X.
        OBJECT_TAB-VIEWED = SYM_CHECK_MARK.
        MODIFY OBJECT_TAB.
        PERFORM EXECUTE_FCODE_F16 USING P_UCOMM.
      ENDLOOP.
*--- user has marked 1 item using cursor
      IF NOT SY-SUBRC IS INITIAL AND
         NOT P_SELFIELD-TABINDEX IS INITIAL.
        READ TABLE OBJECT_TAB INDEX P_SELFIELD-TABINDEX.
        MOVE OBJECT_TAB TO OBJECT_TAB_WA.
        OBJECT_TAB_WA-VIEWED = SYM_CHECK_MARK.
        MODIFY OBJECT_TAB FROM OBJECT_TAB_WA INDEX P_SELFIELD-TABINDEX
        TRANSPORTING VIEWED.
        PERFORM EXECUTE_FCODE_F16 USING P_UCOMM.
      ENDIF.
  ENDCASE.

ENDFORM.                               " USER_COMMAND_F16
*&---------------------------------------------------------------------*
*&      Form  EXECUTE_FCODE_F16
*&---------------------------------------------------------------------*
FORM EXECUTE_FCODE_F16 USING P_UCOMM TYPE SYUCOMM.
  DATA: L_VORNR          LIKE QAPO-VORNR,
        L_PLNFL          LIKE QAPO-PLNFL,
        L_PRUEFLOS       LIKE QALS-PRUEFLOS,
        BEGIN OF L_OLD,
          PRUEFLOS       LIKE QALS-PRUEFLOS,
          PLNFL          LIKE QAPO-PLNFL,
          VORNR          LIKE QAPO-VORNR,
        END OF L_OLD,
        L_CTU_PARAMS  LIKE CTU_PARAMS.
  DATA l_filter          TYPE bapiparam-parva.
  DATA lt_parameter      TYPE TABLE OF bapiparam.
  DATA ls_parameter      TYPE bapiparam.
  DATA lt_return         TYPE TABLE OF bapiret2.
  DATA l_username        TYPE BAPIBNAME-BAPIBNAME.

  CASE P_UCOMM.
*   Prüfbericht
    WHEN 'PRLS'.
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode = 'QGA3'.
      CALL FUNCTION 'QSS1_PRINT_INSPECTION_RESULTS'
        EXPORTING
          I_LOT_NUMBER = OBJECT_TAB-PRUEFLOS
          I_INSP_TYPE  = OBJECT_TAB-ART.
*  Zeugnis
    WHEN 'PRZG'.
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode = 'QC21'.
      SUBMIT RQCAAP01 VIA SELECTION-SCREEN AND RETURN
             WITH P_LOT EQ OBJECT_TAB-PRUEFLOS
             WITH P_DIALOG EQ G_X      "Mit Benutzerdialog
             WITH P_SUBMIT EQ G_X.     "Submit-Modus
*     Prüflos
    WHEN 'PLOS'.
      SET PARAMETER ID 'QLS' FIELD OBJECT_TAB-PRUEFLOS.
      IF G_AKTYP = 'V'.
        PERFORM CALL_TRANSACTION_F16 USING 'QA02'.
      ELSE.
        PERFORM CALL_TRANSACTION_F16 USING 'QA03'.
      ENDIF.

* VE in QVM1/2/3 or manual VE in QA16
    WHEN 'WORK' OR 'WRK2'.
      SET PARAMETER ID 'QLS' FIELD OBJECT_TAB-PRUEFLOS.
      IF OBJECT_TAB-KZ_QAVE IS INITIAL."kein VE getroffen.
        PERFORM CALL_TRANSACTION_F16 USING 'QA11'.
      ELSE.
        PERFORM CALL_TRANSACTION_F16 USING 'QA12'.
      ENDIF.

*     Verwendungsentscheid in QA32/33
    WHEN 'VEAZ'.
      SET PARAMETER ID 'QLS' FIELD OBJECT_TAB-PRUEFLOS.
      IF G_AKTYP = 'V'.
        IF OBJECT_TAB-KZ_QAVE IS INITIAL.        "kein VE getroffen.
          PERFORM CALL_TRANSACTION_F16 USING 'QA11'.
        ELSE.
          PERFORM CALL_TRANSACTION_F16 USING 'QA12'.
        ENDIF.
      ELSE.
        PERFORM CALL_TRANSACTION_F16 USING 'QA13'.
      ENDIF.

*   Ergebnisse
    WHEN 'QAMV'.
      IF OBJECT_TAB-OBTYP NE 'QL1'.
        MESSAGE I181(QE) WITH OBJECT_TAB-PRUEFLOS.
      ELSE.
        CALL FUNCTION 'QELA_INSPECTION_OPERATION_LIST'
          EXPORTING
            AUFPL            = OBJECT_TAB-AUFPL
            I_PLNTY          = OBJECT_TAB-PLNTY
            LOSNUMMER        = OBJECT_TAB-PRUEFLOS
          IMPORTING
            VORNR            = L_VORNR
            PLNFL            = L_PLNFL
          EXCEPTIONS
            NO_DATA_FOUND    = 01
            NO_DATA_SELECTED = 02.
        IF SY-SUBRC NE 0.
          MESSAGE I181(QE) WITH OBJECT_TAB-PRUEFLOS.
        ELSE.
*         Merkmalsfilter
          GET PARAMETER ID 'QMO' FIELD l_filter.
          MOVE sy-uname to l_username.
          CALL FUNCTION 'BAPI_USER_GET_DETAIL'
               EXPORTING
                    username  = l_username
               TABLES
                    parameter = lt_parameter
                    return    = lt_return.
          READ TABLE lt_parameter INTO ls_parameter
                                  with key parid = 'QMO'.
          MOVE object_tab-prueflos TO l_prueflos.
          WHILE L_PRUEFLOS NE L_OLD-PRUEFLOS
             OR L_PLNFL    NE L_OLD-PLNFL
             OR L_VORNR    NE L_OLD-VORNR
             AND NOT L_VORNR IS INITIAL.
            SET PARAMETER ID 'QMO' FIELD ls_parameter-parva.
            SET PARAMETER ID 'QLS' FIELD L_PRUEFLOS.
            SET PARAMETER ID 'QPF' FIELD L_PLNFL.
            SET PARAMETER ID 'QVO' FIELD L_VORNR.
            MOVE OBJECT_TAB-PRUEFLOS   TO L_OLD-PRUEFLOS.
            MOVE L_PLNFL               TO L_OLD-PLNFL.
            MOVE L_VORNR               TO L_OLD-VORNR.
            IF OBJECT_TAB-STAT07 NE SPACE.
*         Prüfpunkte
              SET PARAMETER ID 'QPN' FIELD SPACE.
              SET PARAMETER ID 'EQN' FIELD SPACE.
              SET PARAMETER ID 'IFL' FIELD SPACE.
              IF G_AKTYP = 'V'.
                PERFORM CALL_TRANSACTION_F16 USING 'QE11'.
              ELSE.
                PERFORM CALL_TRANSACTION_F16 USING 'QE13'.
              ENDIF.

            ELSEIF OBJECT_TAB-STAT02 NE SPACE.
*         Teillose
              SET PARAMETER ID 'QTL' FIELD SPACE.
              IF G_AKTYP = 'V'.
                PERFORM CALL_TRANSACTION_F16 USING 'QE14'.
              ELSE.
                PERFORM CALL_TRANSACTION_F16 USING 'QE16'.
              ENDIF.

            ELSE.
*         der Rest
              IF T370A-AKTYP = 'V'.
                PERFORM CALL_TRANSACTION_F16 USING 'QE01'.
              ELSE.
                PERFORM CALL_TRANSACTION_F16 USING 'QE03'.
              ENDIF.
            ENDIF.
            SET PARAMETER ID 'QRV' FIELD ' '.
            SET PARAMETER ID 'QRU' FIELD '00000000'.
            GET PARAMETER ID 'QPF' FIELD L_PLNFL.
            GET PARAMETER ID 'QVO' FIELD L_VORNR.
          ENDWHILE.
          SET PARAMETER ID 'QMO' FIELD l_filter.
        ENDIF.
      ENDIF.
*   Fehlererbearbeitung
    WHEN 'QMEL'.

      SET PARAMETER ID 'QLS' FIELD OBJECT_TAB-PRUEFLOS.

      IF G_AKTYP = 'V'.
*       Bereits Fehler vorhanden
        CALL FUNCTION 'STATUS_CHECK'
          EXPORTING
            OBJNR             = OBJECT_TAB-OBJNR
            STATUS            = 'I0214'
          EXCEPTIONS
            STATUS_NOT_ACTIVE = 01.
        IF SY-SUBRC IS INITIAL.
*         es gibt Fehler
          SET PARAMETER ID 'QFE' FIELD SPACE.
          PERFORM CALL_TRANSACTION_F16  USING 'QF02'  .
        ELSE.
*         Bericht ist leider nicht gefüllt
          CALL TRANSACTION 'QF01'.
        ENDIF.
      ELSE.
        PERFORM CALL_TRANSACTION_F16 USING 'QF03'  .
      ENDIF.
*   Fehlererfassung
    WHEN 'QFER'.

      SET PARAMETER ID 'QLS' FIELD OBJECT_TAB-PRUEFLOS.

      IF G_AKTYP = 'V'.
        CALL FUNCTION 'QAUT_CHECK_TCODE'
          EXPORTING
            I_TCODE = 'QF01'.
        CALL TRANSACTION 'QF01'  .
      ENDIF.


  ENDCASE.
ENDFORM.                               " EXECUTE_FCODE_F16

*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION_F16
*&---------------------------------------------------------------------*
*   Berechtigungsprüfung und Aufruf Transaktion mit SKIP FIRST SCREEN  *
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION_F16 USING P_TCODE TYPE SYTCODE.

  CALL FUNCTION 'QAUT_CHECK_TCODE'
    EXPORTING
      I_TCODE = P_TCODE.

  CALL TRANSACTION P_TCODE AND SKIP FIRST SCREEN.

ENDFORM.                               " CALL_TRANSACTION_F16
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS_F16       "called dynamically
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*

FORM SET_PF_STAT_F16 USING RT_EXTAB TYPE SLIS_T_EXTAB.

  IF SY-TCODE CP 'OQI*'.               " Customizing abklemmen.
    APPEND 'AUTO' TO RT_EXTAB.
    APPEND 'AUT2' TO RT_EXTAB.
    APPEND 'WRK2' TO RT_EXTAB.
    APPEND 'WORK' TO RT_EXTAB.
    APPEND 'PLOS' TO RT_EXTAB.
    APPEND 'VEAZ' TO RT_EXTAB.

    SET PF-STATUS 'MAIN' OF PROGRAM 'RQEVAM10' EXCLUDING RT_EXTAB.
    EXIT.
  ELSE.
    IF SY-TCODE <> 'SE38' AND SY-TCODE <> 'SA38'.
      SELECT SINGLE * FROM TSTCT WHERE SPRSL = SY-LANGU
                                 AND   TCODE = SY-TCODE.
    ELSE.
      TSTCT-TTEXT = SY-TITLE.
    ENDIF.

    CASE G_REPID.
      WHEN 'RQEVAM10' OR 'RQEVAM20' OR 'RQEVAM30'.
        APPEND 'AUTO' TO RT_EXTAB.
        APPEND 'AUT2' TO RT_EXTAB.
        APPEND 'WRK2' TO RT_EXTAB.

      WHEN 'RQEVAI10'.
        APPEND 'WORK' TO RT_EXTAB.

    ENDCASE.
    SET PF-STATUS 'MAIN' OF PROGRAM 'RQEVAM10' EXCLUDING RT_EXTAB.
  ENDIF.


ENDFORM.                               " SET_PF_STATUS_F16
*---------------------------------------------------------------------*
*       FORM GET_COLUMN_MARKED_L                                      *
*---------------------------------------------------------------------*
*       Feld zur markierten Spalte wird ermittelt                     *
*---------------------------------------------------------------------*
*  -->  F_SELFIELD                                                    *
*  -->  F_FIELDCAT_WA                                                 *
*---------------------------------------------------------------------*
FORM GET_COLUMN_MARKED_F16 USING
                           F_FIELDCAT_WA TYPE SLIS_FIELDCAT_ALV
                           F_FIELD       LIKE DFIES-FIELDNAME.
  DATA H_FIELDCAT_TAB TYPE SLIS_T_FIELDCAT_ALV.

  CLEAR F_FIELD.

  IF G_GRID IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
      IMPORTING
        ET_MARKED_COLUMNS = H_FIELDCAT_TAB[]
      EXCEPTIONS
        NO_INFOS          = 1
        PROGRAM_ERROR     = 2
        OTHERS            = 3.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
      IMPORTING
        ET_MARKED_COLUMNS = H_FIELDCAT_TAB[]
      EXCEPTIONS
        NO_INFOS          = 1
        PROGRAM_ERROR     = 2
        OTHERS            = 3.
  ENDIF.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*--- selection of one column supported only
  DESCRIBE TABLE H_FIELDCAT_TAB LINES SY-TABIX.
  IF SY-TABIX = 1.
    READ TABLE H_FIELDCAT_TAB INDEX 1 INTO F_FIELDCAT_WA.
    F_FIELD = F_FIELDCAT_WA-FIELDNAME.
  ELSE.
    MESSAGE I081(IH).
  ENDIF.
ENDFORM.                               "  GET_COLUMN_MARKED_F16

*---------------------------------------------------------------------*
*       FORM GRAPHICS_l                                               *
*---------------------------------------------------------------------*
*       Anzahl/Anteil pro Feld                                        *
*---------------------------------------------------------------------*
FORM GRAPHICS_F16 USING F_SELFIELD TYPE SLIS_SELFIELD.

  DATA: H_FILTERED_ENTRIES_TAB TYPE SLIS_T_FILTERED_ENTRIES.
  DATA H_INDEX                TYPE I.

  DATA: BEGIN OF H_STATISTICS OCCURS 0,
         FIELD(40),
         COUNT TYPE P,
       END OF H_STATISTICS,
       H_COUNT TYPE P,
       H_LINES LIKE SY-TABIX,

       BEGIN OF H_OBJECT_WA,
         FILLER(11) VALUE 'OBJECT_TAB-',
         FIELD(30),                    "Feld zur markierten Spalte
       END OF H_OBJECT_WA,

       H_FIELDCAT_WA TYPE SLIS_FIELDCAT_ALV.

  FIELD-SYMBOLS:
     <H_FIELD>.

  PERFORM GET_COLUMN_MARKED_F16 USING
                            H_FIELDCAT_WA
                            H_OBJECT_WA-FIELD.

  IF NOT H_OBJECT_WA-FIELD IS INITIAL.
    ASSIGN (H_OBJECT_WA) TO <H_FIELD>.
    REFRESH H_STATISTICS.
*--- Statistiktabelle wird aufgebaut --------------------------------
    LOOP AT OBJECT_TAB WHERE SELECTED = G_X.
      WRITE <H_FIELD> TO H_STATISTICS-FIELD.
      H_STATISTICS-COUNT = 1.
      COLLECT H_STATISTICS.
    ENDLOOP.
*--- keine Zeilen markiert -> es wird alles übernommen --------------
    IF NOT SY-SUBRC IS INITIAL.
*--- Filter aus Listviewer muß berücksichtigt werden --------------
      IF G_FILTER_TAB[] IS INITIAL.
        LOOP AT OBJECT_TAB.
          WRITE <H_FIELD> TO H_STATISTICS-FIELD.
          H_STATISTICS-COUNT = 1.
          COLLECT H_STATISTICS.
        ENDLOOP.
      ELSE.
*--- Filter lesen und abgleichen mit itab -------------------------

        LOOP AT OBJECT_TAB.
*--- in filter_entries_tab stehen alle indizes von ausgefilterten
*--- zeilen
          READ TABLE G_FILTERED_ENTRIES_TAB INTO H_INDEX
                                            WITH KEY SY-TABIX
                                                     BINARY SEARCH.
          CHECK NOT SY-SUBRC IS INITIAL.
          WRITE <H_FIELD> TO H_STATISTICS-FIELD.
          H_STATISTICS-COUNT = 1.
          COLLECT H_STATISTICS.
        ENDLOOP.
      ENDIF.
    ENDIF.

    SORT H_STATISTICS BY COUNT DESCENDING.
    DESCRIBE TABLE H_STATISTICS LINES H_LINES.
    IF H_LINES > 20.
      LOOP AT H_STATISTICS.
        IF SY-TABIX > 20.
          H_COUNT = H_STATISTICS-COUNT.
          DELETE H_STATISTICS.
          READ TABLE H_STATISTICS INDEX 20.
          H_STATISTICS-COUNT = H_STATISTICS-COUNT + H_COUNT.
          H_STATISTICS-FIELD = 'Sonstige'(SON).
          MODIFY H_STATISTICS INDEX 20.
        ENDIF.
      ENDLOOP.
    ENDIF.
    CALL FUNCTION 'GRAPH_2D'
      EXPORTING
        VALT       = 'Anzahl'(ANZ)
        MAIL_ALLOW = 'X'
        TITL       = H_FIELDCAT_WA-SELTEXT_M
      TABLES
        DATA       = H_STATISTICS.
  ENDIF.

ENDFORM.                               "  GRAPHICS_F16