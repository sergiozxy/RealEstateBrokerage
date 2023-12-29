# RealEstateBrokerage

## update Dec 28 --

Working on whether to drop the unnecessary samples and working on refining the results. okay in current progress.

--

**current progress**:

The basic structure is as the follows:

- [x] stylized facts (finished)
- [ ] GMM estimations
- [x] dynamically estimations of the effect
- [ ] exogeneous or shocking
- [ ] heterogeneous checkings and robustness checkings

## stylized fact:

using two way fixed effect with multple clustering model and the codes have been done.

## GMM estimations

Use dynamic panel data estimation method to deal with small $T$ large $N$ problem serial correlation problem. This method serves as a further check for the stylized result and pave way for our further analysis.

## dynamically estimations of the effect

We dynamically estimate the effect of real estate brokerage's entry and leaving for the local submarket. We first generate a dummy variable entry indicating the first entry period where the number of brokerage decides to open new offline stores in this given area. Then we generate the post and pre of this period.

After this, we conduct two way fixed effect with multple clustering model to estimate it and drop the pre1 period to avoid collinearity problem. The result indicates entry and post1 period significant for income and number while the pricing the entry is not significant and the post1 is significant.

## exogeneous or shocking

Finally, we consider the exogeneous shock to prove our estimation is asymptotically efficient. Thinking about this problem right now.

## heterogeneous checkings and robustness checkings

easy to manage and leave it alone.
