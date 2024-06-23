library(ggplot2)
library(sf)
library(dplyr)
library(RColorBrewer)
library(ggthemes)
library(scico)
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
                         "重庆城区" = "重庆市",
                         "重庆郊县" = "重庆市")) # we do not care about whether the major cities and the other parts

sansha_data <- base_map %>%
    filter(name == "三沙市")
base_map <- base_map %>%
    filter(name != "三沙市")

# ggplot() +
#     geom_sf(data = base_map) +
#     theme_minimal() +
#     ggtitle("Base Map")

# this is a sample for the data and then we will generate the rest of the data to the result

file_path <- 'C:/Users/Xuyuan/Desktop/macro part/20总结_final.csv'
data <- read.csv(file_path)

# in order to better show the result, we should drop samples that have too short data
merged_data$store_share <- merged_data$lianjia / merged_data$all

selected_cities <- c("天津市", "北京市", "上海市", "南京市", "成都市", "武汉市", "杭州市", "重庆市", "广州市", "深圳市")
english_names <- c("Tianjin", "Beijing", "Shanghai", "Nanjing", "Chengdu", "Wuhan", "Hangzhou", "Chongqing", "Guangzhou", "Shenzhen")

city_mapping <- setNames(english_names, selected_cities)

filtered_data <- merged_data %>%
    filter(name %in% selected_cities) %>%
    mutate(city = city_mapping[name]) %>% # Replace Chinese names with English names
    arrange(desc(store_share)) %>% # Sort by store_share from high to low
    distinct(city, .keep_all = TRUE) # Remove duplicates based on the city name

ten_cities_distribution <- ggplot(filtered_data, aes(x = reorder(city, -store_share), y = store_share)) +
    geom_bar(stat = "identity", fill = "skyblue", color = "black", alpha = 0.7) +
    labs(x = "City",
         y = "Store Share") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file = "distribution_of_ten_cities.pdf", plot = ten_cities_distribution, dpi = 300)

# nrow(data)
merged_data <- left_join(base_map, data, by = "name")


# sum(is.na(merged_data$lianjia))
# there are 17 na values in the result

percentiles <- seq(0.1, 0.9, by = 0.1)
merged_data_filtered <- merged_data[merged_data$store_share > 0, ]
store_share_percentiles <- quantile(merged_data_filtered$store_share, percentiles, na.rm = TRUE)

store_share_percentiles <- c(0, store_share_percentiles)

# Print the result
print(store_share_percentiles)

palette <- colorRampPalette(brewer.pal(11, "Spectral"))(10)

ggplot() +
    geom_sf(data = merged_data, aes(fill = store_share)) +
    scale_fill_gradientn(colours = palette, na.value = "grey50", name = "Store Share", breaks = store_share_percentiles) +
    theme_minimal() +
    theme(
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "grey90"),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 10),
        legend.position = "right",
        legend.title = element_text(size = 10, face = "bold"),
        legend.text = element_text(size = 8)
    ) +
    ggtitle("Market Share Distribution by Region") +
    geom_sf(data = merged_data[is.na(merged_data$store_share), ], fill = "grey70", color = "white")


# Set a color palette
palette <- rev(scico(8, palette = "davos")[2:7])

# Plot the merged data using ggplot2
ggplot() +
    # Add the base map layer
    geom_sf(data = merged_data, aes(fill = store_share), color = "white", size = 0.1) +  
    # Customize fill scale
    scale_fill_gradientn(colours = palette, na.value = "grey50", name = "Market Share") +
    # Coordinate system
    coord_sf() +
    # Theme and additional styling
    ggthemes::theme_map() +
    theme(
        legend.position = "bottom",
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)
    ) +
    # Labels
    labs(
        x = NULL, 
        y = NULL, 
        title = "Market Share Distribution by Region", 
        subtitle = "Market Share in Different Regions", 
        caption = "Source: Your Data Source"
    ) +
    # Highlight regions with missing data
    geom_sf(data = merged_data[is.na(merged_data$store_share), ], fill = "grey70", color = "white") +
    geom_text(data = merged_data[is.na(merged_data$store_share), ],
              aes(label = name, geometry = geometry),
              stat = "sf_coordinates",
              size = 3, color = "black")


# we should also add another line plot so that we can plot the result better in our ten cities' sample