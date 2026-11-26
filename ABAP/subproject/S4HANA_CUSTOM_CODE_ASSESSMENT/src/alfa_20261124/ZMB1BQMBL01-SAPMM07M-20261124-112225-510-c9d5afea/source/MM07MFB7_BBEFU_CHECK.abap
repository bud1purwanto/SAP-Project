************************************************************************
* Check for constellations which cannot be handled but are permitted
* in MM-PUR.
* Note 305582 describes the cases.
* The form has been renewed with note 413908.
************************************************************************
FORM bbefu_check.
* Cross-company purchase orders never create transit stock.
  CHECK NOT xbbefu-bsakz IS INITIAL.
* The critical case is withdrawal from free stock (for the access
* to T156S(Y) later on this means SOBKZ = _. In the PO, the
* issuing indicator is UMSOK).
  IF xbbefu-umsok IS INITIAL.
*   Unvaluated special stock: If the receiving stock is E, then
*   only KZVBR = E/P are permitted. Exception code in LMBMV prevents
*   SATRA from beeing created. Other KZVBR will cause the 101 movment
*   to fail because 101 E only exists for E/P (and _, but this
*   implies KZBWS<>_ which is treated later).
    IF ( xbbefu-kzbws IS INITIAL AND
         xbbefu-sobkz = e        AND
         xbbefu-kzvbr <> e AND xbbefu-kzvbr <> p ).
      MESSAGE e146 WITH
                   'EKPO-SOBKZ=E; EKPO-UMSOK=_; EKPO-KZBWS=_'
                   'EKPO-KZVBR<>E/P (Note 305582)'.
    ENDIF.
*   Valuated special stock: Only KZVBR = E is possible because
*   KZVBR = P would let the GI assume that SQTRA has to be created
*   (BUSTM = MAU8).
*   The cardinal design error is the key-design of T156S(Y) without
*   indicator for receiving stock. So KZVBR was abused for this process.
    IF ( NOT xbbefu-kzbws IS INITIAL AND
         xbbefu-sobkz = e AND
         xbbefu-kzvbr <> e ).
      MESSAGE e146 WITH
                   'EKPO-SOBKZ=E; EKPO-UMSOK=_; EKPO-KZBWS<>_'
                   'EKPO-KZVBR<>E (Note 305582)'.
    ENDIF.
*   With SOBKZ=Q we need KZVBR=P to update SQTRA.
    IF xbbefu-sobkz = q AND xbbefu-kzvbr <> p.
      MESSAGE e146 WITH
                   'EKPO-SOBKZ=Q; EKPO-UMSOK=_; EKPO-KZVBR<>P'
                   '(Note 305582)'.
    ENDIF.
  ENDIF.
ENDFORM.