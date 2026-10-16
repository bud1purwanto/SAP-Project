REPORT ZTMP_MT_POOLRUN.
PARAMETERS: PV TYPE LIPS-VBELN DEFAULT '0085006278'.
TYPES: TY_L TYPE C LENGTH 255.
DATA: LT_P TYPE TABLE OF TY_L, LV_L TYPE TY_L,
      LT_I TYPE TABLE OF TY_L, LV_PROG TYPE PROGNAME,
      LV_MSG TYPE STRING, LV_LIN TYPE I, LV_WRD TYPE STRING.
DATA: LV_SB TYPE STRING.
DATA: BEGIN OF LS_C, N TYPE PROGNAME, T LIKE LT_I, END OF LS_C,
      LT_C LIKE TABLE OF LS_C.
FIELD-SYMBOLS: <C> LIKE LS_C.
DEFINE R.
  READ TABLE LT_C ASSIGNING <C> WITH KEY N = &1.
  IF SY-SUBRC <> 0.
    CLEAR LS_C. LS_C-N = &1. READ REPORT &1 INTO LS_C-T.
    APPEND LS_C TO LT_C. LV_LIN = LINES( LT_C ).
    READ TABLE LT_C ASSIGNING <C> INDEX LV_LIN.
  ENDIF.
  APPEND LINES OF <C>-T FROM &2 TO &3 TO LT_P.
END-OF-DEFINITION.
DEFINE A.
  APPEND &1 TO LT_P.
END-OF-DEFINITION.
DEFINE C.
  CONCATENATE LV_SB &1 INTO LV_SB RESPECTING BLANKS.
END-OF-DEFINITION.
START-OF-SELECTION.
A 'PROGRAM ZTMP_MT_POOL.'.
R 'ZQMI_COA_TOP' 1 180.
A 'DATA: TCERTI TYPE CXTAB_CONTROL,'.
A '      TDETAIL TYPE CXTAB_CONTROL.'.
R 'ZQMI_COA_TOP' 183 186.
A '*'.
A 'RANGES S_ERDAT FOR LIKP-ERDAT.'.
A 'RANGES P_WERKS FOR LIPS-WERKS.'.
A 'RANGES P_CHARG FOR LIPS-CHARG.'.
A 'RANGES P_ATWRT FOR AUSP-ATWRT.'.
A 'RANGES P_MATNR FOR LIPS-MATNR.'.
A 'RANGES P_VBELN FOR LIPS-VBELN.'.
A 'RANGES P_POSNR FOR LIPS-POSNR.'.
A '*'.
A '*'.
A 'DATA INFO(79).'.
R 'ZQMI_COA_TOP' 198 198.
A 'DATA GV_POPT(70).'.
A '*'.
CLEAR LV_SB.
C 'DATA P_XCUS TYPE C VALUE ''X''.'.
APPEND LV_SB TO LT_P.
A 'DATA GV_LCUS(25).'.
A '*'.
A 'DATA P_VCUS TYPE C LENGTH 60.'.
A '*'.
A '*'.
CLEAR LV_SB.
C 'DATA P_XPO TYPE C VALUE ''X''.'.
APPEND LV_SB TO LT_P.
A 'DATA GV_LPO(25).'.
A '*'.
A 'DATA P_VPO TYPE C LENGTH 60.'.
A '*'.
A '*'.
CLEAR LV_SB.
C 'DATA P_XPI TYPE C VALUE ''X''.'.
APPEND LV_SB TO LT_P.
A 'DATA GV_LPI(25).'.
A '*'.
A 'DATA P_VPI TYPE C LENGTH 60.'.
A '*'.
A '*'.
CLEAR LV_SB.
C 'DATA P_XPRD TYPE C VALUE ''X''.'.
APPEND LV_SB TO LT_P.
A 'DATA GV_LPRD(25).'.
A '*'.
A 'DATA P_VPRD TYPE C LENGTH 60.'.
A '*'.
A '*'.
CLEAR LV_SB.
C 'DATA P_XQTY TYPE C VALUE ''X''.'.
APPEND LV_SB TO LT_P.
A 'DATA GV_LQTY(25).'.
A '*'.
A 'DATA P_VQTY TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XCONT TYPE C.'.
A 'DATA GV_LCONT(25).'.
A '*'.
A 'DATA P_VCONT TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XDDAT TYPE C.'.
A 'DATA GV_LDDAT(25).'.
A '*'.
A 'DATA P_VDDAT TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XTHK TYPE C.'.
A 'DATA GV_LTHK(25).'.
A '*'.
A 'DATA P_VTHK TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XGRM TYPE C.'.
A 'DATA GV_LGRM(25).'.
A '*'.
A 'DATA P_VGRM TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XRAW TYPE C.'.
A 'DATA GV_LRAW(25).'.
A '*'.
A 'DATA P_VRAW TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XLC TYPE C.'.
A 'DATA GV_LLC(25).'.
A '*'.
A 'DATA P_VLC TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XWID TYPE C.'.
A 'DATA GV_LWID(25).'.
A '*'.
A 'DATA P_VWID TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XSHP TYPE C.'.
A 'DATA GV_LSHP(25).'.
A '*'.
A 'DATA P_VSHP TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XPRT TYPE C.'.
A 'DATA GV_LPRT(25).'.
A '*'.
A 'DATA P_VPRT TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XMFR TYPE C.'.
A 'DATA GV_LMFR(25).'.
A '*'.
A 'DATA P_VMFR TYPE C LENGTH 60.'.
A '*'.
A '*'.
A 'DATA P_XLIF TYPE C.'.
A 'DATA GV_LLIF(25).'.
A '*'.
A 'DATA P_VLIF TYPE C LENGTH 60.'.
A '*'.
A '*'.
R 'ZQMI_COA_TOP' 297 381.
R 'ZQMI_COA_F01' 1 3.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F01' 24 66.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F01' 166 2133.
A '*'.
R 'ZQMI_COA_F01' 2135 4622.
R 'ZQMI_COA_F02' 1 8.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 14 18.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 300 361.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 365 367.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 371 373.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 382 695.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 707 709.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 713 715.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 719 721.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 787 791.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 797 801.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
A '*'.
R 'ZQMI_COA_F02' 812 1118.
R 'ZQMI_COA_ALV' 1 401.
A 'FORM ZZ_MT_RUN USING PV TYPE LIPS-VBELN.'.
A '  DATA: LV_S TYPE STRING, LV_N TYPE STRING.'.
A '  FIELD-SYMBOLS: <V> TYPE ANY.'.
CLEAR LV_SB.
C '  CALL FUNCTION ''CONVERSION_EXIT_ATINN_I'.
C 'NPUT'''.
APPEND LV_SB TO LT_P.
CLEAR LV_SB.
C '    EXPORTING INPUT = ''ZZNOMORROLL'' IMPO'.
C 'RTING OUTPUT = ATINN_ROLL.'.
APPEND LV_SB TO LT_P.
CLEAR LV_SB.
C '  CALL FUNCTION ''CONVERSION_EXIT_ATINN_I'.
C 'NPUT'''.
APPEND LV_SB TO LT_P.
CLEAR LV_SB.
C '    EXPORTING INPUT = ''ZZCODE'' IMPORTING'.
C ' OUTPUT = ATINN_CODE.'.
APPEND LV_SB TO LT_P.
CLEAR LV_SB.
C '  CALL FUNCTION ''CONVERSION_EXIT_ATINN_I'.
C 'NPUT'''.
APPEND LV_SB TO LT_P.
CLEAR LV_SB.
C '    EXPORTING INPUT = ''ZZWIDTH'' IMPORTIN'.
C 'G OUTPUT = ATINN_WIDTH.'.
APPEND LV_SB TO LT_P.
CLEAR LV_SB.
C '  CALL FUNCTION ''CONVERSION_EXIT_ATINN_I'.
C 'NPUT'''.
APPEND LV_SB TO LT_P.
CLEAR LV_SB.
C '    EXPORTING INPUT = ''ZZLENGTH'' IMPORTI'.
C 'NG OUTPUT = ATINN_LENGTH.'.
APPEND LV_SB TO LT_P.
CLEAR LV_SB.
C '  P_VBELN-SIGN = ''I''. P_VBELN-OPTION = '''.
C 'EQ''. P_VBELN-LOW = PV.'.
APPEND LV_SB TO LT_P.
A '  APPEND P_VBELN.'.
A '  PERFORM GET_DATA.'.
A '  LOOP AT IT_DATA.'.
A '    CLEAR LV_S.'.
A '    DO 7 TIMES.'.
A '      CASE SY-INDEX.'.
A '        WHEN 1. ASSIGN IT_DATA-VBELN TO <V>.'.
A '        WHEN 2. ASSIGN IT_DATA-MATNR TO <V>.'.
A '        WHEN 3. ASSIGN IT_DATA-CHK TO <V>.'.
A '        WHEN 4. ASSIGN IT_DATA-NUM TO <V>.'.
A '        WHEN 5. ASSIGN IT_DATA-MIC TO <V>.'.
A '        WHEN 6. ASSIGN IT_DATA-CMICMIT TO <V>.'.
A '        WHEN 7. ASSIGN IT_DATA-INSLOT TO <V>.'.
A '      ENDCASE.'.
A '      LV_N = <V>. CONDENSE LV_N.'.
CLEAR LV_SB.
C '      CONCATENATE LV_S LV_N INTO LV_S SE'.
C 'PARATED BY ''|''.'.
APPEND LV_SB TO LT_P.
A '    ENDDO.'.
A '    WRITE: / LV_S.'.
A '  ENDLOOP.'.
A 'ENDFORM.'.
A ' '.
GENERATE SUBROUTINE POOL LT_P NAME LV_PROG MESSAGE LV_MSG
  LINE LV_LIN WORD LV_WRD.
IF SY-SUBRC <> 0.
  WRITE: / 'GENERR', SY-SUBRC, LV_LIN, LV_WRD.
  WRITE: / LV_MSG.
  READ TABLE LT_P INTO LV_L INDEX LV_LIN. WRITE: / LV_L(120).
  EXIT.
ENDIF.
PERFORM ZZ_MT_RUN IN PROGRAM (LV_PROG) USING PV.
