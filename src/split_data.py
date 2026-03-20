import pandas as pd
import os
from pathlib import Path

# Read the original train labels
train_labels = pd.read_csv('data/train_labels.csv')

# Get filenames from data/train and data/test directories
train_files = set(f.replace('.wav', '') for f in os.listdir('/home/daniel/github/vowel-detection/data/train/'))
test_files = set(f.replace('.wav', '') for f in os.listdir('/home/daniel/github/vowel-detection/data/test/'))

# Filter labels for files that exist in train directory
train_split = train_labels[train_labels['ID'].isin(train_files)].copy()
train_split.to_csv('/home/daniel/github/vowel-detection/data/train/train_labels.csv', index=False)

# Filter labels for files that exist in test directory
test_split = train_labels[train_labels['ID'].isin(test_files)].copy()
test_split.to_csv('/home/daniel/github/vowel-detection/data/test/test_labels.csv', index=False)

print(f"Created train/train_labels.csv with {len(train_split)} entries")
print(f"Created test/test_labels.csv with {len(test_split)} entries")