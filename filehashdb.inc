robjects = 

robjects += filehashdb/macaulay

filehashdb/macaulay : data/quandl/macaulay.json

robjects += filehashdb/prices0

filehashdb/prices0 : /Users/jrnold/Documents/projects/acw_onset_and_markets/submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields_2.csv /Users/jrnold/Documents/projects/acw_onset_and_markets/submodules/civil_war_era_findata/data/merchants_magazine_us_paper_yields_2.csv

robjects += filehashdb/prices1

filehashdb/prices1 : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prices0

robjects += filehashdb/prwar1

filehashdb/prwar1 : /Users/jrnold/Documents/projects/acw_onset_and_markets/./submodules/civil_war_era_findata/data/bond_metadata.json /Users/jrnold/Documents/projects/acw_onset_and_markets/./submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields.csv /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prices0

robjects += filehashdb/prwar2_summary

filehashdb/prwar2_summary : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prwar2

robjects += filehashdb/prwar2

filehashdb/prwar2 : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prices0 /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prwar1 /Users/jrnold/Documents/projects/acw_onset_and_markets/stan/prwar1.stan

robjects += filehashdb/prwar3_summary

filehashdb/prwar3_summary : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prwar3

robjects += filehashdb/prwar3

filehashdb/prwar3 : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prices0 /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prwar1 /Users/jrnold/Documents/projects/acw_onset_and_markets/stan/prwar2.stan

robjects += filehashdb/prwar4_summary

filehashdb/prwar4_summary : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prwar4

robjects += filehashdb/prwar4

filehashdb/prwar4 : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prices0 /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prwar1 /Users/jrnold/Documents/projects/acw_onset_and_markets/stan/prwar4.stan

robjects += filehashdb/prwar5

filehashdb/prwar5 : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prices0 /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prwar1 /Users/jrnold/Documents/projects/acw_onset_and_markets/stan/prwar4.stan

robjects += filehashdb/riskfree

filehashdb/riskfree : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/macaulay

robjects += filehashdb/spreads1_summary

filehashdb/spreads1_summary : 

robjects += filehashdb/spreads1

filehashdb/spreads1 : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prices0 /Users/jrnold/Documents/projects/acw_onset_and_markets/stan/spreads1.stan

robjects += filehashdb/spreads2_summary

filehashdb/spreads2_summary : 

robjects += filehashdb/spreads2

filehashdb/spreads2 : /Users/jrnold/Documents/projects/acw_onset_and_markets/filehashdb/prices0 /Users/jrnold/Documents/projects/acw_onset_and_markets/stan/spreads2.stan

