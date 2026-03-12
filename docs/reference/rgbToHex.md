# Convertit des valeurs RVB en code couleur hexadécimal

Convertit trois composantes rouge, vert, bleu (entiers de 0 à 255) en
code couleur hexadécimal au format `"#RRGGBB"`, utilisable directement
dans les fonctions graphiques R.

## Usage

``` r
rgbToHex(r, g, b)
```

## Arguments

- r:

  Entier entre 0 et 255. Intensité de la composante rouge.

- g:

  Entier entre 0 et 255. Intensité de la composante verte.

- b:

  Entier entre 0 et 255. Intensité de la composante bleue.

## Value

Un vecteur caractère de longueur 1 contenant le code hexadécimal au
format `"#RRGGBB"`.

## Examples

``` r
# Rouge pur
rgbToHex(255, 0, 0) # "#FF0000"
#> [1] "#FF0000"

# Blanc
rgbToHex(255, 255, 255) # "#FFFFFF"
#> [1] "#FFFFFF"

# Noir
rgbToHex(0, 0, 0) # "#000000"
#> [1] "#000000"

# Orange (couleur issue de la palette maison)
rgbToHex(243, 146, 0) # "#F39200"
#> [1] "#F39200"
```
