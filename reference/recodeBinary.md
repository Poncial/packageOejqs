# Recode des colonnes Qualtrics en binaire et vérifie la cohérence

Cette fonction recode, par référence, plusieurs colonnes d'un
`data.table` issues de Qualtrics en variables binaires indiquant la
présence (1) ou l'absence (0) de valeur.

## Usage

``` r
recodeBinary(
  dt,
  colonnesSource,
  prefix = "bin_",
  verbose = TRUE,
  stopOnIncoherence = FALSE,
  allowOverwrite = FALSE,
  naValues = NULL,
  logFile = NULL
)
```

## Arguments

- dt:

  Un `data.table`. Il est modifié par référence.

- colonnesSource:

  Un vecteur de caractères contenant les noms des colonnes à recoder.

- prefix:

  Chaîne de caractères ajoutée devant les noms des colonnes sources pour
  créer les colonnes binaires. Par défaut `"bin_"`.

- verbose:

  Logique. Si `TRUE` (défaut), affiche les correspondances et le résumé
  final dans la console.

- stopOnIncoherence:

  Logique. Si `TRUE`, la fonction interrompt l'exécution lorsqu'au moins
  une incohérence est détectée.

- allowOverwrite:

  Logique. Si `FALSE` (défaut), la fonction s'arrête si une colonne
  cible existe déjà.

- naValues:

  Vecteur de valeurs à considérer comme manquantes et à convertir en
  `NA` avant recodage (par exemple `""`, `"-99"`, `999`).

- logFile:

  Chemin vers un fichier texte dans lequel les messages d'exécution
  seront écrits. Si `NULL` (défaut), aucun fichier n'est créé.

## Value

Une liste invisible contenant :

- createdColumns:

  Noms des colonnes binaires créées.

- audit:

  Liste d'audits par colonne avec correspondances et incohérences.

- summary:

  `data.table` récapitulatif des comptes NA / 0 / 1.

- nIncoherences:

  Nombre total d'incohérences détectées.

- logFile:

  Chemin du fichier de log utilisé, le cas échéant.

## Details

Le recodage suit la règle :

- valeur non manquante (`!is.na()`) → 1

- valeur manquante (`NA`) → 0

Avant le recodage, certaines valeurs peuvent être forcées en `NA` via
l'argument `naValues`. La fonction réalise ensuite une vérification
globale et détaillée colonne par colonne, et peut écrire un journal
d'exécution dans un fichier externe.

Le recodage repose uniquement sur la détection des valeurs manquantes.
Toute valeur non `NA` (y compris 0, chaînes vides si non listées dans
`naValues`, ou codes textuels) sera transformée en 1.

Les colonnes binaires sont ajoutées directement à `dt`.

La vérification comprend :

- un test global vectorisé sur l'ensemble des lignes ;

- des tables de correspondance Source/Destination uniques ;

- un résumé quantitatif final.

## Examples

``` r
library(data.table)

dt <- data.table(
  Q1 = c(NA, "A", "B", ""),
  Q2 = c(1, NA, 0, -99)
)

recodeBinary(
  dt,
  colonnesSource = c("Q1", "Q2"),
  naValues = c("", -99),
  verbose = TRUE
)
#> 2026-03-12 16:06:35 | Début du recodage binaire.
#> 2026-03-12 16:06:35 | Forçage en NA des valeurs suivantes :  , -99
#> 2026-03-12 16:06:35 | Colonnes binaires créées :  bin_Q1, bin_Q2
#> 2026-03-12 16:06:35 | Nombre total d'incohérences détectées :  0
#> Correspondances pour Q1 → bin_Q1
#>    Source Destination
#>    <char>       <int>
#> 1:   <NA>           0
#> 2:      A           1
#> 3:      B           1
#> 
#> Correspondances pour Q2 → bin_Q2
#>    Source Destination
#>     <num>       <int>
#> 1:     NA           0
#> 2:      0           1
#> 3:      1           1
#> 
#> Résumé global :
#>    colonneSource colonneBinaire   nNA  nOne nZero
#>           <char>         <char> <int> <int> <int>
#> 1:            Q1         bin_Q1     2     2     2
#> 2:            Q2         bin_Q2     2     2     2
#> 2026-03-12 16:06:35 | Fin du traitement.
```
