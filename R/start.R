#' Start multiverse visualisation
#'
#' Initiates a local server using `npm` for the multiverse visualisation. The visualisation can be accessed
#' at `https://localhost:3000`
#' 
#' 
#' @param results path to a JSON file which contains the estimates from each universe in the multiverse analysis.
#' This could be the output of \code{export_data_json()} or \code{export_data__dist_json()}
#' 
#' @param code path to a JSON file which contains the code used to generate the multiverse object. 
#' This could be the output of \code{export_code_json()}
#' 
#' @param data path to a JSON file which contains the dataset used in the multiverse analysis.
#' 
#' @param analysis path to the Explorable Multiverse Analysis Report (EMAR) HTML file. This is usually the result of 
#' knitting the RMarkdown document as \code{knit_as_emar()}.
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
#' 
#' @name start
#' @export
start = function (results, code, data, analysis) {
  milliways_exists = run("npm", "list", wd = system.file("milliways", package = "milliways"), error_on_status = FALSE)
  
  if ((!isTRUE(grep("milliways", milliways_exists$stdout) > 0)) | milliways_exists$status ) {
    cli_text(col_red("Milliways is missing"))
    cli_text(col_red("please install Milliways using `milliways_install()`"))
  } else {
    .spin_load <- make_spinner("dots", template = col_green("preparing Milliways {spin}"))
  
    # copy the data, code and analysis files
    if (file.exists(data)) { # check if valid file exists at <data>
      cli_text(col_green('Loading results from "', results, '"'))
    } else {
      # cli_text(col_red(style_bold('ERROR: file "', data, '" does not exist at the specified location')))
      stop('ERROR: file "', results, '" does not exist at the specified location')
    }

    if (file.exists(code)){ # check if valid file exists at <data>
      cli_text(col_green('Loading code from "', code, '"'))
    } else {
      # cli_text(col_red(style_bold('ERROR: file "', code, '" does not exist at the specified location')))
      stop('ERROR: file "', code, '" does not exist at the specified location')
    }

    if (file.exists(analysis)){ # check if valid file exists at <data>
      cli_text(col_green('Loading knit analysis HTML document from "', analysis, '"'))
    } else {
      # cli_text(col_red(style_bold('ERROR: file "', analysis, '" does not exist at the specified location')))
      stop('ERROR: file "', analysis, '" does not exist at the specified location')
    }

    run(
      command = 'cp',
      args = c(results, paste0(find.package("milliways"), '/milliways/static/data/data.json'))
    )
    run(
      command = 'cp',
      args = c(code, paste0(find.package("milliways"), '/milliways/static/data/code.json'))
    )
    run(
      command = 'cp',
      args = c(data, paste0(find.package("milliways"), '/milliways/static/data/raw-data.json'))
    )
    run(
      command = 'cp',
      args = c(analysis, paste0(find.package("milliways"), '/milliways/public/analysis-doc.html'))
    )
  
    p = process$new(
      command = "npm",
      args = c("run", "build"),
      wd = system.file("milliways", package = "milliways")
    )
  
    while(p$is_alive()) {
      .spin_load$spin()
      Sys.sleep(.05)
    }
    cli_end()
  
    # clear the spinner from the status bar
    .spin_load$finish()
  
    cli_text(style_bold(col_green("{.text successfully built Milliways}")))
  
    process$new(
      command = "npm",
      args = c("run", "start", "&", "sleep", "3"),
      wd = system.file("milliways", package = "milliways")
    )
    
    cli_text(
      style_bold(
        col_green(
          "{.text Initialised Milliways at {.url http://localhost:3000}} (Type exit() to quit Milliways) "
        )
      )
    )
  }
}


