# Load required libraries
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(ellmer)
library(pdftools)
library(googleCloudStorageR)
library(shinyjs)
library(glue)
library(purrr)
library(httr)

# Define UI
ui <- fluidPage(
  # Add custom CSS for styling
  tags$head(
    tags$style(HTML("
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        margin: 0;
        padding: 20px;
      }
      
      .main-container {
        max-width: 600px;
        margin: 0 auto;
        background: white;
        border-radius: 15px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.1);
        padding: 40px;
        margin-top: 50px;
      }
      
      .hero-section {
        text-align: center;
        margin-bottom: 40px;
      }
      
      .hero-title {
        font-size: 2.5em;
        font-weight: bold;
        color: #2c3e50;
        margin-bottom: 20px;
        line-height: 1.2;
      }
      
      .hero-subtitle {
        font-size: 1.2em;
        color: #7f8c8d;
        line-height: 1.6;
        margin-bottom: 10px;
      }
      
      .value-prop {
        font-size: 1em;
        color: #95a5a6;
        line-height: 1.5;
      }
      
      .form-section {
        background: #f8f9fa;
        padding: 30px;
        border-radius: 10px;
        margin-top: 30px;
      }
      
      .form-group {
        margin-bottom: 25px;
      }
      
      .form-group label {
        font-weight: 600;
        color: #2c3e50;
        margin-bottom: 8px;
        display: block;
      }
      
      .form-control {
        width: 100%;
        padding: 12px;
        border: 2px solid #e9ecef;
        border-radius: 8px;
        font-size: 16px;
        transition: border-color 0.3s ease;
      }
      
      .form-control:focus {
        border-color: #667eea;
        outline: none;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
      }
      
      .file-input-wrapper {
        position: relative;
        display: inline-block;
        width: 100%;
      }
      
      .btn-submit {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 15px 40px;
        border-radius: 25px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        width: 100%;
        margin-top: 20px;
      }
      
      .btn-submit:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
      }
      
      .btn-submit:disabled {
        opacity: 0.6;
        cursor: not-allowed;
        transform: none;
      }
      
      .error-message {
        color: #e74c3c;
        font-size: 14px;
        margin-top: 5px;
        display: none;
      }
      
      .success-message {
        background: #d4edda;
        color: #155724;
        padding: 15px;
        border-radius: 8px;
        margin-top: 20px;
        border: 1px solid #c3e6cb;
      }
      
      .loading {
        display: none;
        text-align: center;
        margin-top: 20px;
      }
      
      .spinner {
        border: 3px solid #f3f3f3;
        border-top: 3px solid #667eea;
        border-radius: 50%;
        width: 30px;
        height: 30px;
        animation: spin 1s linear infinite;
        margin: 0 auto 10px;
      }
      
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      
      .required {
        color: #e74c3c;
      }
      
      .example-section {
        background: rgba(102, 126, 234, 0.05);
        border: 1px solid rgba(102, 126, 234, 0.2);
        border-radius: 8px;
        padding: 15px;
        margin-top: 20px;
        text-align: center;
      }
      
      .example-text {
        font-size: 0.9em;
        color: #5a6c7d;
        margin-bottom: 10px;
        font-weight: 500;
      }
      
      .example-links {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 15px;
        flex-wrap: wrap;
      }
      
      .example-link {
        color: #667eea;
        text-decoration: none;
        font-weight: 600;
        padding: 8px 16px;
        border: 2px solid #667eea;
        border-radius: 20px;
        transition: all 0.3s ease;
        font-size: 0.85em;
      }
      
      .example-link:hover {
        background: #667eea;
        color: white;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
      }
      
      .arrow {
        color: #667eea;
        font-weight: bold;
        font-size: 1.2em;
      }
      
      @media (max-width: 500px) {
        .example-links {
          flex-direction: column;
          gap: 10px;
        }
        
        .arrow {
          transform: rotate(90deg);
        }
      }
    "))
  ),
  
  # Main container
  div(class = "main-container",
      # Initialize shinyjs
      useShinyjs(),
      
      # Hero section
      div(class = "hero-section",
          h1(class = "hero-title", "YC App → Pitch Deck"),
          p(class = "value-prop",
            "Save your YC application as a PDF. Upload it here. A deck with 10 slides -- including Problem, Solution,
            Market Opportunity, Traction, Business Model, Team, Competition, and Ask -- will be emailed to you.
            Use it as a starting point for your pitch deck, so you can spend more time building something people want."),
      ),
      div(class = "example-section",
          p(class = "example-text", "See it in action:"),
          div(class = "example-links",
              tags$a(href = "https://www.ycombinator.com/apply/dropbox/", 
                     target = "_blank", 
                     class = "example-link",
                     "Dropbox YC Application"),
              span(class = "arrow", "→"),
              tags$a(href = "https://storage.googleapis.com/yc_reborn/pitch_deck_p5bct97r.pptx", 
                     target = "_blank", 
                     class = "example-link",
                     "Auto-Generated Pitch Deck")
          )),
      
      # Form section
      div(class = "form-section",
          # Email input
          div(class = "form-group",
              tags$label("Email Address", class = "required", `for` = "email"),
              textInput("email", 
                        label = NULL,
                        placeholder = "your@email.com",
                        width = "100%")
          ),
          
          # File upload
          div(class = "form-group",
              tags$label("Y Combinator Application (PDF)", class = "required", `for` = "yc_file"),
              fileInput("yc_file",
                        label = NULL,
                        accept = ".pdf",
                        width = "100%",
                        placeholder = "Choose PDF file...")
          ),
          
          # Submit button
          div(
            actionButton("submit_btn", 
                         "Create My Pitch Deck",
                         class = "btn-submit",
                         disabled = TRUE),
            p(style = "font-size: 14px; color: #6c757d; text-align: center; margin-top: 10px; margin-bottom: 0;",
              "Your pitch deck will be emailed to you in 5 minutes or less.")
          ),
          
          # Loading indicator
          div(class = "loading", id = "loading",
              div(class = "spinner"),
              p("Processing your application...")
          ),
          
          # Messages
          uiOutput("messages")
      )
  )
)

# Helper function for null coalescing operator
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || is.na(x)) y else x
}

# Define server logic
server <- function(input, output, session) {
  
  # Reactive values to track form state
  values <- reactiveValues(
    email_valid = FALSE,
    file_valid = FALSE,
    submitted = FALSE
  )
  
  # Validate email
  observeEvent(input$email, {
    email_pattern <- "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    values$email_valid <- nchar(input$email) > 0 && grepl(email_pattern, input$email)
    updateSubmitButton()
  })
  
  # Validate file upload
  observeEvent(input$yc_file, {
    if (!is.null(input$yc_file)) {
      # Check if file is PDF
      file_ext <- tools::file_ext(input$yc_file$name)
      values$file_valid <- tolower(file_ext) == "pdf"
      
      if (!values$file_valid) {
        showNotification("Please upload a PDF file only.", 
                         type = "error", 
                         duration = 5)
      }
    } else {
      values$file_valid <- FALSE
    }
    updateSubmitButton()
  })
  
  # Function to update submit button state
  updateSubmitButton <- function() {
    isolate({
      button_enabled <- values$email_valid && values$file_valid && !values$submitted
      
      if (button_enabled) {
        updateActionButton(session, "submit_btn", disabled = FALSE)
      } else {
        updateActionButton(session, "submit_btn", disabled = TRUE)
      }
    })
  }
  
  # Reactive for processing job
  process_application <- reactive({
    req(input$submit_btn)
    req(values$email_valid && values$file_valid)
    
    isolate({
      # Show loading immediately
      show("loading")
      
      # 1. Show completion message to user
      output$messages <- renderUI({
        div(class = "success-message",
            h4("✅ Processing Complete!"),
            p(paste("Your Y Combinator application has been processed successfully. 
                   If it was a valid application, your personalized pitch deck will be 
                    sent to", input$email, "shortly.")),
            p("Please check your inbox (and spam folder) within the next few minutes!")
        )
      })
      
      # 2. Kick off data processing job
      tryCatch({
        process_yc_application(
          email = input$email,
          file_path = input$yc_file$datapath,
          file_name = input$yc_file$name
        )
        
        cat("Data processing job initiated successfully\n")
        
      }, error = function(e) {
        cat("Error in processing job:", e$message, "\n")
        
        # Show error message to user
        output$messages <- renderUI({
          div(style = "background: #f8d7da; color: #721c24; padding: 15px; border-radius: 8px; margin-top: 20px; border: 1px solid #f5c6cb;",
              h4("⚠️ Processing Error"),
              p("There was an issue processing your application. Please try again or contact support if the problem persists.")
          )
        })
      })
      
      # Hide loading
      hide("loading")
      
      # Reset form state
      values$submitted <- FALSE
      updateSubmitButton()
      
      return("Processing initiated")
    })
  })
  
  # Handle form submission
  observeEvent(input$submit_btn, {
    if (values$email_valid && values$file_valid) {
      values$submitted <- TRUE
      updateSubmitButton()
      
      # Trigger the processing reactive
      process_application()
      
    } else {
      showNotification("Please fill in all required fields correctly.", 
                       type = "error", 
                       duration = 5)
    }
  })
  
  # Data processing function
  process_yc_application <- function(email, file_path, file_name) {
    cat("Starting data processing job...\n")
    cat("Email:", email, "\n")
    cat("File path:", file_path, "\n")
    cat("File name:", file_name, "\n")
    
    application_text <- pdf_text(pdf = file_path) %>% glue_collapse()
    
    chat_haiku <- chat_anthropic(system_prompt = "You are an expert in evaluating technology startups.",
                                 model='claude-3-5-haiku-20241022')
    valid_or_not <- chat_haiku$chat(glue("Consider the PDF provided below. Tell me if it is a valid ycombinator application or not.
                    If it is, reply 1. If not, reply 0. Only reply with 1 character, 1 or 0.
                    
                    THE PDF FILE: {application_text}
                    
                    Tell me if it is a valid ycombinator application or not.
                    If it is, reply 1. If not, reply 0. Only reply with 1 character, 1 or 0."))
    
    if(valid_or_not == "0") {
      cat("Invalid application\n")
      return(TRUE)
    }
    
    if(valid_or_not == "1") {
      
      ### STEP 1: GET STRUCTURED DATA
      
      yc_pitch_deck_type <- type_object(
        "Complete pitch deck data extracted from Y Combinator application",
        
        # === SLIDE 1: TITLE SLIDE ===
        company_name = type_string(
          "The official company name as stated in the YC application"
        ),
        tagline = type_string(
          "Company tagline, mission statement, or one-line description of what the company does. Should be compelling and concise."
        ),
        founder_names = type_string(
          "Names of all founders, comma-separated (e.g., 'John Smith, Jane Doe')"
        ),
        
        # === SLIDE 2: THE PROBLEM ===
        problem_statement_1 = type_string(
          "Primary problem the company is solving. Should be specific and relatable."
        ),
        problem_statement_2 = type_string(
          "Secondary problem or additional aspect of the main problem"
        ),
        problem_statement_3 = type_string(
          "Third problem point or supporting evidence for the problem's significance"
        ),
        problem_key_insight = type_string(
          "Key insight about the problem space that gives the company unique understanding or positioning"
        ),
        
        # === SLIDE 3: THE SOLUTION ===
        solution_description_1 = type_string(
          "Primary description of how the company solves the problem. Should be clear and specific."
        ),
        solution_description_2 = type_string(
          "Secondary benefit or aspect of the solution"
        ),
        solution_description_3 = type_string(
          "Explanation of how the solution works or its implementation approach"
        ),
        solution_description_4 = type_string(
          "Impact or outcome of the solution for customers or users"
        ),
        feature_1 = type_string(
          "First key feature or capability of the product/service"
        ),
        feature_2 = type_string(
          "Second key feature or capability of the product/service"
        ),
        feature_3 = type_string(
          "Third key feature or capability of the product/service"
        ),
        feature_4 = type_string(
          "Fourth key feature or capability of the product/service"
        ),
        
        # === SLIDE 4: MARKET OPPORTUNITY ===
        tam_size = type_string(
          "Total Addressable Market size with units (e.g., '$50 billion', '100M users')"
        ),
        sam_size = type_string(
          "Serviceable Available Market size with units (e.g., '$5 billion', '20M users')"
        ),
        target_market_description = type_string(
          "Description of the specific target market segment the company is addressing"
        ),
        market_growth_rate = type_string(
          "Market growth rate with timeframe (e.g., '15% annually', 'doubling every 3 years')"
        ),
        revenue_projection = type_string(
          "Projected annual revenue at scale (e.g., '$10M', '$100M ARR')"
        ),
        market_share_target = type_string(
          "Target market share percentage (e.g., '5%', '10%')"
        ),
        
        # === SLIDE 5: TRACTION ===
        users_count = type_string(
          "Number of users, customers, or subscribers (e.g., '1,000', '50K', '2.1M')"
        ),
        users_label = type_string(
          "Label for the user count (e.g., 'Active Users', 'Paying Customers', 'Monthly Subscribers')"
        ),
        revenue_current = type_string(
          "Current revenue with timeframe (e.g., '$50K MRR', '$200K total revenue', '$1M ARR')"
        ),
        traction_point_1 = type_string(
          "First key traction metric or milestone (e.g., user growth, partnerships, press coverage)"
        ),
        traction_point_2 = type_string(
          "Second key traction metric or milestone"
        ),
        traction_point_3 = type_string(
          "Third key traction metric or milestone"
        ),
        customer_validation = type_string(
          "Customer validation story, testimonial, or evidence of product-market fit"
        ),
        
        # === SLIDE 6: BUSINESS MODEL ===
        revenue_stream_1 = type_string(
          "Primary revenue stream description (e.g., 'SaaS subscriptions', 'Transaction fees', 'Product sales')"
        ),
        revenue_stream_2 = type_string(
          "Secondary revenue stream description"
        ),
        revenue_stream_3 = type_string(
          "Additional revenue stream description or future monetization opportunity"
        ),
        pricing_strategy = type_string(
          "Description of pricing approach and strategy (e.g., 'freemium model', 'tiered pricing', 'usage-based')"
        ),
        customer_acquisition_cost = type_string(
          "Customer acquisition cost with currency (e.g., '$50', '$200'). Use 'TBD' if not yet determined."
        ),
        lifetime_value = type_string(
          "Customer lifetime value with currency (e.g., '$500', '$2,000'). Use 'TBD' if not yet determined."
        ),
        
        # === SLIDE 7: TEAM ===
        founder_1_name = type_string(
          "Full name of the first founder"
        ),
        founder_1_title = type_string(
          "Title/role of the first founder (e.g., 'CEO', 'CTO', 'Co-founder')"
        ),
        founder_1_equity = type_string(
          "Equity percentage of the first founder (just the number, e.g., '60', '50')"
        ),
        founder_1_background_1 = type_string(
          "First key background point for founder 1 (education, previous experience, expertise)"
        ),
        founder_1_background_2 = type_string(
          "Second key background point for founder 1"
        ),
        founder_1_background_3 = type_string(
          "Third key background point for founder 1"
        ),
        founder_2_name = type_string(
          "Full name of the second founder. Use 'N/A' if single founder."
        ),
        founder_2_title = type_string(
          "Title/role of the second founder. Use 'N/A' if single founder."
        ),
        founder_2_equity = type_string(
          "Equity percentage of the second founder. Use 'N/A' if single founder."
        ),
        founder_2_background_1 = type_string(
          "First key background point for founder 2. Use 'N/A' if single founder."
        ),
        founder_2_background_2 = type_string(
          "Second key background point for founder 2. Use 'N/A' if single founder."
        ),
        founder_2_background_3 = type_string(
          "Third key background point for founder 2. Use 'N/A' if single founder."
        ),
        
        # === SLIDE 8: COMPETITION ===
        competitor_1_name = type_string(
          "Name of the first main competitor"
        ),
        competitor_1_description = type_string(
          "Brief description of competitor 1 and their approach"
        ),
        competitor_2_name = type_string(
          "Name of the second main competitor"
        ),
        competitor_2_description = type_string(
          "Brief description of competitor 2 and their approach"
        ),
        competitor_3_name = type_string(
          "Name of the third main competitor"
        ),
        competitor_3_description = type_string(
          "Brief description of competitor 3 and their approach"
        ),
        competitive_advantage_1 = type_string(
          "First key competitive advantage or differentiator"
        ),
        competitive_advantage_2 = type_string(
          "Second key competitive advantage or differentiator"
        ),
        secret_sauce = type_string(
          "Unique insight, technology, or approach that competitors don't know or can't easily replicate"
        ),
        
        # === SLIDE 9: THE ASK ===
        funding_amount = type_string(
          "Funding amount requested (e.g., '500K', '1M', '2.5M'). Just the number and unit."
        ),
        use_of_funds_1 = type_string(
          "Primary use of funds with percentage (e.g., '60% - Product development')"
        ),
        use_of_funds_2 = type_string(
          "Secondary use of funds with percentage (e.g., '30% - Marketing and customer acquisition')"
        ),
        use_of_funds_3 = type_string(
          "Additional use of funds with percentage (e.g., '10% - Operations and hiring')"
        ),
        key_milestones = type_string(
          "Key milestones or goals to achieve with the funding"
        ),
        contact_email = type_string(
          "Primary contact email address for the founders"
        ),
        contact_phone = type_string(
          "Primary contact phone number. Use 'Available upon request' if not provided."
        ),
        website_url = type_string(
          "Company website URL. Use 'In development' if not yet available."
        ),
        closing_message = type_string(
          "Final inspiring message, call to action, or vision statement"
        )
      )
      print('type object created')
      deck_prompt <- paste(
        "Extract pitch deck information from this Y Combinator application.",
        "Focus on creating compelling, investor-ready content.",
        "If information is not explicitly stated, infer reasonable content based on context.",
        "For missing information, provide 'TBD' or 'N/A' as appropriate.",
        "\nY Combinator Application:\n",
        application_text
      )
      print('deck prompt created')
      ### STEP 2: POPULATE STRUCTURED DATA INTO TEMPLATE 
      
      chat_sonnet <- chat_anthropic(model = "claude-sonnet-4-20250514")
      pitch_data <- chat_sonnet$chat_structured(deck_prompt, type=yc_pitch_deck_type)
      print('pitch data created')
      
      template_file = "yc_pitch_deck_template.qmd"
      
      # Read the template
      template_content <- readLines(template_file, warn = FALSE)
      template_text <- paste(template_content, collapse = "\n")
      
      # Replace all placeholders with actual values from pitch_data
      for (var_name in names(pitch_data)) {
        placeholder <- paste0("{{", var_name, "}}")
        
        # Handle NULL or missing values
        replacement_value <- if (is.null(pitch_data[[var_name]]) || is.na(pitch_data[[var_name]])) {
          "TBD"
        } else {
          as.character(pitch_data[[var_name]])
        }
        
        # Replace placeholder in template
        template_text <- gsub(placeholder, replacement_value, template_text, fixed = TRUE)
      }
      
      random_id <- paste0(sample(c(letters, 0:9), 8, replace = TRUE), collapse = "")
      filename <- paste0("pitch_deck_", random_id, ".qmd")
      output_file <- filename
      
      # Write populated template to file
      writeLines(strsplit(template_text, "\n")[[1]], output_file)
      
      # Log the generation
      cat("Generated pitch deck:", output_file, "\n")
      cat("Company:", pitch_data$company_name %||% "Unknown", "\n")
      
      # STEP III: RENDER AND UPLOAD
      
      pptx_file <- paste0(tools::file_path_sans_ext(output_file), ".pptx")
      
      tryCatch({
        # Try Quarto first
        if (system("quarto --version", ignore.stdout = TRUE, ignore.stderr = TRUE) == 0) {
          quarto::quarto_render(output_file, output_format = "pptx")
        } else {
          stop("Quarto not available")
        }
      }, error = function(e) {
        # Fallback to rmarkdown
        warning("Quarto not available, using rmarkdown fallback")
        
        # Convert .qmd to .Rmd for rmarkdown compatibility
        rmd_file <- gsub("\\.qmd$", ".Rmd", output_file)
        file.copy(output_file, rmd_file)
        
        # Render with rmarkdown
        rmarkdown::render(rmd_file, output_format = "powerpoint_presentation", 
                          output_file = pptx_file)
      })
      
      upload_values <- gcs_upload(pptx_file,
                                  predefinedAcl = "publicRead",
                                  bucket = Sys.getenv("BUCKET_NAME_192"),
                                  name = pptx_file)
      
      pptx_link <- paste0("https://storage.googleapis.com/", Sys.getenv("BUCKET_NAME_192"), "/", pptx_file)
      
      # STEP IV: EMAIL
      
      url <- "https://api.mailgun.net/v3/mail.sixjupiter.com/messages"
      api_key <- Sys.getenv('mailgun_key')
      mail_message <- glue::glue("Congratulations! You have successfully reincarnated your application. 
                             Below is your deck in PowerPoint format:  
                                 
                                 {pptx_link}
                             
                             ")
      
      the_body <-
        list(
          from="YC Reincarnated <donotreply@mail.sixjupiter.com>",
          to=email,
          subject="Your YC application has been reincarnated!",
          text=mail_message
        )
      
      req <- httr::POST(url,
                        httr::authenticate("api", api_key),
                        encode = "form",
                        body = the_body)
      
      httr::stop_for_status(req)
      
      TRUE
    }
    
    # Simulate processing time for now
    Sys.sleep(1)
    
    cat("Data processing job completed\n")
    return(TRUE)
  }
  
  # Initialize submit button state
  updateSubmitButton()
}

# Run the application
shinyApp(ui = ui, server = server)
