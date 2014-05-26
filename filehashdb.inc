robjects = 

robjects += filehashdb/battle_news_wgts_1

filehashdb/battle_news_wgts_1 : data/news/data/major_battle_news.csv

robjects += filehashdb/battle_news_wgts_2

filehashdb/battle_news_wgts_2 : data/news/data/battle_news.csv data/acw_battles/data/battles.csv

robjects += filehashdb/battles

filehashdb/battles : data/acw_battles/data/battles.csv

robjects += filehashdb/prices0

filehashdb/prices0 : submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields_2.csv submodules/civil_war_era_findata/data/merchants_magazine_us_paper_yields_2.csv submodules/civil_war_era_findata/data/greenbacks.csv

robjects += filehashdb/prices1

filehashdb/prices1 : submodules/civil_war_era_findata/data/merchants_magazine_us_paper_yields_2.csv submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields_2.csv submodules/civil_war_era_findata/data/greenbacks.csv

