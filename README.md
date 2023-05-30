# AutoDock Vina GPU Virtual Screening Statistical Analysis

This repository contains R scripts for running a statistical analysis on the output files of AutoDock Vina GPU virtual screenings. It specifically focuses on data analysis for the scientific paper "Calcium-alginate-chitosan nanoparticle as a potential solution for environmental pesticide removal, a computational approach."

## Content

- **Files Folder**: This folder is intended for storing output files from Vina to be analyzed.
- **Auxiliary Files**: These are additional files used by the scripts to perform the analysis. As a user, you don't have to interact with these files directly. They are managed by the scripts automatically.
- **master.R**: This is the main R script. Running this script will coordinate the execution of the other scripts included in this project.

## How to Use

1. Clone this repository to your local machine.
2. Place your output files from AutoDock Vina GPU virtual screenings in the "Files" folder. These files should be in a specific format. This can be for instance, "polymer_frame10_conf1.log", where:
   - "polymer" is the specific target protein in your study.
   - "frame10" indicates the frame number from your molecular dynamics simulations.
   - "conf1" refers to the specific grid used for the docking process.
3. Run the script named "master.R".

## What Does This Software Do?

The software reads output files from AutoDock Vina GPU virtual screenings that involve a specific target, namely a polymer represented via several frames from molecular dynamics. It supports the analysis of more than one grid per frame. 

Once it has processed the output files, it generates a dataframe that includes columns for "system", "frame", "grid", "ligand", "energy", and "pose". The script then performs statistical analysis on this data, providing insightful visualizations for interpretation.

## Output

The software will provide the following outputs:

- **Dataframe**: A structured dataset that includes the columns "system", "frame", "grid", "ligand", "energy", and "pose". This dataset is used for further statistical analysis.
- **Statistical Analysis Plots**: Several plots will be generated based on the statistical analysis of the data. These plots can be used to draw meaningful insights from the data.

## Requirements

This software requires an installation of R and the following R packages:

- ggplot2
- dplyr
- readr

Please ensure these are installed before running the scripts.

## Contribution

Contributions to the software are welcome. If you find a bug or have an idea for an enhancement, please open an issue or submit a pull request.

## Contact

If you have any questions, feel free to open an issue or send an email to the repository owner.

## License

This software is open source under the MIT License. Please see the LICENSE file for more information.
