################################################################################################################

# IBOL 2024: BOLDconnectR test workflows

###############################################################################################################

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

############################################################################################################################# # Workflow 2
#############################################################################################################################


# Workflow uses the test data (test.data) that comes with the package
?test.data

# api key is required for retrieving data. It is stored in the R session using the bold.apikey function

bold.apikey()


#1. Fetch the data for the records

download_test_data<-bold.fetch(get_by = "processid",
                               identifiers = test.data$processid)
 
head(download_test_data)

#1a. Fetch and filter data based on Altitude
download_test_data.w.filt1<-bold.fetch(get_by = "processid",
                                       identifiers = test.data$processid,
                                       filt_altitude = c(500,1500))

range(download_test_data.w.filt1$elev,na.rm = T)

#1b. Fetch and filter data based on Institutes
download_test_data.w.filt2<-bold.fetch(get_by = "processid",
                                       identifiers = test.data$processid,
                                       filt_institutes = "University of Toronto, Scarborough")

head(subset(download_test_data.w.filt2,
            select = c(processid,bin_uri,inst)),10)

#1c. Fetch and filter data based on identifier
download_test_data.w.filt3<-bold.fetch(get_by = "processid",
                                       identifiers = test.data$processid,
                                       filt_identified.by = "BOLD ID Engine")

head(download_test_data.w.filt3,10)

#1d. Geography
download_test_data.w.filt4<-bold.fetch(get_by = "processid",
                                       identifiers = test.data$processid,
                                       filt_geography = "Churchill")

head(subset(download_test_data.w.filt4,
            select = c(processid,bin_uri,region)),10)


#2. Data summary of the fetched results

# Presets
#a Sequences preset
bold.data.summarize(download_test_data,
                    summarize_by = "presets",
                    presets = 'sequences')

#b Attributions preset
bold.data.summarize(download_test_data,
                    summarize_by = "presets",
                    presets = 'attributions')

# Specific columns
bold.data.summarize(download_test_data,
                    summarize_by = "fields",
                    columns = c("bin_uri","inst","nuc"))


#3. Align sequences 

# A single genus 'Apistogramma' is used here
unique(download_test_data$genus)

download_test_data%>%
  group_by(genus)%>%
  tally()

test.data.align<-bold.fetch(get_by = "processid",
                            identifiers = test.data$processid,
                            filt_taxonomy = 'Attulus')


test.align<-BOLDconnectR:::bold.analyze.align(test.data.align,
                                              marker = "COI-5P",
                                              cols_for_seq_names = c("species","bin_uri"),
                                              align_method = "ClustalOmega")


head(subset(test.align,select = c(aligned_seq,msa.seq.name)),10)

# Check the number of rows of the dataset

nrow(test.align)

#4. Analyze/Visualize the tree
# Since tree generated for more than 50 sequences can get cluttered for base R graphics,(strictly) for visualization purposes, a random sample of 25observations is taken for visualization. Since the output of the bold.analyze.align is a BCDM data frame, it can be directly filtered.

#4a. Without generating the distance matrix output
test.tree<-bold.analyze.tree(test.align,
                                dist_model = "K80",
                                clus_method = "nj",
                                tree_plot = TRUE,
                                tree_plot_type = 'p')


#4b. With the distance matrix output
test.tree.w.dist.mat<-bold.analyze.tree(test.align,
                                           dist_model = "K80",
                                           clus_method = "nj",
                                           tree_plot = TRUE,
                                           tree_plot_type = 'r',
                                           save_dist_mat = TRUE)


View(as.matrix(cichlid.tree.w.dist.mat$dist_matrix))


#5. Biodiversity analysis of the fetched data

#5a. richness estimations based on country as a site category and bin_uri as the 'taxon.rank'

test.richness.diversity<-bold.analyze.diversity(download_test_data,
                                                   taxon_rank = "species",
                                                   site_type = "locations",
                                                   location_type = "region",
                                                   diversity_profile = "richness")


View(test.richness.diversity$richness)


#5b. Beta diversity based on country as a site category and bin_uri as the 'taxon.rank'

test.shannon.diversity<-bold.analyze.diversity(download_test_data,
                                               taxon_rank = "species",
                                               site_type = "locations",
                                               location_type = "region",
                                               diversity_profile = "shannon")

test.shannon.diversity$shannon_div

#6. Visualize the occurrences of the fetched records

#6a. All occurrences
test.map<-bold.analyze.map(download_test_data)

#6b. Specific country
test.map.canada<-bold.analyze.map(download_test_data,country = "Canada")


#7. Export the fasta file of unaligned and multiple sequence alignment (export.file.path & export.file.name must be specified)

bold.export(fetch.cichlid.data,export = "fas",
            fas.seq.name.fields = c("genus","species","bin_uri"),
            export.file.path = ,
            export.file.name = )