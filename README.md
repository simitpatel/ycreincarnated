# YC Reincarnated

**Transform Y Combinator applications into professional pitch decks automatically**

Application to turn a PDF of a YC application into a 10-slide pitch deck using AI-powered content extraction and structured data processing.

**Live Demo**: https://sixjupiter.shinyapps.io/ycreincarnated/

## Overview

This R Shiny application uses Claude AI models to:
1. **Validate** uploaded PDFs as legitimate YC applications (using cost-effective Claude Haiku)
2. **Extract** structured pitch deck content (using Claude Sonnet with ellmer's structured data types)
3. **Generate** professional presentations in multiple formats (HTML, PowerPoint, PDF)
4. **Deliver** results via email with cloud-hosted download links

## Tech Stack

- **Backend**: R 4.5.1, Shiny web framework
- **AI Processing**: Anthropic Claude models via ellmer package
- **Document Generation**: Quarto for multi-format rendering
- **File Processing**: pdftools for PDF text extraction
- **Cloud Storage**: Google Cloud Storage for file hosting
- **Email**: Mailgun API for delivery
- **Deployment**: shinyapps.io

## Prerequisites

### Required Software
- **R 4.5.1+**: Download from [CRAN](https://cran.r-project.org/)
- **Quarto CLI**: Install from [quarto.org](https://quarto.org/docs/get-started/)
- **LaTeX distribution** (for PDF generation): 
  - macOS: MacTeX
  - Windows: MikTeX
  - Linux: TeX Live

### Required R Packages
```r
install.packages(c(
  "shiny", "shinydashboard", "shinyWidgets", "shinyjs", "DT",
  "ellmer", "pdftools", "googleCloudStorageR", 
  "glue", "purrr", "httr", "rmarkdown", "quarto"
))
```

## Environment Setup

Create a `.Renviron` file in your project root with:

```bash
# Anthropic API (required for AI processing)
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Google Cloud Storage (required for file hosting)
BUCKET_NAME_192=your_gcs_bucket_name
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json

# Mailgun API (required for email delivery)
mailgun_key=your_mailgun_private_api_key
```

## File Structure

```
├── app.R                          # Main Shiny application
├── yc_pitch_deck_template.qmd     # Quarto template with {{placeholders}}
├── generated_decks/               # Output directory (auto-created)
├── .Renviron                      # Environment variables (not in repo)
└── README.md
```

## Key Components

### 1. PDF Validation
Uses Claude Haiku ($0.25/MTok input) for cost-effective filtering:
```r
chat_haiku <- chat_anthropic(model='claude-3-5-haiku-20241022')
valid_or_not <- chat_haiku$chat("Is this a valid YC application? Reply 1 or 0.")
```

### 2. Structured Data Extraction
Leverages ellmer's type system for guaranteed JSON output:
```r
yc_pitch_deck_type <- type_object(
  company_name = type_string("Official company name"),
  tagline = type_string("Compelling one-line description"),
  # ... 45 total structured fields
)
```

### 3. Template Population
Dynamic Quarto template with variable substitution:
```r
template_text <- gsub("{{company_name}}", pitch_data$company_name, template_text)
```

### 4. Multi-format Rendering
Supports HTML (RevealJS), PowerPoint, and PDF output with fallback handling.

## Development Notes

### Cost Optimization
- **Validation**: Uses cheaper Haiku model (~$0.0002 per application)
- **Extraction**: Uses Sonnet model (~$0.03 per application) for quality
- **File hosting**: Public GCS links avoid email attachment limits

### Error Handling
- PDF processing errors are caught and logged
- Quarto rendering has rmarkdown fallback
