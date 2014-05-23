
- Event identification through covariance: [@RigobonSack2002, @RigobonSack2005, @RigobonSack2001]
- Overviews

    - Brown and Warner (1985)
	- McKinnon 1997
	- Sandler and Sandler 2013

# Notes on Bond Pricing

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


