library(ggplot2)
library(sf)
library(dplyr)
library(RColorBrewer)
library(ggthemes)
library(scico)

file_path <- 'C:/Users/Xuyuan/Desktop/macro part/20总结_final.csv'
data <- read.csv(file_path)

# in order to better show the result, we should drop samples that have too short data
data$store_share <- data$lianjia / data$all

selected_cities <- c("天津市", "北京市", "上海市", "南京市", "成都市", "武汉市", "杭州市", "重庆市", "广州市", "深圳市")
english_names <- c("Tianjin", "Beijing", "Shanghai", "Nanjing", "Chengdu", "Wuhan", "Hangzhou", "Chongqing", "Guangzhou", "Shenzhen")

city_mapping <- setNames(english_names, selected_cities)

filtered_data <- data %>%
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
