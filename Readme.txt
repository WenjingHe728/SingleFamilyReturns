Steps to run the code:
- Open RStudio
- setwd('D:/Dropbox/Wenjing Andrea/Single family returns')
- source('main.R')


The master file is 'main.R'. Please run this file to generate net yields. In 'main.R', you can modify 'include_metro_sample' to toggle on/off the inclusion of metro samples.

Folders:

- input data: input data after processing raw data from AHS
- output intermediate: all output .csv files for intermediate results. These files may be used for debugging and plotting charts.
- output final: final .csv files for net yields. The final result is net_yield_30cities.csv and net_yield_15metros.csv. The first covers cities from 1985 to 2014. The second covers 15 largest metropolitan areas from 1985 to 2020.

Columns in the net_yield_xxx.csv file:
- Year
- region: MSA for the short sample, OMB13CBSA for the long sample
- state: to match with tax data
- cbsa: to match with HPI data
- rp: median weighted rent-to-price ratio. NA for even number years because AHS survey is every other year.
- tax_rate: from taxes.csv
- vac_rate: vacancy rate calculated from AHS data
- interp_rp: interpolated rp for even years
- interp_tax: interpolated tax rate. (no extrapolation)
- interp_vac: interpolated vacancy rate for even years
- net_yield: net yield using interp_tax
- extrap_tax_1: extrapolate tax after 2012 using the growth rate from 2005 to 2012
- extrap_tax_0.5: extrapolate tax after 2012 using half the growth rate from 2005 to 2012
- net_yield_1: net yield using extrap_tax_1
- net_yield_0.5: net yield using extrap_tax_0.5