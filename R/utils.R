#' @importFrom attempt warn_if
#' @importFrom attempt message_if

node_available <- function(){
  test <- suppressWarnings(
    system(
      "npm -v",
      ignore.stdout = TRUE,
      ignore.stderr = TRUE
    )
  )
  warn_if(
    test,
    ~ .x != 0,
    "Error launching npm"
  )
  message_if(
    test,
    ~ .x != 0,
    "Error launching Node"
  )
  
  if (!test) TRUE else FALSE
}
