tweets_raw <- read_csv("./tweets_v2.csv") |>
    distinct(tweet_id, .keep_all = TRUE)

# COMPUTE USER RANK
.users_rank <- tweets_raw |>
    count(user_id) |>
    mutate(user_rank = percent_rank(n)) |>
    rename(user_ntweets = n)

.rt_rank <- tweets_raw |> 
    group_by(user_id) |>
    summarise(median_rt = median)

tweets <- left_join(tweets_raw, .users_rank, by = join_by(user_id))
tweets_gwcc <- tweets |>
    filter(
        grepl("global\\s?warming|climate\\s?change",
            content,
            ignore.case = TRUE,
            perl = TRUE
        )
    )
# list of users in the bottom 90% by n_tweets
.users_bot_90 <- .users_rank |>
    filter(user_rank < 0.9) |>
    pull(user_id)

# list of users in the top 10% by n_tweets
.users_top_10 <- .users_rank |>
    filter(user_rank >= 0.9) |>
    pull(user_id)
