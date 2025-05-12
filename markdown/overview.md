# About SsDsPred

- SsDsPred is a novel SVM-based framework for the prediction of Single- and Double-Stranded DNA-Binding Proteins.
- SsDsPred was developed by using three pretrained protein language model (PLM)-based embeddings—FastText, ProtTransT5BFDEmbedder (ProtT5), Word2Vec, and their hybrids as input features. 
- The SsDsPred working module is based on optimally selected hybrid features that predicts whether a given sequence is a Single-, Double-Stranded or non-DNA binding protein.


## Reference

- **SsDsPred: A Multi-Embedding SVM Framework for Predicting Single- and Double-Stranded DNA-Binding Proteins (Manuscript Submitted).**


## SsDsPred Algorithm

- Generation of training and independent datasets.
- Extraction of three pretrained protein language model (PLM)-based embeddings—FastText, ProtTransT5BFDEmbedder (ProtT5), Word2Vec, and Hybrid encodings. 
- Selection of optimal features using Boruta and recursive feature elimination (RFE) algorithm.
- 5-fold cross validation using different ML-based classifiers (e.g. KNN, NB, RF, SVM, &amp; XGBOOST). 
- Optimization of hyperparameters. 
- The performance of the selected models are evaluated on the independent datasets separately. 
- Finally, the target sequence is predicted to be as a Single-, Double-Stranded or non-DNA binding protein.
 
## Overview of SsDsPred methodology

<img src="figures/Figure1_v2.jpeg" alt="drawing" width="800" height="800"/>
