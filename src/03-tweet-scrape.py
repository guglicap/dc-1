#!/usr/bin/env python3

import pandas as pd
import numpy as np
import snscrape.modules.twitter as sntwitter
import re
import datetime
import progressbar

TWITTER_DATE_FMT = "%Y-%m-%d"

dis_list = pd.read_csv("tweet_topics.csv")

bar = progressbar.ProgressBar(maxval=dis_list.size).start()
out = open("tweets_v2_2d.csv", mode='w')
for (i, dis) in dis_list.iterrows():

    topics = []

    if not pd.isna(dis.event_name):
        topic = dis.event_name
        if not (dis.dis_type.casefold() in topic.casefold()):
            # emDAT isn't super-clean so e.g. 'Storm Erin' is recorded as
            # 'Erin' which brings up a lot of unrelated tweets about guys named Erin
            topics.append(f"{dis.dis_type} {topic}")
    else:
        # emdat location format is something like a,b,c (something),d
        # we want to ignore the (something) part, and search for e.g. flood in a, flood in b, flood in c etc.
        topic = dis.dis_type
        locs = dis.location
        locs = re.sub("\([^\)]+\)", "", locs)
        locs = re.sub("districts?", "", locs)
        locs = re.sub("cit(?:ies|y)", "", locs)
        locs = re.sub("areas?", "", locs)
        locs = re.sub("provinces?", "", locs)
        locs = locs.split(",")
        for loc in locs:
            loc = loc.strip()
            topics.append(f"{topic} {loc}")

    start_date = datetime.date(
        dis.start_year,
        dis.start_month,
        dis.start_day,
    )
    end_date = start_date + datetime.timedelta(days=2)

    tweets = pd.DataFrame(columns=[
        "dis_id",
        "tweet_id",
        "content",
        "date",
        "user_id",
        "replies",
        "retweets",
        "likes",
        "links",
    ])

    for topic in topics:

        query = f"{topic} since:{start_date.strftime(TWITTER_DATE_FMT)} until:{end_date.strftime(TWITTER_DATE_FMT)}"

        for tweet in sntwitter.TwitterSearchScraper(query).get_items():
            x = {
                "dis_id": dis.dis_id,
                "tweet_id": tweet.id,
                "content": tweet.rawContent,
                "date": tweet.date,
                "user_id": tweet.user.id,
                "replies": tweet.replyCount,
                "retweets": tweet.retweetCount,
                "likes": tweet.likeCount,
                "links": tweet.links,
            }
            tweets = pd.concat(
                [tweets, pd.DataFrame([x])],
                axis=0,
                ignore_index=True,
            )

    tweets.to_csv(
        out,
        index=False,
        header=True if i == 0 else False,
    )
    bar.update(i)

out.flush()
out.close()
bar.finish()
