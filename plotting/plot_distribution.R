library(ggplot2)
library(ggmap)
library(RColorBrewer) # for color selection

# you need to set working directory to the directory that you store the data
setwd('/home/xuyuan/Desktop/2024 summer/real estate paper/oritignal cleaning/RealEstateBrokerage/plotting')

# Read the input spatial-temporal data
data <- read.csv('../dataframe_to_map.csv')

# the code book is listed here:
codebook <- dictionary(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), c('Beijing', 'Chengdu', 'Chongqing', 'Guangzhou', 'Hangzhou', 'Nanjing', 'Shanghai', 'Shenzhen', 'Tianjin', 'Wuhan'))
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
# the we can correspondingly extract the brokerage data from the corresponding file
# we only need the year 2022 data.
data1 <- read_csv('../classifying brokerages/lianjia_beke/')

# now after all these readings we can deal with the 