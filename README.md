# RealEstateBrokerage

## Description

* `analysis` contains the codes that are associated with the anslysis
* `cleaning` contains the codes that generate the data
* `manuscript` contains the `latex` files that generate the manuscript
* `result_table` contains the `tex` source files that replicate the tables
* `archive` is the unused files that should be deleted.

the data should be placed in the base folder, and all of the cleaning or analysis codes should be set working directory to that folder.

## Progress

The dependent variable is `ln_income`, `ln_end_price`, `ln_negotiation_period` and `ln_negotiation` and there are three set of explanatory variables, including density based index (DBI) $X_1 / \sum_{i=1}^n X_i$ (number of stores sorted from large to small), the HHI index (**this is currrently working, wihch is a little bit challenging since we need to count types of other stores near given communities**) the entry and continuous effect and the distance to nearest lianjia. (HHI index may be troublesome because it distorts the actual market concentration, but we can calculate it.)

The basic structure should be we first use distance based to find out the cutoff point, like RD design, and then we conduct our analysis based on the cutoff point. The intuition is that beyond this cutoff point, the number of transactions and income dramatically decreases, and this would cause the effect of lianjia dramatically decreases. Given this, we can take it as the effect of lianjia's stores' ranges. Given this, we can calculate our measures of four sets of explanatory variables. We first conduct multi-way fixed effect, and then we conduct the difference-GMM estimation. Then we use the cutoff-ratio like RD design of the HHI index, density based index, and Gini index (separating the competitive and oligophy market). Finally, we conduct the robustness check and heterogeneity check. Then we conclude the paper. **I believe that this work load gonna be way larger**.

**current progress**:

The basic structure is as the follows:

- [ ] RDD to find cutoff for distance based measure
- [ ] reconstruct the dataset
- [ ] stylized facts (multi-way fixed effect)
- [ ] dynamically estimations of the effect
- [ ] GMM estimations
- [ ] exogeneous or shocking (RD design)
- [ ] heterogeneous checkings and robustness checkings

## stylized fact:

using two way fixed effect with multple clustering model and the codes have been done and should be revised further.

## dynamically estimations of the effect

We dynamically estimate the effect of real estate brokerage's entry and leaving for the local submarket. We first generate a dummy variable entry indicating the first entry period where the number of brokerage decides to open new offline stores in this given area. Then we generate the post and pre of this period.

After this, we conduct two way fixed effect with multple clustering model to estimate it and drop the pre1 period to avoid collinearity problem. The result indicates entry and post1 period significant for income and number while the pricing the entry is not significant and the post1 is significant.

## GMM estimations

Use dynamic panel data estimation method to deal with small $T$ large $N$ serial correlation problem. This method serves as a further check for the stylized result and pave way for our further analysis.

I find that the dynamic effect, after taking the effect of the lagged dependent effect and serial correlation, is quite different than the OLS result. The results also indicates that the previous OLS result is biased and not asymptotically efficient. Therefore, we shuold further prove that our GMM is robust given the exogeneous or shocking.

## exogeneous or shocking

I now use the shocking to prove our GMM estimations are correct. Finally, we consider the exogeneous shock to prove our estimation is asymptotically efficient. 

## heterogeneous checkings and robustness checkings

easy to manage and leave it alone.

## NOTE

Note that we should not drop the ln_lead == 0 becaue these consists of various observations that do not observe the results. These observations contain useful information, so directly dropping it will cause the data do not represent the real situation. We shall include a variable non_online_effect to avoid this problem.
