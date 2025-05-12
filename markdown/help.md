# 1. Instructions for using Web-server

## Input
- Input to the SsDsPred web-server consists of fasta formatted sequences. These sequences can either be pasted directly on the form or uploaded as a file.
- Before predictions, each sequence is checked for the presence of non-standard amino acids **(e.g. B, J, O, U, X, and Z)**.
- Such non-standard amino acid containing sequences are excluded from the analysis. 
- Once you submit the submit button, please wait for a while before the results are available.

## Output
- As soon as the necessary calculations are completed, the prediction results are displayed on the page.
- If a user has submitted large number of sequences, the user may have to wait a bit before the results are available.
- When the predictions are done, the results can also be downloaded as a CSV file.
- The output consists of a dataframe of **FIVE** columns described as below:

### Sample Output

<img src="figures/sample_output.png" alt="drawing"/>

### Explaination of the output

```sh 
      Column 1: The accession number (ID) of the sequence that was predicted as a Single-stranded, Double-stranded or non-DNA binding protein.
      Columns 2: The class of the predicted sequence, i.e. class with the highest probability (DS = Double-stranded DNA-binding sequence; SS = Single-stranded DNA-binding sequence; XX = non-DNA binding sequence)
      Columns 3-5: Probability scores.
```

# 2. Datasets
- Dataset: [Download](all_pos_neg70-final.fasta)


# 4. Reference
- **SsDsPred: A Multi-Embedding SVM Framework for Predicting Single- and Double-Stranded DNA-Binding Proteins (Manuscript Submitted).**
