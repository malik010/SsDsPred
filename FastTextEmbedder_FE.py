from bio_embeddings.embed import FastTextEmbedder
import numpy as np

# Initialize the FastTextEmbedder
embedder = FastTextEmbedder()
def extract_features(sequences):
    features = []
    for seq in sequences:
        if len(seq) == 0:
            raise ValueError("Empty sequence detected.")
        embedding = embedder.embed(seq)
        if embedding.shape[0] != len(seq):
            raise AssertionError(f"Sequence length mismatch: {len(seq)} vs {embedding.shape[0]}")
        pooled_output = np.mean(embedding, axis=0)
        features.append(pooled_output.tolist())
    return features

