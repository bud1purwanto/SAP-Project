* Include RKO74000 - CO-Massenverarbeitung allg. Teil

INCLUDE RBONRART.

* Trace-Objekte
DATA: IT_TRACE like jsto_pre OCCURS 0 with header line.

* F4-Hilfe - allg. verwendbar
DATA: BEGIN OF IT_F4_FIELDS OCCURS 0.
        INCLUDE STRUCTURE HELP_VALUE.
DATA: END   OF IT_F4_FIELDS.
DATA: IT_F4_VALUES(60) TYPE C OCCURS 3 WITH HEADER LINE.
* Sender Selektion -> Funktionsgruppe KASS
DATA: BEGIN OF IT_SENDER OCCURS 0.
        INCLUDE STRUCTURE COSEL2.
DATA: END   OF IT_SENDER.
* INCLUDE RKASSELA. (now in Framework)

* Transaktionscode, Transaktionswährung
DATA:
      GD_WAERS LIKE COBK-KWAER.
* Hilfsfelder
DATA: HLP_VARIANT LIKE RSVAR-VARIANT,
      HLP_ONE,
      HLP_SELART  TYPE KASS_SELART.


*&---------------------------------------------------------------------*
*&      Form  DOMVALUE_TEXT_GET
*&---------------------------------------------------------------------*
*       Die Parameter sind OHNE STRUCTURE, denn sie wird
*       absichtlich mit Feldern unterschiedlicher Struktur
*       aufgerufen -> passende Datendef. nur in dieser Form
*----------------------------------------------------------------------*
*      -->P_name   Name der Domaene                                    *
*      -->P_value  ein Festwert  der Domaene                           *
*      <--P_text   Text zum Festwert                                   *
*----------------------------------------------------------------------*
FORM DOMVALUE_TEXT_GET USING    P_NAME
                                P_VALUE
                       CHANGING P_TEXT.
  DATA: LD_DD07L LIKE DD07L,
        LD_DD07V LIKE  DD07V.

  CLEAR P_TEXT.
  LD_DD07L-DOMVALUE_L = P_VALUE.
  LD_DD07L-DOMNAME  = P_NAME.
  CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
       EXPORTING
            DOMNAME  = LD_DD07L-DOMNAME
            VALUE    = LD_DD07L-DOMVALUE_L
            LANGU    = SY-LANGU
       IMPORTING
            DD07V_WA = LD_DD07V
       EXCEPTIONS
            OTHERS   = 1.
  IF SY-SUBRC IS INITIAL.
    P_TEXT = LD_DD07V-DDTEXT.
  ENDIF.
ENDFORM.                               " DOMVALUE_TEXT_GET