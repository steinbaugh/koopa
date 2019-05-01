#!/usr/bin/env python3
"""Download genome annotations in GTF format.
"""

import argparse
import os

# Get the organism specified by the user.
parser = argparse.ArgumentParser()
parser.add_argument("organism",
                    help="Short latin organism name (e.g. hsapiens)")
args = parser.parse_args()

# Get the Ensembl release information from shell global variables.
ensembl_release = os.environ["ENSEMBL_RELEASE"]
ensembl_release_url = os.environ["ENSEMBL_RELEASE_URL"]
base_url = ensembl_release_url + "/gtf"

organism = args.organism

if organism == "hsapiens":
    print("Homo sapiens (Ensembl GRCh38)")
    url = base_url + "/homo_sapiens/Homo_sapiens.GRCh38." + ensembl_release + ".gtf.gz"
elif organism == "mmusculus":
    print("Mus musculus (Ensembl GRCm38)")
    url = base_url + "/mus_musculus/Mus_musculus.GRCm38." + ensembl_release + ".gtf.gz"
elif organism == "celegans":
    print("Caenorhabditis elegans (Ensembl WBcel235)")
    url = base_url + "/caenorhabditis_elegans/Caenorhabditis_elegans.WBcel235." + ensembl_release + ".gtf.gz"
elif organism == "dmelanogaster":
    # D. melanogaster Ensembl annotations are out of date.
    # Using the FlyBase annotations instead.
    flybase_release_date = os.environ["FLYBASE_RELEASE_DATE"]
    flybase_release_version = os.environ["FLYBASE_RELEASE_VERSION"]
    flybase_release_url = os.environ["FLYBASE_RELEASE_URL"]
    print("Drosophila melanogaster (FlyBase " + flybase_release_date + " " + flybase_release_version + ")")
    url = flybase_release_url + "/gtf/dmel-all-" + flybase_release_version + ".gtf.gz"
else:
    s = """
'{organism}' is not a supported organism.

Currently supported (case sensitive):
  - celegans
  - dmelanogaster
  - hsapiens
  - mmusculus
""".format(organism = organism)
    print(s)
    quit()

file = os.path.basename(url)

# Error if the file exists.
if os.path.isfile(file):
    print(file + "has already been downloaded.")
    quit()

print("Downloading " + file + ".")
os.system("curl -O " + url)

# Decompress, but also keep the original compressed file.
print("Decompressing " + file + ".")
unzip_file = os.path.splitext(file)[0]
os.system("gunzip -c " + file + " > " + unzip_file)
