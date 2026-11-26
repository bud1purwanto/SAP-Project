*eject.
*----------------------------------------------------------------------*
*     Serialnummern für FAuf                                           *
*----------------------------------------------------------------------*
FORM ser_fauf.
  CHECK xbapi IS INITIAL AND xmigo IS INITIAL.
* XSTOR=2: The correct operation must be MMCC (copy mat.doc.),   "384687
* don't copy serial numbers from order (-> operation PPC2)       "384687
  CHECK VM07M-XSTOR <> 2.                                        "384687
  CALL FUNCTION 'SERIALPROFILE_CHECK'
       EXPORTING
            material  = mseg-matnr
            operation = op_ppc2
            ppaufnr   = mseg-aufnr
            ppposnr   = mseg-aufps
            j_vorgang = vm07m-vrgng
            profile   = dm07m-sernp
            quantity  = xanzsn
            mblnr     = smblnr
            mjahr     = mkpf-mjahr
            zeile     = mseg-zeile
            blart     = mkpf-blart
            bwart     = mseg-bwart
            shkzg     = mseg-shkzg
            m_werk    = mseg-werks
            m_lager   = mseg-lgort
            m_charge  = mseg-charg
            cuobj     = dm07m-cuobj
            snbwg     = s156s-snbwg
            bstch     = bstch
            bstup     = bstup
            bapi      = xbapi
            budat     = mkpf-budat
       IMPORTING
            anzsn     = dm07m-anzsn.

ENDFORM.