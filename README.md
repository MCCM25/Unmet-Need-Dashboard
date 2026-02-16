# CPAF Unmet Need Dashboard
*This dashboard is a mock version of a tool delivered to West Lothian Council. Datasets used in this tool contain simulated (dummy) data.*

You can view the [Unmet Need Dashboard](https://mccm-25.shinyapps.io/unmet-need-dashboard/) here.

# Purpose
The purpose of the dashboard is to show for the West Lothian council area data zones where uptake of benefits and services in relation to child poverty are lower than modelled estimates.
These areas where families do not take up the benefits and services they are entitled to are termed areas of 'unmet need'.

# Data 
The data used in the dashboard contain a mix of simulated council held and publicly available data.
Datasets used in this tool are: Free School Meals, Clothing Grant, Education Maintenance Allowance, advice uptake, council tax arrears, foodbank usage, housing arrears. Publicly available datasets Children in low-income families from 
[DWP StatXplore](https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml), and [NRS](https://www.nrscotland.gov.uk/publications/small-area-population-estimates-mid-2022) small area population estimates are also included. 

# Modelling Approach
Building on previous work that looked at identifying data zones with low uptake of education benefits - Free School Meals, Clothing Grant, and Education Maintenance Allowance - the dashboard was built to be able to allow council 
officers to visualise these areas in order to better inform resource allocation and service delivery. Funding for this project allowed for greater scope in the datasets that could be included in the tool.

All data was analysed at data zone level and, where required, aggregated to data zones. Using Census and NRS data sets as denominators was then converted to rates.

To determine whether an area has unmet need, uptake measure (benefit/service) is compared against a demand measure. For example, Free School Meals is compared against the Children in Low-Income Families (CILIF) rate for 10 to 
18 year olds (P6 children and older) at data zone level. Where there is a higher rate of child poverty we would expect to see a higher uptake of Free School Meals. Both uptake and demand measure are fitted to a linear regression 
model with the demand measure (CILIF rate) used as the predictor variable and the uptake measure (Free School Meals) as the outcome. Regression estimates of uptake are compared against actual uptake rates for each area and residual 
differences less than -2 standard deviations/greater than 2 standard deviations from the mean are data zones identified as outliers where uptake differs significantly from what is estimated. 

For more information on the modelling approach and the data used, see the Methodology section in the dashboard.



