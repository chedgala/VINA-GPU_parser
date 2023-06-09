library(tidyverse)
library(tools)
library(ggpubr)
source("./functions.R")
library(scales)
library(ggplot2)

# Set the directory where the Vina outputs (*.log) are located
directory <- "./Files"
my_data_frame <- master(directory)

# my_data_frame %>% head
# my_data_frame %>% tail

options(scipen = 999)


###################################################################################
# plotting docking energy in every frame
fra <- ggboxplot(my_data_frame, x = "frame", y = "energy", color = "frame",
          palette ="hue",
          xlab = "MDs frames",
          ylab = "Docking energy (kcal/mol)", )  +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(color = "black", size = 18),
    axis.title = element_text(color = "black", face = "bold", size = 18),
    axis.text.x = element_text(colour = "black", size = 11),
    axis.text.y = element_text(colour = "black", size = 14),
    axis.ticks = element_line(colour = "black", size = 0.5),
    panel.border = element_rect(colour = "black", fill = NA, size = 0.5)
  ) +
  scale_y_continuous(name = "Docking energy (kcal/mol)", limits = c(-13, 0),
                     #expand = c(0.02,0.02),
                     breaks = seq(from = -13, to = 0, by = 1))
fra
ggsave(file = "Boxplot_energy_frames.png",
       plot = fra, width = 10, height = 8, dpi = 300)

###################################################################################
# plotting docking energy in every grid
gri <- ggboxplot(my_data_frame, x = "grid", y = "energy", color = "grid",
          xlab = "Docking grids",
          ylab = "Docking energy (kcal/mol)" ) +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(color = "black", size = 18),
    axis.title = element_text(color = "black", face = "bold", size = 18),
    axis.text.x = element_text(colour = "black", size = 14),
    axis.text.y = element_text(colour = "black", size = 14),
    axis.ticks = element_line(colour = "black", size = 0.5),
    panel.border = element_rect(colour = "black", fill = NA, size = 0.5)
  ) +
  scale_y_continuous(name = "Docking energy (kcal/mol)", limits = c(-13, 0),
                     #expand = c(0.02,0.02),
                     breaks = seq(from = -13, to = 0, by = 1))

gri
ggsave(file = "Boxplot_energy_grid.png",
       plot = gri, width = 10, height = 8, dpi = 300)


####################################################################################################

library("dplyr")
library("psych")

rank <- 1:624

##################################
# Geometric mean
geo_mean <- my_data_frame %>% group_by(ligand) %>%
  summarise(Geometric_mean = -exp(mean(log(abs(energy))))) %>%
  arrange(Geometric_mean)

geo_mean$RankingGeometricMean <- rank

##################################
# Arithmetric mean
arit_mean <- my_data_frame %>% group_by(ligand) %>%
  summarise(Arithmetic_mean = mean(energy)) %>%
  arrange(Arithmetic_mean)

arit_mean$RankingArithmeticMean <- rank

##################################
# Harmonic mean
harm_mean <- my_data_frame %>% group_by(ligand) %>%
  summarise(Harmonic_mean = harmonic.mean(energy)) %>%
  arrange(Harmonic_mean)

harm_mean$RankingHarmonicMean <- rank

##################################
# Minimum value (best)
min <- my_data_frame %>%
  group_by(ligand) %>%
  summarise(Minimum = min(energy)) %>%
  arrange(Minimum)

min$RankingMinimumValue <- rank

##################################
# Maximum value (worst)
# max <- my_data_frame %>%
#   group_by(ligand) %>%
#   summarise_at(vars(energy),
#                list(Maximum = max)) %>%
#   arrange(Maximum)

##################################
# median
med <- my_data_frame %>% group_by(ligand) %>%
  summarise(Median = median(energy)) %>%
  arrange(Median)

med$RankingMedian <- rank

#############################
# Sort by ligand
g2 <- geo_mean %>% arrange(ligand)
h2 <- harm_mean %>% arrange(ligand)
a2 <- arit_mean %>% arrange(ligand)
min2 <- min %>% arrange(ligand)
med2 <- med %>% arrange(ligand)

candidates <- cbind(g2, h2, a2, min2, med2)

candidates_rank <- subset(candidates, select = c(1, 3, 6, 9, 12, 15))


modeFunction <- function(df) {
  library(dplyr)

  df %>%
    mutate(Mode = apply(.[,2:6], 1, function(x) {
      tab <- table(x)
      if(length(tab) == 5) {
        max(x)
      } else {
        as.numeric(names(tab))[which.max(tab)]
      }
    }),
    FrequencyInRanking = apply(.[,2:6], 1, function(x) {
      tab <- table(x)
      if(length(tab) == 5) {
        paste0("1/", length(x))
      } else {
        paste0(max(tab), "/5")
      }
    }))
}

# Calling mode function
candidates_rank_modes <- modeFunction(candidates_rank)
candidates_rank_modes <- candidates_rank_modes %>%
  arrange(Mode)



########################################
# Saving the data in excel
library(openxlsx)
write.xlsx(candidates_rank_modes, 'candidates_rank_modes.xlsx')
write.xlsx(candidates, 'candidates_full_data.xlsx')


########################################
# getting the energy histogram of the whole dataset

hist <- gghistogram(my_data_frame, x = "energy", fill = "gray",
                    #add = "mean",
                    ylab = "Count",
                    xlab = "Vina energy (kcal/mol)" )  +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(color = "black", face = "bold", size = 16),
    axis.title = element_text(color = "black", face = "bold", size = 18),
    axis.text.x = element_text(colour = "black", size = 12),
    axis.text.y = element_text(colour = "black", size = 12),
    axis.ticks = element_line(colour = "black", size = 0.5),
    panel.border = element_rect(colour = "black", fill = NA, size = 0.5),
  ) +
  scale_x_continuous(name = "Docking energy (kcal/mol)", limits = c(-13, 0),
                     #expand = c(0.02,0.02),
                     breaks = seq(from = -13, to = 0, by = 1)) +
  scale_y_continuous(name = "Frequency", limits = c(0, 80000),
                     #expand = c(0.02,0.02),
                     breaks = seq(from = 0, to = 80000, by = 20000))
  #+
  #theme(panel.grid.major = element_line(colour = "gray", size = 0.2),
  #     panel.grid.minor = element_line(colour = "gray", size = 0.2))

hist
ggsave(file = "Hist_energy_all_pesticides.png",
       plot = hist , width = 15, height = 12, dpi = 300)

########################################################
#getting the energy distribution of the best candidates (modify ligands vector) from my_data_frame
colors <- c("#1F77B4", "#2CA02C", "#D62728", "#9467BD",  "#E377C2")

plot_ligand_histogram <- function(df) {
  library(ggplot2)

  # Select the desired ligands
  ligands <- c("OPT.54676884", "OPT.56945145", "OPT.56602311", "OPT.54680782", "OPT.91771")
  #ligands <- c("OPT.54676884", "OPT.56945145", "OPT.56602311", "OPT.54675779", "OPT.54680782")
  labels <- c("CA1", "CA2", "CA3", "CA4", "CA5")

  df <- df[df$ligand %in% ligands, ]

  # Convert ligand column to factor and specify order of levels
  df$ligand <- factor(df$ligand, levels = ligands)

  # Create histogram with ggplot2
  p <- ggplot(df, aes(x = energy, fill = ligand)) +
    geom_histogram(color = "black") +
    facet_wrap(~ligand, scales = "free_y", ncol = 1) +
    labs(x = "Vina energy (kcal/mol)", y = "Frequency") +
    theme_bw() +
    # theme(plot.title = element_text(hjust = 0.5),
    #       legend.position = "none",
    #       axis.text = element_text(size = 8),
    #       axis.title = element_text(size = 10),
    #       panel.grid.major = element_blank(),
    #       panel.grid.minor = element_blank(),
    #       panel.border = element_blank(),
    #       axis.line = element_line(colour = "black"))
    theme(
      strip.text = element_blank(),
      legend.position = "top",
      legend.title = element_blank(),
      legend.text = element_text(color = "black", face = "bold", size = 13),
      axis.title = element_text(color = "black", face = "bold", size = 18),
      axis.text.x = element_text(colour = "black", size = 12),
      axis.text.y = element_text(colour = "black", size = 12),
      axis.ticks = element_line(colour = "black", size = 0.5),
      panel.border = element_rect(colour = "black", fill = NA, size = 0.5),
    )


  # Add x-axis scale
  p <- p + scale_x_continuous(name = "Docking energy (kcal/mol)", limits = c(-13, 0),
                              breaks = seq(from = -13, to = 0, by = 1))

  p <- p + scale_fill_manual(values = colors, label = labels)

  # p <- p + theme(
  #   legend.position = "top",
  #   legend.title = element_blank(),
  #   #legend.text = element_text(color = "black", size = 14),
  #   axis.title = element_text(color = "black", face = "bold", size = 18),
  #   axis.text.x = element_text(colour = "black", size = 13),
  #   axis.text.y = element_text(colour = "black", size = 14),
  #   axis.ticks = element_line(colour = "black", size = 0.5)
  # )

  p <- p + theme(panel.grid.major = element_blank(),
                 panel.grid.minor = element_blank())

  return(p)
}


h <- plot_ligand_histogram(my_data_frame)
h


ggsave(file = "Hist_energy_best_candidates.png",
       plot = h , width = 15, height = 12, dpi = 300)

############################################
# merge energy histogram of the best candidates and the whole dataframe
library(gridExtra)
tot <- grid.arrange(hist, h, ncol = 1, heights = c(0.4, 1))
tot


ggsave(file = "Hist_energy_total.png",
       plot = tot , width = 15, height = 12, dpi = 300)


########################
cuartiles <- cut(my_data_frame$energy, breaks = quantile(my_data_frame$energy, probs = seq(0, 1, 0.25)), include.lowest = TRUE)
table(cuartiles)


summary(my_data_frame)

########################
# Best candidates analysis

ligands <- c("OPT.54676884", "OPT.56945145", "OPT.56602311", "OPT.54680782", "OPT.91771")

for (h in ligands) {
  subset_data <- my_data_frame %>% filter(ligand == h)
  print(paste0("Resumen para ", h, ":"))
  print(summary(subset_data))
}





ggsave(file = "Hist_energy_all_pesticides.png",
       plot = hist , width = 15, height = 12, dpi = 300)


#########################################################
# get the bins from histogram
plot_data <- ggplot_build(hist)

# get data per bin
bins_data <- plot_data$data[[1]]

bin_intervals <- plot_data$layout$panel_params[[1]]$x.range[1:2]

# show data per bin
print(paste("Bin intervals:", bin_intervals))
print(bins_data)


# sort the frequencies in each bin
bins_data <- bins_data[order(-bins_data$count),]

# Calculate the % for each bind
bins_data$percent_cumulative <- cumsum(bins_data$count)/sum(bins_data$count)*100

# select the rows where the % is <= 80%
bins_selected <- bins_data[bins_data$percent_cumulative <= 20,]

# get the maximum and minimum for each column
x_min <- min(bins_selected$x)
x_max <- max(bins_selected$x)

cat(sprintf("The intervals that contain 80% of the data are: [%f, %f]\n", x_min, x_max))


##########################
hist_count <- ggplot(my_data_frame, aes(x = energy)) +
  geom_histogram(fill = "gray", bins = 20) +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(color = "black", size = 18),
    axis.title = element_text(color = "black", face = "bold", size = 18),
    axis.text.x = element_text(colour = "black", size = 13),
    axis.text.y = element_text(colour = "black", size = 14),
    axis.ticks = element_line(colour = "black", size = 0.5),
    panel.border = element_rect(colour = "black", fill = NA, size = 0.5)
  ) +
  scale_x_continuous(name = "Docking energy (kcal/mol)", limits = c(-13, 0),
                     breaks = seq(from = -13, to = 0, by = 1)) +
  scale_y_continuous(name = "Frequency", limits = c(0, 80000),
                     breaks = seq(from = 0, to = 80000, by = 20000)) +
  stat_bin(geom = "text", aes(label = ..count..), vjust = -0.5)

hist_count

################outliers###############
iqrs <- IQR(my_data_frame$energy)
lim_inf <- quantile(my_data_frame$energy, 0.25) - 1.5 * iqrs
lim_sup <- quantile(my_data_frame$energy, 0.75) + 1.5 * iqrs

lim_inf
lim_sup

inf_outlier <- my_data_frame %>%
  filter(energy < lim_inf)


n_inf_outlier <- nrow(inf_outlier)
n_inf_outlier

sup_outlier <- my_data_frame %>%
  filter(energy > lim_sup)

n_sup_outlier <- nrow(sup_outlier)
n_sup_outlier
