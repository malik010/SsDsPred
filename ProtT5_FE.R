library(reticulate)
library(seqinr)

# Specify the path to your Python executable
use_python("/usr/bin/python3", required = TRUE)

# Source the Python script
source_python("ProtT5_FE.py")

# Function to read and process FASTA file or sequences
read_fasta_sequences <- function(file_path = NULL, sequences_text = NULL) {
  fasta_data <- NULL
  if (!is.null(file_path)) {
    fasta_data <- read.fasta(file = file_path, seqtype = "AA")
  } else if (!is.null(sequences_text)) {
    fasta_data <- read.fasta(text = sequences_text, seqtype = "AA", as.string = TRUE)
  }
  return(fasta_data)
}

# Function to extract features using the Python function
extract_protein_features <- function(sequences) {
  sequence_strings <- sapply(sequences, function(seq) paste(unlist(seq), collapse = ""))
  features <- extract_features(sequence_strings) # Call the Python function
# Convert features to a data frame with unique column names
  features_df <- as.data.frame(do.call(rbind, features))
  colnames(features_df) <- paste0("PT", seq_len(ncol(features_df)))
  return(features_df)
}

# Function to print features in one line for each sequence
print_features <- function(features) {
  for (feature in features) {
    cat(paste(feature, collapse = ","), "\n")
  }
}

# Example usage with a FASTA file
#fasta_file <- "~/SMU/DS_SS_DBPs/ds_ss_neg70-final_train.fasta"
#sequences <- read_fasta_sequences(file_path = fasta_file)

#if (is.null(sequences)) {
#  print("No valid FASTA sequences found.")
#} else {
#  features <- extract_protein_features(sequences)
#  print_features(features)
#}
