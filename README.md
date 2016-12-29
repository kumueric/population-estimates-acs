## POPULATION ESTIMATES WITH R

![center](https://github.com/tyokota/population-estimates-acs/blob/master/img/population-estimates-acs.png?raw=true)

#### Summary
Accessing the US Census Bureau API using R to query 2014 State of Hawaii 5-year estimates.

## Introduction
The [American Community Survey](https://www.census.gov/history/pdf/ACSHistory.pdf) replaces the so-called "long form" once administered during the decennial census survey to gather socioeconomic information on the population. The ACS is conducted between decennial periods to produce annual population statistics and is reported as 5-year, <del>3-year</del> or 1-year estimates. In addition, the ACS provides small area estimates such as [zip code tabulated area(ZCTA) ](https://www.census.gov/geo/reference/zctas.html) and tract area.

> Still unsure as to what the US Census Bureau is all about? A recommended text is the [Bloomberg Financial Series Guide to the Census](https://www.amazon.com/gp/product/B00BJOHKD6/ref=as_li_tl?ie=UTF8&tag=yokota-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B00BJOHKD6&linkId=5d4cfce7c39bf12bd22aa1f3e737e781).

## Data
There are two commonly known methods for extracting ACS data from the US Census Bureau: 

1. US Census Bureau's web-based query tool called the American FactFinder
2. Glossy cut-and-paste data books from local organizations

In recent years, the US Census Bureau has released [APIs to developers](http://www.census.gov/developers/) and several packages are now available that make extracting ACS data seemless in the R workflow. Most notably are the [acs](https://github.com/eglenn/acs) and [acsr](https://github.com/sdaza/acsr) packages. The `acs` package has a companion textbook titled *[Working with the American Community Survey in R](https://www.amazon.com/gp/product/B01LXGLR1K/ref=as_li_tl?ie=UTF8&tag=yokota-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01LXGLR1K&linkId=eeacc564756d893ad3a7c5e873df4bad)*. The following walkthrough covers downloading the ACS 2014 (5-yr est.) into R using the `acsr` package. Please visit the US Census Bureau's site for developers to [request a key](http://www.census.gov/developers/) before proceeding.

#### data dictionary
[Social Explorer](http://www.socialexplorer.com/data/metadata) provides dictionaries for data sets such as the ACS. In this case, I wanted to know what is the total population by sex (e.g., females/males) and age (e.g., 0-17/18-64/65up). Using the data dictionary, I identified *B01001: Sex by Age* as the table of interest. 

#### accessing the API
I accessed the API using the `acsr::sumacs()` function. In this case, I was interested in ZCTA level estimates for Hawaii. I validated my query results with the [FactFinder](http://factfinder.census.gov/faces/nav/jsf/pages/community_facts.xhtml?src=bkmk). In this case both R and FactFinder reported that the total population for 96813 in the 2014 (5 yr. est.) was 22,041. 

The query returns both estimates and margin of error at the specified geographic level. The results are saved as an R data frame which means that the estimates are ready for further analysis in R with minimal effort. For an idea of the work required to sum and recalculate the MOE, please see this presentation by the Maryland State Data Center [slides](http://planning.maryland.gov/msdc/Affiliate_meeting/2010/SDC_Sept16_2010_StatTest&MOEs.pdf).

## Conclusion
Extracting population estimates from the US Census Bureau is quite flexible with R. Aggregation and proportions can be called upon on the fly resulting in clean outputs that are ready for analysis. Speaking from past experiences, the time and effort invested in either package will return dividends on work-life balance.
