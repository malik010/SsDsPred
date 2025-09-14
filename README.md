# SsDsPred: A Multi-Embedding SVM Framework for Predicting Single- and Double-Stranded DNA-Binding Proteins

**SsDsPred** is a novel computational tool capable of distinguishing DNA-binding proteins from non-DNA-binding sequences, 
  and further classifying DNA-binding proteins into **Single-stranded** or **Double-stranded** DNA binding sequences. 
  SsDsPred method utilizes different pretrained Protein Language Model (PLM)-based embeddings such as *FastText*, 
  *ProtTransT5BFDEmbedder (ProtT5)*, and *Word2Vec*. These embeddings are linearly integrated to generate a comprehensive, 
  high-dimensional *hybrid* representation of protein sequences.  

---

## 🚀 Requirements
- **Python:**
- Please check the requirements.txt file to install the necessary Python packages.
- This app uses Python for feature extraction. Ensure you have Python 3.8+ and install the following dependencies:  
  - pip install -r requirements.txt

- **R:**
- In R, run:
    install.packages(c(
  "shiny", "shinythemes", "ggplot2", "pROC", "caret",
  "dplyr", "DT", "data.table", "randomForest", "e1071"
))


## 📦 Installation

### Clone the repository
```bash
git clone https://github.com/malik010/SsDsPred.git
cd SsDsPred
```
## ▶️ Running the App from R:
library(shiny)

runApp("app.R")


## 📖 Usage Instructions
### Instructions for using SsDsPred

- **Input**
  - Input to the SsDsPred consists of **2** or **more** fasta formatted prote8in sequences. These sequences can either be pasted directly on the form or uploaded as a file.
  - Before predictions, each sequence is checked for the presence of non-standard amino acids **(e.g., B, J, O, U, X, and Z)**.
  - Such non-standard amino acid-containing sequences are excluded from the analysis. 
  - Once you submit the submit button, please wait for a while before the results are available.

- **Output**
  - As soon as the necessary calculations are completed, the prediction results are displayed on the page.
  - If a user has submitted a large number of sequences, the user may have to wait a bit before the results are available.
  - When the predictions are done, the results can also be downloaded as a CSV file.
  - The output consists of a dataframe of **FIVE** columns described as below:

### Sample Output

<img src="https://github.com/malik010/SsDsPred/blob/main/www/figures/sample_output.png" alt="drawing"/>

### Explanation of the output

```sh 
      Column 1: The accession number (ID) of the sequence that was predicted as a Single-stranded, Double-stranded, or non-DNA-binding protein.
      Columns 2: The class of the predicted sequence, i.e., class with the highest probability (DS = Double-stranded DNA-binding sequence; SS = Single-stranded DNA-binding sequence; XX = non-DNA-binding sequence)
      Columns 3-5: Probability scores.
```

# Reference
- **SsDsPred: A Multi-Embedding SVM Framework for Predicting Single- and Double-Stranded DNA-Binding Proteins (Manuscript Submitted).**

## Contact

<img src="https://github.com/malik010/SsDsPred/blob/main/www/figures/contact.png" alt="drawing"/>
