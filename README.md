# RealEstateBrokerage

The dependent variable is `ln_income`, `ln_end_price`, `ln_negotiation_period` and `ln_negotiation` and there are three set of explanatory variables, including density based index (DBI), the entry and continuous effect, and the proxy variable to capture the effect of the continuous DBI effect.

**current progress**:

The basic structure is as the follows:

- [x] stylized facts (finished)
- [x] dynamically estimations of the effect
- [x] GMM estimations
- [ ] exogeneous or shocking
- [ ] heterogeneous checkings and robustness checkings

## stylized fact:

using two way fixed effect with multple clustering model and the codes have been done.

## dynamically estimations of the effect

We dynamically estimate the effect of real estate brokerage's entry and leaving for the local submarket. We first generate a dummy variable entry indicating the first entry period where the number of brokerage decides to open new offline stores in this given area. Then we generate the post and pre of this period.

After this, we conduct two way fixed effect with multple clustering model to estimate it and drop the pre1 period to avoid collinearity problem. The result indicates entry and post1 period significant for income and number while the pricing the entry is not significant and the post1 is significant.

Furthermore, we conduct proxy variables to indicate the effect of density on the local market. These proxy variables are crucial for the analysis captures the effect of lianjia's local market influence on each period of local market. Note that after the interaction terms, we can know the real result of the items. We do not include all the variables together because this would cause the effect being overlapped, which will make the result not efficient.

## GMM estimations

Use dynamic panel data estimation method to deal with small $T$ large $N$ serial correlation problem. This method serves as a further check for the stylized result and pave way for our further analysis.

I find that the dynamic effect, after taking the effect of the lagged dependent effect and serial correlation, is quite different than the OLS result. The results also indicates that the previous OLS result is biased and not asymptotically efficient. Therefore, we shuold further prove that our GMM is robust given the exogeneous or shocking.

## exogeneous or shocking

I now use the shocking to prove our GMM estimations are correct. Finally, we consider the exogeneous shock to prove our estimation is asymptotically efficient. The way we choose is to use RD design, which by assuming lianjia's effect will dramatically decrease for the first and second's housing. Working on it.

## heterogeneous checkings and robustness checkings

easy to manage and leave it alone.

## NOTE

Note that we should not drop the ln_lead == 0 becaue these consists of various observations that do not observe the results. These observations contain useful information, so directly dropping it will cause the data do not represent the real situation. We shall include a variable non_online_effect to avoid this problem.
