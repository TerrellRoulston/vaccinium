This folder contains verified GBIF records that have been cleaned from the raw dataset, and for a subset of spp those that have accepted county data further spatially filtered.

Clean data for ang, bor, dar, myr, mys, pal, and ten is copied from the occ_data/clean folder

Whereas

Clean data for ash, cor, cot, ell, fus, sim, vir and hir have been spatially filtered to accepted ranges at a county level in published references (see occ_data/sect_cyan_final/corymbosum_complex_counties.xlsx)

Additonal note:

Previouslly cleaned occurrence data for V. corymbosum and V. formosum where combined to produced a synomous occ dataset prior to county filtering

Same goes for V. fuscatum and V. caesariense

After county filtering for available species the following differences in number of occurrences are observed, this is especially drastic for V. corymbosum

# A tibble: 8 × 5
  species after before removed retained_percent
  <chr>   <dbl>  <dbl>   <dbl>            <dbl>
1 ash        39     51      12             76.5
2 cor      8373  13780    5407             60.8
3 fus      1952   2235     283             87.3
4 cot        96    100       4             96  
5 ell       457   2087    1630             21.9
6 sim       148    157       9             94.3
7 vir       334    362      28             92.3
8 hir       142    145       3             97.9
> 