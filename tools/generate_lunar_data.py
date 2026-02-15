#!/usr/bin/env python3
"""
Generate lunar calendar JSON data for 2020-2035.

This script uses embedded astronomical lookup tables for the Chinese/Japanese
lunar calendar. The data is derived from published astronomical new moon tables
and the traditional Chinese calendar rules.

Each lunar year is defined by:
  - The Gregorian date of Lunar New Year (1st day of 1st lunar month)
  - The number of days in each lunar month (29 or 30)
  - Which month (if any) is a leap month

Output format:
{
  "YYYY-MM-DD": {"m": <lunar_month>, "d": <lunar_day>},
  ...
}

For leap months, "m" is negative (e.g., -4 for leap 4th month).
"""

import json
import datetime
import sys
import os

# Lunar year data table.
# Each entry: (gregorian_new_year_date, [days_in_each_month...], leap_month_index_or_0)
#
# leap_month_index: which position in the month-days list is the leap month.
#   0 = no leap month. If leap_month_index=5, then months[4] is the leap month
#   (i.e., the 5th entry in the array is the leap month).
#
# The month-days list has 12 entries for normal years, 13 for leap years.
# Each value is 29 or 30 (days in that lunar month).
#
# Sources: Published Chinese calendar tables, Hong Kong Observatory,
# Purple Mountain Observatory astronomical data.

LUNAR_YEARS = {
    # 2020: Leap 4th month. New Year = Jan 25
    2020: {
        "new_year": (2020, 1, 25),
        "month_days": [29, 30, 30, 30, 29, 30, 29, 29, 30, 29, 30, 29, 30],
        "leap_month": 4,  # leap month comes after regular month 4
    },
    # 2021: No leap month. New Year = Feb 12
    2021: {
        "new_year": (2021, 2, 12),
        "month_days": [29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29],
        "leap_month": 0,
    },
    # 2022: No leap month. New Year = Feb 1
    2022: {
        "new_year": (2022, 2, 1),
        "month_days": [29, 30, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30],
        "leap_month": 0,
    },
    # 2023: Leap 2nd month. New Year = Jan 22
    2023: {
        "new_year": (2023, 1, 22),
        "month_days": [29, 30, 29, 29, 30, 29, 30, 29, 30, 30, 30, 29, 30],
        "leap_month": 2,
    },
    # 2024: No leap month. New Year = Feb 10
    2024: {
        "new_year": (2024, 2, 10),
        "month_days": [30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29, 30],
        "leap_month": 0,
    },
    # 2025: Leap 6th month. New Year = Jan 29
    2025: {
        "new_year": (2025, 1, 29),
        "month_days": [29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30],
        "leap_month": 6,
    },
    # 2026: No leap month. New Year = Feb 17
    2026: {
        "new_year": (2026, 2, 17),
        "month_days": [29, 30, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30],
        "leap_month": 0,
    },
    # 2027: No leap month. New Year = Feb 6
    2027: {
        "new_year": (2027, 2, 6),
        "month_days": [29, 30, 30, 29, 30, 30, 29, 30, 29, 30, 29, 30],
        "leap_month": 0,
    },
    # 2028: Leap 5th month. New Year = Jan 26
    2028: {
        "new_year": (2028, 1, 26),
        "month_days": [30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 29, 30],
        "leap_month": 5,
    },
    # 2029: No leap month. New Year = Feb 13
    2029: {
        "new_year": (2029, 2, 13),
        "month_days": [30, 29, 30, 30, 29, 30, 29, 30, 29, 30, 29, 30],
        "leap_month": 0,
    },
    # 2030: No leap month. New Year = Feb 3
    2030: {
        "new_year": (2030, 2, 3),
        "month_days": [29, 30, 29, 30, 30, 29, 30, 29, 30, 29, 30, 29],
        "leap_month": 0,
    },
    # 2031: Leap 3rd month. New Year = Jan 23
    2031: {
        "new_year": (2031, 1, 23),
        "month_days": [30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29, 30, 29],
        "leap_month": 3,
    },
    # 2032: No leap month. New Year = Feb 11
    2032: {
        "new_year": (2032, 2, 11),
        "month_days": [30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30],
        "leap_month": 0,
    },
    # 2033: Leap 11th month. New Year = Jan 31
    2033: {
        "new_year": (2033, 1, 31),
        "month_days": [29, 30, 29, 30, 29, 30, 29, 29, 30, 30, 29, 30, 30],
        "leap_month": 11,
    },
    # 2034: No leap month. New Year = Feb 19
    2034: {
        "new_year": (2034, 2, 19),
        "month_days": [29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29],
        "leap_month": 0,
    },
    # 2035: No leap month. New Year = Feb 8
    2035: {
        "new_year": (2035, 2, 8),
        "month_days": [30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30],
        "leap_month": 0,
    },
    # 2036 needed for tail end of Gregorian 2035
    2036: {
        "new_year": (2036, 1, 28),
        "month_days": [29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30],
        "leap_month": 6,
    },
}

# We also need the tail end of lunar year 2019 for early January 2020
# 2019: No leap month (but there were none). New Year = Feb 5, 2019
# Actually we need to cover Jan 1-24, 2020, which falls in lunar year 2019.
LUNAR_YEARS[2019] = {
    "new_year": (2019, 2, 5),
    "month_days": [30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30],
    "leap_month": 0,
}


def build_lunar_year_mapping(lunar_year):
    """
    Build a list of (gregorian_date, lunar_month, lunar_day) for an entire lunar year.
    Returns a list of tuples.
    """
    info = LUNAR_YEARS[lunar_year]
    ny = datetime.date(*info["new_year"])
    month_days = info["month_days"]
    leap = info["leap_month"]

    result = []
    current_date = ny
    lunar_month_num = 0  # will be incremented

    for idx, days in enumerate(month_days):
        lunar_month_num += 1

        # Determine if this position is the leap month
        is_leap = False
        if leap > 0 and idx == leap:
            # This is the leap month (same number as previous)
            is_leap = True
            lunar_month_num -= 1  # reuse the previous month number

        for day in range(1, days + 1):
            m = -lunar_month_num if is_leap else lunar_month_num
            result.append((current_date, m, day))
            current_date += datetime.timedelta(days=1)

    return result


def generate_calendar_data():
    """Generate complete Gregorian-to-lunar mapping for 2020-01-01 to 2035-12-31."""
    # Build all lunar year mappings
    all_mappings = {}

    for lunar_year in sorted(LUNAR_YEARS.keys()):
        entries = build_lunar_year_mapping(lunar_year)
        for greg_date, lm, ld in entries:
            all_mappings[greg_date] = (lm, ld)

    # Filter to our desired range
    start = datetime.date(2020, 1, 1)
    end = datetime.date(2035, 12, 31)

    result = {}
    current = start
    missing = []
    while current <= end:
        if current in all_mappings:
            lm, ld = all_mappings[current]
            result[current.isoformat()] = {"m": lm, "d": ld}
        else:
            missing.append(current.isoformat())
        current += datetime.timedelta(days=1)

    if missing:
        print(f"WARNING: {len(missing)} dates have no lunar mapping!")
        print(f"First missing: {missing[0]}, Last missing: {missing[-1]}")
        sys.exit(1)

    return result


def validate(data):
    """Validate against known reference points."""
    checks = [
        ("2020-01-25", 1, 1, "Chinese New Year 2020"),
        ("2020-01-26", 1, 2, "2020 1/2"),
        ("2021-02-12", 1, 1, "Chinese New Year 2021"),
        ("2022-02-01", 1, 1, "Chinese New Year 2022"),
        ("2023-01-22", 1, 1, "Chinese New Year 2023"),
        ("2024-02-10", 1, 1, "Chinese New Year 2024"),
        ("2025-01-29", 1, 1, "Chinese New Year 2025"),
        ("2026-02-17", 1, 1, "Chinese New Year 2026"),
    ]

    all_ok = True
    for date_str, expected_m, expected_d, label in checks:
        entry = data.get(date_str)
        if entry is None:
            print(f"FAIL: {label} ({date_str}) - no entry found")
            all_ok = False
            continue
        if entry["m"] != expected_m or entry["d"] != expected_d:
            print(f"FAIL: {label} ({date_str}) - expected m={expected_m},d={expected_d}, got m={entry['m']},d={entry['d']}")
            all_ok = False
        else:
            print(f"  OK: {label} ({date_str}) = {entry['m']}/{entry['d']}")

    # Check leap months exist
    leap_checks = [
        (2020, 4, "Leap 4th month in 2020"),
        (2023, 2, "Leap 2nd month in 2023"),
        (2025, 6, "Leap 6th month in 2025"),
    ]
    for year, lm, label in leap_checks:
        found = False
        for date_str, entry in data.items():
            if date_str.startswith(str(year)) and entry["m"] == -lm:
                found = True
                break
        if found:
            print(f"  OK: {label} - found")
        else:
            print(f"FAIL: {label} - NOT found")
            all_ok = False

    return all_ok


def main():
    print("Generating lunar calendar data for 2020-2035...")
    data = generate_calendar_data()
    print(f"Generated {len(data)} entries.")

    print("\nValidating against known reference points...")
    ok = validate(data)

    if not ok:
        print("\nValidation FAILED!")
        sys.exit(1)

    print("\nAll validations passed!")

    output_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        "assets", "data", "lunar_calendar_2020_2035.json"
    )
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, separators=(",", ":"))

    file_size = os.path.getsize(output_path)
    print(f"\nWritten to: {output_path}")
    print(f"File size: {file_size:,} bytes ({file_size/1024:.1f} KB)")


if __name__ == "__main__":
    main()
