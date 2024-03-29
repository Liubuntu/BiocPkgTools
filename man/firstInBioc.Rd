% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/biocDownloadStats.R
\name{firstInBioc}
\alias{firstInBioc}
\title{When did a package enter Bioconductor?}
\usage{
firstInBioc(download_stats)
}
\arguments{
\item{download_stats}{a data.frame from \code{\link{biocDownloadStats}}}
}
\description{
This function uses the biocDownloadStats
data to *approximate* when a package entered
Bioconductor. Note that the download stats
go back only to 2009.
}
