# CPAF_Dashboard
As part of the CPAF project a dashboard to support West Lothian council understand areas of unmet need in relation to child poverty.

## Resources
A mockup of the initial app features has been created in Mockflow. A PDF copy of this is saved here, https://impservihub.sharepoint.com/:w:/s/Research104/EYP1GAoLNa5CnFdPEVz_MYABF9J2RR0aiyhpfVBA5KGJIA?e=uZWCLl, this will be updated if additional tabs and features are added. 

The following flowchart has been created to demonstrate how different parts of the code are related and the process that will be taken for creating the dashboard https://impservihub.sharepoint.com/:u:/s/Research104/EdnNItwPouNJru4Qdc-jkr8BzdGu8HXx_zPGkNMK6Pw5BA?e=AaAhoy. This will be updated if additional tabs and features are added. 

The dashboard will use some of the analysis from previous work analysis unmet need and code can be used from this project https://github.com/Improvement-Service/Child-Poverty-Unmet-Need-Analysis. The dashboard will also build on initial scoping work saved here https://github.com/Improvement-Service/WLC-CPAF-Dashboard.

Code in this tool will follow the Tidyverse style guide which can be viewed here https://style.tidyverse.org/index.html

A starting point for West Lothian data used in this dashboard can be found here https://impservihub.sharepoint.com/:x:/s/Research104/EWSVeRbf6TVKkhFjhVH0JIIB6mbuzEJRuBrCpJLuIpv92A?e=teAHVv, however more will likely become available. We will also likely need to create some appropriate data files to start with, e.g. uptake numbers, demand numbers, lookup between these, shape files. These datasets should be saved in the folder "Data". 

Helper scripts, once created, should be run first to create data ready to be used in the dashboard. 

##  Working Together
The project has been segmented into small tasks and a git Issue has been opened for each of these detailing what needs to be done. These issues were created in the order they should be completed, to view them in order sort from oldest to newest. Each issue has been tagged to show what and where it relates to. Specific types of code (maps, graphs, bespoke functions and reactive expressions) have been tagged so that collaborators can work on the type of issues they are comfortable with.

To start work on an issue:

Select the name of an issue
At the right hand-side where it says "Assignees" assign yourself to the issue
At the right hand-side where it says "Development" create a branch for the issue
Once you have worked on your code open a pull request for the branch and associate it with the issue
Once the pull request has been reviewed and agreed the branch can be merged with the Master branch
Finally close the issue and pull request and delete the branch
