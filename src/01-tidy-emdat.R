library("readxl")
library("tidyverse")
library("stringr")

str_to_snake_case <- function(x) {
    s <- str_replace(
        pattern = " ",
        replacement = "_",
        string = str_to_lower(x)
    )
    return(s)
}

emdat <- read_xlsx(
    path = "emdat_public_2023_03_29_query_uid-iSvZpb.xlsx",
    skip = 6,
    col_names = TRUE
) |>
    select(
        dis_id = "Dis No",
        dis_type = "Disaster Type",
        event_name = "Event Name",
        location = "Location",
        mag_value = "Dis Mag Value",
        mag_scale = "Dis Mag Scale",
        total_affected = "Total Affected",
        total_dmg_usd = "Total Damages, Adjusted ('000 US$)",
        contains("start"),
        contains("end")
    ) |>
    rename_with(str_to_snake_case, .cols = contains("Start")) |>
    rename_with(str_to_snake_case, .cols = contains("End"))
