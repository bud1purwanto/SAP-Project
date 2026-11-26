REPORT prarchp1.
*----------------------------------------------------------------------*
* Prozessauftragssreorg: Setzen Löschvormerkung nach Prüfungen        *
*                        Setzen Löschkennzeichen                      *
*----------------------------------------------------------------------*

* generell vereinbarte Daten
INCLUDE: parchcon,
         parchi03.

* Selektionskriterien
SELECTION-SCREEN BEGIN OF BLOCK bild WITH FRAME TITLE text-sel.
SELECT-OPTIONS: aufnr FOR caufv-aufnr MATCHCODE OBJECT ordb,
                auart FOR caufv-auart.
SELECTION-SCREEN END OF BLOCK bild.

* Parameter zur Bearbeitung
INCLUDE parchi02.

* gemeinsamer Formroutinenpool
INCLUDE parchi01.
INCLUDE parchi04.

* Events
*---------------------------------------------------------------------*
*       INITIALIZATION                                                *
*---------------------------------------------------------------------*
INITIALIZATION.

ENHANCEMENT-POINT PRARCHP1_02 SPOTS ES_PRARCHP1 STATIC .

  PERFORM initialization USING con_ordertype_prorder
                               aobj-pr_order.

* initialize standard options
  PERFORM standard_opt_init.

*----------------------------------------------------------------------*
*       AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM at_selection_screen_output CHANGING p_pretst p_preprd.

*---------------------------------------------------------------------*
*       AT SELECTION-SCREEN ON SELID                                  *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON selid.
  PERFORM check_selid.

*---------------------------------------------------------------------*
*       AT SELECTION-SCREEN                                           *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON BLOCK action.
  PERFORM check_selection_screen USING set_loev set_loek.
*---------------------------------------------------------------------*
*       AT SELECTION-SCREEN FOR F4                                    *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR auart-low.

  CALL FUNCTION 'CO_F4_AUART'
    EXPORTING
      autyp_imp = con_ordertype_prorder
    IMPORTING
      auart_exp = auart-low.

*---------------------------------------------------------------------*
*       AT SELECTION-SCREEN FOR F4                                    *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR auart-high.

  CALL FUNCTION 'CO_F4_AUART'
    EXPORTING
      autyp_imp = con_ordertype_prorder
    IMPORTING
      auart_exp = auart-high.

*---------------------------------------------------------------------*
*       START-OF-SELECTION                                            *
*---------------------------------------------------------------------*
START-OF-SELECTION.

* select orders to be processed
  PERFORM orders_select USING con_ordertype_prorder.

* Aufträge verarbeiten
  PERFORM activities_on_order USING set_loev set_loek p_pretst space.

* Protokoll ausgeben
  PERFORM write_protocoll_new.

* END OF REPORT PRARCHP1