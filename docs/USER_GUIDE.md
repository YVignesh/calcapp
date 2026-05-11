# Calc Studio — User Guide

This is the manual for **Calc Studio**, the all-in-one calculator app. The same content is available inside the app: tap the **`?`** icon on the home screen or on any calculator screen.

---

## Contents

1. [Getting around](#1-getting-around)
2. [Using any calculator](#2-using-any-calculator)
3. [Time periods — days, months or years](#3-time-periods--days-months-or-years)
4. [Calculator category](#4-calculator-category)
   - [Standard](#standard-calculator)
   - [Scientific (incl. inverse trig)](#scientific-calculator)
   - [Graphing calculator](#graphing-calculator)
   - [Advanced math — derivatives, integrals, limits](#advanced-math)
5. [Finance](#5-finance)
6. [Unit Converter](#6-unit-converter)
7. [Health](#7-health)
8. [Cooking](#8-cooking)
9. [Home & Garden](#9-home--garden)
10. [Math & More](#10-math--more)
11. [Themes](#11-themes)
12. [Privacy & data](#12-privacy--data)
13. [Troubleshooting & FAQ](#13-troubleshooting--faq)

---

## 1. Getting around

- The **home screen** shows the seven categories. Tap one to see its tools.
- Use the **search bar** at the top of the home screen — it matches tool names, descriptions and category names. Type "loan", "bmi", "tip", "sin", etc.
- On a laptop/desktop browser, **hover** a category card to preview the tools inside it.
- Every screen has a coloured header; the **colour tells you which category** you are in (Finance is green, Health is pink, Math is purple, and so on).
- Tap **`?`** in the top‑right of any screen to open this guide; the **back arrow** (top‑left) returns to the previous screen.

---

## 2. Using any calculator

1. Fill in the input fields.
2. Tap **Calculate** (or **Convert** / **Plot**, depending on the tool).
3. The answer appears in a coloured **result card**. Tap the **copy** icon on the card to copy the value to your clipboard.
4. The **teal banner** at the top of every tool explains what the tool does and the formula it uses — read it if you're unsure what an input means.
5. Some tools show extra detail below the main result (breakdown tables, charts, secondary figures). Tables with a **copy** icon can be exported as CSV.

---

## 3. Time periods — days, months or years

Calculators that involve a **duration** let you pick the unit from a dropdown next to the number:

- **Compound Interest** — investment term
- **Future Value** — investment term
- **Loan Calculator** — loan term
- **CAGR** — measurement period

Choose **Days**, **Months** or **Years**. Internally everything is converted to years (e.g. *18 Months* = *1.5 Years*), so you're never restricted to whole years.

---

## 4. Calculator category

### Standard calculator
A clean everyday calculator: digits, `+ − × ÷`, `%`, parentheses, decimal point, `⌫` (delete one character) and `AC` (clear all).

### Scientific calculator
Everything in the standard calculator, plus:

- **Trigonometry:** `sin`, `cos`, `tan` and their inverses **`sin⁻¹`, `cos⁻¹`, `tan⁻¹`**.
- **DEG / RAD toggle** — the middle key in the top row of the keypad. In **DEG** mode, angles you enter are treated as degrees and the inverse functions return degrees; in **RAD** mode they're radians. The current mode is shown above the expression (`DEG` / `RAD`).
- **Logarithms & powers:** `log`, `ln`, `x²`, `xⁿ` (general power), `√`.
- **Constants:** `π`, `e`.
- **Live preview** — the result is computed as you type and shown below the expression.
- **History** — tap the clock icon (top‑right) to see recent results; tap one to reuse its value. `Clear` empties the list.
- `⌫` deletes one character; `AC` clears everything.

> **Example:** in DEG mode, `sin( 30 )` → `0.5`; `sin⁻¹( 0.5 )` → `30`. In RAD mode the same `sin⁻¹( 0.5 )` → `0.5235987…`.

### Graphing calculator
Plot up to **three functions of *x*** on the same axes.

1. **Tap a function row** (`f(x)`, `g(x)` or `h(x)`) to make it the active one.
2. Build the equation with the **on‑screen math keypad**:
   - `x` inserts the variable, `x²` inserts a square, `xⁿ` inserts a power, `√` inserts a square root, `π` and `eˣ` are available, plus `sin cos tan ln`.
   - You can write maths **naturally**: `2x` means `2×x`, `3(x+1)` means `3×(x+1)`, `(x)(x)` means `x×x`. Powers are written with `^` and shown as superscripts.
3. Set the **X min** and **X max** for the visible window.
4. Tap **Plot**. Use **Zoom in / Zoom out** to change the window.
5. The **analysis card** for `f(x)` lists the y‑intercept, the x‑intercepts (roots) found in the window, and the minimum and maximum value in view.

The plot handles vertical asymptotes by breaking the curve, and auto‑scales the y‑axis (trimming extreme spikes so the rest of the graph stays readable). A legend below the chart names each curve.

### Advanced math
Three calculus tools, each with a graph. Use **`x`** as the variable and the math keypad to enter `f(x)`.

- **Derivative** — enter `f(x)` and a value of `x`. The app returns the numerical derivative *f′(x)* at that point (symmetric difference quotient) and draws `f(x)` together with the **tangent line** at that point.
- **Integral** — enter `f(x)` and the bounds *a* and *b*. The app returns the definite integral ∫ₐᵇ f(x) dx by **Simpson's rule** (n = 1000) and draws `f(x)` with the **area between *a* and *b* shaded**.
- **Limit** — enter `f(x)` and the point `x` approaches. The app evaluates the **two‑sided limit** numerically and draws `f(x)` near that point with the limit **marked**. If the left and right values disagree, it tells you the limit does not exist; if the function oscillates wildly near the point, it flags the answer as approximate.

> **Example:** Derivative of `x^3 + 2*x` at `x = 2` → `14`. Integral of `sin(x)` from `0` to `3.14159` → ≈ `2`. Limit of `sin(x)/x` as `x → 0` → `1`.

---

## 5. Finance

| Tool | What it does |
| --- | --- |
| **Compound Interest** | Future value with regular contributions; year‑by‑year breakdown; APY, time to double, total rate of return; **growth chart** (balance vs. contributions). |
| **Loan Calculator** | Monthly payment, total interest, principal‑vs‑interest split, full amortization schedule (CSV export), and an extra‑payment "what if" (payoff time and interest saved). |
| **Mortgage Calculator** | PITI payment from home price, down payment, rate, term, property tax and insurance. |
| **APY Calculator** | Annual percentage yield from a nominal rate + compounding frequency; simple‑vs‑compound comparison when you supply a principal. |
| **CAGR Calculator** | Compound annual growth rate from start/end values; total return and absolute gain; inverse mode — the end value needed to hit a target CAGR. |
| **Currency Converter** | Live exchange rates for 30+ currencies (mid‑market reference rates, refreshed daily). |
| **Future Value** | Future value of a lump sum plus monthly contributions. |
| **Retirement Planner** | Projected nest egg at retirement and the income it supports via the 4% safe‑withdrawal rule. |
| **Savings Goal** | How long to reach a savings target given a starting balance, monthly contribution and rate. |
| **Salary Converter** | Convert between hourly, weekly, monthly and annual pay. |
| **Pay Raise** | New salary and the increase amount from a percentage raise. |
| **Credit Card Payoff** | Time and total interest to pay off a balance at a given monthly payment. |
| **Stock Average** | Average cost per share across multiple purchases. |
| **Tip Calculator** | Tip amount and total, with a slider, quick‑percentage buttons and bill split. |
| **Sales Tax / VAT** | Add tax to a price, or back out the pre‑tax amount from a tax‑inclusive price. |
| **Discount** | Sale price and amount saved from a percentage discount. |

---

## 6. Unit Converter

Pick a quantity, choose **From** and **To** units, type a value. The result appears immediately, and a list shows the value in **every** unit of that type at once. Tap the swap button to flip From/To.

Supported quantities: **Length, Weight/Mass, Volume, Temperature, Area, Speed, Time, Data Storage, Pressure, Energy, Power, Fuel Consumption.**

---

## 7. Health

| Tool | What it does |
| --- | --- |
| **BMI** | Body Mass Index with the category band. |
| **BMR** | Basal Metabolic Rate and estimated daily calories by activity level. |
| **Steps to Calories** | Distance walked and calories burned from a step count. |
| **Waist‑to‑Hip Ratio** | Ratio plus the health‑risk band. |
| **Pregnancy** | Estimated due date, current week and trimester from the last‑period date. |

*(Health figures are estimates for general guidance, not medical advice.)*

---

## 8. Cooking

- **Cooking Converter** — cups ↔ grams ↔ ounces ↔ tablespoons, ingredient‑aware where it matters.
- **Oven Temperature** — °C ↔ °F ↔ Gas Mark.

---

## 9. Home & Garden

- **Square Footage** — room/area size from dimensions.
- **Flooring** — material needed for tiles, hardwood, laminate or carpet (with wastage).
- **Electricity Cost** — running cost of an appliance from its wattage and usage.
- **Mulch & Gravel** — volume of garden material for a bed of a given size and depth.
- **Paint** — litres/gallons needed for a given wall area and number of coats.

---

## 10. Math & More

| Tool | What it does |
| --- | --- |
| **Percentage** | "What is X% of Y?", "X is what % of Y?", percentage change. |
| **Fraction** | Add, subtract, multiply and divide fractions; simplified result. |
| **Statistics** | Mean, median, mode, range, quartiles/IQR, population & sample standard deviation and variance from a list of numbers. |
| **Quadratic Solver** | Roots (real or complex) of *ax² + bx + c = 0*, plus the vertex and axis of symmetry. |
| **Triangle Solver** | Solve any triangle from 3 known sides/angles (Law of Sines & Cosines); area, perimeter, in‑/circum‑radius. |
| **Age Calculator** | Exact age in years, months and days; total days lived; next birthday. |
| **Date Difference** | Days, weeks and months between two dates. |
| **Grade / GPA** | Weighted grade average and GPA. |
| **Roman Numerals** | Convert numbers ↔ Roman numerals (1–3999). |
| **Number Base Converter** | Binary ↔ octal ↔ decimal ↔ hexadecimal. |

---

## 11. Themes

Tap the **sun / moon** icon in the top‑right of the home screen to switch between light and dark. Your choice is saved and restored next time you open the app.

---

## 12. Privacy & data

- **Every calculation runs on your device.** Your inputs are never uploaded.
- **No account, no sign‑in, no tracking.**
- The **only** network request the app makes is for **live currency exchange rates**, fetched from the free, key‑less `api.frankfurter.app` API and cached for 30 minutes.
- Your **theme preference** is stored locally on the device.

---

## 13. Troubleshooting & FAQ

**A scientific / graphing expression gives no result.**
Check the expression is well‑formed: matched parentheses, `x` as the variable, functions written as `sin(...)`, `ln(...)`, `sqrt(...)`. Implicit multiplication is supported (`2x`, `3(x+1)`) but a stray letter or operator will make it invalid.

**Inverse trig (`sin⁻¹` etc.) returns degrees, but I expected radians (or vice versa).**
That's the **DEG / RAD** toggle on the scientific calculator. Switch it with the middle key in the top keypad row.

**Currency result looks slightly off compared to my bank.**
The app uses **mid‑market reference rates** published once per business day. Banks and cards add a spread/fee, so a transaction rate will differ.

**The graph cuts off near an asymptote / looks empty.**
Vertical asymptotes break the curve on purpose. If a curve looks flat, the y‑axis was scaled to fit a large spike elsewhere — narrow the **X min/max** window and plot again.

**Health numbers — are they medical advice?**
No. BMI, BMR, pregnancy dates etc. are general estimates. Consult a professional for medical decisions.

**Does the app work offline?**
Yes — everything except the live currency rates works with no connection. Currency uses the most recently cached rates when offline.
