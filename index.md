# badata

**badata** is a data package that provides data from the German Federal
Employment Agency (Bundesagentur für Arbeit – BA) about unemployed
persons, employees, and jobs in Germany from 2012 to 2021 by district
(Kreis) and occupational group.

## Installation

You can install the development version of **badata** from
[GitHub](https://github.com/RegioHub/badata) with:

``` r

# install.packages("devtools")
devtools::install_github("RegioHub/badata")
```

## Usage

**badata** provides the following datasets as `tibbles`/`data.frames`:

``` r

library(badata)

employees_by_workplace
#> # A tibble: 4,410,198 × 6
#>    region occupational_group  year type               group          n
#>    <chr>  <chr>              <int> <chr>              <chr>      <dbl>
#>  1 01001  111                 2013 social insurance   total         36
#>  2 01001  111                 2013 social insurance   foreigners    NA
#>  3 01001  111                 2013 social insurance   women          9
#>  4 01001  111                 2013 marginal part-time total          6
#>  5 01001  111                 2013 marginal part-time foreigners     0
#>  6 01001  111                 2013 marginal part-time women         NA
#>  7 01001  111                 2014 social insurance   total         34
#>  8 01001  111                 2014 social insurance   foreigners    NA
#>  9 01001  111                 2014 social insurance   women          8
#> 10 01001  111                 2014 marginal part-time total          5
#> # ℹ 4,410,188 more rows

employees_by_residence
#> # A tibble: 4,410,198 × 6
#>    region occupational_group  year type               group          n
#>    <chr>  <chr>              <int> <chr>              <chr>      <dbl>
#>  1 01001  111                 2013 social insurance   total         39
#>  2 01001  111                 2013 social insurance   foreigners     3
#>  3 01001  111                 2013 social insurance   women         12
#>  4 01001  111                 2013 marginal part-time total         25
#>  5 01001  111                 2013 marginal part-time foreigners    NA
#>  6 01001  111                 2013 marginal part-time women          9
#>  7 01001  111                 2014 social insurance   total         42
#>  8 01001  111                 2014 social insurance   foreigners     4
#>  9 01001  111                 2014 social insurance   women         13
#> 10 01001  111                 2014 marginal part-time total         23
#> # ℹ 4,410,188 more rows

unemployed_total
#> # A tibble: 814,030 × 5
#>    region occupational_group  year total women
#>    <chr>  <chr>              <int> <dbl> <dbl>
#>  1 01001  111                 2012  15.2  1.08
#>  2 01001  111                 2013  14.7  2   
#>  3 01001  111                 2014  12.5  1.58
#>  4 01001  111                 2015  10.8  1.5 
#>  5 01001  111                 2016  12.9  1.33
#>  6 01001  111                 2017  20.6  1   
#>  7 01001  111                 2018  19.7  2.5 
#>  8 01001  111                 2019  15.8  2.75
#>  9 01001  111                 2020  19.7  2.17
#> 10 01001  111                 2021  15.5  1.92
#> # ℹ 814,020 more rows

unemployed_foreigners
#> # A tibble: 814,030 × 5
#>    region occupational_group  year total women
#>    <chr>  <chr>              <int> <dbl> <dbl>
#>  1 01001  111                 2012  1.92 0.917
#>  2 01001  111                 2013  2.58 1.17 
#>  3 01001  111                 2014  1.33 0    
#>  4 01001  111                 2015  1.92 0    
#>  5 01001  111                 2016  4.17 0    
#>  6 01001  111                 2017 10.8  0    
#>  7 01001  111                 2018  8.67 0    
#>  8 01001  111                 2019  7.5  1.08 
#>  9 01001  111                 2020  9.42 0.75 
#> 10 01001  111                 2021  6    0.667
#> # ℹ 814,020 more rows

jobs
#> # A tibble: 816,060 × 5
#>    region occupational_group  year  total social_insurance
#>    <chr>  <chr>              <int>  <dbl>            <dbl>
#>  1 01001  111                 2012 0.0833           0.0833
#>  2 01001  111                 2013 0.0833           0.0833
#>  3 01001  111                 2014 0.417            0.333 
#>  4 01001  111                 2015 0.333            0.333 
#>  5 01001  111                 2016 0                0     
#>  6 01001  111                 2017 0.25             0.25  
#>  7 01001  111                 2018 0                0     
#>  8 01001  111                 2019 0.0833           0.0833
#>  9 01001  111                 2020 0.0833           0.0833
#> 10 01001  111                 2021 0.25             0.25  
#> # ℹ 816,050 more rows
```

Codes and full names of regions and occupational groups can be looked up
in the respective tables:

``` r

region_codes
#> # A tibble: 401 × 2
#>    code  name                  
#>    <chr> <chr>                 
#>  1 01001 Flensburg, Stadt      
#>  2 01002 Kiel, Landeshauptstadt
#>  3 01003 Lübeck, Hansestadt    
#>  4 01004 Neumünster, Stadt     
#>  5 01051 Dithmarschen          
#>  6 01053 Herzogtum Lauenburg   
#>  7 01054 Nordfriesland         
#>  8 01055 Ostholstein           
#>  9 01056 Pinneberg             
#> 10 01057 Plön                  
#> # ℹ 391 more rows

occupational_group_codes
#> # A tibble: 145 × 2
#>    code  name                                    
#>    <chr> <chr>                                   
#>  1 111   Landwirtschaft                          
#>  2 112   Tierwirtschaft                          
#>  3 113   Pferdewirtschaft                        
#>  4 114   Fischwirtschaft                         
#>  5 115   Tierpflege                              
#>  6 116   Weinbau                                 
#>  7 117   Forst-,Jagdwirtschaft, Landschaftspflege
#>  8 121   Gartenbau                               
#>  9 122   Floristik                               
#> 10 211   Berg-, Tagebau und Sprengtechnik        
#> # ℹ 135 more rows
```

## Citation

To cite package ‘badata’ in publications use:

Nguyen HL, Tsolak D (2026). {badata}: Regional Job Market Data from the
German Federal Employment Agency (Bundesagentur für Arbeit – BA).
<https://doi.org/10.5281/zenodo.7636114>,
<https://github.com/RegioHub/badata>

A BibTeX entry for LaTeX users is

``` R
@Manual{,
  title = {{badata}: Regional Job Market Data from the German Federal Employment Agency
(Bundesagentur für Arbeit -- BA)},
  doi = {10.5281/zenodo.7636114},
  author = {H. Long Nguyen and Dorian Tsolak},
  year = {2026},
  version = {0.2.0},
  url = {https://github.com/RegioHub/badata},
}
```

## Disclaimer

The variable names were translated from German into English, the data
itself remains unchanged and is subject to the copyright of the German
Federal Employment Agency (BA). © [Statistik der Bundesagentur für
Arbeit](https://statistik.arbeitsagentur.de)

This package is in no way officially related to or endorsed by BA.
