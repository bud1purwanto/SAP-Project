*----------------------------------------------------------------------*
*   INCLUDE I56IDOVA                                                   *
*----------------------------------------------------------------------*

* >>>>> Please enter new constants in alphabetical sequence <<<<<

* Delivery states in transportation planning
DATA: BEGIN OF dstat,
        dlnex(2)   VALUE '00',         "Delivery doesn't exist
        dler3(2)   VALUE '01',         "Delivery exists in R/3
        dlale(2)   VALUE '02',         "Delery pending in ALE layer
        dltps(2)   VALUE '03',   "Delivery passed to planning system
        dlerr(2)   VALUE '05',   "Delivery rejected from planning system
        dldr3(2)   VALUE '06',         "Delivrey deleted in R/3
      END OF dstat.

* Delivery states in carrier freight planning
DATA: BEGIN OF dstatc,
        dlnex(2)   VALUE '00',         "Delivery doesn't exist
        dlsnd(2)   VALUE '01',         "Delivery sent to carrier
        dlack(2)   VALUE '02',         "Delivery acknowledge
        dlrej(2)   VALUE '03',         "Delivery rejected
        dlpln(2)   VALUE '04',         "Delivery planned by carrier
        dlerr(2)   VALUE '05',         "Delivery transmission error
        dldr3(2)   VALUE '06',         "Delivrey deleted in R/3
      END OF dstatc.

* Transition codes for delivery state transition in transportation
* planning
DATA: BEGIN OF dtcon,
        dlnew LIKE vtdschg-dtcon VALUE '01',  "Del created
        dlchg LIKE vtdschg-dtcon VALUE '02',  "Del changed
        dldel LIKE vtdschg-dtcon VALUE '03',  "Del deleted
        dlout LIKE vtdschg-dtcon VALUE '04',  "Del passed to ALE layer
        dlrej LIKE vtdschg-dtcon VALUE '05',  "Del rejected from TPS
        dlacc LIKE vtdschg-dtcon VALUE '06',  "Del accepted from TPS
        dlera LIKE vtdschg-dtcon VALUE '07',  "Del erased in both sys
      END OF dtcon.

* Transition codes for delivery state transition in transportation
* planning
DATA: BEGIN OF dtconc,
        dlnew LIKE vtdschgc-dtcon VALUE '01',  "Del created
        dlchg LIKE vtdschgc-dtcon VALUE '02',  "Del changed
        dldel LIKE vtdschgc-dtcon VALUE '03',  "Del deleted
        dlout LIKE vtdschgc-dtcon VALUE '04',  "Del passed to carrier
        dlerr LIKE vtdschgc-dtcon VALUE '05',  "Del error rep. by carr.
        dlacc LIKE vtdschgc-dtcon VALUE '06',  "Del accepted by carr.
        dlera LIKE vtdschgc-dtcon VALUE '07',  "Del erased in both sys
        dlrej LIKE vtdschgc-dtcon VALUE '08',  "Del rejected by carrier
        dlpln LIKE vtdschgc-dtcon VALUE '09',  "Del planned by carrier
  END OF dtconc.


* qualifier constants **************************************************
* orgunits for shipments
CONSTANTS: BEGIN OF e1edt02_qualf,
             tplst      LIKE e1edt05-qualf   VALUE '001', "tr.plan.point
           END OF   e1edt02_qualf.
* additional partnerdata (shipment header)
CONSTANTS: BEGIN OF e1edt04_qualf,
             ilnnr      LIKE e1edt04-qualf   VALUE '001', "int.loc.num.
             scacd      LIKE e1edt04-qualf   VALUE '004', "scacode
             locco      LIKE e1edt04-qualf   VALUE '005', "splcode
             eikto      LIKE e1edt04-qualf   VALUE '006', "own account
           END OF   e1edt04_qualf.
* additional partnerdata (shipment leg)
CONSTANTS: BEGIN OF e1edt07_qualf,
             ilnnr      LIKE e1edt07-qualf   VALUE '001', "int.loc.num.
             scacd      LIKE e1edt07-qualf   VALUE '004', "scacode
             locco      LIKE e1edt07-qualf   VALUE '005', "splcode
             eikto      LIKE e1edt07-qualf   VALUE '006', "own account
           END OF   e1edt07_qualf.
* nodes for stages
CONSTANTS: BEGIN OF e1edt05_qualf,
             knote      LIKE e1edt05-qualf   VALUE '002', "node
             vstel      LIKE e1edt05-qualf   VALUE '003', "ship.point
             werks      LIKE e1edt05-qualf   VALUE '004', "plant
             kunnr      LIKE e1edt05-qualf   VALUE '005', "customer
             lifnr      LIKE e1edt05-qualf   VALUE '006', "vendor
             frei       LIKE e1edt05-qualf   VALUE '499', "free address
           END OF   e1edt05_qualf.
* deadlines on shipment header
CONSTANTS: BEGIN OF e1edt10_qualf,
             dispo      LIKE e1edt10-qualf   VALUE '001', "planning
             regis      LIKE e1edt10-qualf   VALUE '002', "registration
             verla      LIKE e1edt10-qualf   VALUE '003', "loading
             abfer      LIKE e1edt10-qualf   VALUE '004', "dispatch
             trans      LIKE e1edt10-qualf   VALUE '005', "transport
             ankft      LIKE e1edt10-qualf   VALUE '008', "arrival
             abfrt      LIKE e1edt10-qualf   VALUE '009', "departure
             stzei      LIKE e1edt10-qualf   VALUE '011', "stop time
             frei       LIKE e1edt10-qualf   VALUE '499', "others
           END OF   e1edt10_qualf.
* deadlines on shipment stage
CONSTANTS: BEGIN OF e1edt12_qualf,
             trans      LIKE e1edt12-qualf   VALUE '005', "transport
           END OF   e1edt12_qualf.
CONSTANTS: BEGIN OF e1edt45_qualf,
             trans      LIKE e1edt45-qualf   VALUE '005', "transport
           END OF   e1edt45_qualf.
* deadlines on delivery header
CONSTANTS: BEGIN OF e1edt13_qualf,
             tddat      LIKE e1edt13-qualf   VALUE '001', "shipm.plang.
             lddat      LIKE e1edt13-qualf   VALUE '003', "loading
             wadat      LIKE e1edt13-qualf   VALUE '006', "goods issue
             lfdat      LIKE e1edt13-qualf   VALUE '007', "delivery
             ankft      LIKE e1edt13-qualf   VALUE '008', "arrival
             abfrt      LIKE e1edt13-qualf   VALUE '009', "departure
             kodat      LIKE e1edt13-qualf   VALUE '010', "picking
* <<< START_OF_INSERTION_HP_204779 >>>
             bldat      LIKE e1edt13-qualf   VALUE '015', "doc date
* <<< END_OF_INSERTION_HP_204779 >>>
             frei       LIKE e1edt13-qualf   VALUE '499', "others
           END OF   e1edt13_qualf.
* deadlines for location/node
CONSTANTS: BEGIN OF e1edt17_qualf,
             lddat      LIKE e1edt17-qualf   VALUE '003', "loading
             ankft      LIKE e1edt17-qualf   VALUE '008', "arrival
             abfrt      LIKE e1edt17-qualf   VALUE '009', "departure
             stzei      LIKE e1edt17-qualf   VALUE '011', "stop time
             eldat      LIKE e1edt17-qualf   VALUE '012', "unloading
             zollt      LIKE e1edt17-qualf   VALUE '013', "customs
             umsch      LIKE e1edt17-qualf   VALUE '014', "load transfer
             bankf      LIKE e1edt17-qualf   VALUE '018', "best arrival
             babfr      LIKE e1edt17-qualf   VALUE '019', "bestdeparture
             frei       LIKE e1edt17-qualf   VALUE '499', "others
           END OF   e1edt17_qualf.
* orgunits for deliveries
CONSTANTS: BEGIN OF e1edl04_qualf,
             vkorg      LIKE e1edl04-qualf   VALUE '007', "sales org.
             vstel      LIKE e1edl04-qualf   VALUE '003', "ship.point
             lstel      LIKE e1edl04-qualf   VALUE '008', "load.point
             vkbur      LIKE e1edl04-qualf   VALUE '009', "sales office
           END OF   e1edl04_qualf.
* additional partnerdata (delivery header)
CONSTANTS: BEGIN OF e1edl06_qualf,
             ilnnr      LIKE e1edl06-qualf   VALUE '001', "int.loc.num.
             scacd      LIKE e1edl06-qualf   VALUE '004', "scacode
             locco      LIKE e1edl06-qualf   VALUE '005', "splcode
             eikto      LIKE e1edl06-qualf   VALUE '006', "own account
           END OF   e1edl06_qualf.
* controls/activities for delivery
CONSTANTS: BEGIN OF e1edl18_qualf,
             origi      LIKE e1edl18-qualf   VALUE 'ORI', "Original
             chang      LIKE e1edl18-qualf   VALUE 'CHA'. "Change
ENHANCEMENT-POINT I56IDOVA_01 SPOTS ES_I56IDOVA STATIC INCLUDE BOUND.
CONSTANTS:     END OF   e1edl18_qualf.
* stage nodes
CONSTANTS: BEGIN OF e1edl32_quali,
             knbeg      LIKE e1edl32-quali   VALUE '001', "Start node
             knend      LIKE e1edl32-quali   VALUE '002', "End node
           END OF   e1edl32_quali.
CONSTANTS: BEGIN OF e1edt44_quali,
             knbeg      LIKE e1edt44-quali   VALUE '001', "Start node
             knend      LIKE e1edt44-quali   VALUE '002', "End node
           END OF   e1edt44_quali.
* additional data for address segment E1ADREn
CONSTANTS: BEGIN OF e1adre1_qualf,
             ilnnr      LIKE e1adre1-extend_q VALUE '100', "int.loc.num.
             dunno      LIKE e1adre1-extend_q VALUE '200', "DUNS-No
             eikto      LIKE e1adre1-extend_q VALUE '300', "own account
             knref      LIKE e1adre1-extend_q VALUE '301', "reference
             cpuma      LIKE e1adre1-extend_q VALUE '302', "ref. table
             locco      LIKE e1adre1-extend_q VALUE '303', "Location cod
             scacd      LIKE e1adre1-extend_q VALUE '304', "StdCarrierCo
           END OF   e1adre1_qualf.
CONSTANTS: BEGIN OF e1adre4_qualf,
             ilnnr      LIKE e1adre4-extend_q VALUE '100', "int.loc.num.
             dunno      LIKE e1adre4-extend_q VALUE '200', "DUNS-No
             eikto      LIKE e1adre4-extend_q VALUE '300', "own account
             knref      LIKE e1adre4-extend_q VALUE '301', "reference
             cpuma      LIKE e1adre4-extend_q VALUE '302', "ref. table
             locco      LIKE e1adre4-extend_q VALUE '303', "Location cod
             scacd      LIKE e1adre4-extend_q VALUE '304', "StdCarrierCo
             tplst      LIKE e1adre4-extend_q VALUE '305', "Tr.planng.pt
           END OF   e1adre4_qualf.
* address qualifier for segment E1ADRM1
CONSTANTS: BEGIN OF e1adrm1_qualf,
             vstel      LIKE e1adrm1-partner_q VALUE 'OSP',"Shipping Poi
             vkorg      LIKE e1adrm1-partner_q VALUE 'OSO',"Sales Organi
             vkbur      LIKE e1adrm1-partner_q VALUE 'OSF',"Sales Office
             tplst      LIKE e1adrm1-partner_q VALUE 'OTP',"Transp. Plan
           END OF   e1adrm1_qualf.
* address qualifier for segment E1ADRM2
CONSTANTS: BEGIN OF e1adrm2_qualf,
             knote      LIKE e1adrm1-partner_q VALUE 'KND', "nodes
           END OF   e1adrm2_qualf.
* address qualifier for segment E1ADRM5
CONSTANTS: BEGIN OF e1adrm5_qualf,
             knote      LIKE e1adrm5-partner_q VALUE 'KND', "nodes
           END OF   e1adrm5_qualf.
* address qualifier for segment E1ADRM6
CONSTANTS: BEGIN OF e1adrm6_qualf,
             knote      LIKE e1adrm6-partner_q VALUE 'KND', "nodes
           END OF   e1adrm6_qualf.
* address qualifier for segment E1ADRM4
CONSTANTS: BEGIN OF e1adrm4_qualf,
             vstel      LIKE e1adrm4-partner_q VALUE 'OSP',"Shipping Poi
             vkorg      LIKE e1adrm4-partner_q VALUE 'OSO',"Sales Organi
             vkbur      LIKE e1adrm4-partner_q VALUE 'OSF',"Sales Office
           END OF   e1adrm4_qualf.
* qualifier for segment E1EDL24 field HIEVW
CONSTANTS: BEGIN OF e1edl24_hievw,
             batch      LIKE e1edl24-hievw VALUE '1',   "batches
             bomsi      LIKE e1edl24-hievw VALUE '2',   "BOM sub item
             prosl      LIKE e1edl24-hievw VALUE '3',   "product select
             otbon      LIKE e1edl24-hievw VALUE '5',   "on-top bonus
* UEPVW='G': full products (purchase order)             "n_648408
             fullp      LIKE e1edl24-hievw VALUE '6'.   "full product
ENHANCEMENT-POINT I56IDOVA_02 SPOTS ES_I56IDOVA STATIC INCLUDE BOUND.
CONSTANTS:   END OF   e1edl24_hievw.
* qualifier for segment E1EDL41
CONSTANTS: BEGIN OF e1edl41_quali,
             bsdag      LIKE e1edl41-quali VALUE '001', "PO data cust
             bsdwe      LIKE e1edl41-quali VALUE '002', "PO data consign
             bsdst   LIKE e1edl41-quali VALUE '003', "PO data stocktrans
           END OF   e1edl41_quali.
* orgunits for delivery line items
CONSTANTS: BEGIN OF e1edl10_qualf,
             vtweg      LIKE e1edl10-qualf   VALUE '010',
             spart      LIKE e1edl10-qualf   VALUE '011',
             werks      LIKE e1edl10-qualf   VALUE '004',
             lgort      LIKE e1edl10-qualf   VALUE '012',
             vkbur      LIKE e1edl10-qualf   VALUE '013',
             vkgrp      LIKE e1edl10-qualf   VALUE '014',
           END OF   e1edl10_qualf.
* orgunits for delivery line items
CONSTANTS: BEGIN OF e1edl14_qualf,
             bstku      LIKE e1edl14-qualf   VALUE '0',
                                       "Bestellnummer des Kunden
                                       "alle anderen Werte wie VBTYP
           END OF   e1edl14_qualf.
* activities
CONSTANTS: BEGIN OF e1tpsha_actvty,
             ld(2)          VALUE 'LD',"Loading
             ul(2)          VALUE 'UL',"Unloading
             cu(2)          VALUE 'CU',"Customs clearing
             lt(2)          VALUE 'LT',"Load transfer
           END OF   e1tpsha_actvty.
************************************************************************

* Action codes
DATA: BEGIN OF tpacc_actcd,
        c            VALUE 'C',        "Create
        m            VALUE 'M',        "Modify
        d            VALUE 'D',        "Delete
        r            VALUE 'R',        "Remove from schedule
        f            VALUE 'F',        "Fix planning completion
        u            VALUE 'U',        "Unfix planning completion
        x            VALUE 'X',        "Rejection of deliveries
      END   OF tpacc_actcd.

* Load sequence settings
DATA: BEGIN OF tpdls_lodseq,
        very_first   VALUE '1',
        first        VALUE '2',
        normal       VALUE '3',
        last         VALUE '4',
        very_last    VALUE '5',
      END OF tpdls_lodseq.

* Terminal types
DATA: BEGIN OF trmtyp,
        plant    LIKE e1tptrm-trmtyp VALUE 'PL',   "Plant
        customer LIKE e1tptrm-trmtyp VALUE 'CU',   "Customer / recei
        supplier LIKE e1tptrm-trmtyp VALUE 'SU',   "Supplier / sender
        otcust   LIKE e1tptrm-trmtyp VALUE 'OC',   "One time customer
        node     LIKE e1tptrm-trmtyp VALUE 'NO',   "Node
        crossdock LIKE e1tptrm-trmtyp VALUE 'CD',   "Crossdock
        shippnt  LIKE e1tptrm-trmtyp VALUE 'SP',   "Shipping point
        carrier  LIKE e1tptrm-trmtyp VALUE 'CA',   "Carrier
        otsupp   LIKE e1tptrm-trmtyp VALUE 'OS',   "One time supplier
        address  LIKE e1tptrm-trmtyp VALUE 'AD',   "Just an address
      END OF trmtyp.

* Directions
DATA: BEGIN OF directions,
        outbound(2)  VALUE 'OB',       "Outbound
        inbound(2)   VALUE 'IB',       "Inbound
      END OF directions.

* Terminal location category (begin, intermediate and end)
DATA: BEGIN OF tps_tlccat,
        trm_begin      VALUE 'S',
        trm_interbeg   VALUE '1',
        trm_interend   VALUE '2',
        trm_end        VALUE 'D',
        trm_buyer      VALUE 'B',
        trm_payer      VALUE 'P',
      END OF tps_tlccat.

* Time window modes
DATA: BEGIN OF tps_winmod,
        open           VALUE 'O',
        closed         VALUE 'C',
      END OF tps_winmod.

* Node attributes
DATA: BEGIN OF tps_nodtyp,
        crossdock  VALUE 'C',          "Crossdocking facility
        airport    VALUE 'A',          "Airport facility
        railstat   VALUE 'R',          "Railway station facility
        exprrail   VALUE 'E',          "Express railway station fac.
        harbor     VALUE 'H',          "Overseas harbor facility
        innerhrb   VALUE 'I',          "Inner harbor facility
        road       VALUE 'S',          "Road facility
        distcent   VALUE 'D',          "Distribution center facility
      END OF tps_nodtyp.

* Commodity codes for material aggregation
DATA: BEGIN OF tps_coc,
        comm_code(3) VALUE '001',      "Stat. goods code
        matfr_code(3) VALUE '002',     "Material freight code
        mtfgr_code(3) VALUE '003',     "Material freight group
      END OF tps_coc.