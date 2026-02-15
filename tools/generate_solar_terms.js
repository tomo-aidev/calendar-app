#!/usr/bin/env node
/**
 * Generate accurate dates of the 24 solar terms (二十四節気) for years 2020-2035.
 *
 * Uses a simplified VSOP87 algorithm to compute the Sun's ecliptic longitude
 * and bisection to find the exact moment when it reaches specific degrees.
 *
 * Output: assets/data/solar_terms_2020_2035.json
 */

const fs = require('fs');
const path = require('path');

// Solar terms with their ecliptic longitudes (degrees)
const SOLAR_TERMS_BY_LON = [
  ["春分", 0],
  ["清明", 15],
  ["穀雨", 30],
  ["立夏", 45],
  ["小満", 60],
  ["芒種", 75],
  ["夏至", 90],
  ["小暑", 105],
  ["大暑", 120],
  ["立秋", 135],
  ["処暑", 150],
  ["白露", 165],
  ["秋分", 180],
  ["寒露", 195],
  ["霜降", 210],
  ["立冬", 225],
  ["小雪", 240],
  ["大雪", 255],
  ["冬至", 270],
  ["小寒", 285],
  ["大寒", 300],
  ["立春", 315],
  ["雨水", 330],
  ["啓蟄", 345],
];

const CALENDAR_ORDER = [
  "小寒", "大寒", "立春", "雨水", "啓蟄", "春分",
  "清明", "穀雨", "立夏", "小満", "芒種", "夏至",
  "小暑", "大暑", "立秋", "処暑", "白露", "秋分",
  "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"
];

function julianDay(year, month, day, hour = 0) {
  if (month <= 2) {
    year -= 1;
    month += 12;
  }
  const A = Math.floor(year / 100);
  const B = 2 - A + Math.floor(A / 4);
  return Math.floor(365.25 * (year + 4716)) + Math.floor(30.6001 * (month + 1)) + day + hour / 24.0 + B - 1524.5;
}

function sunEclipticLongitude(jd) {
  const T = (jd - 2451545.0) / 36525.0;

  // Mean longitude
  let L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T;
  L0 = ((L0 % 360) + 360) % 360;

  // Mean anomaly
  let M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T;
  const Mrad = (((M % 360) + 360) % 360) * Math.PI / 180;

  // Equation of center
  const C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * Math.sin(Mrad)
    + (0.019993 - 0.000101 * T) * Math.sin(2 * Mrad)
    + 0.000289 * Math.sin(3 * Mrad);

  let sunLon = L0 + C;

  // Apparent longitude (nutation + aberration)
  const omega = 125.04 - 1934.136 * T;
  sunLon = sunLon - 0.00569 - 0.00478 * Math.sin(omega * Math.PI / 180);

  return ((sunLon % 360) + 360) % 360;
}

function jdToDate(jd) {
  // Convert JD to calendar date
  const z = Math.floor(jd + 0.5);
  const f = jd + 0.5 - z;

  let a;
  if (z < 2299161) {
    a = z;
  } else {
    const alpha = Math.floor((z - 1867216.25) / 36524.25);
    a = z + 1 + alpha - Math.floor(alpha / 4);
  }

  const b = a + 1524;
  const c = Math.floor((b - 122.1) / 365.25);
  const d = Math.floor(365.25 * c);
  const e = Math.floor((b - d) / 30.6001);

  const day = b - d - Math.floor(30.6001 * e);
  const month = e < 14 ? e - 1 : e - 13;
  const year = month > 2 ? c - 4716 : c - 4715;

  return { year, month, day };
}

function findSolarTermDate(year, targetLon) {
  // Approximate date: spring equinox ~Mar 20 is 0°
  const daysFromEquinox = (targetLon / 360.0) * 365.25;
  const approxJD = julianDay(year, 3, 20, 12.0) + daysFromEquinox;

  let lo = approxJD - 20;
  let hi = approxJD + 20;

  for (let i = 0; i < 60; i++) {
    const mid = (lo + hi) / 2.0;
    const lonMid = sunEclipticLongitude(mid);
    let diff = ((lonMid - targetLon + 180) % 360 + 360) % 360 - 180;

    if (Math.abs(diff) < 0.00001) break;

    if (diff < 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }

  const mid = (lo + hi) / 2.0;
  // Convert to JST (UTC+9)
  const midJST = mid + 9.0 / 24.0;
  const { year: y, month: m, day: d } = jdToDate(midJST);
  return `${String(y).padStart(4, '0')}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

function generateSolarTerms(startYear = 2020, endYear = 2035) {
  const result = {};

  for (let year = startYear; year <= endYear; year++) {
    const yearData = {};

    for (const [name, lon] of SOLAR_TERMS_BY_LON) {
      let dateStr;
      if (lon >= 285) {
        // Terms in Jan-Mar: search from previous year's equinox cycle
        dateStr = findSolarTermDate(year - 1, lon);
        const dateYear = parseInt(dateStr.substring(0, 4));
        if (dateYear !== year) {
          dateStr = findSolarTermDate(year, lon);
        }
      } else {
        dateStr = findSolarTermDate(year, lon);
        const dateYear = parseInt(dateStr.substring(0, 4));
        if (dateYear !== year) {
          dateStr = findSolarTermDate(year - 1, lon);
        }
      }
      yearData[name] = dateStr;
    }

    // Reorder to calendar order
    const ordered = {};
    for (const name of CALENDAR_ORDER) {
      ordered[name] = yearData[name];
    }
    result[String(year)] = ordered;
  }

  return result;
}

function validate(data) {
  const checks = [
    ["2020", "立春", "2020-02-04"],
    ["2020", "春分", "2020-03-20"],
    ["2020", "夏至", "2020-06-21"],
    ["2020", "秋分", "2020-09-22"],
    ["2020", "冬至", "2020-12-21"],
    ["2024", "立春", "2024-02-04"],
    ["2024", "春分", "2024-03-20"],
    ["2024", "夏至", "2024-06-21"],
    ["2026", "立春", "2026-02-04"],
  ];

  let allOk = true;
  for (const [year, term, expected] of checks) {
    const actual = data[year][term];
    const status = actual === expected ? "OK" : "MISMATCH";
    if (status !== "OK") allOk = false;
    console.error(`  ${year} ${term}: expected=${expected}, actual=${actual} [${status}]`);
  }
  return allOk;
}

// Main
const data = generateSolarTerms(2020, 2035);

console.error("Validation:");
const ok = validate(data);
if (!ok) {
  console.error("WARNING: Some validation checks failed!");
} else {
  console.error("All validation checks passed.");
}

const outputPath = path.join(__dirname, '..', 'assets', 'data', 'solar_terms_2020_2035.json');
fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, JSON.stringify(data, null, 2) + '\n', 'utf-8');
console.error(`Written to: ${outputPath}`);
console.error(`Years: ${Object.keys(data)[0]}-${Object.keys(data).pop()}, Terms per year: ${Object.keys(Object.values(data)[0]).length}`);
