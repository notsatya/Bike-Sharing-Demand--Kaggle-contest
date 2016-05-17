## Bike Sharing Demand (Kaggle contest)

* The background informatioan of this Kaggle contest can found at this [link] {https://www.kaggle.com/c/bike-sharing-demand}
* This R code uses Graident Boosting classification tree to predict the test data in the Bike Sharing Demand Kaggle contest 
* Below is a table showing the RMSLE score for different interaction dept(ID), shrinkage(S), number of trees in model building and prediction



Ntree(model) | Ntree(predict) | ID | S | RMSLE|
------------ | ---------------|----|---|------|
3000|2000|10|0.01|0.425|
2000|2000|10|0.01|0.422|
2000|2000|5|0.01|0.429|
2000|2000|20|0.01|0.426|
500|500|20|0.01|0.457|
2000|2000|5|0.001|0.6069|
2000|2000|5|0.1|0.4385|
