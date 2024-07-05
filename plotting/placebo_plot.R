library(dplyr)
library(haven)
library(ggplot2)
library(extrafont)
library(ggthemes)

name_figures <- c(
    ""
)


loadfonts(device = "win")
setwd("E:/umich/RealEstateBrokerage/analysis/placebo-test")
data <- read_dta("lead_entry_effect.dta")

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

ggsave(name_figure, plot = result, dpi = 300)
