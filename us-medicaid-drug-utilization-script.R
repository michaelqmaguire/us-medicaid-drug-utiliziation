#-----------------------------------------------------------------------------------------------------------------#
#                                                                                                                 #
# PROJECT: US MEDICAID DRUG UTILIZATION                                                                           #
# AUTHOR: MICHAEL MAGUIRE, MS, DMA II                                                                             #
# INSTITUTION: UNIVERSITY OF FLORIDA, COLLEGE OF PHARMACY                                                         #
# DEPARTMENT: PHARMACEUTICAL OUTCOMES AND POLICY                                                                  #
# SUPERVISORS: AMIE GOODIN, PHD MPP | JUAN HINCAPIE-CASTILLO, PHARMD PHD MS                                       #
#                                                                                                                 #
#-----------------------------------------------------------------------------------------------------------------#

## Load packages

library(dplyr)
library(ggplot2)
library(purrr)
library(readr)
library(tidylog)

## Download files

## List out all the urls.
## I can't find a way to pull these without having to manually copy and paste since the id is between
## /views/ and /rows.csv?. It's not something I can just generate in a vector and pull from.

urls <-
  c("https://data.medicaid.gov/api/views/va5y-jhsv/rows.csv?accessType=DOWNLOAD", # 2020
    "https://data.medicaid.gov/api/views/qnsz-yp89/rows.csv?accessType=DOWNLOAD", # 2019
    "https://data.medicaid.gov/api/views/e5ds-i36p/rows.csv?accessType=DOWNLOAD", # 2018
    "https://data.medicaid.gov/api/views/3v5r-x5x9/rows.csv?accessType=DOWNLOAD", # 2017
    "https://data.medicaid.gov/api/views/3v6v-qk5s/rows.csv?accessType=DOWNLOAD", # 2016
    "https://data.medicaid.gov/api/views/ju2h-vcgs/rows.csv?accessType=DOWNLOAD", # 2015
    "https://data.medicaid.gov/api/views/955u-9h9g/rows.csv?accessType=DOWNLOAD", # 2014
    "https://data.medicaid.gov/api/views/rkct-3tm8/rows.csv?accessType=DOWNLOAD", # 2013
    "https://data.medicaid.gov/api/views/yi2j-kk5z/rows.csv?accessType=DOWNLOAD", # 2012
    "https://data.medicaid.gov/api/views/ra84-ffhc/rows.csv?accessType=DOWNLOAD", # 2011
    "https://data.medicaid.gov/api/views/mmgn-kvy5/rows.csv?accessType=DOWNLOAD", # 2010
    "https://data.medicaid.gov/api/views/fhmx-iqs3/rows.csv?accessType=DOWNLOAD", # 2009
    "https://data.medicaid.gov/api/views/ny8j-2ymd/rows.csv?accessType=DOWNLOAD", # 2008
    "https://data.medicaid.gov/api/views/q947-frj2/rows.csv?accessType=DOWNLOAD", # 2007
    "https://data.medicaid.gov/api/views/e7is-4a3j/rows.csv?accessType=DOWNLOAD", # 2006
    "https://data.medicaid.gov/api/views/ezjn-vqh8/rows.csv?accessType=DOWNLOAD", # 2005
    "https://data.medicaid.gov/api/views/rn2y-fgjb/rows.csv?accessType=DOWNLOAD", # 2004
    "https://data.medicaid.gov/api/views/66gr-qxnr/rows.csv?accessType=DOWNLOAD", # 2003
    "https://data.medicaid.gov/api/views/5jcx-2xey/rows.csv?accessType=DOWNLOAD", # 2002
    "https://data.medicaid.gov/api/views/t5ct-xf3k/rows.csv?accessType=DOWNLOAD", # 2001
    "https://data.medicaid.gov/api/views/78qv-c4cn/rows.csv?accessType=DOWNLOAD", # 2000
    "https://data.medicaid.gov/api/views/vhg8-v7wa/rows.csv?accessType=DOWNLOAD", # 1999
    "https://data.medicaid.gov/api/views/ykva-ug36/rows.csv?accessType=DOWNLOAD", # 1998
    "https://data.medicaid.gov/api/views/c7wf-ku3w/rows.csv?accessType=DOWNLOAD", # 1997
    "https://data.medicaid.gov/api/views/jqjw-uby8/rows.csv?accessType=DOWNLOAD", # 1996
    "https://data.medicaid.gov/api/views/v83u-wwk3/rows.csv?accessType=DOWNLOAD", # 1995
    "https://data.medicaid.gov/api/views/8uti-96dw/rows.csv?accessType=DOWNLOAD", # 1994
    "https://data.medicaid.gov/api/views/iu8s-z84j/rows.csv?accessType=DOWNLOAD", # 1993
    "https://data.medicaid.gov/api/views/agzs-hwsn/rows.csv?accessType=DOWNLOAD", # 1992
    "https://data.medicaid.gov/api/views/q7kf-kjqz/rows.csv?accessType=DOWNLOAD"  # 1991
  )

## Create a vector containing all the years.

years <-
  c(2020:1991)

## Create a vector containing the file names for each year.

file_names <-
  paste0(
    "./data/raw/us-medicaid-data-",
    years, 
    ".csv"
  )

## Create a function that downloads the files.
## Set up a function to pull from web.

dl <-
  safely(
    ~ download.file(.x, .y, mode = "wb")
  )

## Execute the function on the urls.

walk2(
  urls,
  file_names,
  dl
)

## Combine all the datasets.

medicaid_1991_2020 <-
  map_dfr(
    file_names,
    ~ read_csv(
      .,
      col_types = cols_only(
        `Utilization Type`        = col_character(),
        "State"                   = col_character(),
        "Year"                    = col_integer(),
        "Quarter"                 = col_integer(),
        `Product Name`            = col_character(),
        `Labeler Code`            = col_guess(),
        `Product Code`            = col_guess(),
        `Package Size`            = col_guess(),
        "NDC"                     = col_guess(),
        `Number of Prescriptions` = col_guess(),
        `Suppression Used`        = col_guess()
      )
    )
  )

## Remove the national level data into its own dataset.

national_medicaid_data <-
  medicaid_1991_2020 %>%
    filter(State == "XX") %>%
    janitor::clean_names() %>%
    mutate_if(is.character, .funs = tolower)

## Remove the state level data into its own dataset.

state_level_medicaid_data <-
  medicaid_1991_2020 %>%
    filter(State != "XX") %>%
    janitor::clean_names() %>%
    mutate_if(is.character, .funs = tolower)

## Create dataset that JHC wanted: distinct by labeler_code, product_code, package_size, product_name, and NDC.

national_products <-
  national_medicaid_data %>%
  select(labeler_code, product_code, package_size, product_name, ndc)

state_products <- 
  state_level_medicaid_data %>%
  select(labeler_code, product_code, package_size, product_name, ndc)

all_products <-
  union(
    national_products,
    state_products
  )

## Need to do some data quality/integrity checks.

record_count_by_year <-
  medicaid_1991_2020 %>%
  group_by(Year) %>%
  summarise(n = n())

## Plot the observation counts by year.

png("./plots/record-count-by-year.png", width = 16, height = 9, res = 1200, units = "in")
ggplot(data = record_count_by_year) +
  # create a bar chart with year as x-axis and the count as the y-axis. Make it blue.
  geom_col(aes(x = Year, y = n), fill = "dodgerblue2") + 
  # Add a text field to each column. Format it so it has commas, and angle it 90 degrees. Change color and size.
  geom_text(aes(x = Year, y = n, label = scales::comma(n), hjust = 2, angle = 90), color = "white", size = 5) +
  # apply theme_ipsum_rc, my favorite theme
  hrbrthemes::theme_ipsum_rc() +
  # make sure all years are displayed on x-axis
  scale_x_continuous(breaks = years) +
  # format it so it doesn't show scientific notation.
  scale_y_continuous(labels = scales::comma) + 
  # remove grid lines, make the text on the x and y axis black.
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(color = "black"),
        axis.text.y = element_text(color = "black")) + 
  # finally, a title.
  ggtitle("Record count distributions - Medicaid drug utilization data, 1991 to 2020")
dev.off()

## Create record counts by year/quarter.

record_count_by_quarter <-
  medicaid_1991_2020 %>%
  group_by(Year, Quarter) %>%
  summarise(n = n())

## Plot observations by year/quarter

png("./plots/record-count-by-year-and-quarter.png", width = 16, height = 9, res = 1200, units = "in")
ggplot(data = record_count_by_quarter) +
  # create a bar chart with year as x-axis and the count as the y-axis. Make it blue.
  geom_col(aes(x = Year, y = n, fill = factor(Quarter))) + 
  # Add a text field to each column. Format it so it has commas, and angle it 90 degrees. Change color and size.
  # Group everything by quarter, change label text to black if it's quarter 4 (bar color is yellow), and adjust
  # text such that it's centered in each bar.
  geom_text(aes(x = Year, y = n, group = Quarter, label = scales::comma(n)),
            angle = 90, color = ifelse(record_count_by_quarter$Quarter == 4, "black", "white"), size = 4, position = position_stack(vjust = .5)) +
  # apply theme_ipsum_rc, my favorite theme
  hrbrthemes::theme_ipsum_rc() +
  # make sure all years are displayed on x-axis
  scale_x_continuous(breaks = years) +
  # format it so it doesn't show scientific notation.
  scale_y_continuous(labels = scales::comma) + 
  # remove grid lines, make the text on the x and y axis black.
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(color = "black"),
        axis.text.y = element_text(color = "black")) + 
  scale_fill_viridis_d() +
  # finally, a title.
  ggtitle("Record count distributions by quarter - Medicaid drug utilization data, 1991 to 2020")
dev.off()

## Output the entire Medicaid dataset

write_csv(
  medicaid_1991_2020,
  file = "./data/clean/medicaid-data-1991-to-2020.csv",
  na = ""
)

## Output the national dataset

write_csv(
  national_medicaid_data,
  "./data/clean/national-level-medicaid-data-1991-to-2020.csv",
  na = ""
)

## Output the state level dataset.

write_csv(
  state_level_medicaid_data,
  "./data/clean/state-level-medicaid-data-1991-to-2020.csv",
  na = ""
)

## Output the product information dataset requested by JHC.

write_csv(
  all_products,
  "./data/clean/medicaid-product-information.csv",
  na = ""
)
