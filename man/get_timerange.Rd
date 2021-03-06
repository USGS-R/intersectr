% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{get_timerange}
\alias{get_timerange}
\title{Get Timerange}
\usage{
get_timerange(nc_file, t_var)
}
\arguments{
\item{nc_file}{character path or url to a NetCDF source}

\item{t_var}{character name of time variable}
}
\description{
Helper function to get start and end time stamps from a NetCDF source.
}
\examples{
nc_file <- system.file("extdata/metdata.nc", package = "intersectr")
get_timerange(nc_file, ncmeta::nc_coord_var(nc_file, "precipitation_amount")$T)
}
