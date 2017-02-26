get_ok_response <- function(urls) {
  for (url in urls) {
    resp <- httr::GET(url)
    if (resp$status_code == 200) break
  }
  if (resp$status_code == 500) {
    stop("No text available")
  }
  resp
}
