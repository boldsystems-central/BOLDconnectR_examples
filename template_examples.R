############################################################################################################################# 
 
# IBOL 2024: BOLDconnectR test workflows


#############################################################################################################################

###### Fetch

#options:
#1. dataset/project codes
#2. sampleids
#3. processids
#4. BIN uris

#operational options
#a. takes a unique list of the identifiers (duplicates are not a problem)
#b. retrieves the data in batches to avoid bandwidth issues
#c. retrieves specific columns

#establish key
devtools::install_github("https://github.com/boldsystems-central/BOLDconnectR")
library(BOLDconnectR)

# Paste apikey in the function in single/double quotes
bold.apikey()

#option 1
bcdm_df<-bold.fetch(get_by = "dataset_codes", identifiers = "DS-IBOLR24")

#option 2 (using test.data sampleids)
bcdm_df<-bold.fetch(get_by = "sampleid", identifiers = test.data$sampleid)

#option 3 (using test.data processids)
bcdm_df<-bold.fetch(get_by = "processid", identifiers = test.data$processid)

#option 4 (using bin_uris)

bcdm_df<-bold.fetch(get_by = "bin_uris", identifiers = c("BOLD:ADE1075",
                                                         "BOLD:ADE2074",
                                                         "BOLD:ADE1271",
                                                         "BOLD:ACS1988",
                                                         "BOLD:AAB9845",
                                                         "BOLD:AAZ4742"))


#operating mode b: pass-thru - default is TSV.  It would be nice if JSONL was supported but not critical or important. (will be saved in the working directory; working directory can be accessed by getwd())

bcdm_subset_df<-bold.fetch(get_by = "dataset_codes", 
                           identifiers = "DS-IBOLR24", 
                           export="braconid_export", 
                           na.rm = TRUE)

#column filters: throw an error if non-valid columns
fetch.test.data<-bold.fetch(get_by = "dataset_codes", 
                            identifiers = "DS-IBOLR24", 
                            export="braconid_export.", 
                            na.rm = TRUE, 
                            cols=c("bins"))

#column presets: logic for this and above is: 1. generate a list of request fields; 2. confirm that all fields are BCDM; 3. apply filters while downloading. This has been used in the bold.export function (presets given in the exports section below)
# fetch.test.data<-bold.fetch(get_by = "dataset/project", identifiers = c("DS-IBOLR24"), col_presets="tax,geo", cols="processid,sampleid,collection_date")


#logic should be as follows:

#0. confirm parameters provided are valid 
#1. get the list of fields. If none provide just use the full set
#2. confirm list is valid. Do this regardless of if they provide a subset of columns
#3. retrieve data in batches
#4. handle output to session or file
#5. for each batch output a progress report in red. The reporting is as follows:
#     Initating download
#     Batches: 1..2..3..4..5..6
#     Download complete


###############################################################################################################################################################################################

###### Export (will be saved in the working directory; working directory can be accessed by getwd())

# taxonomy preset
bold.export(bold_df = bcdm_df,
            export_type = "preset_df",
            presets = 'taxonomy',
            export_to = "bcdm.export")

# geography preset
bold.export(bold_df = bcdm_df,
            export_type = "preset_df",
            presets = 'geography',
            export_to = "bcdm.export")

# unaligned fasta file
bold.export(bold_df = bcdm_df,
            export_type = "fas",
            cols_for_fas_names = c("processid","bin_uri"),
            export_to = "bcdm.export_fas")


###############################################################################################################################################################################################

###### Summarize






###############################################################################################################################################################################################

###### Search - wait
