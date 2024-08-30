############################################################################################################################# 
 
# IBOL 2024: BOLDconnectR test workflows


#############################################################################################################################


############################################################################################################################# # Workflow 1
#############################################################################################################################

# The test data for the workflow consists of a total of 715 publicly avaiable records of 62 species from 2 species rich insect orders Diptera and Lepidoptera. The data has been compiled such that the records overall have a wide distribution

# api key is required for retrieving data. It can be stored as a variable. Paste the API key here

api.key = 

# Installing BiocManager, msa and Biostrings is required for the sequence alignment function of BOLDconnectR

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install('msa')

BiocManager::install('Biostrings')

library(msa)

library(Biostrings)


if(!require('dplyr',quietly = TRUE))
{
  install.packages('dplyr')
  
  library(dplyr)
  
}

## Installing and importing 'BOLDconnectR'

# devtools::install_github("https://github.com/sameerpadhye/BOLDconnectR.git",
#                          auth_token = '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')

# devtools::install_github("https://github.com/boldsystems-central/BOLDconnectR.git")

devtools::install_github("https://github.com/boldsystems-central/BOLDconnectR/tree/v0.0.1-beta")

library(BOLDconnectR)

######################################## BOLDconnectR Functions ##########################################################


#0. Obtain all the meta data related (names, data type and brief explanation) to the data fields currently available on BOLD

bold.fields.data<-bold.fields.info()

View(bold.fields.data)

#1. Fetch the data for the records. The records are stored as a public dataset on BOLD database and is retrieved. The dataset code is entered in the 'param.data' argument. When providing single names for 'param.data' the param.index should be kept 1 by default. Care has to be taken to change the query.param to dataset_codes; Otherwise it will throw an error

fetch.test.data<-bold.fetch(param.data = "DS-IBOLR24",
                               query.param = "dataset_codes",
                               param.index = 1,
                               api_key = api.key)


# Check the number of rows downloaded
nrow(fetch.test.data)

# Fetch and filter data

#2a. Latitude
fetch.test.data.w.filt1<-bold.fetch(param.data = "DS-IBOLR24",
                                       query.param = "dataset_codes",
                                       param.index = 1,
                                       api_key = api.key,
                                    filt.latitude = c(9,45))
#Confirm the result
range(fetch.test.data.w.filt1$lat)

# Check the number of rows downloaded
nrow(fetch.test.data.w.filt1)


#2b. Sequence source
fetch.test.data.w.filt2<-bold.fetch(param.data = "DS-IBOLR24",
                                       query.param = "dataset_codes",
                                       param.index = 1,
                                       api_key = api.key,
                                       filt.seq.source = "Centre for Biodiversity Genomics")

#Confirm the result
head(subset(fetch.test.data.w.filt2,select = c(processid,bin_uri,sequence_run_site)),10)

# Check the number of rows downloaded
nrow(fetch.test.data.w.filt2)


#2c. Specific fields from the data
fetch.test.data.w.filt3<-bold.fetch(param.data = "DS-IBOLR24",
                                    query.param = "dataset_codes",
                                    param.index = 1,
                                    api_key = api.key,
                                    filt.fields = c("bin_uri","country.ocean","genus","species"))
#Confirm the result
head(fetch.test.data.w.filt3,10)

#2d. Basecount range
fetch.test.data.w.filt4<-bold.fetch(param.data = "DS-IBOLR24",
                                    query.param = "dataset_codes",
                                       param.index = 1,
                                       api_key = api.key,
                                       filt.basecount = c(600,670))
#Confirm the result
range(fetch.test.data.w.filt4$nuc_basecount)


#2e. Export locally (file.type, file.path and file.name must be provided)
fetch.test.data.export<-bold.fetch(param.data = "DS-IBOLR24",
                                   query.param = "dataset_codes",
                                      param.index = 1,
                                      api_key = api.key,
                                      filt.basecount = c(600,670),
                                      export = TRUE,
                                      file.type = "csv",
                                      file.path = "",
                                      file.name = "")


#3. Align sequences 
# Please note:
#a.It might take considerable time depending on the system used). 
#b.The way this function is called (BOLDconnectR:::bold.analyze.align) since it is an internal function of the package.
#c. The function by default uses all the default settings of 'msa'. Specific parameters like gap penalties can be passed through the '...' argument of the function(use ?msa::msa)

# A single genus COI sequence data within the range of 600-650 basepairs is fetched here for convenience
fetch.test.data.4.align<-bold.fetch(param.data = "DS-IBOLR24",
                                    query.param = "dataset_codes",
                                    param.index = 1,
                                    api_key = api.key,
                                    filt.taxonomy = "Manduca",
                                    filt.marker = "COI-5P",
                                    filt.basecount = c(600,650))

# Sequence is aligned using ClustalOmega with default settings
align.test.data<-BOLDconnectR:::bold.analyze.align(fetch.test.data.4.align,
                                                      seq.name.fields = c("species","bin_uri"),
                                                      align.method = "ClustalOmega")
# Confirm the result
head(subset(align.test.data,select = c(aligned_seq,msa.seq.name)),10)

#4. Analyze/Visualize the tree
# The tree generated for more than 50 sequences can get cluttered for base R graphics. Additionally, BOLDConnectR provides a simple nj plot with default settings. Additional modifications to the analysis/plot can either be done by passing arguments to ape::dist.dna argument via '...' OR  the 'phylo' object returned as a output.


#4a. Without generating the distance matrix output
test.tree<-bold.analyze.tree(align.test.data,
                                dist.model = "K80",
                                clus="njs",
                                tree.plot = TRUE,
                                tree.plot.type = 'p')

# The phylo object which can be used for further customization of the plot
test.tree$data_for_plot

# base frequencies
test.tree$base_freq 


#4b. With the distance matrix output
test.tree.w.dist.mat<-bold.analyze.tree(align.test.data,
                                           dist.model = "K80",
                                           clus="nj",
                                           dist.matrix = TRUE,
                                           tree.plot = TRUE,
                                           tree.plot.type = 'p')

# view the distance matrix
View(as.matrix(test.tree.w.dist.mat$dist_matrix))


#5. Biodiversity analysis of the fetched data

#5a. richness estimations based on country as a site category and bin_uri as the 'taxon.rank'

test.richness.diversity<-bold.analyze.diversity(fetch.test.data,
                                                   taxon.rank = "bin_uri",
                                                   site.cat = "country.ocean",
                                                   richness.res = TRUE,
                                                   rich.plot.curve = TRUE,
                                                   rich.curve.estimatr = "Chao1",
                                                   rich.curve.x.axis = "Samples")

# View the richness estimator results
View(test.richness.diversity$richness)

# View the estimation plot
test.richness.diversity$richness_plot

# View the community matrix generated for the diversity analysis
test.richness.diversity$comm.matrix


#5b. Preston plots based on region as a site category and bin_uri as the 'taxon.rank'

test.richness.diversity2<-bold.analyze.diversity(fetch.test.data,
                                                taxon.rank = "bin_uri",
                                                site.cat = "region",
                                                preston.res = T,
                                                pres.plot.y.label = "bin_uri")
# View the preston plot
test.richness.diversity2$preston.plot

# View the preston results (Please note that the 'No. of species' in the result actually reflects the No. of taxon.rank selected)
test.richness.diversity2$preston.res


#5c. Beta diversity based on country as a site category and bin_uri as the 'taxon.rank'

test.beta.diversity<-bold.analyze.diversity(fetch.test.data,
                                               taxon.rank = "bin_uri",
                                               site.cat = "country.ocean",
                                               beta.res = TRUE,
                                               beta.index = "jaccard")

# View total beta diversity
View(as.matrix(test.beta.diversity$total.beta))

# View the species replacement partition
View(as.matrix(test.beta.diversity$replace))


#6. Visualize the occurrences of the fetched records

#6a. All occurrences
test.map<-bold.analyze.map(fetch.test.data)

#6b. Specific country
test.map.brazil=bold.analyze.map(fetch.test.data,country = "Australia")


#7. Export the fasta file of unaligned and multiple sequence alignment (export.file.path & export.file.name must be specified)

bold.export(fetch.test.data,
            export = "fas",
            fas.seq.name.fields = c("genus","species","bin_uri"),
            export.file.path = "",
            export.file.name = "")
