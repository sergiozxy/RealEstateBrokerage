library(dplyr)
library(haven)
library(ggplot2)
library(extrafont)
library(ggthemes)
library(showtext)

name_figures <- c(
  "placebo_entry_num.pdf",
  "placebo_entry_lead.pdf",
  "placebo_entry_period.pdf",
  "placebo_entry_concession.pdf"
)

name_figures2 <- c(
    "placebo_plat_num.pdf",
    "placebo_plat_lead.pdf",
    "placebo_plat_period.pdf",
    "placebo_plat_concession.pdf"
)

# This is for Windows System
loadfonts(device = "win")

# for LINUX system:
# Enable showtext to automatically use the registered fonts
showtext_auto()

# Manually add the Times New Roman font
font_add("Times New Roman", 
         regular = "/usr/share/fonts/truetype/msttcorefonts/times.ttf",
         bold = "/usr/share/fonts/truetype/msttcorefonts/timesbd.ttf",
         italic = "/usr/share/fonts/truetype/msttcorefonts/timesi.ttf",
         bolditalic = "/usr/share/fonts/truetype/msttcorefonts/timesbi.ttf")
# Windows System
setwd("E:/umich/RealEstateBrokerage/analysis/placebo-test")
# Linux System
setwd("/home/xuyuan/Desktop/RealEstateBrokerage/analysis/placebo-test")

file_names <- c('num_entry_effect.dta', 'lead_entry_effect.dta', 'period_entry_effect.dta', 'conces_entry_effect.dta')
file_names2 <- c('num_platform.dta', 'lead_platform.dta', 'period_platform.dta', 'conces_platform.dta')



for (i in 1:length(file_names)) {
    data <- read_dta(file_names[i])
    
    means <- colMeans(data)
    sds <- apply(data, 2, sd)
    
    names_list <- c('pre2', 'pre1', 'entry', 'post1', 'post2', 'post3')
    
    plot_data <- data.frame(
        Coefficient = factor(names_list, levels = names_list),
        Mean = means,
        SD = sds
    )
    
    result <- ggplot(plot_data, aes(x = Coefficient, y = Mean)) +
        geom_point(size = 3, color = "darkblue") +
        geom_errorbar(aes(ymin = Mean - SD, ymax = Mean + SD), width = 0.2) +
        theme_classic(base_family = "Times New Roman") +  # Use Arial font
        labs(y = "Mean Value",
             x = "Coefficient") +
        theme_bw() +  # Apply a beautiful theme from ggthemes
        theme(
            text = element_text(family = "Times New Roman", size = 14),  # Use Arial font
            axis.title = element_text(size = 9, face = "bold"),
            axis.text = element_text(size = 7, face = "bold"),
            plot.title = element_text(size = 7, hjust = 0.5),
            legend.title = element_text(size = 5),
            legend.text = element_text(size = 5)
        )
    
    ggsave(name_figures[i], plot = result, dpi = 300)
}



for (i in 1:length(file_names2)) {
    data <- read_dta(file_names2[i])
    
    means <- colMeans(data)
    sds <- apply(data, 2, sd)
    
    names_list <- c('pre2', 'pre1', 'entry', 'post1', 'post2', 'post3')
    
    plot_data <- data.frame(
        Coefficient = factor(names_list, levels = names_list),
        Mean = means,
        SD = sds
    )
    
    result <- ggplot(plot_data, aes(x = Coefficient, y = Mean)) +
        geom_point(size = 3, color = "darkblue") +
        geom_errorbar(aes(ymin = Mean - SD, ymax = Mean + SD), width = 0.2) +
        theme_classic(base_family = "Times New Roman") +  # Use Arial font
        labs(y = "Mean Value",
             x = "Coefficient") +
        theme_bw() +  # Apply a beautiful theme from ggthemes
        theme(
            text = element_text(family = "Times New Roman", size = 14),  # Use Arial font
            axis.title = element_text(size = 9, face = "bold"),
            axis.text = element_text(size = 7, face = "bold"),
            plot.title = element_text(size = 7, hjust = 0.5),
            legend.title = element_text(size = 5),
            legend.text = element_text(size = 5)
        )
    
    ggsave(name_figures2[i], plot = result, dpi = 300)
}

