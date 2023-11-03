import pandas as pd
import numpy as np
import re
import os

def split(
    expr_fname: str,
    pheno_fname: str,
    training_prop: float,
    train_suffix: str = "train",
    test_suffix: str = "test"
) -> None:
    """Randomly split pheno and corresponding gene expression data into training and test data

    Parameters
    ----------
    expr_fname: str
        path to expression .csv file. Every column must be a gene expression profile. Unique
        sample names are provided as column names
    pheno_fname: str
        path to pheno .csv file. Every row corresponds belongs to one sample. Unique sample
        names are provided as index
    data_dir: str
        directory where to find expr_fname and pheno_fname
    training_prop: float
        in [0, 1]. Proportion of samples that will go into training data. Rest will go into
        test data
    train_suffix: str
        suffix to append to expr_fname for training data
    test_suffix: str
        same for test data
    """

    data_dir, _ = os.path.split(expr_fname)

    fnames = {
        "pheno": pheno_fname,
        "expr": expr_fname
    }
    data = dict()

    index_col = 0
    header = 0
    expr_df = pd.read_csv(expr_fname, index_col = index_col, header = header)
    pheno_df = pd.read_csv(pheno_fname, index_col = index_col, header = header)

    if not set(expr_df.columns) == set(pheno_df.index):
        raise ValueError("Row names of pheno data do not one-to-one match column names of \
                         expression data")
    else:
        print("Well done! Sample names in pheno and expression data match 100%.")

    # divide ...
    shuffle = np.random.choice(
        pheno_df.index, 
        size = len(pheno_df.index),
        replace = False
        )
    div_idx = np.ceil(len(pheno_df.index) * training_prop).astype(int)

    # ... et impera
    data["train"] = dict()
    data["test"] = dict()
    training_samples = shuffle[:div_idx]
    test_samples = shuffle[:div_idx]
    data["train"]["expr"] = expr_df.loc[:, training_samples]
    data["train"]["pheno"] = pheno_df.loc[training_samples]
    data["test"]["expr"] = expr_df.loc[:, test_samples]
    data["test"]["pheno"] = pheno_df.loc[test_samples]

    # craft new file names and write into file
    for tr_te in ["train", "test"]:
        target_dir = os.path.join(data_dir, tr_te)
        print("Writing " + tr_te + "data into " + target_dir)
        if not os.path.exists(target_dir):
            os.mkdir(target_dir)
        for ph_expr in ["pheno", "expr"]:
            first, last = os.path.split(fnames[ph_expr])
            fname = os.path.join(first, tr_te, last)
            data[tr_te][ph_expr].to_csv(fname)    