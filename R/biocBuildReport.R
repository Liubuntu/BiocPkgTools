#' Tidy Bioconductor build report results
#' 
#' The online Bioconoductor build reports
#' are great for humans to look at, but
#' they are not easily computable. This function
#' scrapes HTML and text files available
#' from the build report online pages to generate
#' a tidy data frame version of the build report.
#' 
#' @param version character(1) the version number
#' as used to access the online build report. For 
#' example, "3.6". The default is the "current version"
#' as specified in \code{BiocManager::version}. Note
#' that this is a character() variable, not a number.
#' 
#' @return a \code{tbl_df} object with columns pkg, version,
#' author, commit, date, node, stage, and result.
#' 
#' @importFrom readr read_lines
#' @importFrom tibble as_tibble
#' @importFrom rvest html_text html_nodes
#' @importFrom xml2 read_html
#' @import rex
#' @importFrom dplyr left_join
#' @importFrom BiocManager version
#' 
#' @examples 
#' 
#' # Set the stage--what version of Bioc am 
#' # I using?
#' BiocManager::version()
#' 
#' latest_build = biocBuildReport()
#' head(latest_build)
#' 
#' @export
biocBuildReport <- function(version=as.character(BiocManager::version())) {
    if(!is.character(version)) {
        stop('version should be a character string representing the Bioconductor version, such as "3.6"')
    }
  url = sprintf('http://bioconductor.org/checkResults/%s/bioc-LATEST/STATUS_DB.txt',version)
  dat = readr::read_lines(url)
  z = re_matches(dat,rex(
    start,
    capture(except_any_of('#'),name='pkg'),
    '#',
    capture(except_any_of('#'),name='node'),
    '#',
    capture(except_any_of(blank,':'),name='stage'),
    ':',blank,
    capture(anything,name='result')
  ))
  
  
  dat = xml2::read_html(sprintf('http://bioconductor.org/checkResults/%s/bioc-LATEST/',version))
  
  pkgnames = html_text(html_nodes(dat,xpath='/html/body/table[@class="mainrep"]/tr/td[@rowspan="3"]'))
  # Note that bioc-3.9 has TWO mac builders, so the number of build rows
  # is "4", not "3". 
  if(length(pkgnames)==0) {
    pkgnames = html_text(html_nodes(dat,xpath='/html/body/table[@class="mainrep"]/tr/td[@rowspan="4"]'))
  }
  
  y = rex::re_matches(pkgnames,
                      rex(
                        start,
                        capture(any_alnums, name='pkg'),
                        maybe(any_blanks),
                        capture(except_any_of(any_alphas),name="version"),
                        maybe(any_blanks),
                        capture(anything,name='author'),
                        "Last",anything,"Commit:",
                        capture(anything,name="commit"),
                        "Last",anything,'Changed',anything,"Date:",any_non_alnums,
                        capture(any_of(list(digit,'-',blank,':')),name='last_changed_date')
                      ))
  y = y[!is.na(y$pkg),]
  
  df = suppressMessages(y %>% left_join(z)) # just suppress "Joining by...."
  df = as_tibble(df)
  df[['bioc_version']]=version
  df[['last_changed_date']] = as.POSIXct(df[['last_changed_date']])
  attr(df,'last_changed_date') = as.POSIXct(df[['last_changed_date']][1])
  attr(df,'class') = c('biocBuildReport',class(df))
  df
}

