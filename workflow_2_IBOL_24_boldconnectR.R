############################################################################################################################# # Workflow 2
#############################################################################################################################

# The test data for the workflow consists of all public records available for three neotropical Cichlids (group of primarily freshwater fish found on all continents except Antarctica) genera: Apistogramma, Crenicichla (South America) and Cichlasoma (North, Central and South America).

# api key is required for retrieving data. It can be stored as a variable (Paste the API key here)

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

# devtools::install_github("https://github.com/boldsystems-central/BOLDconnectR.git")

devtools::install_github("https://github.com/boldsystems-central/BOLDconnectR/tree/v0.0.1-beta")

library(BOLDconnectR)

######################################## BOLDconnectR Functions ##########################################################

# Here the IDs are downloaded using 'bold.public.search' function and the data is then fetched using 'bold.fetch'

#1. Search for records (public data)

search.cichlid.data<-bold.public.search(taxonomy= c("Apistogramma",
                                                    "Crenicichla","Cichlasoma"))

#2. Fetch the data for the records

fetch.cichlid.data<-bold.fetch(search.cichlid.data,
                               query.param = "processid",
                               param.index = 1,
                               api_key = api.key)

# Fetch and filter data

#2a. Altitude
fetch.cichlid.data.w.filt1<-bold.fetch(search.cichlid.data,
                                       query.param = "processid",
                                       param.index = 1,
                                       api_key = 'CE89B5A8-5ABE-4FB5-AEC6-187786EB1ED6',
                                       filt.altitude = c(1,300))

range(fetch.cichlid.data.w.filt1$elev)

#2b. Institutes
fetch.cichlid.data.w.filt2<-bold.fetch(search.cichlid.data,
                                       query.param = "processid",
                                       param.index = 1,
                                       api_key = api.key,
                                       filt.institutes = "South African Institute for Aquatic Biodiversity")

head(subset(fetch.cichlid.data.w.filt2,select = c(processid,bin_uri,inst)),10)

#2c. Specific fields from the data
fetch.cichlid.data.w.filt3<-bold.fetch(search.cichlid.data,
                                       query.param = "processid",
                                       param.index = 1,
                                       api_key = api.key,
                                       filt.fields = c("family","genus","region","identified_by"))

head(fetch.cichlid.data.w.filt3,10)

#2d. Geography
fetch.cichlid.data.w.filt4<-bold.fetch(search.cichlid.data,
                                       query.param = "processid",
                                       param.index = 1,
                                       api_key = api.key,
                                       filt.geography = c("Brazil", "Mexico"))

head(subset(fetch.cichlid.data.w.filt4,select = c(processid,bin_uri,country.ocean)),10)



#3. Align sequences 

# A single genus 'Apistogramma' is used here

fetch.cichlid.data.align<-bold.fetch(search.cichlid.data,
                                     query.param = "processid",
                                     param.index = 1,
                                     api_key = api.key,
                                     filt.taxonomy = 'Apistogramma')


align.cichlid.data<-BOLDconnectR:::bold.analyze.align(fetch.cichlid.data.align,
                                                      marker = "COI-5P",
                                                      seq.name.fields = c("species","bin_uri"),
                                                      align.method = "ClustalOmega")


head(subset(align.cichlid.data,select = c(aligned_seq,msa.seq.name)),10)

# Check the number of rows of the dataset

nrow(align.cichlid.data)


#4. Analyze/Visualize the tree
# Since tree generated for more than 50 sequences can get cluttered for base R graphics,(strictly) for visualization purposes, a random sample of 25observations is taken for visualization. Since the output of the bold.analyze.align is a BCDM data frame, it can be directly filtered.


set.seed(123)

cichlid.data.for.tree<-align.cichlid.data%>%
  dplyr::sample_n(25)%>%
  data.frame(.)

#4a. Without generating the distance matrix output
cichlid.tree<-bold.analyze.tree(cichlid.data.for.tree,
                                dist.model = "K80",
                                clus="nj",
                                tree.plot = TRUE,
                                tree.plot.type = 'p')


#4b. With the distance matrix output
cichlid.tree.w.dist.mat<-bold.analyze.tree(cichlid.data.for.tree,
                                           dist.model = "K80",
                                           clus="nj",
                                           dist.matrix = TRUE,
                                           tree.plot = TRUE,
                                           tree.plot.type = 'f')

View(as.matrix(cichlid.tree.w.dist.mat$dist_matrix))


#5. Biodiversity analysis of the fetched data

#5a. richness estimations based on country as a site category and bin_uri as the 'taxon.rank'

cichlid.richness.diversity<-bold.analyze.diversity(fetch.cichlid.data,
                                                   taxon.rank = "bin_uri",
                                                   site.cat = "country.ocean",
                                                   richness.res = TRUE,
                                                   rich.plot.curve = TRUE,
                                                   rich.curve.estimatr = "Chao1",
                                                   rich.curve.x.axis = "Individuals")


View(cichlid.richness.diversity$richness)

cichlid.richness.diversity$richness_plot


#5b. Beta diversity based on country as a site category and bin_uri as the 'taxon.rank'

cichlid.beta.diversity<-bold.analyze.diversity(fetch.cichlid.data,
                                               taxon.rank = "bin_uri",
                                               site.cat = "country.ocean",
                                               beta.res = TRUE,
                                               beta.index = "sorenson")

View(as.matrix(cichlid.beta.diversity$total.beta))


#6. Visualize the occurrences of the fetched records

#6a. All occurrences
cichlid.map<-bold.analyze.map(fetch.cichlid.data)

#6b. Specific country
cichlid.map.brazil=bold.analyze.map(fetch.cichlid.data,country = "Brazil")


#7. Export the fasta file of unaligned and multiple sequence alignment (export.file.path & export.file.name must be specified)

bold.export(fetch.cichlid.data,export = "fas",
            fas.seq.name.fields = c("genus","species","bin_uri"),
            export.file.path = ,
            export.file.name = )