source("renv/activate.R")
if (grepl("^win", .Platform$OS.type, ignore.case=TRUE) != "windows") {
  options(width = (function(){
    width = strtoi(system("tput cols || echo 80", intern = TRUE))
    if (is.na(width) || width <= 0) 80 else width
  })())
}