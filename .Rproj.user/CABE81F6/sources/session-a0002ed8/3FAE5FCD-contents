# main function -------------------------------------------------------

master <- function(directory){

  # Read the names of the files in the folder
  file_names <- list.files(path = directory)

  parts = matrix(data = NA,nrow = length(file_names),ncol = 3)
  dfi = data.frame(system = NULL,
                   frame = NULL,
                   grid = NULL,
                   ligand = NULL,
                   energy = NULL,
                   pose = NULL)

  for(i in 1:length(file_names)){

    cat("Document",i,"of",length(file_names),"\n")

    data <- readLines(paste0("./Files/",file_names[i]))
    df1 <- parser(data)
    m = nrow(df1)
    df1$pose <- rep(1:9,m/9)

    #Split the parts of the file name
    parts[i,] <- strsplit(file_names[i], "_frame|_conf|.log") %>% unlist

    dfi0 <- data.frame(system = rep(parts[i,1],m),
                       frame = rep(parts[i,2],m),grid = rep(parts[i,3],m))
    dfi_temp <- cbind(dfi0,df1)
    dfi <- rbind(dfi,dfi_temp)
  }

  #parsing the name of the ligand
  dfi$ligand <- as.factor(unlist(lapply(as.character(dfi$ligand), extract_after_out)))
  return(dfi)
}


# Parser ---------------------------------------------------------------

parser <- function(data){
  # Initialize variables to store the parsed data
  ligands <- list()
  modes <- list()
  affinities <- list()
  rmsd_lb <- list()
  rmsd_ub <- list()

  # Loop over the lines of the data
  for (i in seq_along(data)) {
    # Use regular expressions to parse the ligand name and the data for each mode
    if (grepl("Refining ligand", data[i])) {
      ligand <- gsub("^.*pdbqt_frame19_config1_out/", "", data[i])
      ligand <- gsub(" results...done.$", "", ligand)
      modes[[ligand]] <- c()
      affinities[[ligand]] <- c()
      rmsd_lb[[ligand]] <- c()
      rmsd_ub[[ligand]] <- c()
    } else if (grepl("\\d+\\s+(-?\\d+\\.\\d+)\\s+(-?\\d+\\.\\d+)\\s+(-?\\d+\\.\\d+)", data[i], perl=TRUE)) {
      mode_data <- strsplit(trimws(data[i]), "\\s+")
      modes[[ligand]] <- c(modes[[ligand]], as.numeric(mode_data[[1]][1]))
      affinities[[ligand]] <- c(affinities[[ligand]], as.numeric(mode_data[[1]][2]))
      rmsd_lb[[ligand]] <- c(rmsd_lb[[ligand]], as.numeric(mode_data[[1]][3]))
      rmsd_ub[[ligand]] <- c(rmsd_ub[[ligand]], as.numeric(mode_data[[1]][4]))
    }
  }

  a <- data.frame(affinities)
  n <- reshape2::melt(a, id.vars = character(), measure.vars = colnames(a))
  colnames(n) <- c("ligand","energy")

  return(n)
}


# Extract ligand ----------------------------------------------------------

# Function to extract the part of the text after "out."
extract_after_out <- function(text) {
  parts <- strsplit(text, "out\\.")
  return(parts[[1]][2])
}
