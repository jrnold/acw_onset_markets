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

