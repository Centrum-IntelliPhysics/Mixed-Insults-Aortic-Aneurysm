## Table of contents
* [General info](#general-info)

## General info

This Git repository contains codes for the **'Importance of localized dilatation and distensibility in identifying thoracic aortic aneurysm contributors with neural operators'** paper which can be found here: [Link](link_url).

Authors: [David S. Li](https://scholar.google.com/citations?user=3ra1swQAAAAJ&hl=en),  [Somdatta Goswami](https://scholar.google.com/citations?user=GaKrpSkAAAAJ&hl=en&oi=sra), [Qianying Cao](https://scholar.google.com/citations?user=OrdbclEAAAAJ&hl=en&oi=ao), [Vivek Oommen](https://scholar.google.com/citations?user=JWbuVUcAAAAJ&hl=en&oi=ao), [George Em Karniadakis](https://scholar.google.com/citations?user=yZ0-ywkAAAAJ&hl=en),  [Jay D. Humphrey](https://seas.yale.edu/faculty-research/faculty-directory/jay-humphrey).

# Cases and Architectures

The repository contains 16 cases analyzing different architectures and information available to the network. The following list provides the key to identifying each of the manuscript's experiments. 
## Cases
| Case | Training Data | Format |
|------|--------------|---------|
| Case 1 | Dilatation only | Grayscale maps |
| Case 2 | Dilatation only | Heat maps |
| Case 3 | Dilatation & distensibility | Grayscale maps |
| Case 4 | Dilatation & distensibility | Heat maps |

## Network Architectures
- Network A: CNN-based DeepONet
- Network B: FNN-based DeepONet
- Network C: UNet
- Network D: LNO

# Usage

There are 3 main scripts for performing the analysis, described below.

## data_preproc.m
This script preprocesses the input data for training the networks. The user sets the case number, signifying data type. The output contains the testing results (dimensions of 50 testing cases, 40-41 positions in the circumferential and axial directions) for all network architectures. After generating, the user saves the workspace in the corresponding allResults folder (with the correct suffix).

## plot_errors.m
This script generates error plots of network predictions. It creates either all-sample or individual-sample error plots.

## plot_2Dresults.m
This script generates 2D colormap plots of network predictions. It generates 3 plots:
- Figure 1: Input data and ground truth of elastic fiber integrity and mechanosensing insults.
- Figure 2: Elastic fiber integrity predictions and absolute errors.
- Figure 3: Mechanosensing predictions and absolute errors.
