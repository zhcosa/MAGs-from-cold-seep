# MAGs-from-cold-seep
Scripts for the analysis of cold seep microbiome

The individual data packages are summarized in the manuscript:
Huan Zhang, Minxiao Wang, Hao Wang, Hao Chen, Lei Cao, Zhaoshan Zhong, Chao Lian, Li Zhou, Chaolun Li. Metagenome sequencing and 768 microbial genomes from cold seep in South China Sea. Scientific Data.


Raw Data was conducted to acquire the Clean Datausing Readfq v8 (https://github.com/cjfields/readfq).

The initial de novo assembly was carried out by the code in the file MEGAHIT. 

Genomes were then binned, refined and dereplicated, reassembled by the code in the file MetaWRAP.

Taxonomic classification of each bin was determined by the code in the file GTDB-Tk. 

The bin quality assessment was performed by the code in the file CheckM. 

All the predicted genes were searched against the nr database and KEGG prokaryote databaseby the code in the file Diamond and blast2kegg.pl. 

Orthologs were found by the code in the file Orthofinder.

Each ortholog was aligned, trimmed  and manually assessed, by the code in th file of  Phylogenomic tree.pl.
