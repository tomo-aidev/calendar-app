#!/usr/bin/env python3
"""
Generate accurate dates of the 24 solar terms (二十四節気) for years 2020-2035.

Uses the ephem library to compute the Sun's ecliptic longitude and find
the exact moments when it reaches the specific degrees for each solar term.
Falls back to a pure-Python numerical approach if ephem is not available.

Output: assets/data/solar_terms_2020_2035.json
"""

import json
import math
import os
import sys
from datetime import datetime, timedelta, timezone

# Each solar term corresponds to a specific ecliptic longitude of the Sun.
# Starting from spring equinox (0°), each term is 15° apart.
# We list them in order of ecliptic longitude.
SOLAR_TERMS = [
    ("春分", 0),
    ("清明", 15),
    ("穀雨", 30),
    ("立夏", 45),
    ("小満", 60),
    ("芒種", 75),
    ("夏至", 90),
    ("小暑", 105),
    ("大暑", 120),
    ("立秋", 135),
    ("処暑", 150),
    ("白露", 165),
    ("秋分", 180),
    ("寒露", 195),
    ("霜降", 210),
    ("立冬", 225),
    ("小雪", 240),
    ("大雪", 255),
    ("冬至", 270),
    ("小寒", 285),
    ("大寒", 300),
    ("立春", 315),
    ("雨水", 330),
    ("啓蟄", 345),
]


def try_use_ephem():
    """Try to use the ephem library for high-accuracy computation."""
    try:
        import ephem
        return ephem
    except ImportError:
        return None


def solar_longitude_ephem(ephem_mod, dt):
    """Get the Sun's ecliptic longitude at a given datetime using ephem."""
    sun = ephem_mod.Sun()
    sun.compute(ephem_mod.Date(dt))
    # ephem returns ecliptic longitude in radians
    ecl = ephem_mod.Ecliptic(sun)
    return math.degrees(ecl.lon) % 360


def find_solar_term_date_ephem(ephem_mod, year, target_lon):
    """
    Find the date (JST) when the Sun reaches the target ecliptic longitude
    in the given year, using ephem with bisection.
    """
    # Estimate the approximate date based on longitude
    # Spring equinox (~Mar 20) is 0°, so offset from there
    days_from_equinox = (target_lon / 360.0) * 365.25
    approx_date = datetime(year, 3, 20, tzinfo=timezone.utc) + timedelta(days=days_from_equinox)

    # Handle wrap-around for terms before March 20
    if target_lon >= 285:  # 小寒 through 啓蟄 can be in the next calendar year
        # These terms (285°-345°) occur roughly Dec-Mar
        # The approx_date might overshoot into the next year
        pass

    # Search window: +/- 20 days from estimate
    lo = approx_date - timedelta(days=20)
    hi = approx_date + timedelta(days=20)

    def get_lon(dt):
        return solar_longitude_ephem(ephem_mod, dt)

    # Bisection method
    for _ in range(50):  # 50 iterations gives sub-second accuracy
        mid = lo + (hi - lo) / 2
        lon_mid = get_lon(mid)

        # Handle the 360°/0° boundary
        diff = (lon_mid - target_lon + 180) % 360 - 180

        if abs(diff) < 0.0001:  # Close enough
            break

        if diff < 0:
            lo = mid
        else:
            hi = mid

    # Convert to JST (UTC+9)
    jst = mid + timedelta(hours=9)
    return jst.strftime("%Y-%m-%d")


# ---------- Pure Python fallback using simplified VSOP87 ----------

def julian_day(year, month, day, hour=0.0):
    """Compute Julian Day Number."""
    if month <= 2:
        year -= 1
        month += 12
    A = int(year / 100)
    B = 2 - A + int(A / 4)
    return int(365.25 * (year + 4716)) + int(30.6001 * (month + 1)) + day + hour / 24.0 + B - 1524.5


def sun_ecliptic_longitude(jd):
    """
    Compute the Sun's ecliptic longitude using a simplified VSOP87-like formula.
    Accuracy: ~0.01 degrees (sufficient for determining the date of solar terms).
    """
    T = (jd - 2451545.0) / 36525.0  # Julian centuries from J2000.0

    # Mean longitude of the Sun
    L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T
    L0 = L0 % 360

    # Mean anomaly of the Sun
    M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T
    M_rad = math.radians(M % 360)

    # Equation of center
    C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * math.sin(M_rad)
    C += (0.019993 - 0.000101 * T) * math.sin(2 * M_rad)
    C += 0.000289 * math.sin(3 * M_rad)

    # Sun's true longitude
    sun_lon = L0 + C

    # Apparent longitude (correct for nutation and aberration)
    omega = 125.04 - 1934.136 * T
    sun_lon = sun_lon - 0.00569 - 0.00478 * math.sin(math.radians(omega))

    return sun_lon % 360


def find_solar_term_date_pure(year, target_lon):
    """
    Find the date (JST) when the Sun reaches the target ecliptic longitude
    using pure Python with bisection.
    """
    # Estimate approximate date
    days_from_equinox = (target_lon / 360.0) * 365.25
    approx_jd = julian_day(year, 3, 20, 12.0) + days_from_equinox

    # Search window
    lo = approx_jd - 20
    hi = approx_jd + 20

    for _ in range(60):
        mid = (lo + hi) / 2.0
        lon_mid = sun_ecliptic_longitude(mid)

        diff = (lon_mid - target_lon + 180) % 360 - 180

        if abs(diff) < 0.00001:
            break

        if diff < 0:
            lo = mid
        else:
            hi = mid

    # Convert JD to calendar date in JST (UTC+9)
    # mid is in UT, add 9 hours
    mid_jst = mid + 9.0 / 24.0

    # JD to calendar date
    z = int(mid_jst + 0.5)
    f = mid_jst + 0.5 - z

    if z < 2299161:
        a = z
    else:
        alpha = int((z - 1867216.25) / 36524.25)
        a = z + 1 + alpha - int(alpha / 4)

    b = a + 1524
    c = int((b - 122.1) / 365.25)
    d = int(365.25 * c)
    e = int((b - d) / 30.6001)

    day = b - d - int(30.6001 * e)
    month = e - 1 if e < 14 else e - 13
    yr = c - 4716 if month > 2 else c - 4715

    return f"{yr:04d}-{month:02d}-{day:02d}"


def generate_solar_terms(start_year=2020, end_year=2035):
    """Generate all solar term dates for the given year range."""
    ephem_mod = try_use_ephem()

    if ephem_mod:
        print("Using ephem library for high-accuracy computation.", file=sys.stderr)
        find_date = lambda year, lon: find_solar_term_date_ephem(ephem_mod, year, lon)
    else:
        print("ephem not available. Using simplified VSOP87 algorithm.", file=sys.stderr)
        find_date = find_solar_term_date_pure

    result = {}

    for year in range(start_year, end_year + 1):
        year_data = {}
        for name, lon in SOLAR_TERMS:
            # Solar terms with longitude >= 285 (小寒 onward) that occur in
            # early months of the year have their Sun at those longitudes
            # starting from the previous year's equinox cycle.
            # We need to search in the correct year.
            if lon >= 285:
                # These terms (小寒=285, 大寒=300, 立春=315, 雨水=330, 啓蟄=345)
                # occur in Jan-Mar of `year`, but the ecliptic search anchored
                # at Mar 20 of `year-1` would find them.
                date_str = find_date(year - 1, lon)
            else:
                date_str = find_date(year, lon)

            # Verify the date falls in the expected year
            date_year = int(date_str[:4])
            if date_year != year:
                # Try the other year
                if lon >= 285:
                    date_str = find_date(year, lon)
                else:
                    date_str = find_date(year - 1, lon)

            year_data[name] = date_str

        # Reorder to calendar order (Jan -> Dec)
        ordered = {}
        calendar_order = [
            "小寒", "大寒", "立春", "雨水", "啓蟄", "春分",
            "清明", "穀雨", "立夏", "小満", "芒種", "夏至",
            "小暑", "大暑", "立秋", "処暑", "白露", "秋分",
            "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"
        ]
        for name in calendar_order:
            ordered[name] = year_data[name]

        result[str(year)] = ordered

    return result


def validate(data):
    """Validate against known reference dates."""
    checks = [
        ("2020", "立春", "2020-02-04"),
        ("2020", "春分", "2020-03-20"),
        ("2020", "夏至", "2020-06-21"),
        ("2020", "秋分", "2020-09-22"),
        ("2020", "冬至", "2020-12-21"),
        ("2024", "立春", "2024-02-04"),
        ("2024", "春分", "2024-03-20"),
        ("2024", "夏至", "2024-06-21"),
        ("2026", "立春", "2026-02-04"),
    ]
    all_ok = True
    for year, term, expected in checks:
        actual = data[year][term]
        status = "OK" if actual == expected else "MISMATCH"
        if status != "OK":
            all_ok = False
        print(f"  {year} {term}: expected={expected}, actual={actual} [{status}]", file=sys.stderr)
    return all_ok


def main():
    data = generate_solar_terms(2020, 2035)

    print("Validation:", file=sys.stderr)
    ok = validate(data)
    if not ok:
        print("WARNING: Some validation checks failed!", file=sys.stderr)
    else:
        print("All validation checks passed.", file=sys.stderr)

    # Write JSON
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    output_path = os.path.join(project_dir, "assets", "data", "solar_terms_2020_2035.json")

    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Written to: {output_path}", file=sys.stderr)
    print(f"Years: {min(data.keys())}-{max(data.keys())}, Terms per year: {len(list(data.values())[0])}", file=sys.stderr)


if __name__ == "__main__":
    main()
