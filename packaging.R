#=====================================================================================
# BUILD THE PACKAGE
#=====================================================================================

if (FALSE) {
  library(ranger)
  library(FNN)
  lapply(list.files("R", full.names = TRUE), source)
}

library(usethis)
library(devtools)

# Create a new package
dir.create(file.path("release"))
pkg <- file.path("release", "missRanger")

create_package(
  pkg,
  fields = list(
    Title = "Fast Imputation of Missing Values",
    Type = "Package",
    Version = "2.1.0",
    Date = Sys.Date(),
    Description = "Alternative implementation of the beautiful 'MissForest' algorithm used to impute 
    mixed-type data sets by chaining random forests, introduced by Stekhoven, D.J. and 
    Buehlmann, P. (2012) <doi.org/10.1093/bioinformatics/btr597>. Under the hood, it uses the 
    lightning fast random jungle package 'ranger'. Between the iterative model fitting, 
    we offer the option of using predictive mean matching. This firstly avoids imputation 
    with values not already present in the original data (like a value 0.3334 in 0-1 coded variable). 
    Secondly, predictive mean matching tries to raise the variance in the resulting conditional 
    distributions to a realistic level. This would allow e.g. to do multiple imputation when 
    repeating the call to missRanger(). 
    A formula interface allows to control which variables should be imputed by which.",
    `Authors@R` = "person('Michael', 'Mayer', email = 'mayermichael79@gmail.com', role = c('aut', 'cre', 'cph'))",
    URL = "https://github.com/mayer79/missRanger",
    BugReports = "https://github.com/mayer79/missRanger/issues",
    Depends = "R (>= 3.5.0)",
    VignetteBuilder = "knitr",
    License = "GPL(>= 2)",
    Maintainer = "Michael Mayer <mayermichael79@gmail.com>"))

file.copy(file.path(pkg, "DESCRIPTION"), to = getwd(), overwrite = TRUE)
# Use package has no option to look for pkg, so we first copy description from pkg, modify it and move back
use_package("stats", "Imports")
use_package("FNN", "imports")
use_package("ranger", "Imports")
use_package("dplyr", "Suggests")
use_package("survival", "Suggests")
use_package("mice", "Suggests")
use_package("knitr", "Suggests")

# Set up other files -------------------------------------------------
# use_readme_md()
# use_news_md()
# use_cran_comments()

# Copy readme etc.
file.copy(c(".Rbuildignore", "NEWS.md", "README.md", "cran-comments.md", "DESCRIPTION"), pkg, overwrite = TRUE)

# Copy R scripts and document them
file.copy(list.files("R", full.names = TRUE), file.path(pkg, "R"), overwrite = TRUE)
devtools::document(pkg)

# Copy vignette
# use_vignette(name = "missRanger", title = "missRanger")
dir.create(file.path(pkg, "vignettes"))
dir.create(file.path(pkg, "doc"))
dir.create(file.path(pkg, "Meta"))
file.copy(list.files("vignettes", full.names = TRUE),
          file.path(pkg, "vignettes"), overwrite = TRUE)

devtools::build_vignettes(pkg)

# Check
check(pkg, manual = TRUE)

# Create
build(pkg)
build(pkg, binary = TRUE)

# Install
install(pkg)

# modify .Rbuildignore in build project to ignore the proj file.

check_win_devel(pkg)

check_rhub(pkg)

devtools::release(pkg)

usethis::use_pkgdown()
pkgdown::build_site(pkg)
