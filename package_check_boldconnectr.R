check_packages<-function()
{

cat(paste("The R version on your machine is: ",R.version$major,".",R.version$minor,sep=''))
  
cat("\n\nBOLDconnectR requires: R(>= 4.0.0)\n")  
  
installed_packages <- as.data.frame(installed.packages()[, c("Package", "Version")])

dependencies <- "ape(>= 5.5), BAT(>= 2.0), data.table(>= 1.13), dplyr(>= 1.0.1), ggplot2(>= 3.3.2), httr(>= 1.4.2), jsonlite(>= 1.7),\nmaps(>= 3.3), methods, reshape2, rnaturalearth, sf(>= 0.9.4),\nskimr(>= 2.1.2), tidyr(>= 1.1.1), utils, vegan(>= 2.5.7)"

package_names_w_versions<-unlist(strsplit(dependencies,",\\s"))

dependencies.df <- data.frame(package_names = package_names_w_versions)

dependencies.df$Package <- sub("\\(.*", "", dependencies.df$package_names)

dependencies.df$v_greater_or_equal_to <- ifelse(
  grepl("\\(.*\\)", dependencies.df$package_names),
  sub(".*\\((.*)\\)", "\\1", dependencies.df$package_names),
  NA
)

dependencies.df$v_greater_or_equal_to <- gsub("\\)", "", dependencies.df$v_greater_or_equal_to)

dependencies.df$v_greater_or_equal_to <- gsub(">=", "", dependencies.df$v_greater_or_equal_to)


dependencies_available <- merge(installed_packages, dependencies.df, by = "Package")

# Rename the columns 'Version' and 'v_greater_or_equal_to'
names(dependencies_available)[names(dependencies_available) == "Version"] <- "Version_available"

names(dependencies_available)[names(dependencies_available) == "v_greater_or_equal_to"] <- "min_version_required"

dependencies_available<-dependencies_available[,-3]

cat("\nDisplaying the dependent packages required by BOLDconnectR that are available on your machine with their respective versions and the minimum version required for running the package smoothly. The NA values in the min_version_required either mean that its a core package or the latest version is available on your machine if installed previously:\n\n")

print(dependencies_available)

cat("\n")

# Suggestions

suggestions<-data.frame(Package=c("Biostrings", "BiocManager", "msa"))

suggestions_available <- merge(installed_packages, suggestions, by = "Package")

cat("\nDisplaying the suggested packages required by the bold.analyze.align and bold.analyze.tree functions of BOLDconnectR that are available with their respective versions for running the package smoothly. Please note:\n\n")

print(suggestions_available)

}
check_packages()
