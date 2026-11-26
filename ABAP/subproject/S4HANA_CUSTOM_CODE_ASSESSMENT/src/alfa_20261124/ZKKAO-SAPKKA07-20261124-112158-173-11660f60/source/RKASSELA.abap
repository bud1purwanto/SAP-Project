***INCLUDE RKASSELA .

TYPE-POOLS KASS.

CONSTANTS: BEGIN OF CON_SELART,

*            business process
             BP  TYPE KASS_SELART VALUE 'BP ',
*            profitability segments (not fully supported in KASS!!!)
             EO  TYPE KASS_SELART VALUE 'EO ',
*            cost object
             HP  TYPE KASS_SELART VALUE 'HP ',
*            cost center
             KS  TYPE KASS_SELART VALUE 'KS ',
*            cost center, including cost center/activity type
             KSL TYPE KASS_SELART VALUE 'KSL',
*            cost center/activity type
             KL  TYPE KASS_SELART VALUE 'KL ',
*            internal order
             OR  TYPE KASS_SELART VALUE 'OR',
*            internal order
             OR1 TYPE KASS_SELART VALUE 'OR1',
*            run schedule
             OR2 TYPE KASS_SELART VALUE 'OR2',
*            production order
             OR3 TYPE KASS_SELART VALUE 'OR3',
*            process order
             OR4 TYPE KASS_SELART VALUE 'OR4',
*            by product order
             OR5 TYPE KASS_SELART VALUE 'OR5',
*            project all, without hierarchy
             PR  TYPE KASS_SELART VALUE 'PR ',
*            project all, without hierarchy for Costs To Complete
             PRC TYPE KASS_SELART VALUE 'PRC',
*            project actual, with hierarchy (interest calc. only)
             PRI TYPE KASS_SELART VALUE 'PRI',
*            project plan, with hierarchy (interest calc. only)
             PRP TYPE KASS_SELART VALUE 'PRP',
*            project plan surcharge (only wbs-elm. and CO int. orders)
             PRS TYPE KASS_SELART VALUE 'PRS',
*            project plan data transfer
             PRO TYPE KASS_SELART VALUE 'PRO',
*            project progress
             PRE TYPE KASS_SELART VALUE 'PRE',
*            project with hierarchy, including SD orders
             PRV TYPE KASS_SELART VALUE 'PRV',
*            project with hierarchy, all subordinated objects
             PRW TYPE KASS_SELART VALUE 'PRW',
*            customer order
             VB  TYPE KASS_SELART VALUE 'VB ',
*            worklists for schedule manager,
             WL  TYPE KASS_SELART VALUE 'WL ',
*            worklist selection for analysis reports
             WLR TYPE KASS_SELART VALUE 'WLR',
*            prefix wl.. reserved for special worklist selections!

*            Real estate all (Immobilien)
             RE  TYPE KASS_SELART VALUE 'RE ',
           END   OF CON_SELART.