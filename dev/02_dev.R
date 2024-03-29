# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
###################################
#### CURRENT FILE: DEV SCRIPT #####
###################################

# Engineering

golem::run_dev()

## Dependencies ----
## Amend DESCRIPTION with dependencies read from package code parsing
## install.package('attachment') # if needed.
attachment::att_amend_desc()

## Add modules ----
## Create a module infrastructure in R/
golem::add_module(name = "name_of_module1", with_test = TRUE) # Name of the module
golem::add_module(name = "name_of_module2", with_test = TRUE) # Name of the module

## Add helper functions ----
## Creates fct_* and utils_*
golem::add_fct("helpers", with_test = TRUE)
golem::add_utils("helpers", with_test = TRUE)

## External resources
## Creates .js and .css files at inst/app/www
golem::add_js_file("script")
golem::add_js_handler("handlers")
golem::add_css_file("custom")
golem::add_sass_file("custom")

## Add internal datasets ----
## If you have data in your package
usethis::use_data_raw(name = "my_dataset", open = FALSE)

## Tests ----
## Add one line by test you want to create
usethis::use_test("app")

# Documentation

golem::add_fct( "helpers" )
golem::add_utils( "helpers" )

usethis::use_package("pkg.you.want.to.add")

## Vignette ----
usethis::use_vignette("shinySbm")
devtools::build_vignettes()

## Code Coverage----
## Set the code coverage service ("codecov" or "coveralls")
usethis::use_coverage()

# Create a summary readme for the testthat subdirectory
covrpage::covrpage()

## CI ----
## Use this part of the script if you need to set up a CI
## service for your application
##
## (You'll need GitHub there)
usethis::use_github()

# GitHub Actions
usethis::use_github_action()
# Chose one of the three
# See https://usethis.r-lib.org/reference/use_github_action.html
usethis::use_github_action_check_release()
usethis::use_github_action_check_standard()
usethis::use_github_action_check_full()
# Add action for PR
usethis::use_github_action_pr_commands()

# Travis CI
usethis::use_travis()
usethis::use_travis_badge()

# AppVeyor
usethis::use_appveyor()
usethis::use_appveyor_badge()

# Circle CI
usethis::use_circleci()
usethis::use_circleci_badge()

# Jenkins
usethis::use_jenkins()

# GitLab CI
usethis::use_gitlab_ci()

# You're now set! ----
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")



# je suppose que c'est une interface de chargement
#   add_busy_spinner(
# spin = 'breeding-rhombus',
# color = '#978E83',
# timeout = 100,
# position = 'top-right',
# onstart = TRUE,
# margins = c(10, 10)
# ),

# install.packages("remotes")
# remotes::install_github("rstudio/shinyuieditor")

# shinyuieditor::launch_editor(app_loc = "new-app/") nouvelle app
# shinyuieditor::launch_editor(app_loc = "existing-app/")

# les icones
# https://fontawesome.com/v4/icons/





usethis::use_pipe(export = TRUE)

usethis::use_package("visNetwork")
usethis::use_package("plotly")
usethis::use_package("shinyalert")
usethis::use_package("flextable")
usethis::use_package("stringr")
usethis::use_package("dplyr")
usethis::use_package("colourpicker")
usethis::use_package("reshape2")
usethis::use_package("quarto")
usethis::use_package("plyr")
usethis::use_package("shinyWidgets")
usethis::use_package("shinythemes")
usethis::use_package("ggsignif")
usethis::use_package("sortable")
usethis::use_package("officer")
usethis::use_package("webshot2")
usethis::use_package("Rmisc")
usethis::use_package("moments")
usethis::use_package("readxl")
usethis::use_package("openxlsx")
# usethis::use_package("shinydashboardPlus")
# usethis::use_package("magrittr")

## USED modules
golem::add_module(name = "tab_upload", with_test = TRUE)
golem::add_module(name = "tab_show", with_test = TRUE)
golem::add_module(name = "tab_sbm", with_test = TRUE)
golem::add_module(name = "tab_network", with_test = TRUE)
golem::add_module(name = "tab_extraction", with_test = TRUE)
golem::add_module(name = "tab_about_us", with_test = TRUE)

golem::add_module(name = "select_nb_groups", with_test = TRUE)
golem::add_module(name = "select_net_type", with_test = TRUE)
golem::add_module(name = "show_group_names", with_test = TRUE)
golem::add_module(name = "help_to_import", with_test = TRUE)

golem::add_module(name = "upload_code", with_test = TRUE)
golem::add_module(name = "sbm_code", with_test = TRUE)
golem::add_module(name = "show_code", with_test = TRUE)
golem::add_module(name = "network_code", with_test = TRUE)

## USED functions
golem::add_fct("matrixNicePrint")
golem::add_fct("errorHandeling")
golem::add_fct("linkListMatrix")
golem::add_fct("sbmMatrixClass")
golem::add_fct("specific_css_style")
golem::add_fct("specific_plots")
golem::add_fct("getGroup")
golem::add_fct("flextables")
golem::add_fct("is_bipartite")
golem::add_fct("plotSbm")
golem::add_fct("plotNet")
golem::add_fct("fct_adjacency_to_edges")
golem::add_fct("fct_melt")
golem::add_fct("fct_get_shapes")

a = sortable::rank_list(
  text = "Cliquer glisser dans l'ordre souhaité (plusieurs selection possible avec la touche CTRL)",
  labels = label,
  input_id = ns("select_drag_order"),
  options = sortable::sortable_options(multiDrag = TRUE))
