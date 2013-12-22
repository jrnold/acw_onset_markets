# Battle News

Data with lists of articles with news of major battles in the American Civil War.

- ``battle_news.csv``: All articles about battles of CWSAC significance "A" between their start date and 3 weeks after their conclusion. Some significance "B" battles from the Lower Seaboard and Trans-Mississippi theaters are included to provide better estimates of the time it took news to reach New York from different locations.
- ``major_battle_news.yaml``: Dates for battles of CWSAC significance "A". These are the dates which news of the progress and completion of a battle were first reported.

Battle News
==================

Both datasets only use articles from the *New York Times* in the Proquest database, *Historical Newspapers*.

For ``battle_news.csv``:

- Searched for terms, usually the name of the battle or the last name
  of Union commander. Filter by
  
  - start date to end date + 14 days (with a few exceptions for
    battles with abnormally delayed information)
  - only include the following types of documents
  
    - "article"
    - "front page"
    - "war/military news"
- Given the initial search results, manually filter all those articles which
  appear to be primarily about the battle.
  
for ``major_battle_news.csv`` the dates around the end of the battle were manually searched to find when news from the start to the end of the battle was reported.
For sieges only news of the conclusion was reported.
This is more in line with how the markets seemed to respond to news.
I also consulted the "Montetary Affairs" articles for any mention of the battle in order to determine the time at which news reached the market.
