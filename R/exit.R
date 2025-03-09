#' Exit the multiverse visualisation tool
#'
#' Exits the local node server that was initialised using the \code{start} for the multiverse visualisation.
#'
#' @name exit
#' @export
exit = function() {
  # .pid = system("ps -ef | grep sirv | awk '{print $2}'", intern = TRUE)
  # # if .pids are active --> kill
  # for (i in .pid) {
  #   .is_running = suppressWarnings(system(paste0("ps -o pid= ", i), intern = TRUE)) # will return the pid if TRUE
  #   if (isTRUE(.is_running == i)) {
  #     system(paste("kill", i))
  #   }
  # }
  invisible(system("killall -9 node", ignore.stdout = TRUE, ignore.stderr = TRUE))
}
