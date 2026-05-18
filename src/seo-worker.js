const ORIGIN = "https://calcstudioapp.com";

const categoryPages = {
  "/category/calculator": page(
    "Calculator Tools | Calc Studio",
    "Use standard, scientific, advanced math and graphing calculators in Calc Studio.",
    "Calculator Tools",
    "Choose from standard arithmetic, scientific functions, advanced math helpers and graph plotting tools.",
    ["Standard Calculator", "Scientific Calculator", "Advanced Math", "Graphing Calculator"],
  ),
  "/category/finance": page(
    "Finance Calculators | Calc Studio",
    "Plan payments, savings, returns, salaries, discounts and taxes with free finance calculators.",
    "Finance Calculators",
    "Estimate loans, mortgages, investment growth, retirement savings, credit card payoff time and everyday money questions.",
    ["Compound Interest", "Loan Calculator", "Mortgage Calculator", "Credit Card Payoff", "Currency Converter"],
  ),
  "/category/units": page(
    "Unit Converters | Calc Studio",
    "Convert length, weight, volume, temperature, area, speed, time, data, pressure, energy, power and fuel units.",
    "Unit Converters",
    "Switch between common metric, imperial and technical units with practical converters for school, travel, cooking and projects.",
    ["Length", "Weight and Mass", "Volume", "Temperature", "Speed", "Energy"],
  ),
  "/category/health": page(
    "Health Calculators | Calc Studio",
    "Estimate BMI, BMR, calories, step distance, waist-to-hip ratio and pregnancy dates.",
    "Health Calculators",
    "Use simple health calculators for everyday estimates. Results are educational and should not replace medical advice.",
    ["BMI Calculator", "BMR and TDEE Calculator", "Steps to Calories", "Waist-to-Hip Ratio", "Pregnancy Calculator"],
  ),
  "/category/cooking": page(
    "Cooking Converters | Calc Studio",
    "Convert cooking measurements and oven temperatures for recipes.",
    "Cooking Converters",
    "Convert cups, grams, ounces, tablespoons, teaspoons and oven temperature scales while adapting recipes.",
    ["Cooking Converter", "Oven Temperature Converter"],
  ),
  "/category/home": page(
    "Home and Garden Calculators | Calc Studio",
    "Estimate square footage, flooring, electricity cost, mulch, gravel and paint for home projects.",
    "Home and Garden Calculators",
    "Plan common house and garden projects with material, area and energy cost calculators.",
    ["Square Footage", "Flooring Calculator", "Electricity Cost", "Mulch and Gravel", "Paint Calculator"],
  ),
  "/category/math": page(
    "Math Calculators | Calc Studio",
    "Solve percentage, fraction, statistics, quadratic, triangle, age, date, grade, Roman numeral and base conversion problems.",
    "Math Calculators",
    "Get quick answers for classroom math, date calculations, grades and number conversions.",
    ["Percentage Calculator", "Fraction Calculator", "Statistics Calculator", "Quadratic Solver", "Triangle Solver"],
  ),
};

const PAGES = {
  "/": page(
    "Calc Studio | Free Online Calculators for Math, Finance, Units and Health",
    "Use 54 free calculators for finance, scientific math, graphing, unit conversion, health, cooking, home projects and everyday math.",
    "Calc Studio - Free Online Calculators for Math, Finance, Units and Health",
    "Calc Studio brings calculators and converters into one fast app for students, everyday users and professionals.",
    ["Finance calculators", "Scientific and graphing calculators", "Unit converters", "Health and cooking tools", "Home project estimators"],
    "All-in-one calculator suite",
    "Why use Calc Studio?",
    "Most tools run directly on your device and show useful context such as formulas, steps, charts or tables where they help.",
  ),
  "/help": page(
    "Calc Studio Help | Calculator Tips and Support",
    "Find help for using Calc Studio calculators, reading results and sending feedback.",
    "Calc Studio Help",
    "Learn how to use the calculator suite, understand result panels and send examples when something needs attention.",
    ["Use the search and categories to find tools", "Check result cards for formulas and assumptions", "Send feedback with examples for incorrect results"],
  ),
  ...categoryPages,
  ...toolPages([
    ["/calculator", "Standard Calculator", "Basic arithmetic calculator for addition, subtraction, multiplication, division, percentages and quick everyday math.", ["Live result preview", "Calculation history", "Keyboard and keypad input"]],
    ["/scientific", "Scientific Calculator", "Use trigonometry, inverse trigonometry, logarithms, powers, roots, constants and DEG/RAD angle modes.", ["sin, cos, tan and inverse functions", "DEG and RAD modes", "Logs, roots, powers and constants"]],
    ["/advanced-math", "Advanced Math Calculator", "Work with derivatives, integrals, limits and visual math helpers for advanced expressions.", ["Derivative helpers", "Integral helpers", "Limit calculations", "Graph-supported exploration"]],
    ["/graph", "Graphing Calculator", "Plot functions of x, compare curves and inspect roots, intercepts, minimum and maximum values in the visible range.", ["Plot multiple functions", "Adjust graph range", "Estimate roots and intercepts"]],
    ["/compound-interest", "Compound Interest Calculator", "Calculate investment growth from principal, interest rate, compounding frequency, time and monthly contributions.", ["Future value", "Interest earned", "Year-by-year growth table"]],
    ["/loan", "Loan Calculator with Amortization", "Calculate monthly loan payments, total interest, payoff time and amortization schedules for fixed-rate loans.", ["Monthly payment", "Total interest", "Amortization table", "Extra payment savings"]],
    ["/mortgage", "Mortgage Calculator", "Estimate monthly mortgage payments including principal, interest, property tax and insurance.", ["Principal and interest", "Taxes and insurance", "Loan amount after down payment"]],
    ["/apy", "APY Calculator", "Convert APR and compounding frequency into annual percentage yield.", ["Effective annual yield", "Compounding comparison", "APR to APY conversion"]],
    ["/cagr", "CAGR Calculator", "Calculate compound annual growth rate from a starting value, ending value and time period.", ["Annualized growth", "Total return", "Formula breakdown"]],
    ["/currency", "Currency Converter", "Convert currencies using live exchange rates with cached offline-friendly results.", ["Live exchange rates", "Popular currency pairs", "Cached results"]],
    ["/future-value", "Future Value Calculator", "Estimate the future value of investments with contributions, interest and compounding.", ["Future balance", "Total contributions", "Interest earned"]],
    ["/retirement", "Retirement Planner", "Estimate retirement savings growth and compare future nest egg targets.", ["Projected balance", "Contribution planning", "Long-term growth estimates"]],
    ["/savings-goal", "Savings Goal Calculator", "Find how long it will take to reach a savings target with deposits and interest.", ["Time to goal", "Required savings", "Interest impact"]],
    ["/salary", "Salary Calculator", "Convert pay between hourly, weekly, monthly and annual salary amounts.", ["Hourly to annual", "Annual to monthly", "Work schedule assumptions"]],
    ["/pay-raise", "Pay Raise Calculator", "Calculate salary increases by percentage or dollar amount and compare old and new pay.", ["Raise amount", "New salary", "Percent increase"]],
    ["/credit-card", "Credit Card Payoff Calculator", "Find how long it takes to pay off credit card debt and how much interest you will pay.", ["Payoff months", "Total interest", "Low-payment warning"]],
    ["/stock-average", "Stock Average Price Calculator", "Calculate the average cost basis across multiple stock purchases.", ["Average share price", "Total shares", "Total invested"]],
    ["/tip", "Tip Calculator", "Calculate tips, split bills and per-person totals for restaurant checks.", ["Tip amount", "Bill split", "Per-person total"]],
    ["/sales-tax", "Sales Tax Calculator", "Calculate sales tax, VAT, pre-tax price or total price from a tax rate.", ["Add tax", "Remove tax", "Total purchase price"]],
    ["/discount", "Discount Calculator", "Calculate sale price, savings and final price after percentage discounts.", ["Discount amount", "Final price", "Stacked shopping checks"]],
    ["/units/length", "Length Converter", "Convert meters, feet, inches, yards, miles, centimeters and kilometers.", ["Metric and imperial units", "Feet to meters", "Miles to kilometers"]],
    ["/units/weight", "Weight and Mass Converter", "Convert kilograms, grams, pounds, ounces and stone.", ["Kilograms to pounds", "Ounces to grams", "Stone conversion"]],
    ["/units/volume", "Volume Converter", "Convert liters, milliliters, gallons, quarts, cups and fluid ounces.", ["Metric volume", "US volume", "Recipe-friendly units"]],
    ["/units/temperature", "Temperature Converter", "Convert Celsius, Fahrenheit and Kelvin temperatures.", ["Celsius to Fahrenheit", "Fahrenheit to Celsius", "Kelvin conversion"]],
    ["/units/area", "Area Converter", "Convert square meters, square feet, acres, hectares and other area units.", ["Square feet", "Acres", "Hectares"]],
    ["/units/speed", "Speed Converter", "Convert kilometers per hour, miles per hour, meters per second and knots.", ["mph to km/h", "m/s conversion", "Knots conversion"]],
    ["/units/time", "Time Converter", "Convert seconds, minutes, hours, days, weeks, months and years.", ["Seconds to hours", "Days to weeks", "Common time units"]],
    ["/units/data", "Data Storage Converter", "Convert bytes, KB, MB, GB, TB and PB.", ["Binary-style storage units", "File size conversions", "Large data units"]],
    ["/units/pressure", "Pressure Converter", "Convert pascal, bar, PSI, atm and mmHg pressure units.", ["PSI to bar", "Pascal conversion", "Atmospheres and mmHg"]],
    ["/units/energy", "Energy Converter", "Convert joules, calories, kilowatt-hours, BTU and other energy units.", ["Joules", "Calories", "kWh", "BTU"]],
    ["/units/power", "Power Converter", "Convert watts, kilowatts, horsepower and related power units.", ["Watts to horsepower", "Kilowatt conversion", "Power unit comparison"]],
    ["/units/fuel", "Fuel Consumption Converter", "Convert MPG, liters per 100 km and kilometers per liter.", ["MPG conversion", "L/100km conversion", "km/L conversion"]],
    ["/bmi", "BMI Calculator", "Calculate body mass index in metric or imperial units with standard adult BMI category ranges.", ["Metric and imperial inputs", "BMI category", "Formula explanation"]],
    ["/bmr", "BMR and TDEE Calculator", "Estimate basal metabolic rate and daily calorie needs using activity level.", ["BMR estimate", "Maintenance calories", "Activity multiplier"]],
    ["/steps", "Steps to Calories Calculator", "Estimate walking distance and calories burned from step count and body weight.", ["Distance estimate", "Calories burned", "Step count conversion"]],
    ["/waist-hip", "Waist-to-Hip Ratio Calculator", "Calculate waist-to-hip ratio and compare it with common health-risk reference ranges.", ["Ratio result", "Category guidance", "Metric and imperial inputs"]],
    ["/pregnancy", "Pregnancy Calculator", "Estimate due date, current pregnancy week and trimester from dates.", ["Due date", "Pregnancy week", "Trimester estimate"]],
    ["/cooking", "Cooking Converter", "Convert common cooking measurements including cups, grams, ounces, tablespoons and teaspoons.", ["Volume measures", "Weight measures", "Recipe conversions"]],
    ["/oven-temp", "Oven Temperature Converter", "Convert oven temperatures between Celsius, Fahrenheit and gas marks.", ["Celsius", "Fahrenheit", "Gas mark"]],
    ["/square-footage", "Square Footage Calculator", "Calculate room or area size from length and width measurements.", ["Area result", "Multiple units", "Project planning"]],
    ["/flooring", "Flooring Calculator", "Estimate flooring material needs for tile, hardwood, laminate or carpet projects.", ["Area coverage", "Waste allowance", "Material estimate"]],
    ["/electricity", "Electricity Cost Calculator", "Estimate electricity usage cost from power, time and energy rate.", ["kWh usage", "Cost estimate", "Appliance comparisons"]],
    ["/mulch", "Mulch and Gravel Calculator", "Estimate mulch, gravel or garden material volume for a coverage area and depth.", ["Coverage area", "Depth", "Material volume"]],
    ["/paint", "Paint Calculator", "Estimate how much paint is needed for walls, rooms and coats.", ["Wall area", "Coats", "Paint quantity"]],
    ["/percentage", "Percentage Calculator", "Solve common percentage questions including percent of a number, percent change and reverse percentage.", ["Percent of a number", "Percent change", "Reverse percentage"]],
    ["/fraction", "Fraction Calculator", "Add, subtract, multiply, divide and simplify fractions.", ["Fraction arithmetic", "Simplified result", "Mixed number support"]],
    ["/statistics", "Statistics Calculator", "Calculate mean, median, mode, range, quartiles and standard deviation.", ["Mean and median", "Mode and range", "Standard deviation"]],
    ["/quadratic", "Quadratic Solver", "Solve quadratic equations and inspect roots for ax squared plus bx plus c equals zero.", ["Real and complex roots", "Discriminant", "Formula steps"]],
    ["/triangle", "Triangle Solver", "Solve triangle sides, angles, area and perimeter from known values.", ["Side lengths", "Angles", "Area and perimeter"]],
    ["/age", "Age Calculator", "Calculate exact age in years, months and days between dates.", ["Exact age", "Next birthday", "Date difference"]],
    ["/date-diff", "Date Difference Calculator", "Calculate days, weeks, months and years between two dates.", ["Day count", "Weeks", "Months and years"]],
    ["/grade", "Grade Calculator", "Calculate weighted grades, GPA-style averages and target scores.", ["Weighted average", "Final grade", "Target score"]],
    ["/roman", "Roman Numeral Converter", "Convert between numbers and Roman numerals.", ["Number to Roman", "Roman to number", "Canonical numeral check"]],
    ["/base-converter", "Number Base Converter", "Convert numbers between binary, octal, decimal and hexadecimal.", ["Binary", "Octal", "Decimal", "Hexadecimal"]],
  ]),
};

function page(title, description, h1, summary, items, listTitle = "What this calculator shows", detailTitle = "How Calc Studio helps", detail) {
  return {
    title,
    description,
    keywords: keywordsFor(title, description),
    h1,
    summary,
    listTitle,
    items,
    detailTitle,
    detail: detail || "Calc Studio keeps the calculator fast, readable and usable across mobile, tablet and desktop browsers.",
  };
}

function toolPages(rows) {
  return Object.fromEntries(rows.map(([path, name, description, items]) => [
    path,
    page(
      `${name} | Calc Studio`,
      description,
      name,
      description,
      items,
      `What the ${name.toLowerCase()} shows`,
      "Formula and assumptions",
      "Results are estimates based on the values you enter. Where useful, Calc Studio shows formulas, steps, tables or breakdowns so you can understand the answer.",
    ),
  ]));
}

function keywordsFor(title, description) {
  return `${title.replace(" | Calc Studio", "").toLowerCase()}, online calculator, calc studio, ${description.toLowerCase().split(" ").slice(0, 8).join(" ")}`;
}

function normalizePath(pathname) {
  if (!pathname || pathname === "/") return "/";
  return pathname.replace(/\/+$/, "") || "/";
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function escapeAttr(value) {
  return escapeHtml(value);
}

function safeJson(value) {
  return JSON.stringify(value).replace(/</g, "\\u003c");
}

function renderList(items) {
  return items.map((item) => `      <li>${escapeHtml(item)}</li>`).join("\n");
}

function injectHead(html, path, route) {
  const canonical = `${ORIGIN}${path === "/" ? "/" : path}`;
  const bootstrap = {
    path,
    meta: {
      title: route.title,
      description: route.description,
      keywords: route.keywords,
    },
    content: {
      title: route.h1,
      summary: route.summary,
      listTitle: route.listTitle,
      items: route.items,
      detailTitle: route.detailTitle,
      detail: route.detail,
      faq: [
        [`What is ${route.h1}?`, route.description],
        ["Is Calc Studio free?", "Yes. Calc Studio calculators are free to use in your browser."],
      ],
    },
  };

  return html
    .replace(/<title>[\s\S]*?<\/title>/, `<title>${escapeHtml(route.title)}</title>`)
    .replace(/<meta name="description" content="[^"]*">/, `<meta name="description" content="${escapeAttr(route.description)}">`)
    .replace(/<meta property="og:title" content="[^"]*">/, `<meta property="og:title" content="${escapeAttr(route.title)}">`)
    .replace(/<meta property="og:description" content="[^"]*">/, `<meta property="og:description" content="${escapeAttr(route.description)}">`)
    .replace(/<meta property="og:url" content="[^"]*">/, `<meta property="og:url" content="${escapeAttr(canonical)}">`)
    .replace(/<meta name="twitter:title" content="[^"]*">/, `<meta name="twitter:title" content="${escapeAttr(route.title)}">`)
    .replace(/<meta name="twitter:description" content="[^"]*">/, `<meta name="twitter:description" content="${escapeAttr(route.description)}">`)
    .replace(/<link rel="canonical" href="[^"]*">/, `<link rel="canonical" href="${escapeAttr(canonical)}">`)
    .replace(
      '<link rel="manifest" href="manifest.json">',
      `<link rel="manifest" href="manifest.json">\n  <script>window.__CALC_STUDIO_SEO__=${safeJson(bootstrap)};</script>`,
    );
}

function injectBody(html, route) {
  return html
    .replace(/<h1 id="seo-title">[\s\S]*?<\/h1>/, `<h1 id="seo-title">${escapeHtml(route.h1)}</h1>`)
    .replace(/<p id="seo-summary">[\s\S]*?<\/p>/, `<p id="seo-summary">${escapeHtml(route.summary)}</p>`)
    .replace(/<h2 id="seo-list-title">[\s\S]*?<\/h2>/, `<h2 id="seo-list-title">${escapeHtml(route.listTitle)}</h2>`)
    .replace(/<ul id="seo-list">[\s\S]*?<\/ul>/, `<ul id="seo-list">\n${renderList(route.items)}\n    </ul>`)
    .replace(/<h2 id="seo-detail-title">[\s\S]*?<\/h2>/, `<h2 id="seo-detail-title">${escapeHtml(route.detailTitle)}</h2>`)
    .replace(/<p id="seo-detail">[\s\S]*?<\/p>/, `<p id="seo-detail">${escapeHtml(route.detail)}</p>`);
}

function withPageHeaders(response) {
  const headers = new Headers(response.headers);
  headers.set("Content-Type", "text/html; charset=UTF-8");
  headers.set("Cache-Control", "public, max-age=300, s-maxage=3600");
  headers.set("X-Content-Type-Options", "nosniff");
  headers.set("Referrer-Policy", "strict-origin-when-cross-origin");
  headers.set("Permissions-Policy", "geolocation=(), microphone=(), camera=(), payment=()");
  headers.set("X-Frame-Options", "SAMEORIGIN");
  headers.set("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
  return headers;
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = normalizePath(url.pathname);
    const route = PAGES[path];
    const response = await env.ASSETS.fetch(request);

    if (request.method !== "GET" || !route) {
      return response;
    }

    const contentType = response.headers.get("Content-Type") || "";
    if (!contentType.includes("text/html")) {
      return response;
    }

    let html = await response.text();
    html = injectBody(injectHead(html, path, route), route);

    return new Response(html, {
      status: response.status,
      statusText: response.statusText,
      headers: withPageHeaders(response),
    });
  },
};
