# RealEstateBrokerage

## Jan 16 update:

now add the `ln_negotiation` as the variable.

1. First, we need to apply Regression discontinuity to define the best influential space; This thing should be carried out by examing the general patterns of all data;
2. Stylized fact, we apply stlized fact using two way fixed effect. We shuold know that the different regions have different patterns, so why not using each cities to generate a unique `density` estimator and make a table to show it; Besides, we also show that the GMM estimator of them.
4. Actually, I should use the areas where lianjia do not have a store to study the effect, i.e., drop the communities that already have lianjia? Examine the impact of Lianjia's entry into new markets. You can compare markets where Lianjia opened new branches with similar markets where it did not. This analysis would focus on the effect of Lianjia's physical presence in new locations.
5. Finally we study Market Maturity Variations: Compare mature markets where brokerages have been established for a long time with emerging markets where brokerages are relatively new.
6. Dynamic treatment effect, like generating a dummy of have_metro and generate pre periods, after periods and multplying it with lianjia's density to test the result. (thinking about this)
7. Other Heterogenous tests and checks. Like: Competitor Analysis: Compare areas where Lianjia faces different levels of competition. The impact of Lianjia in highly competitive markets versus those with limited competition could reveal its market influence.

## Description

* `analysis` contains the codes that are associated with the anslysis
* `cleaning` contains the codes that generate the data
* `classifying brokerages` contains the codes to regenerate the result and using techiniques to calculate the HHI index in each of the region
* `manuscript` contains the `latex` files that generate the manuscript
* `result_table` contains the `tex` source files that replicate the tables
* `archive` is the unused files that should be deleted.

the data should be placed in the base folder, and all of the cleaning or analysis codes should be set working directory to that folder.

## Progress

The dependent variable is `ln_income`, `ln_end_price`, `ln_negotiation_period` and `ln_negotiation` and there are three set of explanatory variables, including density based index (DBI) $\frac{X_1}{\Sigma_{i=1}^n X_i}$ (number of stores sorted from large to small), the HHI index (**this is currrently working, wihch is a little bit challenging since we need to count types of other stores near given communities**) the entry and continuous effect and the distance to nearest lianjia. (HHI index may be troublesome because it distorts the actual market concentration, but we can calculate it.)

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

## RDD to find cutoff for distance based measure

We derive the result using *rdrobust* command in R. The result should be the same regarding the whole values.

## reconstruct the dataset

the dataset now contains 222843 observations, and this is correct. The only thing that we need to reclean is to:

1. first, we drop the lianjia's number, beke's number and the density.
2. We merge all of the regions' real estate brokerage's types and using the techniques of most overlapping properties to cluster the types of the brokerages. For example, *da tang*, *lian jia*, and so on.
3. explain why using 500 meters for other pois: (A 500-meter radius often provides a good estimate of accessibility, A 500-meter radius is equivalent to a 10-minute walking distance. This distance is often used because it represents a practical and manageable reach for residents, particularly in urban or densely populated areas, A particular distance might be chosen based on the sensitivity of housing prices to changes at that scale. (cite papers))
4. we reconstruct using lianjia's numbers, beke's numbers and the density and other results using the radius of the cutoff value.

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
