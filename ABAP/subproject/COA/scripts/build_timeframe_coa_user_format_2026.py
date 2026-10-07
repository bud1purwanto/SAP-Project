#!/usr/bin/env python3
"""Recreate the user's original COA schedule table and Gantt with revised dates."""

import calendar
from datetime import date
from pathlib import Path

import build_timeframe_coa_2026 as workbook


OUTPUT = Path(__file__).resolve().parents[1] / "docs" / "Timeframe_COA_Format_Asli_Revisi_2026.xlsx"

# Historical rows and their Done status follow the schedule provided by the user.
# Future dates are proposed from the COA MOM follow-up discussed on 10 Oct 2026.
ITEMS = [
    ("PREPARE", "Project Initiation", "Project scope and schedule defined", date(2026, 5, 18), date(2026, 5, 22), "Done"),
    ("PREPARE", "Discovery and Evaluation", "Solutions discovered and evaluated", date(2026, 5, 18), date(2026, 5, 22), "Done"),
    ("PREPARE", "Business Process Map", "Business process map defined", date(2026, 5, 18), date(2026, 5, 29), "Done"),
    ("EXPLORE", "Business Blueprint Design", "Business Blueprint Design completed and documented", date(2026, 5, 25), date(2026, 5, 29), "Done"),
    ("EXPLORE", "Business Blueprint Confirmation & Finalization", "Business Blueprint Design approved", date(2026, 5, 25), date(2026, 6, 5), "Done"),
    ("EXPLORE", "Enhancement (RICEF) Design", "RICEF Design documented", date(2026, 5, 25), date(2026, 6, 5), "Done"),
    ("EXPLORE", "Authorization Requirement and Design", "Authorization requirements and design documented", date(2026, 5, 25), date(2026, 6, 5), "Done"),
    ("EXPLORE", "QA COA Templates, Header & Alias Confirmation", "QA-approved COA master template, Export/Domestic header, and Product Alias examples", date(2026, 10, 12), date(2026, 10, 16), "Waiting QA"),
    ("EXPLORE", "QA Barrier MIC/Plan & Batch List Confirmation", "Confirmed Barrier MIC limits, SPSR0003 plan, and customer Batch List template", date(2026, 10, 12), date(2026, 10, 16), "To Confirm"),
    ("EXPLORE", "Mapping Review & Test Scenario Approval", "Customer/alias/outsource/multi-step rules and expected test results approved", date(2026, 10, 19), date(2026, 10, 23), "Planned"),
    ("REALIZE", "Enhancement (RICEF) Development — Initial", "Initial RICEF design developed", date(2026, 6, 1), date(2026, 8, 7), "Done"),
    ("REALIZE", "Run Scenario Test and Integration Test", "Scenario/integration tests continued; revised scope retested and issues resolved", date(2026, 6, 8), date(2026, 11, 20), "In Progress"),
    ("REALIZE", "COA Mapping, Tracing & Limit Revision", "Customer/alias mapping, four-step tracing, limits and out-of-spec display ready", date(2026, 10, 26), date(2026, 11, 13), "Planned"),
    ("REALIZE", "Barrier Inspection & Upload Revision", "Manual/upload of three values, Last Value and sample correction ready", date(2026, 10, 26), date(2026, 11, 13), "Planned"),
    ("REALIZE", "COA Form, Batch List & Report Revision", "Export/Domestic COA, Batch List and Report revisions ready", date(2026, 11, 2), date(2026, 11, 13), "Planned"),
    ("REALIZE", "Final Integration Test for Revisions", "Barrier–COA–Batch List regression tested; defects triaged", date(2026, 11, 16), date(2026, 11, 20), "Planned"),
    ("REALIZE", "Prepare UAT and EUT", "UAT scenarios, evidence sheets and EUT materials ready", date(2026, 11, 16), date(2026, 11, 20), "Planned"),
    ("DEPLOY", "User Acceptance Test (UAT)", "QA UAT approved after retest", date(2026, 11, 23), date(2026, 12, 4), "Planned"),
    ("DEPLOY", "End User Training (EUT)", "End users trained on COA and Barrier workflow", date(2026, 11, 30), date(2026, 12, 4), "Planned"),
    ("DEPLOY", "Prepare Production System Environment", "Production environment, transport and master data ready", date(2026, 12, 7), date(2026, 12, 9), "Planned"),
    ("DEPLOY", "Cut-over Strategy", "Production window, cutover steps and rollback plan approved", date(2026, 11, 30), date(2026, 12, 4), "Planned"),
    ("RUN", "Go Live", "COA and Barrier live in production", date(2026, 12, 10), date(2026, 12, 10), "Planned"),
    ("RUN", "Support After Go Live", "Functional/technical issues monitored and resolved", date(2026, 12, 11), date(2026, 12, 18), "Planned"),
]


def month_buckets():
    buckets = []
    for month in range(5, 13):
        last = calendar.monthrange(2026, month)[1]
        for first_day, last_day in ((1, 7), (8, 14), (15, 21), (22, last)):
            buckets.append((date(2026, month, first_day), date(2026, month, last_day)))
    return buckets


def gantt_sheet():
    buckets = month_buckets()
    s = workbook.Sheet("Gantt 2026", [54] + [5.8] * 32, freeze=(1, 4), fit_height=1)
    s.span(1, 1, 33, "COA PROJECT TIMEFRAME  |  REVISED 10 OCTOBER 2026", 1)
    s.height(1, 36)
    s.put(2, 1, "ACTIVITY", 2)
    s.span(2, 2, 33, "2026", 2)
    for month in range(5, 13):
        first = 2 + (month - 5) * 4
        s.span(3, first, first + 3, calendar.month_name[month].upper(), 3)
        for n in range(4):
            label = ["01–07", "08–14", "15–21", "22–EOM"][n]
            s.put(4, first + n, label, 4)
    s.height(4, 27)

    row = 5
    previous = None
    for phase, activity, _, start, end, status in ITEMS:
        if phase != previous:
            s.put(row, 1, phase if phase != "RUN" else "GO LIVE SUPPORT", 5)
            for col, (bstart, bend) in enumerate(buckets, 2):
                active = any(
                    item[0] == phase and item[3] <= bend and item[4] >= bstart
                    for item in ITEMS
                )
                s.put(row, col, "", 3 if active else 6)
            s.height(row, 24)
            row += 1
            previous = phase
        s.put(row, 1, "   " + activity, 6)
        for col, (bstart, bend) in enumerate(buckets, 2):
            active = start <= bend and end >= bstart
            style = {
                "Done": 7,
                "In Progress": 8,
                "Waiting QA": 11,
                "To Confirm": 8,
                "Planned": 9,
            }[status] if active else 6
            marker = "" if not active else (
                "GO" if activity == "Go Live" else ""
            )
            s.put(row, col, marker, 11 if activity == "Go Live" and active else style)
        s.height(row, 22)
        row += 1
    s.span(row + 1, 1, 33, "GREEN  Done   |   AMBER  In Progress / To Confirm   |   RED  Waiting QA / Go Live   |   GREY  Planned", 13)
    s.span(row + 2, 1, 33, "Proposed go live: 10 Dec 2026. Requires QA inputs by 16 Oct, UAT approval, and an agreed production cutover window.", 14)
    s.height(row + 2, 30)
    return s


def table_sheet():
    s = workbook.Sheet("Schedule Table", [16, 57, 86, 17, 17, 20], freeze=(0, 4))
    s.span(1, 1, 6, "COA PROJECT TIMEFRAME  |  ORIGINAL FORMAT, REVISED DATES", 1)
    s.height(1, 35)
    s.span(2, 1, 6, "Historical Done rows follow the supplied plan. Later dates are proposed as of 10 Oct 2026; QA input due 16 Oct is a schedule condition.", 14)
    s.height(2, 33)
    s.span(3, 1, 6, "Go Live target: 10 Dec 2026  |  Support: 11–18 Dec 2026  |  QA UAT approval and production window remain to be confirmed.", 13)
    s.height(3, 31)
    for col, title in enumerate(("PHASE", "ACTIVITIES", "DELIVERABLES", "START DATE", "END DATE", "STATUS"), 1):
        s.put(4, col, title, 18)
    s.height(4, 31)
    previous = None
    for row, item in enumerate(ITEMS, 5):
        phase, activity, deliverable, start, end, status = item
        s.put(row, 1, phase if phase != previous else "", 13 if phase != previous else 12)
        s.put(row, 2, activity, 12)
        s.put(row, 3, deliverable, 12)
        s.put(row, 4, start, 17)
        s.put(row, 5, end, 17)
        s.put(row, 6, status, {
            "Done": 15,
            "In Progress": 14,
            "Waiting QA": 16,
            "To Confirm": 14,
            "Planned": 9,
        }[status])
        s.height(row, 44 if len(deliverable) > 60 else 34)
        previous = phase
    s.filter_ref = f"A4:F{4 + len(ITEMS)}"
    return s


def notes_sheet():
    s = workbook.Sheet("Schedule Changes", [27, 47, 27, 68], freeze=(0, 3))
    s.span(1, 1, 4, "KEY DATE CHANGES AND ASSUMPTIONS", 1)
    s.height(1, 35)
    headers = ("ACTIVITY", "OLD PLAN", "REVISED PLAN", "REASON / CONDITION")
    for col, value in enumerate(headers, 1):
        s.put(3, col, value, 18)
    rows = [
        ("QA input", "MOM: 4 Oct 2026", "16 Oct 2026 (proposed)", "QA COA template and header had not been delivered as of 10 Oct; other QA items need status confirmation."),
        ("Integration test", "8 Jun–11 Sep 2026", "8 Jun–20 Nov 2026", "Original testing remains In Progress in the supplied plan; revised scope needs final regression."),
        ("Prepare UAT / EUT", "31 Aug–4 Sep 2026", "16–20 Nov 2026", "UAT package follows revised development and integration test."),
        ("UAT", "7–11 Sep 2026", "23 Nov–4 Dec 2026", "QA sign-off depends on final templates, test cases and retest."),
        ("End User Training", "7–18 Sep 2026", "30 Nov–4 Dec 2026", "Training follows near-final UAT build."),
        ("Production environment", "21–25 Sep 2026", "7–9 Dec 2026", "Transport and master data readiness follow UAT sign-off."),
        ("Cut-over strategy", "21–25 Sep 2026", "30 Nov–4 Dec 2026", "QA/production must approve cutover window and rollback plan."),
        ("Go Live", "28 Sep–2 Oct 2026", "10 Dec 2026 target", "Target depends on QA input by 16 Oct and agreed production window."),
        ("Support After Go Live", "2–31 Oct 2026", "11–18 Dec 2026", "One-week initial support after the revised go live target."),
    ]
    for row, values in enumerate(rows, 4):
        for col, value in enumerate(values, 1):
            s.put(row, col, value, 12)
        s.height(row, 53)
    s.span(14, 1, 4, "If QA decisions or production cutover move, recalculate the remaining duration and agree a new target date.", 14)
    s.height(14, 35)
    return s


if __name__ == "__main__":
    workbook.OUTPUT = OUTPUT
    workbook.write_workbook([table_sheet(), gantt_sheet(), notes_sheet()])
