#' Install multiverse visualisation tool
#'
#' Install the multiverse visualisation tool using npm in the R system directory for mvis
#' 
#' @param force install multiverse visualisation tool using npm without user prompt
#' 
#' @importFrom processx run
#' @importFrom processx process
#' @importFrom cli make_spinner
#' @importFrom cli cli_text
#' @importFrom cli style_bold
#' @importFrom cli make_ansi_style
#' @importFrom cli col_red
#' @importFrom cli col_green
#' @importFrom cli cli_end
#' @importFrom yesno yesno2
#'
#' @name install
#' @export
milliways_install = function(force = FALSE) {
  if (!node_available()) {
    cli_text(col_red("Node is required to open mvis but is not installed. Please install the current version of node from {.url https://nodejs.org/en/}"))
  } else {
    # mvis is not installed
    ok <- yesno2("This will install our app on your local library. Are you ok with that? ")
    
    if (ok) {
      .spin_install <- make_spinner("dots", template = col_red("installing Milliways {spin}"))
      
      p = process$new(
        command = "npm", 
        args = c("install"),
        wd = system.file("milliways", package = "milliways")
      )
  
      while(p$is_alive()) {
        .spin_install$spin()
        Sys.sleep(.05)
      }
      
      cli_end()
      # clear the spinner from the status bar
      .spin_install$finish()
      cli_text(col_green("successfully installed Milliways"))
    }
  }
}
