library(shiny)
library(seqinr)
library(reticulate)
library(caret)
library(shinydashboard)
library(markdown)

# Define the read_fasta_sequences function
read_fasta_sequences <- function(file_path = NULL, sequences_text = NULL) {
  if (!is.null(file_path)) {
    # Read from file
    fasta_data <- seqinr::read.fasta(file = file_path, seqtype = "AA")
  } else if (!is.null(sequences_text)) {
    # Process pasted text
    fasta_lines <- unlist(strsplit(sequences_text, "\n"))  # Split into lines
    fasta_lines <- trimws(fasta_lines)  # Remove leading/trailing whitespace

    # Identify header lines (starting with '>')
    headers <- grep("^>", fasta_lines)
    if (length(headers) == 0) stop("No valid FASTA headers found in the pasted text.")

    # Extract sequences
    fasta_data <- lapply(seq_along(headers), function(i) {
      start <- headers[i]
      end <- ifelse(i == length(headers), length(fasta_lines), headers[i + 1] - 1)
      sequence <- paste(fasta_lines[(start + 1):end], collapse = "")
      list(name = sub("^>", "", fasta_lines[start]), sequence = sequence)
    })

    # Convert to a named list for compatibility with seqinr-style output
    names(fasta_data) <- sapply(fasta_data, function(x) x$name)
    fasta_data <- lapply(fasta_data, function(x) unlist(strsplit(x$sequence, "")))
  } else {
    stop("Either file_path or sequences_text must be provided.")
  }
  return(fasta_data)
}

# Use Python environment
use_python("/usr/bin/python3", required = TRUE)


# Load pre-trained SVM model
mm <- readRDS("models/hybrid_svmR.RDS") # Assuming the model is saved as hybrid_svmR.RDS

# UI Definition
ui <- dashboardPage(
  dashboardHeader(title = "SsDsPred"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Algorithm", tabName = "algorithm", icon = icon("cogs")),
      menuItem("Help", tabName = "help", icon = icon("question-circle")),
      menuItem("Contact", tabName = "contact", icon = icon("envelope"))
    )
  ),
  dashboardBody(
    tabItems(
      # Home Tab
      tabItem(tabName = "home", h1("Welcome to SsDsPred", align="center", style = "color:green"),
			 p(h2(align="center", "A Multi-Embedding SVM Framework for Predicting Single- and Double-Stranded DNA-Binding Proteins")),
        fluidRow(
          box(
            title = "Input Options",
            width = 12,
            radioButtons("input_type", "Input Method:",
              choices = list("Paste Sequence" = "paste", "Upload FASTA File" = "upload"),
              selected = "upload"
            ),
            conditionalPanel(
              condition = "input.input_type == 'paste'",
              actionButton("sample_sequences", "Sample Input Sequences"),
	      textAreaInput("sequence_text", "Paste Sequences (FASTA format):", rows = 10)
            ),
            conditionalPanel(
              condition = "input.input_type == 'upload'",
              uiOutput("file_input_ui")
            ),
            actionButton("process", "Predict"),
            actionButton("reset", "Reset")
          ),
          box(
            title = h4(align="center", "Prediction results will be displayed here when the output is ready. You can also download the output as a CSV file as soon as the results are displayed below."),
            width = 12,
            tableOutput("predictions"),
            downloadButton("download", "Download Results")
          )
        )
      ),
      # Algorithm Tab
      tabItem(tabName = "algorithm", includeMarkdown("markdown/overview.md")),
      # Help Tab
      tabItem(tabName = "help", includeMarkdown("markdown/help.md")),
      # Contact Tab
      tabItem(tabName = "contact", includeMarkdown("markdown/contact.md"))
      )
    )
  )

# Server Logic
server <- function(input, output, session) {
 # Dynamically render the file input
  output$file_input_ui <- renderUI({
    fileInput("fasta_file", "Upload FASTA File", accept = ".fasta")
  }) 

# Predefined sample sequences in FASTA format
  sample_sequences <- ">1BM9A,DS
MKEEKRSSTGFLVKQRAFLKLYMITMTEQERLYGLKLLEVLRSEFKEIGFKPNHTEVYRSLHELLDDGILKQIKVKKEGA
KLQEVVLYQFKDYEAAKLYKKQLKVELDRCKKLIEKALSDNF
>1BW6A,DS
MGPKRRQLTFREKSRIIQEVEENPDLRKGEIARRFNIPPSTLSTILKNKRAILASE
>1JB7B,SS
MSKGASAPQQQSAFKQLYTELFNNEGDFSKVSSNLKKPLKCYVKESYPHFLVTDGYFFVAPYFTKEAVNEFHAKFPNVNI
VDLTDKVIVINNWSLELRRVNSAEVFTSYANLEARLIVHSFKPNLQERLNPTRYPVNLFRDDEFKTTIQHFRHTALQAAI
NKTVKGDNLVDISKVADAAGKKGKVDAGIVKASASKGDEFSDFSFKEGNTATLKIADIFVQEKGKDALNKAADHTDGAKV
KGGAKGKGKAAAKAAKGKKL
>2VTBE,SS
MNDHIHRVPALTEEEIDSVAIKTFERYALPSSSSVKRKGKGVTILWFRNDLRVLDNDALYKAWSSSDTILPVYCLDPRLF
HTTHFFNFPKTGALRGGFLMECLVDLRKNLMKRGLNLLIRSGKPEEILPSLAKDFGARTVFAHKETCSEEVDVERLVNQG
LKRVGNSTKLELIWGSTMYHKDDLPFDVFDLPDVYTQFRKSVEAKCSIRSSTRIPLSLGPTPSVDDWGDVPTLEKLGVEP
QEVTRGMRFVGGESAGVGRVFEYFWKKDLLKVYKETRNGMLGPDYSTKFSPWLAFGCISPRFIYEEVQRYEKERVANNST
YWVLFELIWRDYFRFLSIKCGNSLFHLGGPRNVQGKWSQDQKLFESWRDAKTGYPLIDANMKELSTTGFMSNRGRQIVCS
FLVRDMGLDWRMGAEWFETCLLDYDPCSNYGNWTYGAGVGNDPREDRYFSIPKQAQNYDPEGEYVAFWLQQLRRLPKEKR
HWPGRLMYMDTVVPLKHGNGPMAGGSKSGGGFRGSHSGRRSRHNGP
>C5A1N3,XX
MGMYKYIREAWKSPKKSYVGELLKKRMIKWRREPVVVRIERPTRLDRARSLGYQAKQGYVVVRVRVRRGGRKRPRWKGGR
KPSKMGMVKYSPKKSLQWIAEEKAARKFPNLEVLNSYWVGEDGMYKWFEVIMVDPHHPVIKSDPKIAWITGKAHKGRVFR
GLTSAGKKGRGLRNKGKGAEKVRPSVRANKGKTK
>A1E9M9,XX
MGQKINPLGFRLGTTQKHHSFWFAQPKNYSEGLQEDKKIRDCIKNYIQKNRKKGSNRKIESDSSSEVITHNRKMDSGSSS
EVITHIEIQKEIDTIHVIIHIGFPNLLKKKGAIEELEKDLQKEINSVNQRFNISIEKVKEPYRQPNILAEYIAFQLKNRV
SFRKAMKKAIELTKKADIRGVKVKIAGRLGGKEIARAESIKRGRLPLQTIRAKIDYCCYPIRTIYGVLGVKIWIFVDEE"

observeEvent(input$sample_sequences, {
    # Populate the text box with sample sequences
    updateTextAreaInput(session, "sequence_text", value = sample_sequences)
  })


  observeEvent(input$process, {
# Determine input type
    if (input$input_type == "paste") {
      # Process pasted sequences
      sequences <- read_fasta_sequences(sequences_text = input$sequence_text)
    } else if (input$input_type == "upload") {
      req(input$fasta_file)  # Ensure file is uploaded
      sequences <- read_fasta_sequences(file_path = input$fasta_file$datapath)
    }
    # Validate sequences
    if (is.null(sequences) || length(sequences) == 0) {
      stop("No valid sequences found.")
    }
      # Extract sequence IDs (accessions)
  sequence_ids <- names(sequences)  # Extract sequence IDs from the FASTA file

    # Flatten sequences
    sequence_strings <- sapply(sequences, function(seq) paste(unlist(seq), collapse = ""))

     # Validate sequence lengths
    valid_sequences <- sequence_strings[nchar(sequence_strings) >= 30]
    if (length(valid_sequences) == 0) {
      stop("No valid sequences with the required minimum length (30) found.")
    }
valid_sequences <- as.character(valid_sequences)  # Ensure it's a character vector
    
    # Generate embeddings
    embeddings_list <- list()

    # FastText Embedding
    source("FastTextEmbedder_FE.R")
     embeddings_list[["FastText"]] <- extract_protein_features(valid_sequences)
if (is.vector(embeddings_list[["FastText"]])) {
  embeddings_list[["FastText"]] <- matrix(embeddings_list[["FastText"]], nrow = 1)
}      

# ProtT5 Embedding
source("ProtT5_FE.R")
embeddings_list[["ProtT5"]] <- extract_protein_features(valid_sequences)
if (is.vector(embeddings_list[["ProtT5"]])) {
  embeddings_list[["ProtT5"]] <- matrix(embeddings_list[["ProtT5"]], nrow = 1)
}

# Word2Vec Embedding
source("Word2VecEmbedder_FE.R")
embeddings_list[["Word2Vec"]] <- extract_protein_features(valid_sequences)
if (is.vector(embeddings_list[["Word2Vec"]])) {
  embeddings_list[["Word2Vec"]] <- matrix(embeddings_list[["Word2Vec"]], nrow = 1)
}

colnames(embeddings_list[["FastText"]]) <- paste0("FT", seq_len(ncol(embeddings_list[["FastText"]])))
colnames(embeddings_list[["ProtT5"]]) <- paste0("PT", seq_len(ncol(embeddings_list[["ProtT5"]])))
colnames(embeddings_list[["Word2Vec"]]) <- paste0("W2V", seq_len(ncol(embeddings_list[["Word2Vec"]])))

      # Ensure all embeddings have the correct number of rows (same as valid_sequences)
cat("FastText features dimensions:", dim(embeddings_list[["FastText"]]), "\n")
cat("ProtT5 features dimensions:", dim(embeddings_list[["ProtT5"]]), "\n")
cat("Word2Vec features dimensions:", dim(embeddings_list[["Word2Vec"]]), "\n")

# Combine embeddings
    hybrid_features <- do.call(cbind, embeddings_list)
    # Standardize column names (remove prefixes)
      colnames(hybrid_features) <- sub("^(FastText\\.|ProtT5\\.|Word2Vec\\.)", "", colnames(hybrid_features))

    # Dynamically handle selected features
    required_columns <- c("PT725", "PT788", "PT842", "PT592", "PT693", "PT169", "PT182", "PT295", "PT836", "PT309", "PT590", "PT383", "PT495", "PT460", "PT864", "PT275", "PT765", "PT485", "PT946", "PT376", "FT467", "PT1003", "PT224", "PT86", "PT458", "PT122", "PT168", "PT599", "PT112", "PT192", "PT448", "PT387", "FT310", "PT976", "PT57", "PT981", "PT602", "PT914", "PT920", "PT525", "PT733", "PT977", "PT218", "PT761", "PT225", "PT368", "PT313", "PT767", "PT426", "PT294", "PT274", "PT852", "PT416", "PT876", "FT109", "PT228", "PT248", "PT468", "PT120", "FT287", "PT563", "PT838", "PT159", "PT145", "PT820", "PT694", "PT588", "PT437", "PT972", "PT666", "PT444", "PT612", "PT190", "PT648", "PT174", "PT996", "PT892", "PT319", "PT633", "PT179", "PT503", "PT33", "PT421", "PT621", "PT522", "PT950", "PT285", "PT316", "PT243", "PT868", "PT722", "PT247", "PT455", "PT403", "PT1001", "PT435", "PT870", "PT404", "PT581", "FT429", "PT81", "PT96", "PT117", "PT735", "PT770", "PT40", "PT766", "PT634", "PT380", "PT580", "PT257", "FT275", "PT928", "FT359", "PT953", "PT691", "PT849", "PT979", "PT307", "PT173", "PT997", "PT15", "PT472", "PT268", "PT550", "PT817", "PT202", "PT689", "PT431", "PT873", "PT10", "PT698", "PT880", "PT641", "FT312", "PT526", "FT53", "PT498", "PT438", "PT658", "PT822", "FT417", "PT207", "PT531", "PT623", "PT372", "PT686", "PT150", "PT234", "PT262", "PT837", "PT575", "PT803", "PT405", "PT334", "PT704", "PT188", "PT809", "PT402", "PT702", "PT617", "W2V353", "PT123", "FT65", "PT191", "PT194", "PT675", "PT332", "W2V52", "PT43", "PT760", "PT1014", "PT167", "PT245", "PT681", "PT815", "PT85", "PT362", "PT183", "FT246", "PT871", "PT630", "PT542", "PT244", "PT978", "PT246", "PT67", "PT1012", "PT115", "PT647", "PT975", "PT131", "PT157", "PT562", "PT433", "PT70", "FT4", "PT394", "PT732", "PT149", "PT50", "PT499", "FT492", "PT11", "PT14", "PT487", "PT267", "PT311", "PT436", "PT993", "PT643", "PT910", "PT20", "PT798", "PT198", "FT486", "PT22", "PT662", "PT786", "PT971", "PT529", "PT970", "PT802", "PT955", "PT750", "W2V441", "PT948", "PT73", "PT569", "PT349", "PT874", "PT1017", "PT434", "PT573", "PT995", "FT289", "PT543", "PT89", "PT466", "PT424", "PT232", "FT52", "PT483", "PT406", "PT374", "PT697", "PT109", "PT210", "PT901", "PT305", "PT91", "PT395", "PT618", "FT96", "PT819", "PT554", "PT414", "PT660", "PT36", "PT730", "PT219", "PT443", "PT322", "PT135", "PT336", "PT517", "PT511", "FT421", "FT493", "PT69")     # Add the full list of selected features here
    #print(valid_columns)

    # Ensure only the required columns are selected
valid_columns <- intersect(required_columns, colnames(hybrid_features))
selected_features <- hybrid_features[, valid_columns, drop = FALSE]


# Check if all 270 required columns are available
if (length(valid_columns) < length(required_columns)) {
  stop(paste(
    "Not all required columns are available in hybrid_features.",
    "Missing columns:", paste(setdiff(required_columns, valid_columns), collapse = ", ")
  ))
}

cat("Valid sequences count:", length(valid_sequences), "\n")
cat("Hybrid feature dimensions:", dim(hybrid_features), "\n")
cat("Selected feature dimensions:", dim(selected_features), "\n")

# Test predict with type = "prob"
probabilities <- tryCatch({
  predict(mm, newdata = selected_features, type = "prob")
}, error = function(e) {
  cat("Error in probability prediction:", e$message, "\n")
  NULL
})

if (!is.null(probabilities)) {
# Assign the final class based on the maximum probability
  predictions <- colnames(probabilities)[apply(probabilities, 1, which.max)]
    
# Construct results with sequence IDs and probabilities
    results <- cbind(
      Seq_ID = sequence_ids,
      Prediction = predictions,
      probabilities
    )
} else {
  cat("Probabilities are NULL. Check the model or input data.\n")
}
    # Display results
    output$predictions <- renderTable({ results })

        # Allow downloading of the results
    output$download <- downloadHandler(
      filename = "predictions.csv",
      content = function(file) {
        write.csv(results, file, row.names = FALSE)
      }
    )
  })

 # Reset logic
  observeEvent(input$reset, {
     # Reset file input by re-rendering it
    output$file_input_ui <- renderUI({
      fileInput("fasta_file", "Upload FASTA File", accept = ".fasta")
    })
    # Reset text box
    updateTextAreaInput(session, "sequence_text", value = "")

    # Reset radio button selection
    updateRadioButtons(session, "input_type", selected = "upload")

    # Clear results table
    output$predictions <- renderTable({ NULL })
  })
}
    # Run the Shiny App
shinyApp(ui = ui, server = server)

