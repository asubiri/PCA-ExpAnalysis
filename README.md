# PROJECT NAME
	pseudocountsExpAnalysis

## Description
	This protocol has been developed as part of the Master's thesis entitled "Search for new polygenic risk variants associated with obesity and diabetes" at the Universidad Pablo de Olavide, defended by Alba Subiri (2025).

	It is the pseudocount matrix analysis protocol with the ExpHunter Suite integrative differential expression analysis and functional enrichment library (doi: 10.1038\/s41598-021-94343-w). It consists of two scripts for the preparation of variable information to be used for Principal Component Analysis (PCA) and its execution in the ExpHunter Suite Differential Expression and Functional Analysis program.

## Installation
1. Please clone this repository
	```bash
		git clone https://github.com/usuario/pseudocountsExpAnalysis.git
	```
2. Install from R-Bioconductor ExpHunter Suite package

3. Change initializes to ExpHunter Suite package binaries in launch.sh

4. Run parse\_data.sh giving a pseudocounts matrix and variable files to prepare all variables for PCA.

5. Run launch.sh to execute ExpHunter Suite (mode A, B and C for different variables selection).

