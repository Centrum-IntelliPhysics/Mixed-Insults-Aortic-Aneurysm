## Table of contents
* [General info](#general-info)

## General info

This Git repository contains codes for the **'Importance of localized dilatation and distensibility in identifying thoracic aortic aneurysm contributors with neural operators'** paper which can be found here: [Link](link_url).

Authors: [David S. Li](https://scholar.google.com/citations?user=5mNu_m4AAAAJ&hl=en),  [Somdatta Goswami](https://scholar.google.com/citations?user=GaKrpSkAAAAJ&hl=en&oi=sra), [Qianying Cao](https://scholar.google.com/citations?user=OrdbclEAAAAJ&hl=en&oi=ao), [Vivek Ommen](https://scholar.google.com/citations?user=JWbuVUcAAAAJ&hl=en&oi=ao), [George Em Karniadakis](https://scholar.google.com/citations?user=yZ0-ywkAAAAJ&hl=en),  [Jay D. Humphrey](https://seas.yale.edu/faculty-research/faculty-directory/jay-humphrey).

# Cases and Architectures

The repository contains 16 cases analyzing different architectures and information available to the network. The following list provides a key to access each of tehse experiments. 
## Cases
| Case | Training Data | Format |
|------|--------------|---------|
| Case 1 | Dilatation only | Heat maps |
| Case 2 | Dilatation & distensibility | Heat maps |
| Case 3 | Dilatation only | Grayscale maps |
| Case 4 | Dilatation & distensibility | Grayscale maps |

## Network Architectures
- Network A: LNO
- Network B: CNN-based DeepONet
- Network C: FNN-based DeepONet
- Network D: UNet
