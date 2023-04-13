tweets_count <- left_join(
    tweets |>
        filter(
            user_id %in% .users_bot_90
        ) |>
        count(dis_id) |>
        rename(tot = n),
    tweets_gwcc |>
        filter(
            user_id %in% .users_bot_90
        ) |>
        count(dis_id) |>
        rename(gwcc = n),
    by = join_by(dis_id)
) |>
    filter(!is.na(tot)) |>
    mutate(gwcc = ifelse(is.na(gwcc), 0, gwcc))

dis_tweet_count <- emdat |>
    filter(!dis_type %in% c("Drought", "Extreme temperature", "Volcanic activity")) |>
    left_join(
        tweets_count,
        by = join_by(dis_id)
    ) |>
    filter(tot > 100)

.color_palette <- c("#000000", "#e69f00", "#56b4e9", "#009e73")

dis_tweet_count <- dis_tweet_count |>
    filter(!is.na(tot)) |>
    mutate(frac_gwcc = gwcc / tot)


plot_gwcc <- dis_tweet_count |>
    group_by(dis_type, start_year) |>
    summarise(percentage = median(frac_gwcc)) |>
    ggplot(aes(x = start_year, y = percentage * 100, colour = dis_type)) +
    scale_color_manual(values = .color_palette) +
    geom_line() +
    xlab("Year") +
    ylab("Percentage of tweets mentioning climate change") +
    labs(color = "Event Type") +
    # ylim(0, 7.5) +
    theme_minimal()

ggsave("plots/gwcc_all.pdf")

i <- 1
for (ev_type in c("Earthquake", "Flood", "Storm", "Wildfire")) {
    plot <- dis_tweet_count |>
        filter(dis_type == ev_type) |>
        group_by(start_year) |>
        summarise(percentage = median(frac_gwcc)) |>
        ggplot(aes(x = start_year, y = percentage * 100)) +
        theme_bw() +
        theme(
            axis.title = element_blank(),
            axis.text = element_text(size = 24)
        ) +
        xlim(2008, 2022) +
        geom_point(size = 6, colour = .color_palette[i]) +
        geom_smooth(method = lm, colour = .color_palette[i], se = FALSE, linetype = "dashed") +
        ylim(0, NA)
    # ylim(0, 7.5) +
    ggsave(str_glue("plots/gwcc_", ev_type, ".pdf"))
    i <- i + 1
}
