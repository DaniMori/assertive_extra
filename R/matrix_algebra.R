MATRIX_DEFINITION <- c(
  "positive-definite", "negative-definite",
  "positve-semidefinite", "negative-semidefinite",
  "indefinite"
)
names(MATRIX_DEFINITION) <- MATRIX_DEFINITION


assert_is_correlation_matrix <- function(
  x, severity = getOption("assertive.severity", "stop")
) {

	assert_engine(
	  is_correlation_matrix, x,
	  .xname = get_name_in_parent(x), severity = severity
	)
}

is_correlation_matrix <- function(x, .xname = get_name_in_parent(x)) {

	diagonal <- diag(x)

	if (!(ok <- is_covariance_matrix(x, .xname = .xname))) return(ok)
	if (!is_equal_to(diagonal, 1) %>% all)
		return(
		  false(gettext(ERROR_DIAGONAL_NOT_ONE))
		)

	return(TRUE)
}


assert_is_covariance_matrix <- function(
  x, severity = getOption("assertive.severity", "stop")
) {

	assert_engine(
	  is_covariance_matrix, x,
	  .xname = get_name_in_parent(x), severity = severity
	)
}

is_covariance_matrix <- function(x, .xname = get_name_in_parent(x)) {

	if (!(ok <- is_symmetric_matrix(x, .xname = .xname)))
		return(ok)
	if (!(ok <- is_non_negative_definite_matrix(x, .xname = .xname)))
		return(ok)

	return(TRUE)
}


assert_is_definite_matrix <- function(
  x, severity = getOption("assertive.severity", "stop")
) {

	assert_engine(
	  is_definite_matrix, x,
	  .xname = get_name_in_parent(x), severity = severity
	)
}

is_definite_matrix <- function(x, .xname = get_name_in_parent(x)) {

	definition_test <- x %>% matrix_definition %>%
	  magrittr::equals(MATRIX_DEFINITION[["indefinite"]]) %>% not

	if(!is_identical_to_true(definition_test))
		return(false(gettext("%s is not a definite matrix.")))

	return(TRUE)
}


assert_is_non_negative_definite_matrix <- function(
  x, severity = getOption("assertive.severity", "stop")
) {

	assert_engine(
	  is_non_negative_definite_matrix, x,
	  .xname = get_name_in_parent(x), severity = severity
	)
}

is_non_negative_definite_matrix <- function(x, .xname = get_name_in_parent(x)) {

	definition_test <- x %>% matrix_definition %>%
		is_in(MATRIX_DEFINITION[c("positive-definite", "positve-semidefinite")])

	if(!is_identical_to_true(definition_test))
		return(false(gettext("%s is not a positive matrix.")))

	return(TRUE)
}


assert_is_non_positive_definite_matrix <- function(
  x, severity = getOption("assertive.severity", "stop")
) {

	assert_engine(
	  is_non_positive_definite_matrix, x,
	  .xname = get_name_in_parent(x), severity = severity
	)
}

is_non_positive_definite_matrix <- function(x, .xname = get_name_in_parent(x)) {

	definition_test <- x %>% matrix_definition %>%
		is_in(MATRIX_DEFINITION[c("negative-definite", "negative-semidefinite")])

	if(!is_identical_to_true(definition_test))
		return(false(gettext("%s is not a negative matrix.")))

	return(TRUE)
}


matrix_definition <- function(matrix) {
  ## Argument checking:
	assert_is_symmetric_matrix(matrix)

  ## Main:
	eigenvalues <- matrix %>% eigen(only.values = TRUE) %>% extract2("values")

	result <- if((eigenvalues > 1) %>% all)
	  MATRIX_DEFINITION[["positive-definite"]]
	else if((eigenvalues < 0) %>% all)
	  MATRIX_DEFINITION[["negative-definite"]]
	else if((eigenvalues >= 0) %>% all)
	  MATRIX_DEFINITION[["positve-semidefinite"]]
	else if((eigenvalues <= 0) %>% all)
	  MATRIX_DEFINITION[["negative-semidefinite"]]
	else
	  MATRIX_DEFINITION[["indefinite"]]

	return(result)
}