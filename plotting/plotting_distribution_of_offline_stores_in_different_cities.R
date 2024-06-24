library(ggplot2)
library(sf)
library(dplyr)
library(RColorBrewer)
library(ggthemes)
library(scico)
library(viridis)
library(cowplot)
library(ggspatial)
library(grid)
# https://bookdown.org/nicohahn/making_maps_with_r5/docs/ggplot2.html
# https://upgo.lab.mcgill.ca/2019/12/13/making-beautiful-maps/

setwd('E:/umich/RealEstateBrokerage-main/ChinaAdminDivisonSHP/3. City')

base_shp <- "city.shp"
base_map <- st_read(base_shp)

names(base_map)[names(base_map) == 'ct_name'] <- 'name'
base_map <- base_map %>%
    mutate(name = recode(name, 
                         "北京城区" = "北京市",
                         "天津城区" = "天津市",
                         "上海城区" = "上海市",
                         "重庆城区" = "重庆市")) # we do not care about whether the major cities and the other parts

sansha_data <- base_map %>%
    filter(name == "三沙市")
base_map <- base_map %>%
    filter(name != "三沙市")

# this is a sample for the data and then we will generate the rest of the data to the result

file_path <- 'C:/Users/Xuyuan/Desktop/macro part/20总结_final.csv'
data <- read.csv(file_path)

# in order to better show the result, we should drop samples that have too short data

selected_cities <- c("天津市", "北京市", "上海市", "南京市", "成都市", "武汉市", "杭州市", "重庆市", "广州市", "深圳市")
selected_centroids <- merged_data[merged_data$name %in% selected_cities, ]
selected_centroids$centroid <- st_centroid(selected_centroids$geometry)

# nrow(data)
merged_data <- left_join(base_map, data, by = "name")
merged_data$store_share <- merged_data$lianjia / merged_data$all * 100


percentiles <- seq(0.1, 0.9, by = 0.1)
merged_data_filtered <- merged_data[merged_data$store_share > 0, ]
store_share_quantiles <- quantile(merged_data_filtered$store_share, percentiles, na.rm = TRUE)

max_value <- max(merged_data$store_share, na.rm = TRUE)
print(store_share_quantiles)

labels <- c(paste0("(", c(0, round(store_share_quantiles, 2)), ", ", c(round(store_share_quantiles, 2), round(max_value, 2)), "]"))

# Categorize store_share into bins based on the quantiles with custom labels
merged_data$store_share_bin <- cut(merged_data$store_share,
                                   breaks = c(-Inf, store_share_quantiles, Inf),
                                   labels = labels,
                                   right = FALSE)

merged_data$store_share_bin <- as.character(merged_data$store_share_bin)
merged_data$store_share_bin[is.na(merged_data$store_share)] <- "NA"
merged_data$store_share_bin[merged_data$store_share == 0] <- "0"
merged_data$store_share_bin <- factor(merged_data$store_share_bin, levels = c(labels, "0", "NA"))


crs_target <- st_crs(3415)
merged_data <- st_transform(merged_data, crs_target)
selected_centroids <- st_transform(selected_centroids, crs_target)
sansha_data <- st_transform(sansha_data, crs_target)

# Define a color palette
palette <- c(viridis(length(labels)), "snow", "grey70")
# , option = "magma"

distribution_across_cities <- ggplot() +
    geom_sf(data = merged_data[merged_data$store_share_bin %in% labels, ], 
            aes(fill = store_share_bin)) +
    geom_sf(data = merged_data[merged_data$store_share_bin == "0", ], 
            fill = "snow", color = "black") +
    geom_sf(data = merged_data[merged_data$store_share_bin == "NA", ], 
            fill = "grey70", color = "black") +
    geom_sf(data = selected_centroids, aes(geometry = centroid), color = "red", size = 1, shape = 21, fill = "yellow") +
    scale_fill_manual(values = palette, name = "Store Share", 
                      labels = c(labels, "0", "NA"), na.value = "grey50") +
    annotation_scale(location = "bl", width_hint = 0.5) + # Add scale bar
    annotation_north_arrow(location = "tl", which_north = "true", 
                           pad_x = unit(0.05, "in"), pad_y = unit(0.05, "in"),
                           style = north_arrow_fancy_orienteering) + # Add north arrow
    theme_minimal() +
    theme(
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "grey90"),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 10),
        legend.position = c(0.03, 0.03),  # Adjust the position to place it in the bottom left corner
        legend.justification = c(0, 0),  # Ensure proper alignment within the plot area
        legend.title = element_text(size = 10, face = "bold"),
        legend.text = element_text(size = 8)
    )

sansha_plot <- ggplot() +
    geom_sf(data = sansha_data, fill = "grey70", color = "black") +
    theme_void() +
    ggtitle("Sansha") # +
#     theme(plot.margin = margin(1, 1, 1, 1, "cm"))  # 增加图的边距
# 
# sansha_plot_with_dashed_box <- sansha_plot +
#     annotation_custom(
#         grob = rectGrob(gp = gpar(col = "black", lty = "dashed", fill = NA)),
#         xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf
#     )

combined_plot <- ggdraw() +
    draw_plot(distribution_across_cities) +
    draw_plot(sansha_plot, x = 0.75, y = 0.05, width = 0.2, height = 0.2)


combined_plot

ggsave(file = "distribution_of_cities_share.pdf", plot = combined_plot, dpi = 150)
