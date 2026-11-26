*eject
*---------------------------------------------------------------------*
*       FORM T180_INTERPRETIEREN                                      *
*---------------------------------------------------------------------*
*       Startwerte einlesen und Folgebildsteuerung daraus initiali-   *
*       sieren. Der Aufruf dieses Teiles der Initialisierung einer    *
*       Transaktion ist für alle VAnn (00 <= nn <= 43) zwingend er-   *
*       forderlich.                                                   *
*---------------------------------------------------------------------*
FORM T180_INTERPRETIEREN USING US_TCODE.

  DATA: DA_PARVW LIKE VBPA-PARVW.

* Nur bei Call Function kann der Tcode wechseln.
* Da in bestimmten Fällen bei CALL_FUNCTION = 'X' lediglich der TRTYP
* verändert wird (DP90), lies T180 in diesen Fällen immer wieder ein
  IF T180-TCODE = SPACE OR
     CALL_FUNCTION NE SPACE.
    SELECT SINGLE * FROM T180 WHERE TCODE = US_TCODE.
    IF SY-SUBRC NE 0.
      CLEAR T180.
      MESSAGE E145 WITH US_TCODE.
    ENDIF.
  ENDIF.

  CHECK CALL_FUNCTION = SPACE.

* Definition des Verarbeitungsortes
  T185-BLDGR  = T180-BLDGR.
  T185-PANEL  = T180-PANEL.

* Arbeitsgebiet und Aktivitaetsklassifizierung
  MODUL-POOL = T180-AGIDV.
  T185F-AGIDV = MODUL-POOL.

  T185F-TRTYP = T180-TRTYP.
  T185F-AKTYP = T180-AKTYP.
* CUA-Parameter fuer Action-Bar und Titel holen
* zusätzlich wird der Transaktionstyp übergeben --> im PAI muß nur
* noch die Routine FCODE_BERABEITEN gerufen werden (QVH 250391)
  CALL FUNCTION 'CUA_PARAMETER_READ'
       EXPORTING
            PROGRAMM   = T185F-AGIDV
            BILDGRUPPE = T185-BLDGR
            BILD       = T185-PANEL
            TYP        = T185F-TRTYP
       IMPORTING
            CUA_STATUS = T185V-STATUS
            CUA_TITEL  = T185V-CTITEL
            CUA_PARA1  = T185V-PARA1
            CUA_PARA2  = T185V-PARA2
            CUA_PARA3  = T185V-PARA3
            CUA_PARA4  = T185V-PARA4.

* CUA-Titel 2. Parameter setzen
  CASE T180-TRTYP.
    WHEN CHARA.
      RV45A-TXT_TITCUA = TEXT-007.
    WHEN CHARH.
      RV45A-TXT_TITCUA = TEXT-005.
    WHEN CHARV.
      RV45A-TXT_TITCUA = TEXT-006.
  ENDCASE.
  SET PARAMETER ID 'VTV' FIELD T180-TRVOG.
  WRITE 'AG' TO DA_PARVW.
  SET PARAMETER ID 'PAR' FIELD DA_PARVW.


ENDFORM.