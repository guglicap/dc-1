emdat |>
    filter(start_year < 2023) |>
    select(dis_id, dis_type, event_name, location, contains("start"), contains("end")) |>
    filter(!is.na(start_day) & !is.na(end_day)) |>
    write_csv(
        "tweet_topics.csv",
        quote = "needed",
        col_names = TRUE,
    )