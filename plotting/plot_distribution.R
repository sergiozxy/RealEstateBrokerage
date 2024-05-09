library(ggplot2)
library(ggmap)
library(RColorBrewer) # for color selection
library(aspace)
library(sf)
library(glue)
library(viridis)
library(stringr)
# you should register with google API
register_google(key = "your key")
# you need to set working directory to the directory that you store the data
setwd('/home/xuyuan/Desktop/2024 summer/real estate paper/oritignal cleaning/RealEstateBrokerage/plotting') # change this directory that contains the data

# Read the input spatiotemporal data
data <- read.csv('../dataframe_to_map.csv')

# the code book is listed here:
codebook <- setNames(c('Beijing', 'Chengdu', 'Chongqing', 'Guangzhou', 'Hangzhou', 'Nanjing', 'Shanghai', 'Shenzhen', 'Tianjin', 'Wuhan'), c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))

# Dictionary mapping English city names to Chinese city names
city_dict <- c(
  Beijing = "北京市",
  Chengdu = "成都市",
  Chongqing = "重庆市",
  Guangzhou = "广州市",
  Hangzhou = "杭州市",
  Nanjing = "南京市",
  Shanghai = "上海市",
  Shenzhen = "深圳市",
  Tianjin = "天津市",
  Wuhan = "武汉市"
)

if (file.exists('../figures/distribution_of_hp_and_broker')){
    pass
} else {
    dir.create(file.path('../figures/distribution_of_hp_and_broker'))
}

for (i in 1 : 10){
  # the we can correspondingly extract the brokerage data from the corresponding file
  # we only need the year 2022 data.
  temp_data <- data[data$city_id == i, ]
  # extract the temperary city name
  temp_data$city_name <- codebook[as.character(temp_data$city_id)]
  # store the english name of the city
  english_name <- temp_data[1, "city_name"]
  temp_data$city_name_chinese <- city_dict[temp_data$city_name]
  # and correspondingly chinese name
  file_name <- temp_data[1, "city_name_chinese"]
  files <- glue('../classifying brokerages/lianjia_beke/{file_name}22.csv')
  data1 <- read.csv(files)
  temp_data$geometry <- st_as_sfc(temp_data$geometry)
  # Convert the data frame to an sf object
  temp_data <- st_as_sf(temp_data)
  # Extract coordinates
  coords <- st_coordinates(temp_data)
  temp_data$lon <- coords[, "X"]
  temp_data$lat <- coords[, "Y"]
  # now retrieve the google map
  map_sf <- get_map(english_name, zoom = 10, maptype = 'satellite')
  ggmap(map_sf)
  # read the administrative data and make it geometry
  admin_data <- sf::st_read(glue('../administrative data/{file_name}.json'))
  points_sf <- st_as_sf(data1, coords = c("gpsx", "gpsy"), crs = st_crs(admin_data))
  # clean the administrative data to make it valid
  admin_data <- st_make_valid(admin_data)
  # now merge the data
  points_with_admin <- st_join(points_sf, admin_data, join = st_within)
  # Count NA in each column
  na_count_by_column <- sapply(points_with_admin, function(x) sum(is.na(x)))
  # print(na_count_by_column)
  # we can see that every one is masked correctly
  # extract the coordinates of the points
  coords_points <- st_coordinates(points_with_admin)
  points_with_admin$lon <- coords_points[, "X"]
  points_with_admin$lat <- coords_points[, "Y"]
  g.base <- ggmap(map_sf) +
    stat_density2d(data = temp_data, aes(x = lon, y = lat, fill = ..density..), geom = 'tile', contour = F, alpha = .5) +
    scale_fill_viridis(option = "magma") + # option = 'inferno'
    labs(
      # ,subtitle = 'There are also moderate pockets of crime in SOMA & the Mission'
      ,fill = str_c(glue('{english_name} \nHousing Price'))
    ) +
    theme(text = element_text(color = "#444444")
          ,plot.title = element_text(size = 22, face = 'bold')
          ,plot.subtitle = element_text(size = 12)
          ,axis.text = element_blank()
          ,axis.title = element_blank()
          ,axis.ticks = element_blank()
    ) +
    guides(fill = guide_legend(override.aes= list(alpha = 1)))
  # g.base
  name_figure <- glue('../figures/distribution_of_hp_and_broker/{english_name}.pdf')
  name_list_0 <- unique(points_with_admin$name.y)
  g.ellipse.spr <- g.base
  # now we plot for the standard ellipse
  for (j in 1:length(name_list_0)){
    dfi <- subset(points_with_admin, points_with_admin$name.y == name_list_0[j])
    # print(dfi)
    if (nrow(dfi) < 10) next
    des <- data.frame(dfi[, c('lon', 'lat')])
    # print(des)
    coordinates(des) <- ~ lon + lat
    cas_region <- SpatialPoints(coords = des)
    cas_region <- data.frame(coordinates(cas_region))
    r.SDE <- calc_sde(id = 1, points = cas_region)
    # print(r.SDE)
    print(j)
    # ellipse.spr <- data.frame(r.SDE$coordsSDE)
    coordsSDE <- r.SDE$FORPLOTTING$coordsSDE
    ellipse.spr <- data.frame(x = coordsSDE[,1], y = coordsSDE[,2])
    # print(ellipse.spr)
    names(ellipse.spr)[1] <- 'long'
    names(ellipse.spr)[2] <- 'lat'
    centre.spr <- data.frame(r.SDE$CENTRE.x, r.SDE$CENTRE.y)
    # Add ellipse points to the plot
    g.ellipse.spr <- g.ellipse.spr +
      geom_point(data = ellipse.spr, aes(x = long, y = lat),
                 color = 'green', alpha = 0.05, size = 0.08)
  }
  g.ellipse.spr
  ggsave(name_figure, plot = g.ellipse.spr, width = 7, height = 5, dpi = 300)
}

