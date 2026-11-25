ENHANCEMENT 1  .

*******************************************************
* Created by: PST_MONICA
* Created on: 31.08.2012
* Usage: Copy Field VBAK-KTEXT (Description)
*        dan VSNMR_V (Version) to Sales Header Text
*        khusus untuk PI (Quotation Export)
*******************************************************
DATA:
      ZAUART LIKE VBAK-AUART,
      ZKTEXT LIKE VBAK-KTEXT,
      ZVBELN LIKE VBAK-VBELN,
      IT_LINE TYPE TLINE OCCURS 0 WITH HEADER LINE,
      WA_LINE LIKE LINE OF IT_LINE,
      ZVSNMR LIKE VBAK-VSNMR_V,
      Z_VBELN LIKE THEAD-TDNAME,
      ZSTRING(132) .

ZAUART = XVBAK-AUART.

IF ZAUART EQ 'ZEQT'.

  ZKTEXT = VBAK-KTEXT.
  ZVBELN = XVBAK-VBELN.
  ZVSNMR = VBAK-VSNMR_V.

  Z_VBELN = ZVBELN.

  IF ZVSNMR NE ''.
    CONCATENATE ZKTEXT '(' ZVSNMR ')' INTO ZSTRING SEPARATED BY SPACE.
  ELSE.
    ZSTRING = ZKTEXT.
  ENDIF.

  CLEAR IT_LINE.
  REFRESH IT_LINE.

  WA_LINE-TDLINE = ZSTRING.
  APPEND WA_LINE TO IT_LINE.

  CALL FUNCTION 'CREATE_TEXT'
    EXPORTING
      FID               = 'Z101'
      FLANGUAGE         = SY-LANGU
      FNAME             = Z_VBELN
      FOBJECT           = 'VBBK'
      SAVE_DIRECT       = 'X'
      FFORMAT           = '*'
      TABLES
        FLINES          = IT_LINE
 EXCEPTIONS
   NO_INIT           = 1
   NO_SAVE           = 2
   OTHERS            = 3
          .


IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

ENDIF.

  DELETE FROM MEMORY ID 'ZBADI_ADD_TAB_SO'.
  SET PARAMETER ID 'ZDATE'  FIELD SPACE.
  SET PARAMETER ID 'ZLINE'  FIELD SPACE.
  SET PARAMETER ID 'ZGRUP'  FIELD SPACE.
  SET PARAMETER ID 'ZSBU'   FIELD SPACE.
  SET PARAMETER ID 'ZMATKL' FIELD SPACE.
  SET PARAMETER ID 'ZSO'    FIELD SPACE.
  SET PARAMETER ID 'ZITEM'  FIELD SPACE.

ENDENHANCEMENT.
