*----------------------------------------------------------------------*
***INCLUDE MV50AF0B_BELEG_LESEN_BUFFERED .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BELEG_LESEN_BUFFERED
*&---------------------------------------------------------------------*
FORM BELEG_LESEN_BUFFERED USING IF_VBELN LIKE LIKP-VBELN
                                IF_GET_DELIVERY_BUFFERED     TYPE XFELD
                                IF_NO_GENERIC_SYSTEM_SERVICE TYPE XFELD
                                IF_NICHT_SPERREN             TYPE XFELD.


  DATA: LT_DELIVERY_KEYS   TYPE LESHP_DELIVERY_KEY_T,
        LT_DELIVERIES      TYPE LESHP_DELIVERY_T,
        LS_DELIVERY_KEY    TYPE LESHP_DELIVERY_KEY,
        LF_SUBRC           TYPE SYSUBRC,
        LX_FCP_CONTROL     TYPE LESHP_FILL_COM_PART_CONTROL,
        LS_TO_BE_SELECTED  TYPE LESHP_DATA,
        LT_ORDER_UNLOCKABLE TYPE LESHP_ORDER_NOT_LOCKABLE_T,
        LS_ORDER_UNLOCKABLE TYPE LESHP_ORDER_NOT_LOCKABLE,
        LT_DELI_UNLOCKABLE TYPE LESHP_DELIVERY_KEY_T,         "AIP
        LS_DELI_UNLOCKABLE LIKE LINE OF LT_DELI_UNLOCKABLE,   "AIP
        LF_LOCK_DELIVERY   LIKE IF_NICHT_SPERREN,             "AIP
        LF_LOCK_PREDECES   LIKE IF_NICHT_SPERREN,             "AIP
        LF_MSGV1           LIKE SY-MSGV1,                     "AIP
        LT_DELI_UNLOCKABLE_CSL TYPE LESHP_DELIVERY_KEY_T,
        LF_CHANGE_OFF      LIKE V50AGL-DLV_CHANGE_OFF,
        LF_CHANGE_ASYNC    TYPE C,
        LF_LINES           TYPE I.
  DATA: I_DNACT  LIKE RDGDNACT,
        LF_MESSAGES_READ TYPE XFELD.                          "n_1159308

* Tabellen mit Fehlerhandling lesen
  DATA: BL_ERROR.
  DATA: DA_FCODE LIKE SY-TCODE.
  DATA: LF_WADAT_IST LIKE LIKP-WADAT_IST.
  DATA: LF_DEBUG_MODE(20).
  DATA: LF_GTS_DISPLAY_MODE TYPE BOOLEAN.

* EhP 3: Actual goods movement time
  DATA: LS_WADAT TYPE SHP_WADAT.

  BL_ERROR = CHARX.
* do some preparation
  LIKP-VBELN = IF_VBELN.

ENHANCEMENT-POINT beleg_lesen_buffered_01 SPOTS es_sapmv50a.
* setzen Parameter
  CASE T180-TRVOG.
    WHEN CHARD.
      SET PARAMETER ID 'VLM' FIELD LIKP-VBELN.
    WHEN CHARG.
      SET PARAMETER ID 'VLG' FIELD LIKP-VBELN.
  ENDCASE.

  LIKP-MANDT = SY-MANDT.

* Richtigen FCode setzen, wenn nach WABU ENT2 folgen soll
  IF SY-UCOMM EQ SPACE.
    FCODE = 'ENT2'.
    PERFORM TRANSFORM_FCODE CHANGING FCODE.
  ENDIF.

*----- begin of AIP

*-enqueue handling for delivery and predecessors

* old logic:
*   if_nicht_sperren: space - lock delivery and predecessor
*                     X     - lock only predecessor
*                     Y     - lock nothing
*   but: enqueue-handling depends also from other flags like
*        T180-TRTYP, kommirueckmeldung, v50agl-synchon ...
*
* new logic: we have two independend flags for the buffer call
*   lf_lock_delivery: space - don't lock delivery
*                     X     - lock the delivery
*   lf_lock_predeces: space - don't lock predecessor(s)
*                     X     - lock predecessor(s)

*-enqueue handling for delivery
  CLEAR LF_LOCK_DELIVERY.
  DO 1 TIMES.   "to copy the checks of Lieferung_Sperren (MV50AF0L)
    CHECK: T180-TRTYP NE CHARA,
           NOT IF_VBELN IS INITIAL.
    CHECK: IF_NICHT_SPERREN = SPACE.
    CHECK: FCODE(4) NE 'VL01',
           FCODE(4) NE 'VL03',
           FCODE(4) NE 'VL04',
           FCODE(4) NE 'VL06',
           FCODE(4) NE FCODE_ENDE.
    LF_LOCK_DELIVERY = CHARX.
  ENDDO.

*-enqueue handling for predecessor
  CLEAR LF_LOCK_PREDECES .
* if not ( v50agl-kommirueckmeldung = 'X' and v50agl-synchr..."n_1012854
  IF IF_NICHT_SPERREN <> CHARY.
    DO 1 TIMES.                      "fake for check-statement
      CHECK T180-TRTYP <> CHARA.
      LF_LOCK_PREDECES = CHARX.
    ENDDO.
*   endif.                                                    "n_1012854
  ENDIF.

*----- end of AIP

* fill interface
  CLEAR LX_FCP_CONTROL.
  LS_DELIVERY_KEY-VBELN = LIKP-VBELN.
  LS_TO_BE_SELECTED-ALL = CHARX.
  APPEND LS_DELIVERY_KEY TO LT_DELIVERY_KEYS.
  IF LIKP-VBELN IS INITIAL.
    LS_DELIVERY_KEY-VBELN = GC_IMPOSSIBLE.
    APPEND LS_DELIVERY_KEY TO LT_DELIVERY_KEYS.
  ENDIF.
* select all except xvbadr - this is done later on
  LX_FCP_CONTROL-TO_BE_SELECTED-ALL          = CHARX.
  LX_FCP_CONTROL-FILL_X_TABLES-ALL_SEGMENTS  = CHARX.
* lx_fcp_control-no_enqueue_via_buffer       = nicht_sperren. "AIP
  LX_FCP_CONTROL-ENQUEUE_DELIVERY            = LF_LOCK_DELIVERY."AIP
  LX_FCP_CONTROL-ENQUEUE_PREDECESSOR         = LF_LOCK_PREDECES."AIP
  CLEAR LX_FCP_CONTROL-INIT_COM_PART.  "this is done before

* invert buffer_flag - also not nice, but same logic as for enqueue
* the flag must set to Y (!!)
  IF IF_GET_DELIVERY_BUFFERED IS INITIAL.
    LX_FCP_CONTROL-BYPASSING_BUFFER = 'Y'. "no use and filling of buffer
  ELSE.
    LX_FCP_CONTROL-BYPASSING_BUFFER = SPACE.
  ENDIF.

* read delivery via buffer
  PERFORM FILL_COMMON_PART(SHP_CORE_FILL_COMMON_PART)
                           USING    LT_DELIVERY_KEYS
                                    LX_FCP_CONTROL
                                    LT_DELIVERIES
                           CHANGING LT_DELI_UNLOCKABLE      "AIP
                                    LT_DELI_UNLOCKABLE_CSL
                                    LT_ORDER_UNLOCKABLE
                                    LF_SUBRC.

  DESCRIBE TABLE LT_DELI_UNLOCKABLE_CSL LINES LF_LINES.
  IF LF_LINES > 0.
    V50AGL-DLV_CHANGE_OFF = 'X'.
  ENDIF.

*----- begin of AIP
* message for locked deliveries
* first attempt; actually we would need a correct message
* handling via buffer to get the correct message (user, reason)

  LOOP AT LT_ORDER_UNLOCKABLE INTO LS_ORDER_UNLOCKABLE.
    PERFORM MESSAGE_HANDLING(SAPMV50A) USING POSNR_LOW
                                             LS_ORDER_UNLOCKABLE-MSGNO
                                             'E'
                                             LS_ORDER_UNLOCKABLE-MSGID
                                             LS_ORDER_UNLOCKABLE-MSGV1
                                             LS_ORDER_UNLOCKABLE-MSGV2
                                             LS_ORDER_UNLOCKABLE-MSGV3
                                             LS_ORDER_UNLOCKABLE-MSGV4.

  ENDLOOP.


  LF_MSGV1 = SY-MSGV1.
  LOOP AT LT_DELI_UNLOCKABLE INTO LS_DELI_UNLOCKABLE.
    IF V50AGL-DLV_CHANGE IS INITIAL.
      PERFORM MESSAGE_HANDLING(SAPMV50A) USING POSNR_LOW
                                               '046'
                                               'E'
                                               'VL'
                                               LS_DELI_UNLOCKABLE-VBELN
                                               LF_MSGV1 "assume MC601
                                               SPACE
                                               SPACE.
    ELSE.
      PERFORM MESSAGE_HANDLING(SAPMV50A) USING POSNR_LOW
                                               SY-MSGNO
                                               SY-MSGTY
                                               SY-MSGID
                                               SY-MSGV1
                                               SY-MSGV2
                                               SY-MSGV3
                                               SY-MSGV4.
    ENDIF.
  ENDLOOP.
  IF NOT LT_DELIVERY_KEYS[] IS INITIAL AND
         LF_SUBRC EQ           CHAR1      . " does not exist ...
    READ TABLE LT_DELIVERY_KEYS INTO LS_DELIVERY_KEY INDEX 1.
    MESSAGE E302 WITH LS_DELIVERY_KEY-VBELN.
  ENDIF.



*  if lf_subrc > 0.
*    if lf_lock_delivery eq charx.
*      perform lieferung_sperren using likp-vbeln.
*    endif.
*    perform lieferung_entsperren using if_vbeln.
*    message e302 with likp-vbeln.
*  endif.
*----- end of AIP

* fill workarea of header tables
  READ TABLE XLIKP INDEX 1.
  XLIKP_UPDKZ = UPDKZ_OLD.
  MOVE-CORRESPONDING XLIKP TO LIKP.
  MOVE-CORRESPONDING XLIKP TO LIKPD.
   *LIKP  = LIKP.
   *LIKPD = LIKPD.
  YLIKP = XLIKP.
*  READ TABLE ylikp INDEX 1.
*  REFRESH ylikp. "like in beleg_lesen: fill only work area "wbr

* Move scenario flag to buffer                              "v_n_990782
  IF LIKP-SPE_LE_SCENARIO NE SPACE.
    CALL METHOD /SPE/CL_CTRL=>BUFFER_SCENARIO_FLAG
      EXPORTING
        I_LE_SCENARIO = LIKP-SPE_LE_SCENARIO.
  ENDIF.                                                    "^_n_990782

  SLIKP-TABIX = 1.

ENHANCEMENT-POINT beleg_lesen_buffered_02 SPOTS es_sapmv50a.
* Falls Aufruf aus dem Lieferungsmonitor: WADAT_IST aus Memory holen
  IF ( SY-TCODE = 'VL02N' OR SY-TCODE = 'VL32N' )
       AND SY-BINPT NE SPACE.
ENHANCEMENT-SECTION     EHP_BELEG_LESEN_BUFFERED_02 SPOTS ES_SAPMV50A.
    IMPORT WADAT_IST TO LF_WADAT_IST FROM MEMORY ID 'WS_LM'.
    IF NOT LF_WADAT_IST IS INITIAL.
      LIKP-WADAT_IST = LF_WADAT_IST.
      IF LIKP NE *LIKP.
        XLIKP = LIKP.
        APPEND YLIKP.
        XLIKP_UPDKZ = UPDKZ_UPDATE.
      ENDIF.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ENDIF.

* Zuliefererabwicklung: Korrekturlieferungen nicht änderbar
  IF LIKP-KLIEF = CHARX AND
     T180-TRTYP = CHARV.
    MESSAGE E136.
  ENDIF.

* Berechtigung prüfen
  IF LIKP-VBTYP NA VBTYP_MMLI.
    DATA: DA_ACTVT LIKE TACT-ACTVT,
          DA_SUBRC LIKE SY-SUBRC.
    IF FCODE(4) = 'DRCK' OR                                 "46A BEY
       FCODE(4) = 'PRNT'.
      DA_ACTVT = '04'.
    ELSE.
      DA_ACTVT = '  '.
    ENDIF.
    PERFORM BERECHTIGUNG_PRUEFEN USING DA_ACTVT DA_SUBRC.
    IF DA_SUBRC NE 0  AND DA_ACTVT = ACTVT_04.
      PERFORM LIEFERUNG_ENTSPERREN USING LIKP-VBELN.
      MESSAGE E087 WITH LIKP-VSTEL.
    ENDIF.
  ENDIF.

* Steuerungstabellen zum Belegkopf lesen.
  PERFORM TVLK_SELECT USING LIKP-LFART
                              BL_ERROR
                              SY-SUBRC.

* prüfen auf gültige Kombination
* Auslieferungen dürfen nur mit tcode VL01-VL03 bearbeitet werden,
* Anlieferungen nur mit tcode Vl31-VL33 und Grob-WE mit tcode VL41-VL43
  IF LIKP-VBTYP CA VBTYP_LIAV AND T180-TRVOG NE CHARD OR
     LIKP-VBTYP CA VBTYP_GRWE AND T180-TRVOG NE CHARG OR
     LIKP-VBTYP CA VBTYP_LIEF AND T180-TRVOG NE CHAR6.
    MESSAGE E143.
  ENDIF.

* betroffene Versandstelle lesen
  IF LIKP-VBTYP NA VBTYP_MMLI.
    PERFORM TVST_SELECT USING LIKP-VSTEL
                              BL_ERROR
                              SY-SUBRC.
  ENDIF.


* Partner Lieferungskopf lesen
*  PERFORM vbpa_select USING likp-mandt
*                            likp-vbeln.

* Warenempfänger lesen      (jedoch nur den Namen versorgen)
* xvbadr is filled before, but do this anyway because of KUWEV "wbr 46c
  IF LIKP-VBTYP NA VBTYP_MMLI.
    PERFORM WARENEMPFAENGER_BEREITSTELLEN.
  ELSE.
    PERFORM LIEFERAVIS_EATAB_FUELLEN.
  ENDIF.


ENHANCEMENT-POINT es_mv50af0b_01 SPOTS es_sapmv50a.

  ILIPS_TABIX_ZEILE_1 = 1.

* Verkaufsorganisation lesen
  IF LIKP-VBTYP NA VBTYP_MMLI.
    PERFORM TVKO_SELECT USING LIKP-VKORG
                              SPACE
                              SY-SUBRC.
  ENDIF.

* fill workarea of header status
  READ TABLE XVBUK INDEX 1.
  VBUK  = XVBUK.
  CVBUK = XVBUK.

* fill workarea of item status
  READ TABLE XVBUP INDEX 1.
* hopefully nobody is working with cvbup

* create compressed flow information
  CALL FUNCTION 'RV_XVBAPF_CREATE'
    EXPORTING
      VBELN   = IF_VBELN
    TABLES
      FXVBFA  = XVBFA
      FXVBAPF = XVBAPF.

  SORT XVBAPF BY VBELN POSNR.


* Delivery item(s)
  LIEFERUNG_OR = CHARX.

* Buffered lock and read for the predecessors
* already done in 'fill_common_part'   (4.70)
* perform lock_and_fill_buffer(sapmv50a).

  LOOP AT XLIPS.
    LIPS = XLIPS.
    CLEAR LIPSD.
    MOVE-CORRESPONDING LIPSD TO XLIPS.
ENHANCEMENT-POINT beleg_lesen_buffered_04 SPOTS es_sapmv50a.
    PERFORM LIPS_X_AUFBAUEN USING SY-TABIX.
    IF XLIPS-VGBEL NE SPACE.
      LIEFERUNG_OR = SPACE.
    ENDIF.
  ENDLOOP.
ENHANCEMENT-SECTION     mv50af0b_beleg_lesen_01 SPOTS es_sapmv50a.
* fill workarea
  READ TABLE XLIPS INDEX 1.
END-ENHANCEMENT-SECTION.

  IF SY-SUBRC EQ 0.
    RV50A-VTWEG = XLIPS-VTWEG.
    RV50A-SPART = XLIPS-SPART.
  ENDIF.
  ILIPS_TABIX_ZEILE_1 = 1.

* Verkaufsorganisation wegen Sprache lesen
  IF LIKP-VBTYP NA VBTYP_MMLI.
    PERFORM TVKO_SELECT USING LIKP-VKORG
                              SPACE
                              SY-SUBRC.

* TVTA fuer Materialzugriffe lesen
    IF NOT RV50A-VTWEG IS INITIAL AND
       NOT RV50A-SPART IS INITIAL.
      PERFORM TVTA_SELECT USING LIKP-VKORG
                                RV50A-VTWEG
                                RV50A-SPART.
    ENDIF.
  ENDIF.

* Konditionen einlesen im Änderungsmodus, falls Kalkulationsschema da
  IF T180-TRTYP = CHARV AND NOT LIKP-KALSP IS INITIAL.      "50A
    PERFORM KONV_SELECT.
  ENDIF.

* Read all messages inbound and outbound
* Performance: Messages for outbound deliveries only
* if no_messages update is set
  IF (     LIKP-VBTYP         CA VBTYP_LIEF
       AND NO_MESSAGES_UPDATE IS INITIAL )
  OR ( LIKP-VBTYP CA VBTYP_LIAV )
  OR ( LIKP-VBTYP CA VBTYP_GRWE ).
*   Nachrichten lesen (V2 und V4)
    DATA: XOBJKY_TO LIKE NAST-OBJKY.
*   Fuellen Key fuer Nachrichtenstatus
    MOVE LIKP-VBELN TO XOBJKY.
    MOVE LIKP-VBELN TO XOBJKY_TO.
    MOVE '9999999999'   TO XOBJKY_TO+10.
*   Messages are read in VL60/BORGR earlier                 "v_n_1157949
    CALL METHOD /SPE/CL_INB_ACTION_INFO=>GET_MESSAGES_READ_INDICATOR
      IMPORTING
        E_MESSAGES_READ  = LF_MESSAGES_READ.
*   Do not read messages again (manually messages could be overwritten)
    IF LF_MESSAGES_READ <> 'X' OR
       V50AGL-NO_MESSAGE_READ IS INITIAL.                     "n_1159308
*     Messages must be read once, if not earlier done
      CALL FUNCTION 'RV_MESSAGES_READ'
        EXPORTING
          MSG_KAPPL    = TVLK-KAPPL
          MSG_OBJKY    = XOBJKY
          MSG_OBJKY_TO = XOBJKY_TO.
    ENDIF.                                                  "^_n_1157949
  ENDIF.

* Messages read for application V4 (only outbound)
  IF (     LIKP-VBTYP         CA VBTYP_LIEF
       AND NO_MESSAGES_UPDATE IS INITIAL ).
    CALL FUNCTION 'RV_MESSAGES_READ'
      EXPORTING
        MSG_KAPPL    = 'V4'
        MSG_OBJKY    = XOBJKY
        MSG_OBJKY_TO = XOBJKY_TO.
  ENDIF.

* Füllt Workarea KOMKBV2 für Nachrichtenfindung V2
* Outbound delivery
  IF (     LIKP-VBTYP         CA VBTYP_LIEF
       AND NO_MESSAGES_UPDATE IS INITIAL ).
    CALL FUNCTION 'COMMUNICATION_AREA_KOMKBV2'
      EXPORTING
        MSG_LIKP  = LIKP
        MSG_OLD   = 'X'
        MSG_RV50A = RV50A
        MSG_VBUK  = VBUK
        MSG_TRTYP = T180-TRTYP
      TABLES
        TAB_PART  = PART
        TAB_LIPS  = XLIPS
        TAB_VBPA  = XVBPA.
  ENDIF.

* Fill workarea: inbound delivery
  IF LIKP-VBTYP CA VBTYP_LIAV.
    CALL FUNCTION 'COMMUNICATION_AREA_KOMKBE1'
      EXPORTING
        MSG_LIKP  = LIKP
        MSG_OLD   = 'X'
        MSG_RV50A = RV50A
        MSG_VBUK  = VBUK
        MSG_TRTYP = T180-TRTYP
      TABLES
        TAB_PART  = PART
        TAB_LIPS  = XLIPS
        TAB_VBPA  = XVBPA.
  ENDIF.

* Fill workarea: rough goods receipt
  IF LIKP-VBTYP CA VBTYP_GRWE.
    CALL FUNCTION 'COMMUNICATION_AREA_KOMKBM1'
      EXPORTING
        MSG_LIKP  = LIKP
        MSG_OLD   = 'X'
        MSG_RV50A = RV50A
        MSG_VBUK  = VBUK
        MSG_TRTYP = T180-TRTYP
      TABLES
        TAB_PART  = PART
        TAB_LIPS  = XLIPS
        TAB_VBPA  = XVBPA.
  ENDIF.

* Aufbau einer Hilfstabelle für Serialnummern in Verbindung mit
* Chargen
  REFRESH XLIPS_SER.
  LOOP AT XLIPS.
    XLIPS_SER-POSNR = XLIPS-POSNR.
    XLIPS_SER-UECHA = XLIPS-UECHA.
    XLIPS_SER-ANZSN = XLIPS-ANZSN.
    APPEND XLIPS_SER.
  ENDLOOP.
  SORT XLIPS_SER BY POSNR.

* Gefahrgutzusatzdaten lesen
  PERFORM GG_LIPSDG_READ USING XLIPS-VBELN.

* Dangerous goods: Template-Material processing
* Check if templatematerial processing should be processed
  MOVE-CORRESPONDING LIKP TO I_DNACT.
  CALL FUNCTION 'EHS003_CHECK_TPPR_ACTIVE'
    EXPORTING
      I_DNACT     = I_DNACT
      I_VBTYP     = LIKP-VBTYP
    EXCEPTIONS
      TPPR_ACTIVE = 1
      OTHERS      = 2.

  IF SY-SUBRC = 1.
* EH&S functionality is active
    V50AGL-TPPR_ACTIVE = CHARX.
    CALL FUNCTION 'EHS003_DGMSD_DLV_READ'
      EXPORTING
        I_LIKP_TAB = LIKP
      EXCEPTIONS
        OTHERS_    = 1.
  ENDIF.

* Generic system service activation necessary for dialog processing
* only. Call moved to UEBERSICHT_ANSTEUERN (FV50PF0U) n_533596

  IF ( XLIKP-VLSTK = 'B' AND
       XLIKP-VERURSYS EQ SPACE AND
       T180-TRTYP EQ CHARV )
     OR
     ( XLIKP-VLSTK = 'A' AND
       XLIKP-VERURSYS NE SPACE AND
       T180-TRTYP EQ CHARV ).
* check for change management configuration
    CALL FUNCTION 'SHP_CHANGE_ACTIVE'
      EXPORTING
        IF_VBTYP         = XLIKP-VBTYP
        IF_LGNUM         = XLIKP-LGNUM
        IF_LOGSYS        = XLIKP-VERURSYS
      IMPORTING
        EF_ACTIVE        = V50AGL-DLV_CHANGE
        EF_ACTIVE_ASYNC  = LF_CHANGE_ASYNC
        EF_EMERGENCY_OFF = LF_CHANGE_OFF.
*   Do not overwrite CHANGE_OFF flag if set earlier by CSL call
    IF LF_CHANGE_OFF NE SPACE.
      V50AGL-DLV_CHANGE_OFF = LF_CHANGE_OFF.
    ENDIF.
  ENDIF.

* Prüfen,ob Gefahrgutprüfung aktiv ist. Kennzeichen in V50AGL übernehmen
  PERFORM GG_CHECK_ACTIVE_SIMPLE CHANGING V50AGL-GEFAHRGUT_AKTIV.
  IF V50AGL-GEFAHRGUT_AKTIV = GC_GG_INAKTIV.
    PERFORM CUA_FCODE_ALLOW USING FCODE_GEFAHRGUTPRUEFUNG NO.
  ENDIF.

* Fill cross-docking process number if available
  CALL METHOD /SPE/CL_CD_DOCFLOW=>GET_PROCESS_NUMBER
    EXPORTING
      IF_DELIVERY   = LIKP-VBELN
    RECEIVING
      EF_CD_PROCESS = LIKPD-SPE_CD_PROCESS.

  MOVE-CORRESPONDING LIKP TO XLIKP.
  MOVE-CORRESPONDING LIKPD TO XLIKP.
  MOVE-CORRESPONDING VBUK TO XVBUK.

  MODIFY XLIKP INDEX 1.                                     "n_792288

ENHANCEMENT-POINT beleg_lesen_buffered_03 SPOTS es_sapmv50a.
*----- begin of AIP

* Bei Auslieferungen nochmal Warenempfänger lesen, wegen Werksfindung
  IF LIKP-VBTYP CN VBTYP_MMLI.
    PERFORM WARENEMPFAENGER_BEREITSTELLEN.
  ENDIF.

* GTS: Determine whether the delivery is changeable
  IF NOT LIKP-SAKES IS INITIAL.
    PERFORM SAFE_KEEPING_MODE_DET CHANGING LF_GTS_DISPLAY_MODE.
  ENDIF.
* Switch to display mode in certain situations
  IF T180-TRTYP NE CHARA AND
     ( ( LIKP-VLSTK EQ CHARB AND
         VBUK_KREDIT_NEUAUFBAU  NE CHARX   AND                "n_1179751
         V50AGL-CONFIRM_CENTRAL IS INITIAL AND
         LF_CHANGE_ASYNC        IS INITIAL AND
         ( V50AGL-DLV_CHANGE IS INITIAL OR
           NOT V50AGL-DLV_CHANGE_OFF IS INITIAL )
        ) OR
       ( LIKP-VLSTK CA 'EF' AND
         VBUK_KREDIT_NEUAUFBAU NE CHARX AND                   "n_1179751
         LIKP-VERURSYS IS INITIAL AND
         V50AGL-CONFIRM_CENTRAL IS INITIAL ) OR
       ( VBUK-BESTK EQ CHARA )               OR
*        GTS: not changeable if under safe keeping
       ( LIKP-SAKES          EQ CHARB AND
         LF_GTS_DISPLAY_MODE EQ CHARX )
     ).
* SPE MP 24.02.2005 SPE returns can only be changed with reservations
    DATA: LF_DISPLAY_MODE TYPE C.
    LF_DISPLAY_MODE = CHARX.
  ENDIF.
  IF LF_DISPLAY_MODE EQ SPACE AND
     T180-TRTYP NE CHARA      AND
     V50AGL-DIALOG NE SPACE   AND
     LIKP-VBTYP EQ VBTYP_LIRE AND
     ( LIKP-SPE_LE_SCENARIO EQ GC_LE_SCENARIO-RETURN OR
     LIKP-SPE_LE_SCENARIO EQ GC_LE_SCENARIO-TPOP ).
    MESSAGE S105(/SPE/RET) DISPLAY LIKE 'W'.
  ENDIF.
  IF LF_DISPLAY_MODE NE SPACE.
* end SPE MP

*   Dataloss flag not necessary in display mode.
    CLEAR R185D-DATALOSS.
*   Set new internal transaction code
    IF t180-tcode = 'VL32N'.                                "v_n_1374189
      PERFORM t180_interpretieren USING 'VL33N'.
    ELSEIF T180-TCODE = 'VL02N'.
      PERFORM t180_interpretieren USING 'VL03N'.
    ELSEIF T180-TCODE = 'VL02'.
      PERFORM t180_interpretieren USING 'VL03'.
    ELSEIF T180-TCODE = 'VLPOD'.
      PERFORM t180_interpretieren USING 'VLPODA'.
    ENDIF.
    CALL FUNCTION 'DEQUEUE_ALL'.
    REFRESH cua_exclude.                                    "^_n_1374189
    PERFORM EXCLUDE_FUNCTION_TRTYP.
    PERFORM CUA_FCODE_ALLOW USING 'ANZA_T' NO.
    IF LIKP-VLSTK EQ CHARB.
      IF V50AGL-DLV_CHANGE_OFF IS INITIAL.
        MESSAGE S239(VL).
      ELSE.
        MESSAGE S579(VL).
      ENDIF.
    ELSEIF LIKP-VLSTK EQ CHARE.
      MESSAGE S477(VL).
    ELSEIF LIKP-VLSTK EQ CHARF.
      MESSAGE S481(VL).
    ELSEIF VBUK-BESTK EQ CHARA.
      MESSAGE S357(VL).                                   "aip retro
    ELSEIF LIKP-SAKES EQ CHARB.             "GTS Safe Keeping Status
      MESSAGE S594(VL).
    ENDIF.
  ENDIF.

  IF LIKP-VLSTK EQ CHARC AND                                "v_n_892160
     NOT V50AGL-CONFIRM_CENTRAL IS INITIAL.
    IF /SPE/CL_CTRL=>GET_WHNR_TYP( I_LGNUM = LIKP-LGNUM )
         EQ /SPE/CL_CTRL=>C_WHNR_WMS.
      MESSAGE E598(VL).
    ENDIF.
  ENDIF.                                                    "^_n_892160

* Hinweis bzw. Aenderungseinschraenkung abh. von Status in Transport
  IF T180-TRTYP NE CHARA.              "Nicht beim Anzeigen
    IF AUFRUFER NE CHART.
      CALL FUNCTION 'SD_DELIVERY_SHIPMENT_STATUS'
        EXPORTING
          I_LIKP                = XLIKP
          I_VBUK                = XVBUK
        TABLES
          I_VBFA                = XVBFA
        EXCEPTIONS
          SHIPMENT_STATUS_INFO  = 1
          DELIVERY_CHANGE_BLOCK = 2
          SHIPPING_UNIT_FREIGHT = 3.
      IF SY-SUBRC NE 0.
*       653424: Delivery data must not be edit, if the inbound shipment
*       is completed or the shipment costs are settled. The correction
*       of note 518736 (4.6C) has to be called off. Instead of it, the
*       modification note 653425 is made, explaining all the risks for
*       the succeeding document to become inconsistent by changes of the
*       delivery data during Goods Receipt.
        IF ( SY-SUBRC EQ 2 OR SY-SUBRC EQ 3 ).
*       line deleted                                         n_1361227
*          likp-vbtyp na vbtyp_liav.   "518736 called off by n_653424
          STATUS_TRANSPORT = SY-SUBRC.
        ENDIF.
        IF GS_MHPAR-GLOMD EQ GC_GLOMD-DIALOG.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*----- end of AIP
ENHANCEMENT-POINT mv50af0b_beleg_lesen_02 SPOTS es_sapmv50a STATIC .

ENHANCEMENT-POINT mv50af0b_beleg_lesen_03 SPOTS es_sapmv50a.

  IF STATUS_TRANSPORT NE 0.
    DO 99 TIMES VARYING DA_FCODE FROM CUA_EXCLU_TRANSPORT-F01
                                 NEXT CUA_EXCLU_TRANSPORT-F02.
      IF DA_FCODE(4) = '9999'.
        EXIT.
      ENDIF.
      PERFORM CUA_FCODE_ALLOW USING DA_FCODE NO.
    ENDDO.
  ENDIF.

* Tabelle TVPOD einlesen
  IF ( NOT VBUK-PDSTK IS INITIAL OR
     NOT XVBUK-PDSTK IS INITIAL ).
    PERFORM POD_TVPOD_READ.
  ENDIF.

* In case of posting goods issue of an outbound delivery which was
* splitted, lock original delivery  (ULa, 4.6c)
  IF        FCODE(4)        =  'WABU'
    AND     LIKP-VBTYP      CA VBTYP_LIEF
    AND NOT TVSHP-SPLITLOCK IS INITIAL.
    PERFORM DSP_VBELN_OLD_LOCK USING LIKP-VBELN.
  ENDIF.

  PERFORM CALL_BADI_READ_DELIVERY.

* Userexit
  PERFORM USEREXIT_READ_DOCUMENT.

ENDFORM.                               " BELEG_LESEN_BUFFERED