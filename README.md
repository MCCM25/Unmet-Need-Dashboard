# CPAF Unmet Need Dashboard
*This dashboard is a mock version of a tool delivered to West Lothian Council by the Improvement service where some datasets have been adapted to simulate council held information*

# Purpose
The purpose of the dashboard is to show at the West Lothian council area data zones where uptake of benefits and services in relation to child poverty are lower than modelled estimates. These areas where families do not take up the benefits and services
they are entitled to are termed areas of 'unmet need'.

# Data 
The data used in the tool contain a mix of simulated and publicly available data. Where datasets used in the original dashboard were sourced from local authorities or third sector organisations, these have been 
adapted to produce simulated data that retains the underlying original distribution. Datasets where data has been simulated are: Free School Meals, Clothing Grant, Education Maintenance Allowance, Advice uptake, council tax arrears, foodbank usage,
and housing arrears. All other datasets used are publicly available from National Records of Scotland (NRS), Census Scotland 2022 and DWP StatXplore and retain the original figures. 

# Modelling Approach
Building on previous work that looked at identifying data zones with low uptake of education benefits - Free School Meals, Clothing Grant, and Education Maintenance Allowance - the dashboard was built to be able to allow council officers to visualise thise areas
in order to better inform resource allocation and service delivery. Funding for this project allowed for greater scope in the datasets that could be included in the tool.

All data was analysed at data zone level and, where required, aggregated to data zones. Using Census and NRS data sets as denominators was then converted to rates.

To determine whether an area has unmet need, uptake measure (benefit/service) is compared against a demand measure. For example, Free School Meals is compared against the Children in Low-Income Families (CILIF) rate for 10 to 18 year olds (P6 children and older)
at data zone level. Where there is a higher rate of child poverty we would expect to see a higher uptake of Free School Meals. Both uptake and demand measure are fitted to a linear regression model with the demand measure (CILIF rate) used as the predictor variable and 
the uptake measure (Free School Meals) as the outcome. Regression estimates of uptake are compared against actual uptake rates for each area and residual differences less than -2 standard deviations/greater than 2 standard deviations from the mean are those data zones
identified as outliers where uptake differs significantly from what is estimated. Although the focus of the project was highlighting data zones with lower benefit uptake (those less than -2 standard deviations), the dashboard also displays areas where
uptake is higher than estimated as it was felt that awareness and knowledge of these may help to inform council officers of suitable outreach strategies that can be applied to other areas.


For more information on the modelling appraoch and the data used, see the Methodology section in the dashboard.



