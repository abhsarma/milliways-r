#' @importFrom processx run
#' @importFrom processx process
#' @importFrom cli make_spinner
#' @importFrom cli cli_text
#' @importFrom cli style_bold
#' @importFrom cli make_ansi_style

compile = function () {
  text_default = make_ansi_style("#25BC24")
  text_red = make_ansi_style("#FA5263")

  if (Sys.which("monolith") == "") {
    cli_text(style_bold(text_red("monolith is not installed")))
    cli_text(style_bold(text_red("monolith is required to compile MVis")))
    cli_text("please install monolith: {.url https://github.com/Y2Z/monolith}")
  } else {

    system2(command = "npm", args = c("--prefix", "./node_modules/multiverse-vis/", "run", "start", "&", "sleep", "3"))
    cli_text("finished loading...compiling into static HTML file")
    system2("monolith", "http://localhost:3000/index.html", "./template.html")
    system2("killall", c("-9", "node"))
    cli_text("process complete")
  }
}

