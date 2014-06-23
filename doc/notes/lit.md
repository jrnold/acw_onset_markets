# Event Studies

Some overviews

- The original paper was @FamaFisherJensenEtAl1969, "The Adjustment of Stock Prices to New Information".
- Event identification through covariance: [@RigobonSack2002, @RigobonSack2005, @RigobonSack2001]
- Overviews

    - @BrownWarner1985
	- @MacKinlay1997
	- @KhotariWarner2006
	- @CampbellLoMacKinlay2012
	- @SandlerSandler2013
	- @RkaynakWright2013

- Examples Using Conflicts

    - firm level data:

    	- @AbadieGardeazabal2003: compares the effects of GDP per capita in the Basque regio relative to a synthetic control region without terrorism. Also stocks of firms increased when the truce became credible.
    	- @GuidolinLaFerrara2007: Relationship between the death of the rebel leader in Angola in 2002 and the stocks of diamond mining firms operating in Angola.

	- financial indicators

	    - @LeighWolfersEtAl2003 and @WolfersZitzewitz2009 : reaction of oil and stock prices to war related news using prediction markets.
		- @RibobonSack2005: Use indetification by heteroskedasticity to study the reaction of US financial indicators to war risk between Jan 2003 and Mar 2005.
		- @AmihulWohl: effects of probability increase before and after the outbreak of the Second Gulf War.
		- @GuidolinLaFerrara2010: sample of 101 internal and inter-state conflicts on stock market exchange rates, oil, commodity prices
		- @DubeKaplanNaidu201: impact of US-backed coups in the 1950s and 1960s and decisions leading up to them on partially nationalized firms.
		- @ChenSiems2004 : response of US and global capital markets to 14 terrorist and military attacks in the 20th century
		- @SchneiderTroeger2006: reactions of DJIA, FTSE, and CAC to the intensity of conflicts in Iraq, Israel, and Yugoslavia
		- @Hall2004 : Swiss exchange rates during WWI for information on expectaions about the resolution of the war.

- Other articles

    - @SnowbergWolfersZitzewitz2011 : Prediction markets can provide the prior probabilities needed in event studies

# Notes on Bond Pricing

Some miscellaneous notes about bond pricing.

At some time the price of a bond is represented as a discounted flow of payments;
I'll abstract away from the specifics and including both principal and interest payments as cashflows.
Suppose there a $n$ future payments, $c_1, ..., c_n$, occurring at times $m_1, ..., m_n$.
For simplicity, assume a constant interest rate, $r$.
Then the present value of the bond is
$$
v = \sum_i^n c_i e^{-r m_i}
$$

The derivative of the value of bond with respect to the interest rate is
$$
\begin{aligned}[t]
\frac{\partial v}{\partial r} = - \sum_i^n m_i c_i e^{-r m_i}
\end{aligned}
$$
Thus an increase in the interest rate, decreases the price of the bond.
The is related to the modified duration $D$ as,
$$
D = - \frac{\partial v}{\partial r} \frac{1}{v}
$$

Represent each $m_i$ as a function of the time at which the bond is valued, $t$.
Since an increase in time decreases the maturity by the same amount, $\frac{d\,m_i(t)}{d\,t} = - d\,t$.
The total derivative of the value of the bond with respect to the interest rate is thus,
$$
\begin{aligned}[t]
\frac{d\,v}{d\,t} &= \sum_{i = 1}{n} \frac{d\,v}{d\,m_i}  \\
 &= r \sum_{i = 1}{n} c_i e^{-r m_i} d\,t \\
 &= r v
\end{aligned}
$$
However, the above derivative considers an infintesimal change in the time.
In particular, it excludes the possibility that a payment is made between times.
The difference in prices due to a discrete change in price, holding $r$ constant is,
$$
\begin{aligned}[t]
v_{t + \Delta t} - v_t &= \sum_{i = 1}^n c_i e^{-r m_{i,t}} \left( (m_{i,t} > \Delta t) e^{r \Delta t} - 1 \right)
\end{aligned}
$$

The clean price of a bond is $v_t - f c_1$ where $f$ is the coupon factor between 0 and 1, which if $m_0$ is the previous coupon payment, $f = \frac{m_1}{m_1 - m_0}$.
Consider the case in which $\Delta t \in [m_1, m_2]$,
$$
v^*_{t + \Delta_t} - v^*_t &= \sum_{i = 2}^n c_i e^{-r m_{i,t}} \left( e^{r t} - 1 \right) - f_2 c_2 - (e^{-r m_1} - f_1) c_1
$$
Let $m_0$ be the time to the previous payment before $m_1$, then $f_1 = \frac{- m_0}{m_1 - m_0}$ and $f_2 = \frac{t + \Delta t - m_1}{m_2 - m_1}$.
Note that as $m_1 \to 0$, $e^{-r m_1} - f_1 \to 0$.
Let $f_2 = \frac{\Delta t - m_1}{m_2 - m_1}$, then as $\Delta t \to m_1$, $f_2 c_2 \to 0$.


# Yields

For simplicity yields to maturity are calculated using continuous compounding.
The yield to maturity, $r^*$ of a bond with price $p$, and future payments $c_{1}, \dots, c_n$ with at times $m_1, \dots, m_n$, is
$$
r^* = \argmax_r (\sum_{i = 1}^{n} c_i e^{r m_i} - p)^2
$$

To account for payments of interest and principal being made in specie and the price being made in currency, all of these are converted to gold dollars at the current exchange rate; as in @Macaulay1938 [Appendix C].
A better conversion could have to account for expected future gold rate [@Roll1972], but as there are no gold future prices available for that period, a constant conversion is assumed.

# Models

## Yields

Let $y_{jt}$ be the yield of bond $j$ at time $t$.
Bonds are offset by a constant amount ($\mu_t$) from a common interest rate $\theta_j$.
A more complete factor model would model the yield curve.
$$
y_{jt} &= \mu_j + \theta_t + \epsilon \\
\theta &= \alpha + \rho \theta_t + \partial \theta_t + \nu_t
$$
The parameter $\partial \theta_t$ can be a function of battles and other events.

One problem with this model is that the most frequent observed asset data is for greenbacks,
but treating them as a zero-coupon bond only the product of their interest rate and maturity is known.
It is clear that the loadings on the common factor $\theta_t$ would both not be one and would vary over time.

## Prices

Let $y_{jt}$ be the price of asset $j$ at time $t$.
$$
y_{jt} &= \mu_j + \theta_t + \epsilon \\
\theta &= \alpha + \rho \theta_t + \partial \theta_t + \nu_t
$$

In this setup, it is hard to account for changes in prices just due to changes in maturity without explicitly modeling the interst rate factor.

# Misc

## Missouri

Vote for admission of Kansas as a slave state in 1858, cited as important by Weingast.

- S.37 (35th) on Jan 4, 1858: https://www.govtrack.us/congress/bills/35/s100370
- S.161 (35th) on Feb 18, 1858: https://www.govtrack.us/congress/bills/35/s101610

## Breaks

### Oct 31, 1856

This is around the time of the presidential election of 1856, but there is no discussion of the election in the Bankers' Magazine: `election <http://books.google.com/books?id=MlkmAQAAIAAJ&pg=PA495#v=snippet&q=election&f=false>`__, `Buchanan <http://books.google.com/books?id=MlkmAQAAIAAJ&pg=PA495#v=snippet&q=buchanan&f=false>`__.

Dicussion of money market.

The main thing cited as affecting the market was large exports of coin to Europe - banks reduce loans, contraction of credit and money

  The transactions at the stock exchange during the last month have
  reached a larger extent than for several years past during a similar
  period Although early in the month the scarcity of money and the
  prevailing high rates have been adverse to speculation the tendency
  of prices baa been upward and our quotations exhibit a considerable
  advance

  Holders of Government 6's are firm and only small lots are
  occasionally offered at our quotations State Blocks have been active
  and we note large sales of Missouri Virginia and Tennessee 6's the
  former at higher and Tennessee at unchanged prices Georgia 6's also
  have met with a better demand than for some time past and California
  7's have recovered from the depression prevailing in the summer

`Merchants' Magazine <http://books.google.com/books?id=4okoAAAAYAAJ&pg=PA588#v=onepage&q=commercial%20chronicle%20october&f=false>`__ cites tight money and credit.

- `election <http://books.google.com/books?id=4okoAAAAYAAJ&printsec=frontcover&source=gbs_ge_summary_r&cad=0#v=onepage&q=election&f=false>`__
- `Buchanan <http://books.google.com/books?id=4okoAAAAYAAJ&printsec=frontcover&source=gbs_ge_summary_r&cad=0#v=snippet&q=buchanan&f=false>`__


### March 13, 1857

Possible events

- Mar 4, 1857: James Buchanan
- Mar 6, 1857: Dred Scott v Sanford

`Dred <http://books.google.com/books?id=MlkmAQAAIAAJ&pg=PA831#v=snippet&q=dred&f=false>`__,
`pierce <http://books.google.com/books?id=MlkmAQAAIAAJ&pg=PA831#v=snippet&q=pierce&f=false>`__
`slavery <http://books.google.com/books?id=MlkmAQAAIAAJ&pg=PA831#v=snippet&q=slavery&f=false>`__
`slave <http://books.google.com/books?id=MlkmAQAAIAAJ&pg=PA831#v=snippet&q=slave&f=false>`__


Neither of these are cited in the *Bankers' Magazine*

Large fluctuations in the market. Lots of deamand for state bonds.

   In the slock market there have been during the month numerous
   fluctuations and a violent yet prevails between the bears and bulls
   of Wall street as to the ascendancy and the rise or fall in prices
   In government bonds the rotes are nominal few being offered in the
   market the Secretary of the Treasury is prepared to pay a premium
   of 16 per cent on the bonds doe in 1367 8 with the accrued interest
   of three months equivalent in all to 11 IX per cent Large amounts
   of these bonds are still held by our Savings Banks and by Trustees
   the former in consideration of the perfect reliability of the
   securities in case any emergency should arise wherebv might be
   necessary to turn them into cash Otherwise o due regard to the
   Interests of depositors would point to an exchange for the solid
   and reliable six per cent loans of Missouri Kentucky Virginia North
   Carolina Georgia Tennessee Louisiana and other States Since our
   last monthly the sales of Virginia and Missouri bonds have been
   very large Of the loiter it Is thought several millions will be
   required this year for banking purposes under the new Isw of that
   We an iiex fluctuations In market values at the close of the past
   seven weeks


Merchants' magazine

- `election <http://books.google.com/books?id=-qURAAAAYAAJ&printsec=frontcover&source=gbs_ge_summary_r&cad=0#v=snippet&q=election&f=false>`__
- `buchanan <http://books.google.com/books?id=-qURAAAAYAAJ&printsec=frontcover&source=gbs_ge_summary_r&cad=0#v=snippet&q=buchanan&f=false>`__

`Merchants' Magazine <http://books.google.com/books?id=-qURAAAAYAAJ&&pg=PA457>`__

   The stock market has fluctuated more rapidly than usual and with
   less apparent reason but the bears have the advantage in the
   struggle and the speculators show but little courage

Mostly cites financial problems, and tight money and credit. 

