import json,sys
S=json.load(open('scen.json'))
LBL={'1':'L-QM01','2':'L-QM02','3':'L-QM03','4':'L-QM04','6':'L-QM07/08','12':'ML-QM01','13':'ML-QM02','16':'AL-STRUKTUR','17':'AL-MIXED','18':'AL-VALUE1','19':'AL-VALUE2'}
def so(k,test):
    s=S[k]; k_=s['knvv']; items=[]
    for r in s['rolls']:
        for it in items:
            if it[0]==r['m']: it[1]+=r['q']; break
        else: items.append([r['m'],r['q']])
    L=[f"REPORT ZQA_SO{k}.",
"PARAMETERS: P_TEST TYPE C DEFAULT ' '.",
"DATA: LS_H TYPE BAPISDHD1, LS_HX TYPE BAPISDHD1X,",
"  LT_I TYPE TABLE OF BAPISDITM WITH HEADER LINE,",
"  LT_IX TYPE TABLE OF BAPISDITMX WITH HEADER LINE,",
"  LT_P TYPE TABLE OF BAPIPARNR WITH HEADER LINE,",
"  LT_S TYPE TABLE OF BAPISCHDL WITH HEADER LINE,",
"  LT_SX TYPE TABLE OF BAPISCHDLX WITH HEADER LINE,",
"  LT_R TYPE TABLE OF BAPIRET2 WITH HEADER LINE,",
"  LT_EX TYPE TABLE OF BAPIPAREX WITH HEADER LINE,",
"  LS_EV TYPE BAPE_VBAP, LS_EVX TYPE BAPE_VBAPX,",
"  LV_SO TYPE BAPIVBELN-VBELN, LV_E TYPE C.",
f"LS_H-DOC_TYPE = '{'ZEOR' if k_['WAERS']=='USD' else 'ZDOR'}'.",
"LS_H-SALES_ORG = '1000'.",
f"LS_H-DISTR_CHAN = '{'02' if k_['WAERS']=='USD' else '01'}'.",
"LS_H-DIVISION = '00'.",
f"LS_H-PURCH_NO_C = 'UAT COA {LBL[k]}'.",
"LS_H-REQ_DATE_H = SY-DATUM.",
f"LS_H-SALES_OFF = '{k_['VKBUR']}'.",
f"LS_H-PMNTTRMS = '{k_['ZTERM']}'.",
"LS_HX-UPDATEFLAG = 'I'. LS_HX-DOC_TYPE = 'X'.",
"LS_HX-SALES_ORG = 'X'. LS_HX-DISTR_CHAN = 'X'.",
"LS_HX-DIVISION = 'X'. LS_HX-PURCH_NO_C = 'X'.",
"LS_HX-REQ_DATE_H = 'X'. LS_HX-SALES_OFF = 'X'.",
"LS_HX-PMNTTRMS = 'X'.",
"DEFINE ITM.",
"  LT_I-ITM_NUMBER = &1. LT_I-MATERIAL = &2.",
"  LT_I-PLANT = '2000'. LT_I-TARGET_QTY = &3.",
"  LT_I-TARGET_QU = 'KG'. APPEND LT_I.",
"  LT_IX-ITM_NUMBER = &1. LT_IX-UPDATEFLAG = 'I'.",
"  LT_IX-MATERIAL = 'X'. LT_IX-PLANT = 'X'.",
"  LT_IX-TARGET_QTY = 'X'. LT_IX-TARGET_QU = 'X'.",
"  APPEND LT_IX.",
"  LT_S-ITM_NUMBER = &1. LT_S-SCHED_LINE = '0001'.",
"  LT_S-REQ_QTY = &3. LT_S-REQ_DATE = SY-DATUM.",
"  APPEND LT_S.",
"  LT_SX-ITM_NUMBER = &1. LT_SX-SCHED_LINE = '0001'.",
"  LT_SX-UPDATEFLAG = 'I'. LT_SX-REQ_QTY = 'X'.",
"  LT_SX-REQ_DATE = 'X'. APPEND LT_SX.",
"  CLEAR: LS_EV, LS_EVX, LT_EX. LS_EV-POSNR = &1.",
"  LS_EV-ZDATE = SY-DATUM. LS_EV-ZLINE = 'Z'.",
"  LT_EX-STRUCTURE = 'BAPE_VBAP'.",
"  LT_EX-VALUEPART1 = LS_EV. APPEND LT_EX.",
"  CLEAR LT_EX. LS_EVX-POSNR = &1.",
"  LS_EVX-ZDATE = 'X'. LS_EVX-ZLINE = 'X'.",
"  LT_EX-STRUCTURE = 'BAPE_VBAPX'.",
"  LT_EX-VALUEPART1 = LS_EVX. APPEND LT_EX.",
"END-OF-DEFINITION."]
    for i,(m,q) in enumerate(items,1): L.append(f"ITM '{i*10:06d}' '{m}' '{q:.3f}'.")
    L+=[f"LT_P-PARTN_ROLE = 'AG'. LT_P-PARTN_NUMB = '{s['c']}'.",
"APPEND LT_P.",
f"LT_P-PARTN_ROLE = 'WE'. LT_P-PARTN_NUMB = '{s['c']}'.",
"APPEND LT_P.",
"CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'",
"  EXPORTING ORDER_HEADER_IN = LS_H ORDER_HEADER_INX = LS_HX",
"            TESTRUN = P_TEST",
"  IMPORTING SALESDOCUMENT = LV_SO",
"  TABLES RETURN = LT_R ORDER_ITEMS_IN = LT_I",
"         ORDER_ITEMS_INX = LT_IX ORDER_PARTNERS = LT_P",
"         ORDER_SCHEDULES_IN = LT_S ORDER_SCHEDULES_INX = LT_SX",
"         EXTENSIONIN = LT_EX.",
"LOOP AT LT_R.",
"  WRITE: / LT_R-TYPE, LT_R-ID(8), LT_R-NUMBER, LT_R-MESSAGE(90).",
"  IF LT_R-TYPE CA 'EA'. LV_E = 'X'. ENDIF.",
"ENDLOOP.",
"IF P_TEST IS INITIAL AND LV_E IS INITIAL.",
"  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'",
"    EXPORTING WAIT = 'X'.",
"  WRITE: / 'COMMIT SO', LV_SO.",
"ELSE.",
"  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.",
"  WRITE: / 'NO COMMIT (test/error)', LV_SO.",
"ENDIF."]
    src='\n'.join(L).replace("PARAMETERS: P_TEST TYPE C DEFAULT ' '.",f"DATA P_TEST TYPE C VALUE '{'X' if test else ' '}'.")
    bad=[l for l in src.split('\n') if len(l)>72]
    assert not bad,bad
    open(f'gen/so{k}.abap','w').write(src)
for k in S: so(k,True)
