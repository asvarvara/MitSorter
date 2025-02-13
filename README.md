# MitSorter

[![Snakemake](https://img.shields.io/badge/snakemake-≥8.4.4-brightgreen.svg)](https://snakemake.bitbucket.io)

The precise discrimination between mitochondrial DNA (mtDNA) and nuclear mitochondrial DNA segments (NUMTs) is critical for accurate data analysis, particularly in studies focused on mitochondrial diseases and phylogenetics. Correct classification is not only crucial for reliable variant calling since NUMTs can confound the detection and interpretation of mtDNA mutations, but it also opens new avenues for investigating the functional implications of NUMTs methylation within nuclear genomic contexts. As Oxford Nanopore Technologies (ONT) enables direct methylation detection, offering the opportunity to classify these sequences based on the absence of CpG methylation in human mtDNA, we developed MitSorter, a bioinformatic stand-alone tool that distinguishes true mtDNA reads from NUMTs. 
<br/>
<br/>
MitSorter is an easy-to-use customizable pipeline generated through the Snakemake management system to reproduce the analysis steps needed to discriminate mitochondrial reads from ONT raw data to pod5 format.
<br/>
<br/>

##  📋  Authors

* Sharon Natasha Cox [@sharonnatashacox](https://github.com/sharonnatashacox)
* Angelo Sante Varvara [@asvarvara](https://github.com/asvarvara)
<br/>

##  ⚙️  Installation

### Git clone

Create a dedicated folder and download package source files via git clone.

```
$ mkdir MitSorter
$ cd MitSorter/
$ git clone https://github.com/asvarvara/MitSorter.git
```

### Configure needed tools

Gain access to the necessary tools by creating a Conda environment using the environment.yaml file.
<br/>
Then, activate it.

```
$ conda create env --name snakemake --file=environment.yaml
$ conda activate snakemake
```
<br/>

##  🔍  Input

MitSorter exclusively accepts ONT raw data in pod5 format. If you have raw data in fast5 format you can easily convert in pod5 format with [pod5](https://github.com/nanoporetech/pod5-file-format) converter tool.
<br/>
<br/>
Please note that to be compliant with the workflow structure, it is mandatory to add your pod5 files in a specific folder at this path *"/data/[sample_name]/pod5/"*.
<br/>
Subsequently, edit *config.yaml* to add your sample name, which has to be the same as the one used in the previous path. Once updated, you are ready to start.
<br/>
<br/>

##  🔧  Usage

MitSorter is a standard Snakemake workflow, if you are not familiar with all commands you can have a look [here](https://snakemake.readthedocs.io/en/stable/executing/cli.html#all-options).
<br/>
Just launch Snakemake, only one Snakefile in the current folder will be found and the complete workflow will run automatically.
```
$ snakemake
```
Consider launching the whole workflow in dry-mode before to test if it works properly.
```
$ snakemake -n
```
<br/>

##  📊  Output

This workflow generates the following files:
- BAM file which includes only non-methylated reads, in the *sorted_reads* folder
- BAM file which includes only methylated reads, in the *sorted_reads* folder
- General modified bases statistics regarding methylated BAM, in the *results* folder
- General modified bases statistics regarding not methylated BAM, in the *results* folder
<br/>

##  📌  Additional info

MitSorter has been tested on an HPC Cluster platform and requires GPU usage, as the first step of the pipeline, basecalling with [dorado](https://github.com/nanoporetech/dorado) is computationally intensive. We strongly recommend processing one sample at a time. 
<br/>
However, if the personal computing environment  supports multiple GPUs, the workflow can be parallelized the workflow by simply specifying multiple samples in a list within the *config.yaml* file (e.g. samples : [HG002, HG003]).
<br/>

Recommended requirements (one sample):

+ GPUs = 1
+ CPUs = 64
+ Memory = 128GB

Tested on the recently released [HG002](https://labs.epi2me.io/giab-2025.01/) Genome In A Bottle sample and is downlodable *via* aws (s3://ont-open-data/giab_2025.01/flowcells/HG002). Feel free to tweak the settings following your specific needs.
<br/>
You can specify the number of cores via the *--cores* flag to the snakemake command.
<br/>
<br/>
The workflow uses the latest available version of Dorado for the Conda environment (dorado-0.7.2, https://anaconda.org/HCC/dorado/files) for basecalling, together with the most recent modified basecalling models (sup v5.0.0) to achieve optimal accuracy for following variant calling. 
<br/>
However, this configuration may introduce computational slowdowns. A significant speed-up in the basecalling step can be achieved by switching to the (hac v4.3.0) models without leading differences in terms of discrimination between methulated and unmethylated reads. This modification can be implemented by adjusting the model specification in the second rule of the *Snakefile*.
<br/>
<br/>
Both pairs of models are provided in the repository and you can find them inside the *data* folder, as well as the hac v4.1.0 models that are required mandatorily in case of older 4kHz input data
