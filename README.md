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
$ git clone https://github.com/asvarvara/MitSorter
```

### Configure needed tools

Get access to needed tools creating a conda environment via *environment.yaml* file. 
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
Subsequently, edit *config.yaml* adding your sample name, which had to be the same one used in the previous path, and you are ready to go.
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
- BAM file which includes only not methylated reads, in the *sorted_reads* folder
- BAM file which includes only methylated reads, in the *sorted_reads* folder
- General modified bases statistics regarding methylated BAM, in the *results* folder
- General modified bases statistics regarding not methylated BAM, in the *results* folder
<br/>

##  📌  Additional info

MitSorter has been tested on an HPC Cluster platform and requires GPU usage as the first step of the pipeline is the basecalling with [dorado](https://github.com/nanoporetech/dorado). We strongly recommend launching one sample at a time, though it is possible to parallelize the workflow by simply specifying two different samples in a list in the *config.yaml* file.
<br/>

Recommended requirements (one sample):

+ GPUs = 1
+ CPUs = 64
+ Memory = 128GB

Tested on the recently released [HG002](https://labs.epi2me.io/giab-2025.01/) Genome In A Bottle sample. Feel free to tweak the settings following your specific needs.
<br/>
You can specify the number of cores via the *--cores* flag to the snakemake command.
<br/>
<br/>
The workflow is designed to use the latest model by dorado in terms of basecalling and modified bases calling (sup v5.0.0) to deliver the most accurate performances, but it can lead to slowdowns of the whole process. In those cases, a sensible speed-up of the basecalling step can be achieved by changing the models to the hac 4.3.0 versions, changing them in the second rule of *Snakefile*.
<br/>
Both pairs of models are provided in the repo and you can find them inside the *data* folder.
