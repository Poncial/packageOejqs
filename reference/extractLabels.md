# Extract variable labels from a data.table

This function retrieves the `"label"` attribute from a set of columns in
a `data.table` and returns them in a two-column `data.table`.

## Usage

``` r
extractLabels(dt, cols)
```

## Arguments

- dt:

  A `data.table` containing labelled variables.

- cols:

  A character vector of column names from which to extract labels.

## Value

A `data.table` with two columns:

- variable:

  Column name.

- label:

  Value of the `"label"` attribute for the column (may be `NULL`).

## Details

The function assumes that labels are stored as attributes named
`"label"` If a column does not have a `"label"` attribute, `NA` is
returned.

## Examples

``` r
library(data.table)

dt <- data.table(
  age = c(20, 30),
  sex = c(1, 2)
)
attr(dt$age, "label") <- "Age of respondent"
attr(dt$sex, "label") <- "Biological sex"

extractLabels(dt, c("age", "sex"))
#>    variable             label
#>      <char>            <char>
#> 1:      age Age of respondent
#> 2:      sex    Biological sex
```
