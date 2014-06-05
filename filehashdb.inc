robjects = 

robjects += filehashdb/battle_news_wgts_1

filehashdb/battle_news_wgts_1 : data/news/data/major_battle_news.csv

robjects += filehashdb/battle_news_wgts_2

filehashdb/battle_news_wgts_2 : data/news/data/battle_news.csv data/acw_battles/data/battles.csv

robjects += filehashdb/battles

filehashdb/battles : data/acw_battles/data/battles.csv

robjects += filehashdb/greenbacks_1

filehashdb/greenbacks_1 : submodules/civil_war_era_findata/data/greenbacks.csv

robjects += filehashdb/macaulay

filehashdb/macaulay : data/quandl/macaulay.json

robjects += filehashdb/m_greenbacks_1

filehashdb/m_greenbacks_1 : stan/m2.stan /home/jrnold/Documents/bonds_and_battles/filehashdb/m_greenbacks_1 R/db_m_spreads_1.R

robjects += filehashdb/m_greenbacks_2

filehashdb/m_greenbacks_2 : stan/m2.stan /home/jrnold/Documents/bonds_and_battles/filehashdb/m_greenbacks_1 R/db_m_spreads_2.R

robjects += filehashdb/m_spreads_0

filehashdb/m_spreads_0 : /home/jrnold/Documents/bonds_and_battles/filehashdb/prices1 /home/jrnold/Documents/bonds_and_battles/filehashdb/riskfree stan/m0.stan data/init/m_spreads_0.rds

robjects += filehashdb/m_spreads_1

filehashdb/m_spreads_1 : stan/m1.stan /home/jrnold/Documents/bonds_and_battles/filehashdb/battle_news_wgts_2 /home/jrnold/Documents/bonds_and_battles/filehashdb/battles R/db_m_spreads_0.R

robjects += filehashdb/m_spreads_2

filehashdb/m_spreads_2 : stan/m1.stan /home/jrnold/Documents/bonds_and_battles/filehashdb/battle_news_wgts_2 /home/jrnold/Documents/bonds_and_battles/filehashdb/battles R/db_m_spreads_1.R R/db_m_spreads_0.R

robjects += filehashdb/prices0

filehashdb/prices0 : submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields_2.csv submodules/civil_war_era_findata/data/merchants_magazine_us_paper_yields_2.csv

robjects += filehashdb/prices1

filehashdb/prices1 : /home/jrnold/Documents/bonds_and_battles/filehashdb/prices0

robjects += filehashdb/prwar1

filehashdb/prwar1 : stan/prwar.stan ./submodules/civil_war_era_findata/data/bond_metadata.json ./submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields.csv

robjects += filehashdb/prwar2

filehashdb/prwar2 : stan/prwar.stan ./submodules/civil_war_era_findata/data/bond_metadata.json ./submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields.csv

robjects += filehashdb/riskfree

filehashdb/riskfree : /home/jrnold/Documents/bonds_and_battles/filehashdb/macaulay

