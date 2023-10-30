""""Download, preprocess and store 562 DLBCL RNAseq bulks provided by Schmitz et al. (2018), PMID: 29641966

This script yields three files: two csv files with pheno and expression data, respectively, and one json file holding info. Modify the names and directories for these files via the below global variables"""

import os
import pandas as pd
import json
import urllib.request
import re
import sys
from ..split import split

# where to store the data
data_dir = "data/schmitz"
expr_fname = os.path.join(data_dir, "expr.csv")
pheno_fname = os.path.join(data_dir, "pheno.csv")
info_fname = os.path.join(data_dir, "info.json")

clean = True # remove (raw) downloaded files
training_prop = 0.66 # proportion of samples that will go into training data
# set to None if you want no splitting into training and test at all

# where to find the data
expr_url = "https://api.gdc.cancer.gov/data/894155a9-b039-4d50-966c-997b0e2efbc2"
pheno_url = "https://api.gdc.cancer.gov/data/529be438-e42c-4725-a3f3-66f6fd42ffae"
pheno_sheet_no = 8


def main():
    # create download-file names
    expr_download_fname = os.path.join(data_dir, "expr.tsv")
    pheno_download_fname = os.path.join(data_dir, "pheno.xlsx")

    if not os.path.exists(data_dir):
        print("Creating new data directory", data_dir)
        os.makedirs(data_dir)

    if not os.path.exists(expr_download_fname):
        print("\nDownloading expression data into " + expr_download_fname)
        urllib.request.urlretrieve(
            url = expr_url,
            filename = expr_download_fname
        )
    if not os.path.exists(pheno_download_fname):
        print("Downloading pheno data into " + pheno_download_fname)
        urllib.request.urlretrieve(
            url = pheno_url,
            filename = pheno_download_fname
        )

    print("\nReading in expression and pheno data")
    expr_df = pd.read_csv(
        expr_download_fname,
        delimiter = "\t",
        low_memory = False
    )
    pheno_df = pd.read_excel(
        pheno_download_fname,
        sheet_name = pheno_sheet_no
    )

    # aesthetics
    pheno_df = pheno_df.rename(columns = lambda cname: re.sub(r"\s", "_", cname).lower())
    pheno_df.set_index("dbgap_submitted_subject_id", inplace = True) # subject id as row names
    expr_df.set_index("Gene", inplace = True) # hgnc gene ids as row names (index)
    expr_df = expr_df.iloc[:, 2:] # remove other gene id rows

    print("\nChecking if expression and pheno data match")
    print("expression shape before harmonizing:", expr_df.shape)
    print("pheno shape before harmonizing:", pheno_df.shape)
    pheno_df = pheno_df.loc[expr_df.columns]
    expr_df = expr_df.loc[:, pheno_df.index]
    print("expression shape after harmonizing:", expr_df.shape)
    print("pheno shape after harmonizing:", pheno_df.shape)

    print("\nGenerating info")
    info_dict = {
        "publication": {
            "title": "Genetics and Pathogenesis of Diffuse Large B-Cell Lymphoma",
            "author": "Schmitz et al.",
            "year": 2018,
            "doi": "10.1056/NEJMoa1801445",
            "pubmed id": 29641966
        },
        "data": {
            "website": "https://gdc.cancer.gov/about-data/publications/DLBCL-2018",
            "disease type": "DLBCL",
            "number of samples": pheno_df.shape[0],
            "pheno data": {
                "included in survival analysis": str((pheno_df["included_in_survival_analysis"] == "Yes").sum()) + " of " + str(pheno_df.shape[0])
            },
            "expression data": {
                "technology": "bulk RNAseq",
                "number of genes": expr_df.shape[0],
                "gene symbols": "HGNC",
                "primary processing": "see Supplementary Appendix 1 @ https://api.gdc.cancer.gov/data/288619d2-a7b6-4ee3-aa27-ae2c77887b31, p. 6",
                "normalization": "fpkm values in log2 scale"    
            }
        }
    }

    print("\nWriting...")
    print("...info into " + info_fname)
    with open(info_fname, "w") as f:
        json.dump(info_dict, f, indent = 4)
    print("...expression data into " + expr_fname)
    expr_df.to_csv(expr_fname)
    print("...pheno data into " + pheno_fname)
    pheno_df.to_csv(pheno_fname)
    
    if clean:
        print("\nRemoving downloaded raw files")
        os.remove(pheno_download_fname)
        os.remove(expr_download_fname)

    if training_prop is not None:
        split(
            expr_fname = expr_fname,
            pheno_fname = pheno_fname,
            training_prop = training_prop
        )

    print("\nDone!")


if __name__ == "__main__":
    # main()
    split.split(
        expr_fname = expr_fname,
        pheno_fname = pheno_fname,
        training_prop = training_prop
    )