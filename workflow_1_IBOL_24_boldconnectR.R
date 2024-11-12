##########################################################################################################################
 
# BOLDconnectR test workflows

##########################################################################################################################

# Installing the package

devtools::install_github("https://github.com/boldsystems-central/BOLDconnectR")

# Importing the package

library(BOLDconnectR)

# Installing BiocManager, msa and Biostrings is required for the sequence alignment function of BOLDconnectR

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install('msa')

BiocManager::install('Biostrings')

# Optional

if(!require('dplyr',quietly = TRUE))
{
  install.packages('dplyr')
  
}

library(msa)

library(Biostrings)

library(dplyr)

########################################################################################################################## Workflow 1
##########################################################################################################################

# The workflow's test data consists of 715 publicly available records of 62 species from 2 species-rich insect orders Diptera and Lepidoptera (Dataset code: DS-IBOLR24). The data has been compiled so that the records have a wide distribution overall.


######################################## BOLDconnectR Functions ##########################################################

# Load the API key in the R session

bold.apikey()


#0. Obtain all the meta data related (names, data type and brief explanation) to the data fields currently available on BOLD

bold.fields.data<-bold.fields.info()

View(bold.fields.data)

#1. Fetch the data for the records. 
# The records are stored as a public dataset on BOLD database and is retrieved. The dataset code is entered in the 'param.data' argument. When providing single names for 'param.data' the param.index should be kept 1 by default. Care has to be taken to change the query.param to dataset_codes; Otherwise it will throw an error

fetch.test.data<-bold.fetch(identifiers = "DS-IBOLR24",
                               get_by = "dataset_codes")


# Check the number of rows downloaded
nrow(fetch.test.data)

# Fetch and filter data

#2a. Latitude
fetch.test.data.w.filt1<-bold.fetch(identifiers = "DS-IBOLR24",
                                    get_by = "dataset_codes",
                                    filt_latitude = c(9,45))
#Confirm the result
range(fetch.test.data.w.filt1$coord)

# Check the number of rows downloaded
nrow(fetch.test.data.w.filt1)


#2b. Sequence source
fetch.test.data.w.filt2<-bold.fetch(identifiers = "DS-IBOLR24",
                                    get_by = "dataset_codes",
                                    filt_seq_source = "Centre for Biodiversity Genomics")

#Confirm the result
head(subset(fetch.test.data.w.filt2,select = c(processid,
                                               bin_uri,
                                               sequence_run_site)),10)

# Check the number of rows downloaded
nrow(fetch.test.data.w.filt2)


#2c. basepair count filter
fetch.test.data.w.filt3<-bold.fetch(identifiers = "DS-IBOLR24",
                                    get_by = "dataset_codes",
                                    filt_basecount = c(550,650))
#Confirm the result
head(subset(fetch.test.data.w.filt2,
            select = c(processid,
                       bin_uri,
                       nuc_basecount)),10)

#2d. specific columns
fetch.test.data.w.filt4<-bold.fetch(identifiers = "DS-IBOLR24",
                                    get_by = "dataset_codes",
                                    cols = c("processid","sampleid","species","bin_uri"))
#Confirm the result
head(fetch.test.data.w.filt4,10)


#2e. Export locally (file.type, file.path and file.name must be provided)
fetch.test.data.export<-bold.fetch(identifiers = "DS-IBOLR24",
                                   get_by = "dataset_codes",
                                      filt_basecount = c(600,670),
                                      export = "C:/Users/samee/OneDrive/Desktop/trial")

#3. Data summary of the fetched results

# By presets
# Geography preset
bold.data.summarize(fetch.test.data,
                    summarize_by = "presets",
                    presets = 'geography')
# Taxonomy preset
bold.data.summarize(fetch.test.data,
                    summarize_by = "presets",
                    presets = 'taxonomy')

# All data

all_data_summary<-bold.data.summarize(fetch.test.data,
                                      summarize_by = "all_data")
# Summary table
all_data_summary$summary

# Summary plot
all_data_summary$plot


#4. Align sequences 
# Please note:
#a. Biostrings and msa need to be imported beforehand
#b.It might take considerable time depending on the system used). 
#c. The function by default uses all the default settings of 'msa'. Specific parameters like gap penalties can be passed through the '...' argument of the function(use ?msa::msa)

# A single genus COI sequence data within the range of 600-650 basepairs is fetched here for convenience
fetch.test.data.4.align<-bold.fetch(identifiers = "DS-IBOLR24",
                                    get_by = "dataset_codes",
                                    filt_taxonomy = "Manduca",
                                    filt_basecount = c(600,670))

# Sequence is aligned using ClustalOmega with default settings
align.test.data<-bold.analyze.align(bold_df = fetch.test.data.4.align,
                                    marker = "COI-5P",
                                    cols_for_seq_names = c("species","bin_uri"),
                                    align_method = "ClustalOmega")
# Confirm the result
head(subset(align.test.data,select = c(aligned_seq,msa.seq.name)),10)

#5. Analyze/Visualize the tree
# The tree generated for more than 50 sequences can get cluttered for base R graphics. Additionally, BOLDConnectR provides a simple nj plot with default settings. Additional modifications to the analysis/plot can either be done by passing arguments to ape::dist.dna argument via '...' OR  the 'phylo' object returned as a output.

#5a. Without generating the distance matrix output
test.tree<-bold.analyze.tree(bold_df=align.test.data,
                                dist_model = "K80",
                                clus_method = "njs",
                                tree_plot = TRUE,
                                tree_plot_type = 'p')

# The phylo object which can be used for further customization of the plot
test.tree$data_for_plot

# base frequencies
test.tree$base_freq 


#5b. With the distance matrix output
test.tree.w.dist.mat<-bold.analyze.tree(bold_df=align.test.data,
                                        dist_model = "K80",
                                        clus_method = "njs",
                                        tree_plot = TRUE,
                                        tree_plot_type = 'p',
                                        save_dist_mat = TRUE)

# view the distance matrix
View(as.matrix(test.tree.w.dist.mat$save_dist_mat))


#6. Biodiversity analysis of the fetched data

#6a. richness estimations based on country as a site category and bin_uri as the 'taxon.rank'

test.richness.diversity<-bold.analyze.diversity(bold_df=fetch.test.data,
                                                   taxon_rank = "genus",
                                                site_type = "locations",
                                                   location_type = "country.ocean",
                                                   diversity_profile = "richness")

# View the richness estimator results
View(test.richness.diversity$richness)

# Occurrence matrix (site X species)
test.richness.diversity$comm.matrix


#6b. Preston plots based on region as a site category and bin_uri as the 'taxon.rank'

test.richness.diversity2<-bold.analyze.diversity(bold_df=fetch.test.data,
                                                 taxon_rank = "genus",
                                                 site_type = "locations",
                                                 location_type = "country.ocean",
                                                 diversity_profile = "preston")
# View the preston plot
test.richness.diversity2$preston.plot


#6c. Beta diversity based on country as a site category and bin_uri as the 'taxon.rank'

test.beta.diversity<-bold.analyze.diversity(bold_df=fetch.test.data,
                                            taxon_rank = "genus",
                                            site_type = "locations",
                                            location_type = "country.ocean",
                                            diversity_profile = "beta",
                                            beta_index = "jaccard")

# View total beta diversity
View(as.matrix(test.beta.diversity$total.beta))

# View the species replacement partition
View(as.matrix(test.beta.diversity$replace))


#7. Visualize the occurrences of the fetched records

#7a. All occurrences
test.map<-bold.analyze.map(fetch.test.data)

#7b. Specific country
test.map.brazil=bold.analyze.map(fetch.test.data,country = "Australia")


#8. Export the fasta file of unaligned and multiple sequence alignment (export.file.path & export.file.name must be specified)

bold.export(bold_df = fetch.test.data,
            export_type = "fas",
            cols_for_fas_names = c("genus","species","bin_uri"),
            export_to = "C:/Users/samee/OneDrive/Desktop/trial")
