Date README last edited: 2025-10-24

# Watt-HL-SMN
*Risk of subsequent malignant neoplasms for >5-year survivors of Hodgkin Lymphoma in the Netherlands*

## People and permissions

Gordie Watt (rw)
Michael Schaapveld (r)
Beatriz Torrinha (r)

## Project Description

### Purpose 
The last comprehensive update on SMN risk in the HL cohort was in 2015
(Schaapveld _et al. NEJM_ 2015). Since then, the cohort has continued to grow, 
including treatment date through 2013 and follow-up through 2022. 

The purpose of thie study is to evaluate the risk of SMNs for a more contemporary 
set of survivors, treated from 1989-2013, with up to 28 years of follow-up.

### Basic wayfinding

`renv` is used for managing dependencies. The lockfile `renv.lock` can be read in
when recreating this work to ensure that R version and package dependencies
are satisfied.

`git` is used for version control. The repository is accessible from 
https://gitlab.rhpc.nki.nl/Epi-H8/hl-smn/watt-hl-smn. The main branch used by 
G. Watt during analysis is protected. Please create a new branch for further
analyses. The .gitignore file includes proprietary files (.docx) plus anything
that may include data (i.e. all delimited, binary, and .xslx files)

This is an R project (Watt-HL-SMN.Rproj). 

The main analysis file for the manuscripts is ``SMN-risk.qmd'', saved in the 
`/scripts` folder. There are a number of 'helper scripts' with miscellaneous 
functions or derivations that are saved separately alongside this file in the 
`/scripts` directory.

Output is saved in `output`. Anything that is included in the manuscripts 
should be findable here.



