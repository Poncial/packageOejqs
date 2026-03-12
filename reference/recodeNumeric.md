# Recode des colonnes Likert en numériques et vérifie les correspondances

Cette fonction recode plusieurs colonnes d'un `data.table` contenant des
réponses Likert (ou textuelles) en variables numériques selon un vecteur
de recodage nommé.

## Usage

``` r
recodeNumeric(
  dt,
  colonnesSource,
  recod,
  prefix = "num_",
  verbose = TRUE,
  stopOnIncoherence = FALSE,
  allowOverwrite = FALSE,
  naValues = NULL,
  logFile = NULL
)
```

## Arguments

- dt:

  Un `data.table` modifié par référence.

- colonnesSource:

  Vecteur de caractères indiquant les colonnes à recoder.

- recod:

  Vecteur nommé indiquant le mapping `label -> valeur numérique`.

- prefix:

  Préfixe ajouté aux colonnes recodées.

- verbose:

  Logique. Affiche les audits et résumés.

- stopOnIncoherence:

  Logique. Si `TRUE`, stoppe l'exécution lorsqu'au moins une valeur non
  recodée est détectée.

- allowOverwrite:

  Logique. Autorise l'écrasement de colonnes existantes.

- naValues:

  Valeurs à forcer en `NA` avant recodage.

- logFile:

  Chemin vers un fichier texte de journalisation.

## Value

Une liste invisible contenant :

- createdColumns:

  Colonnes numériques créées.

- audit:

  Liste d'audits par colonne.

- summary:

  Table récapitulative NA source / cible.

- nIncoherences:

  Nombre total de valeurs non recodées.

- logFile:

  Chemin du log si utilisé.

## Details

De nouvelles colonnes sont créées avec un préfixe donné. La fonction
effectue ensuite une vérification globale et détaillée afin d'identifier
les valeurs non recodées, et peut écrire un journal d'exécution.

Toute valeur non présente dans `recod` sera transformée en `NA` dans la
colonne recodée et signalée lors de la vérification.

Le recodage repose sur une conversion préalable en caractères pour
supporter facteurs et chaînes.

## Examples

``` r
library(data.table)

dt <- data.table(
  Q1 = c("Pas du tout", "Plutôt non", "Plutôt oui"),
  Q2 = c("Oui", "Non", "Oui")
)

recod <- c(
  "Pas du tout" = 1,
  "Plutôt non" = 2,
  "Plutôt oui" = 3,
  "Oui" = 1,
  "Non" = 0
)

recodeNumeric(
  dt,
  colonnesSource = c("Q1", "Q2"),
  recod = recod,
  verbose = TRUE
)
#> 2026-03-12 15:23:38 | Début recodage numérique.
#> 2026-03-12 15:23:38 | Colonnes numériques créées :  num_Q1, num_Q2
#> 2026-03-12 15:23:38 | Nombre total de valeurs non recodées :  0
#> Correspondances pour Q1 → num_Q1
#>         Source Destination
#>         <char>       <num>
#> 1: Pas du tout           1
#> 2:  Plutôt non           2
#> 3:  Plutôt oui           3
#> 
#> Correspondances pour Q2 → num_Q2
#>    Source Destination
#>    <char>       <num>
#> 1:    Non           0
#> 2:    Oui           1
#> 
#> Résumé global :
#>    colonneSource colonneNumerique nSourceNA nTargetNA
#>           <char>           <char>     <int>     <int>
#> 1:            Q1           num_Q1         0         0
#> 2:            Q2           num_Q2         0         0
#> 2026-03-12 15:23:38 | Fin du recodage numérique.
```
