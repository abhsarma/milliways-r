globalVariables(c(".max", ".min", "cdf.x", "cdf.y", "limits", "universe"))
#' Exporting results from a multiverse analysis to JSON
#'
#' @description Calculates distributional information for parameters of multiverse analysis
#'
#'
#' @name get_ccurve
#' @param x a tidy tibble or data frame which contains summary statistics or distributional information
#' of each regression coefficient parameter
#' @param term column in the data frame, x, which contains the name of the coefficients
#' @param mean column in the data frame, x, which contains the mean estimate for each coefficient
#' @param sd column in the data frame, x, which contains the standard error estimate for each coefficient
#' @param dist column in the data frame, x, which contains vectorised distributions---an object of class
#' `distribution` for each coefficient
#'
#' @return a data frame
#'
#' @examples
#' \donttest{
#' library(dplyr)
#' library(tidyr)
#'
#' M = multiverse()
#'
#' inside(M, {
#'   df = tibble(
#'     x = rnorm(100),
#'     y = x * 0.5 + rnorm(100, 0, 2)
#'  )
#'
#'  # alternatives to remove outlier
#'  df.filtered = df %>%
#'    filter(
#'      branch(outlier_exclusion,
#'         "2SD" ~ abs(y - mean(y)) > 2*sd(y),
#'         "3SD" ~ abs(y - mean(y)) > 3*sd(y)
#'      )
#'  )
#'
#'   fit = lm(y ~ x, data = df)
#'   res = broom::tidy(fit)
#' })
#'
#' execute_multiverse(M)
#'
#' multiverse::expand(M) %>%
#'   extract_variables(res) %>%
#'   unnest(res) %>%
#'   get_dist(term, estimate, std.error)
#' }
#'
#'
#' @importFrom rlang enquo
#' @importFrom rlang quo
#' @importFrom rlang quo_text
#' @importFrom rlang is_missing
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate
#' @importFrom dplyr group_by
#' @importFrom dplyr rename
#' @importFrom readr type_convert
#' @importFrom tidyr unnest_wider
#' @importFrom stats quantile
#' @importFrom distributional cdf
#' @importFrom distributional dist_normal
#' @importFrom purrr map
#' @importFrom purrr map2
#' @importFrom tidyr nest
#' @importFrom tidyselect starts_with
#' 
#' @rdname get_ccurve
#' @export
get_ccurve = function(x, term, mean, sd, dist, n = 100) {
  term = enquo(term)
  
  if (missing(dist) & (!missing(mean) & !missing(sd))){
    # we have estimate and std.error
    .mu = enquo(mean)
    .sd = enquo(sd)
    dist = quo(dist)
    
    # change to distributional vectors
    .res_df = mutate(x, dist = dist_normal(!!.mu, !!.sd))
    
  } else if (!missing(dist) & missing(mean) & missing(sd)) {
    # we have a distributional object
    dist = enquo(dist)
    
    .res_df = x
    
  } else {
    stop("No complete and/or distinct argument set provided")
  }
  
  get_dist_ccurve(.res_df, !!term, !!dist, n)
}

#' @rdname get_ccurve
#' @export
get_dist_ccurve = function(x, term, dist, n = 100) {
  dist = enquo(dist)
  term = enquo(term)
  
  x = rename(select(
    rename(x, universe = .universe), 
    -starts_with(".")
  ), .universe = universe)
  
  .res_df = mutate(group_by(x, !!term), limits = map(!!dist, get_limits))
  .res_df = mutate(unnest_wider(.res_df, limits), .min = min(.min), .max = max(.max))
  
  select(
      mutate(.res_df,
             cdf.x = map2(.min, .max, ~ seq(.x, .y, length.out = n)),
             cdf.y = map2(!!dist, cdf.x, ~ unlist(cdf(.x, .y)))
      ),
      - !!dist, -.min, -.max
    )
}

#' @rdname get_ccurve
#' @export
append_point_estimate = function(.append_to, x, .term) {
  .term = enquo(.term)
  
  x = x |> 
    rename(universe = .universe) |> 
    select(-starts_with(".")) |> 
    rename(.universe = universe) |> 
    mutate(term = quo_text(.term), std.error = NULL, cdf.x = NULL, cdf.y = NULL) |> 
    rename(estimate = !!.term) |> 
    mutate(std.error = 0, cdf.x = map(estimate, c), cdf.y = list(0.5))
  
  rbind(.append_to, x)
}