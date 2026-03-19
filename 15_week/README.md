# Week 15: Interactive Visualization with R Shiny
## PLSC 498 - Visualizing Social Data

This folder contains all course materials for Week 15, focusing on building interactive web applications with R Shiny.

---

## Folder Structure

```
15_week/
├── slides/
│   ├── 15_01_week.Rmd          # Lecture 1: Shiny Basics
│   ├── 15_02_week.Rmd          # Lecture 2: Advanced Layouts
│   ├── plsc498.css             # Shared styling for xaringan slides
│   └── [compiled HTML files]
├── data/
│   ├── create_data.R           # Data curation script
│   ├── senate_app_01_basic.R   # Approach 1: Basic sidebar layout
│   ├── senate_app_02_navbar.R  # Approach 2: Navigation bar
│   ├── cow_app_03_dashboard.R  # Approach 3: Shinydashboard
│   └── cow_app_04_bslib.R      # Approach 4: Modern bslib theming
├── problem_set/
│   └── [problem set files]
└── README.md                   # This file
```

---

## Course Materials Overview

### Lectures

#### **Lecture 1: Introduction to Shiny** (`15_01_week.Rmd`)
- What is R Shiny and why use it?
- Structure of Shiny apps (UI + Server)
- Reactive programming model
- Input and output functions
- Common UI layouts (sidebar, tabs, navbar)
- Reactive expressions and filters
- Complete walkthrough of Senate ideology app

**Topics covered:** 428 lines, 15 slides with code examples

#### **Lecture 2: Advanced Layouts** (`15_02_week.Rmd`)
- Navigation bar layout (`navbarPage()`)
- Shinydashboard framework
- Modern design with bslib
- Comparison of all four approaches
- Correlates of War dataset overview
- App case studies with each approach
- Best practices and common patterns
- Deployment options
- Debugging tips

**Topics covered:** 752 lines, 30+ slides with comprehensive examples

---

## Shiny App Templates

Four different approaches to building Shiny apps, each demonstrating a different layout style:

### **Approach 1: Basic Sidebar Layout** (`senate_app_01_basic.R`)
- **Dataset:** US Senate ideology scores (DW-NOMINATE)
- **Controls:** Congress selector, party filter, slider
- **Outputs:** Scatter plot, histogram, data table
- **Use case:** Simple apps with few controls
- **Lines:** 168
- **Dependencies:** shiny, dplyr, ggplot2, Rvoteview

**Features:**
- Straightforward sidebar + main panel layout
- Three tabbed outputs
- Reactive data filtering
- Clean, minimal design

### **Approach 2: Navigation Bar Layout** (`senate_app_02_navbar.R`)
- **Dataset:** US Senate ideology scores
- **Navigation:** 4 main tabs (Visualization, Statistics, Data, About)
- **Features:** Interactive statistics, downloadable data
- **Use case:** Multi-section apps with clear hierarchy
- **Lines:** 271
- **Dependencies:** shiny, dplyr, ggplot2, bslib

**Features:**
- Top navigation bar with multiple sections
- Collapsible filters
- Summary statistics with reactive updates
- State-level breakdown table
- CSV download functionality

### **Approach 3: Shinydashboard** (`cow_app_03_dashboard.R`)
- **Dataset:** Correlates of War interstate conflicts
- **Components:** Value boxes, sidebar menu, tabbed content
- **Use case:** Professional dashboards for monitoring KPIs
- **Lines:** 406
- **Dependencies:** shiny, shinydashboard, dplyr, ggplot2, plotly

**Features:**
- Dashboard header with title
- Left sidebar with filters and menu
- KPI value boxes (total wars, deaths, duration, countries)
- Multiple analysis tabs
- Plotly interactive visualizations
- Data explorer with raw data

### **Approach 4: Modern bslib Design** (`cow_app_04_bslib.R`)
- **Dataset:** Correlates of War interstate conflicts
- **Framework:** Bootstrap 5 with bslib
- **Components:** Page navbar, responsive cards, modern theme
- **Use case:** Modern, mobile-responsive applications
- **Lines:** 462
- **Dependencies:** shiny, bslib, dplyr, ggplot2, plotly

**Features:**
- Modern Bootstrap 5 design
- Responsive sidebar layout
- Color-themed cards with full-screen toggle
- Multiple navigation tabs
- Plotly interactive charts
- Markdown content support
- Professional styling throughout

---

## Data Curation

### `create_data.R`
Comprehensive script to download or generate both datasets:

**US Senate Data:**
- Downloads using `Rvoteview` package
- Gets DW-NOMINATE ideology scores for recent Congresses
- Includes: member ID, name, state, party, Congress, ideology dimensions
- Fallback: generates synthetic data if download fails
- Outputs: `senate_ideology.rds`, `senate_ideology.csv`

**Correlates of War Data:**
- Downloads using `peacesciencer` package with `create_stateyears()` and `add_cow_wars()`
- Includes: state, year, war number, war type, duration, fatalities
- Fallback: generates synthetic conflict data
- Outputs: `cow_wars.rds`, `cow_wars.csv`

**How to run:**
```r
# In RStudio, open create_data.R and run all
source("data/create_data.R")

# Or from console:
setwd("15_week")
source("data/create_data.R")
```

---

## Running the Apps

### Prerequisites
Install required packages first:
```r
install.packages(c("shiny", "dplyr", "ggplot2", "plotly"))
install.packages("shinydashboard")
install.packages("bslib")
install.packages("Rvoteview")  # For senate data
install.packages("peacesciencer")  # For COW data
```

### Running Each App

**Option 1: RStudio**
1. Open the `.R` file in RStudio
2. Click the "Run App" button in the toolbar
3. App opens in a browser window

**Option 2: Console**
```r
setwd("15_week/data")
shiny::runApp("senate_app_01_basic.R")
shiny::runApp("senate_app_02_navbar.R")
shiny::runApp("cow_app_03_dashboard.R")
shiny::runApp("cow_app_04_bslib.R")
```

**Option 3: From Outside the Directory**
```r
shiny::runApp("path/to/15_week/data/senate_app_01_basic.R")
```

### Data Requirements
Apps expect to find `.rds` files in the same directory:
- `senate_ideology.rds`
- `cow_wars.rds`

Run `create_data.R` first to generate these files.

---

## Comparison of Four Approaches

| Feature | Basic | Navbar | Dashboard | bslib |
|---------|-------|--------|-----------|-------|
| **Learning Curve** | Very Easy | Easy | Medium | Medium |
| **Lines of Code** | 168 | 271 | 406 | 462 |
| **Visual Appeal** | Good | Good | Professional | Excellent |
| **Mobile Responsive** | Yes | Yes | Yes | Yes |
| **Best For** | Simple apps | Multi-section | KPI monitoring | Modern design |
| **Setup Complexity** | Minimal | Low | Medium | Low |
| **Customization** | Good | Good | Limited | Excellent |
| **Recommended Use** | Learning | Small to medium | Enterprise | Modern projects |

---

## Key Concepts Taught

### Shiny Fundamentals
- **UI (User Interface):** Layout functions (`fluidPage`, `sidebarLayout`, etc.)
- **Server:** Reactive logic and event handlers
- **Reactivity:** Automatic updates when inputs change
- **Reactive Expressions:** Reusable computed values

### Input Functions
`textInput()`, `numericInput()`, `sliderInput()`, `selectInput()`, `checkboxInput()`, `checkboxGroupInput()`, `radioButtons()`, `actionButton()`, `dateInput()`, `fileInput()`

### Output Functions
`textOutput()`, `plotOutput()`, `tableOutput()`, `dataTableOutput()`, `htmlOutput()`, `verbatimTextOutput()`

### Rendering Functions
`renderPlot()`, `renderText()`, `renderTable()`, `renderDataTable()`, `renderUI()`, `renderPrint()`

### Layout Patterns
1. **Sidebar Layout:** `sidebarLayout(sidebarPanel(), mainPanel())`
2. **Navigation Bar:** `navbarPage(tabPanel(), tabPanel(), ...)`
3. **Dashboard:** `dashboardPage(dashboardHeader(), dashboardSidebar(), dashboardBody())`
4. **Modern Pages:** `page_navbar()`, `layout_sidebar()`, `navset_card_tab()`

### Advanced Patterns
- Reactive dependencies and isolation
- Conditional UI rendering
- Download handlers
- Tabbed interfaces
- Value boxes and cards
- Interactive visualizations (Plotly)

---

## Learning Path

1. **Start Here:** Read Lecture 1 slides
2. **Run the basic app:** `senate_app_01_basic.R`
3. **Read Lecture 2 slides**
4. **Explore each approach:**
   - Senate navbarPage approach
   - COW dashboard approach
   - COW bslib approach
5. **Modify apps:** Change colors, add new plots, filter differently
6. **Create your own:** Apply to your own data

---

## Common Issues and Solutions

### "Error: object 'senate_data' not found"
- **Cause:** Data file not in working directory
- **Solution:** Run `create_data.R` first, or check working directory with `getwd()`

### "Error: could not find function 'shinyApp'"
- **Cause:** shiny package not loaded
- **Solution:** Add `library(shiny)` to top of script

### "Reactive not updating when input changes"
- **Cause:** Forgot parentheses when calling reactive
- **Solution:** Use `filtered_data()` not `filtered_data`

### "App won't run - syntax error"
- **Cause:** Missing parenthesis or bracket
- **Solution:** Check RStudio's error highlighting (red X on line)

### "Plots/outputs are blank"
- **Cause:** Input filtering removed all data
- **Solution:** Check input ranges, verify data exists

---

## Deployment Options

### Local Sharing
```r
# Others access via your IP
shiny::runApp(host = "0.0.0.0", port = 8100)
```

### shinyapps.io (Free Tier Available)
```r
library(rsconnect)
rsconnect::deployApp("path/to/app")
```

### Docker
```dockerfile
FROM rocker/shiny:latest
COPY data/senate_app_01_basic.R /srv/shiny-server/app/app.R
```

---

## Additional Resources

### Official Documentation
- [Shiny Official Site](https://shiny.rstudio.com/)
- [Shiny Cheat Sheet](https://raw.githubusercontent.com/rstudio/cheatsheets/master/shiny.pdf)
- [shinydashboard Documentation](https://rstudio.github.io/shinydashboard/)
- [bslib Documentation](https://rstudio.github.io/bslib/)

### Tutorials
- [RStudio Shiny Tutorial](https://shiny.rstudio.com/tutorial/)
- [Shiny Gallery](https://shiny.rstudio.com/gallery/)

### Books
- "Mastering Shiny" by Hadley Wickham (free online)
- "Outstanding User Interfaces with Shiny" by David Granjon

### Data Sources
- [Rvoteview](https://voteview.com/) - Senate voting data
- [Correlates of War](https://correlatesofwar.org/) - Conflict data

---

## File Manifest

| File | Type | Lines | Purpose |
|------|------|-------|---------|
| `15_01_week.Rmd` | Lecture | 428 | Introduction to Shiny fundamentals |
| `15_02_week.Rmd` | Lecture | 752 | Advanced layouts and case studies |
| `plsc498.css` | Style | 5 | Custom CSS for xaringan slides |
| `create_data.R` | Script | 202 | Data curation (Senate + COW) |
| `senate_app_01_basic.R` | Shiny App | 168 | Basic sidebar layout (Senate) |
| `senate_app_02_navbar.R` | Shiny App | 271 | Navigation bar layout (Senate) |
| `cow_app_03_dashboard.R` | Shiny App | 406 | Shinydashboard approach (COW) |
| `cow_app_04_bslib.R` | Shiny App | 462 | Modern bslib design (COW) |

**Total:** 2,689 lines of teaching materials and code

---

## Credits and Attribution

Created for PLSC 498: Visualizing Social Data
Penn State University
Instructor: Jared Edgerton

Course materials incorporate:
- Official RStudio Shiny documentation
- Correlates of War project data
- VoteView/Rvoteview package
- Best practices from R community

---

## Version History

- **v1.0** (March 16, 2026): Initial release with all four app approaches
  - 2 comprehensive lecture slides
  - 4 Shiny app templates (basic, navbar, dashboard, bslib)
  - Complete data curation script
  - CSS styling and documentation
