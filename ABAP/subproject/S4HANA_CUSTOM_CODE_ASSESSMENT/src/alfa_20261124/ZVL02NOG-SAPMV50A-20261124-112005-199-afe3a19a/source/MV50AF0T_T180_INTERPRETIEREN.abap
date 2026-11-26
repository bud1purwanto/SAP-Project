*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T180_INTERPRETIEREN                               *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T180_INTERPRETIEREN                                      *
*---------------------------------------------------------------------*
*       Startwerte einlesen und Folgebildsteuerung daraus initiali-   *
*       sieren. Der Aufruf dieses Teiles der Initialisierung einer    *
*       Transaktion ist für alle VAnn (00 <= nn <= 43) zwingend er-   *
*       forderlich.                                                   *
*---------------------------------------------------------------------*
FORM t180_interpretieren USING value(us_tcode) LIKE sy-tcode.

  IF us_tcode = ' '.
    us_tcode = tc_vl02.
  ENDIF.
  SELECT SINGLE * FROM t180 WHERE tcode = us_tcode.
  IF sy-subrc NE 0.
    MESSAGE e015 WITH us_tcode.
  ENDIF.
* Definition des Verarbeitungsortes
  t185-bldgr  = t180-bldgr.
  t185-panel  = t180-panel.
* Arbeitsgebiet und Aktivitaetsklassifizierung
  t185f-agidv = t180-agidv.
  modul-pool+3(5) = t180-agidv.
  t185f-trtyp = t180-trtyp.
  t185f-aktyp = t180-aktyp.
* CUA-Parameter fuer Action-Bar und Titel holen
* zusätzlich wird der Transaktionstyp übergeben --> im PAI muß nur
* noch die Routine FCODE_BERABEITEN gerufen werden (QVH 250391)
  CALL FUNCTION 'CUA_PARAMETER_READ'
    EXPORTING
      programm   = t185f-agidv
      bildgruppe = t185-bldgr
      bild       = t185-panel
      typ        = t185f-trtyp
    IMPORTING
      cua_status = t185v-status
      cua_titel  = t185v-ctitel
      cua_para1  = t185v-para1
      cua_para2  = t185v-para2
      cua_para3  = t185v-para3
      cua_para4  = t185v-para4.

* CUA-Titel 2. Parameter setzen
  CASE t180-trtyp.
    WHEN chara.
      rv50a-txt_titcua = text-005.
    WHEN charh.
      rv50a-txt_titcua = text-003.
    WHEN charv.
      rv50a-txt_titcua = text-004.
  ENDCASE.

ENDFORM.                    "T180_INTERPRETIEREN
*eject