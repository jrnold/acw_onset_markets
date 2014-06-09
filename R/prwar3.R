library("rstan")
library("jsonlite")
library("dplyr")
library("reshape2")

BOND_METADATA_FILE <- PROJ$path("submodules/civil_war_era_findata/data/bond_metadata.json")
BANKERS_FILE <- PROJ$path("submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields.csv")
MODEL_FILE <- PROJ$path("stan/prwar.stan")
    
.DEPENDENCIES <-
    c(MODEL_FILE, BOND_METADATA_FILE, BANKERS_FILE)

#' MCMC parameters
ITER <- 2^9
WARMUP <- 2^8
SAMPLES <- 2^8
THIN <- 1
SEED <- 254460
CHAINS <- 1

PEACE <- as.Date(c("1855-08-24", "1857-10-16"))
WAR <- as.Date(c("1861-04-15", "1861-05-18"))
RANGE <- as.Date(c("1858-1-1", "1861-4-10"))

#' Only use the U.S. Government, confederate and border states.
BONDSERIES <- c("georgia_6pct" = "georgia_6pct_1872",
                "kentucky_6pct" = "kentucky_6pct_1871",
                "louisiana_6pct" = "louisiana_6pct_1881",
                "missouri_6pct" = "missouri_6pct_1872",
                "north_carolina_6pct" = "north_carolina_1873",
                "tennessee_6pct" = "tennessee_6pct_1889",
                "US_6pct_1868" = "us_6pct_1868_jul",
                "US_5pct_1874" = "us_5pct_1874",
                "virginia_6pct" = "virginia_6pct_1888"
                )

get_bond_yields <- function() {
    (mutate(read.csv(BANKERS_FILE),
            date = as.Date(date))
     %>% filter(bond %in% unname(BONDSERIES))
     %>% mutate(series = factor(series),
                bond = factor(bond))
     )
}

get_bond_metadata <- function() {
    fromJSON(BOND_METADATA_FILE)
}

pvbond <- function(rate, effectiveDate, cashflows) {
    sum((filter(cashflows,
                date > effectiveDate)
         %>% mutate(date = as.Date(date),
                    maturity = as.integer(date - effectiveDate) / 365.25,
                    dcf = amount * exp(-rate * maturity)))$dcf)
}

bondpresval <- function(r, x, m, p = 1) {
    n <- length(x)
    pv <- numeric(n)
    for (i in 1:n) {
        if (i == 1) {
            mlag <- p * 0 + (1 - p) * m[i]
        } else {
            mlag <- p * m[i - 1] + (1 - p) * m[i]
        }
        pv[i] <- sum(x[i:n] * exp(- r * (m[i:n] - mlag)))
    }
    pv
}


#' Calculate yields for War and Peace
#'
#' For 5's of 1874 use the peace yield for 6's of 1868
#' 
get_war_peace_yields <- function() {
    bond_yields <- get_bond_yields()

    peace_yields <-
        (group_by(bond_yields, series)
         %>% filter(date >= PEACE[1] & date <= PEACE[2])
         %>% summarise(yield_peace = mean(ytm),
                       yield_peace_sd = sd(ytm))
         )
    
    war_yields <-
        (group_by(bond_yields, series)
         %>% filter(date >= WAR[1] & date <= WAR[2])
         %>% summarise(yield_war = mean(ytm),
                       yield_war_sd = sd(ytm))
         )
    
    wp_yields <- merge(war_yields, peace_yields, all=TRUE)
    wp_yields[wp_yields$series == "US_5pct_1874", c("yield_peace", "yield_peace_sd")] <-
        wp_yields[wp_yields$series == "US_6pct_1868", c("yield_peace", "yield_peace_sd")]
    wp_yields
}


get_data <- function() {
    #' Keep only dates in the relevant range
    bond_data <-
        (filter(get_bond_yields(),
                date >= RANGE[1] & date <= RANGE[2])
         %>% mutate(bond = as.factor(bond),
                    series = as.factor(series))
         %>% select(date, series, bond, price)
         %>% mutate(asset_num = as.integer(series))
         )
    datelist <-
        mutate(data.frame(date = sort(unique(bond_data$date))),
               time = seq_along(date),
               tdiff = c(7, as.integer(diff(time))))
    bond_data <- merge(bond_data, datelist[ , c("date", "time")])
    bond_metadata <- get_bond_metadata()

    yields <- get_war_peace_yields()
    
    #' Get cashflows
    cashflows <-
        plyr::mdply(merge(filter(bond_data, bond %in% BONDSERIES),
                          yields),
                    function(bond, date, yield_war, ...) {
                        bond <- as.character(bond)
                        date2 <- date
                        cashflows <-
                            (filter(mutate(bond_metadata[[bond]][["cashflows"]],
                                           date = as.Date(date)),
                                    date > date2)
                             %>% mutate(maturity = as.integer(date - date2) / 365.25)
                             %>% select(maturity, amount)
                             %>% group_by(maturity)
                             %>% summarise(amount = sum(amount))
                             %>% mutate(i = seq_along(amount),
                                        lagmaturity = c(0, maturity[-length(maturity)]),
                                        warpv1 = bondpresval(yield_war, amount, maturity, p = 1),
                                        warpv2 = bondpresval(yield_war, amount, maturity, p = 0),
                                        warpv3 = bondpresval(yield_war, amount, maturity, p = 0.5))
                             )
                    })

    
    numpayments <-
        (group_by(cashflows, time, series)
         %>% summarise(n = max(i)))
    amounts <- acast(cashflows, time + series ~ i, value.var = "amount",
                     fill = 0)
    maturities <- acast(cashflows, time + series ~ i, value.var = "maturity",
                        fill = 1000)
    maturities_lag <- acast(cashflows, time + series ~ i, value.var = "lagmaturity",
                            fill = 1000)
    maturities_mid <- 0.5 * (maturities + maturities_lag)
    warpv <- acast(cashflows, time + series ~ i, value.var = "warpv1",
                fill = 0)
    list(prices = bond_data,
         dates = datelist,
         cashflows = cashflows,
         numpayments = numpayments,
         amounts = amounts,
         maturities = maturities,
         maturities_lag = maturities_lag,
         maturities_mid = maturities_mid,
         warpv = warpv,
         yields = yields)
}

get_standata <- function() {
    .data <- get_data()
    list(nobs = nrow(.data$prices),
         n_times = max(.data$prices$time),
         time = .data$prices$time,
         tdiff = .data$dates$tdiff,
         n_series = length(unique(.data$prices$series)),
         series = as.integer(.data$prices$series),
         logprice = log(.data$prices$price),
         n_payments_max = ncol(.data$amounts),
         n_payments = .data$numpayments$n,
         payment = .data$amounts,
         maturity = .data$maturities,
         maturity_lag = .data$maturities_lag,
         yield_war = .data$yields$yield_war,
         yield_peace = .data$yields$yield_peace,
         warpv = .data$warpv,
         # initial state
         logbeta_init_mean = log(0.005),
         logbeta_init_sd = 10)
}

get_init <- function() {
    list(logbeta_innov = c(-0.73172623303487, -0.11923762522319, -0.000503486625790598, 
             -0.185965113472842, -0.0494187801536267, -0.034210264660108, 
             -0.0362502242721997, 0.0123630196918264, -0.134391151057592, 
             -0.0949119921324011, -0.0054341304314235, 0.0426335681402841, 
             -0.0128405837164776, -0.107636013649153, -0.0608192072312291, 
             -0.0915155908382338, -0.145000160951961, -0.043029006379524, 
             -0.0660116039684103, -0.238237451880607, -0.16598428000531, -0.00787730658928485, 
             -0.0625512835704932, 0.0367365326920509, -0.0818079412075227, 
             -0.179108908183153, -0.0598915899987007, -0.133711921097106, 
             -0.0576355767647757, -0.216497490968079, 0.0513356359264113, 
             -0.136376778307679, 0.0484803442234388, 0.0464537560642847, 0.0461520003434041, 
             -0.000777644476731234, 0.0468779598018156, -0.129037310572843, 
             0.239806091491471, -0.0640708148232509, -0.0271778283450926, 
             -0.0615810679515731, 0.0896590900885557, 0.0778336178418843, 
             0.139717545583625, 0.0825835408068517, 0.112964051765996, -0.013721205297909, 
             0.0330364223004856, -0.0422209436294127, 0.108265416160859, 0.00871667660123455, 
             0.00822133961717943, 0.0631000087701743, 0.0770349815151509, 
             -0.0697766009499737, -0.0285434726208268, -0.182453361071997, 
             0.0442206723694677, 0.081696294090244, 0.175316853044543, -0.0164335976293349, 
             0.0189759114856064, 0.0634002512816823, 0.0254975201835048, 0.112112324728667, 
             -0.067380305090469, 0.103415332885512, -0.00457530585488345, 
             0.172333625842784, -0.00317464347387393, 0.0109087523159777, 
             0.080132815262852, 0.177464736186607, 0.218101042783696, 0.0709715415095948, 
             0.049415922703875, 0.168765414885612, 0.279503494071247, 0.126316440512281, 
             0.119547160406588, -0.037493715327259, 0.132124171812906, -0.0280649012177047, 
             0.00804273536889255, -0.131804975886202, 0.0821617369658538, 
             0.0230923531542168, 0.130091687546637, 0.202149629744446, 0.0198237192768251, 
             0.202084982826472, -0.0227312778673716, 0.0527513624795726, 0.0664871649952266, 
             0.03246822285165, 0.0140453647413982, 0.068518270785025, 0.0288226755111908, 
             0.245695810839584, -0.019674371119672, 0.0507935089131864, 0.0990469468500021, 
             0.0341377599857732, -0.0724411659581568, 0.388601909681496, 0.145726428419992, 
             -0.0344579752082552, 0.158751007074729, 0.0416513739166115, 0.097815377722875, 
             0.0780647803453871, 0.0102201649218554, 0.0467637398633101, 0.250392315578648, 
             0.153935398311896, 0.123606012017206, 0.0891972064304131, 0.085308428327726, 
             0.254281388044269, 0.123279405769694, 0.160596186011729, 0.0417667164963801, 
             0.301219724236227, 0.251676395967871, 0.0609280029616591, 0.223557102578158, 
             0.135727003171184, 0.210800706552348, 0.202437341525167, 0.304622182876119, 
             0.212957479308891, 0.297918360840862, 0.173888744391265, 0.502012793084978, 
             0.273415651873369, 0.693493955399859, 0.258567175098568, 0.208456634713104, 
             0.418320656291803, 0.557094721574196, 0.402023531007173, 0.67055526334001, 
             0.781234464325918, 0.751338733975875, 0.823965457326646, 1.10577797290477, 
             1.09726120420333, 1.2911606349557, 1.49674718031855, 1.1564224520346, 
             0.650359079181, 0.40995396543016, 0.172553990315719, -0.0954285084245904, 
             -0.166136427391906, 0.0784663119295659, 0.378066580419907, 0.912712200997498, 
             -0.010157191254347, 0.406153605160007, -0.0457914525714653, 0.167215232818342, 
             -0.116800310340418, -0.334549897033509, 0.0563662573713938, 0.234888403848776, 
             0.524318688079641),
         sigma = 0.3980312,
         psi = c(0.0375200428358776, 0.0210533644945257, 0.0459794032954274, 
             0.0889323048221386, 0.0937721595408579, 0.185880199473058, 0.118374663402883, 
             0.0666113392205531)
         )
}

main <- function() {
    standata <- get_standata()
    m <- stan_model(MODEL_FILE)
    sampling(m, data = standata, init = list(get_init()),
             chains = CHAINS, iter = ITER, seed = SEED,
             warmup = WARMUP, thin = THIN)
}
