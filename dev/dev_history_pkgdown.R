# ==============================================================
# dev/dev_history_pkgdown.R
# Script de mise en place et de déploiement pkgdown
# ==============================================================

# -- 1. Initialiser pkgdown (une seule fois) -------------------
usethis::use_pkgdown()

# -- 2. Ajouter les dépendances nécessaires aux vignettes ------
usethis::use_package("knitr",     type = "Suggests")
usethis::use_package("rmarkdown", type = "Suggests")

# -- 3. Prévisualiser le site en local -------------------------
pkgdown::build_site()

# Ou pour ne reconstruire qu'une partie :
pkgdown::build_home()       # page d'accueil (README)
pkgdown::build_reference()  # page des fonctions
pkgdown::build_articles()   # vignettes
pkgdown::build_news()       # NEWS.md

# -- 4. Déployer sur GitHub Pages (automatique via CI) ---------
usethis::use_pkgdown_github_pages()
# Cela :
#   - Crée .github/workflows/pkgdown.yaml
#   - Active GitHub Pages sur la branche gh-pages
#   - Le site se met à jour à chaque push sur main

# -- 5. URL du site après déploiement --------------------------
# https://poncial.github.io/packageOejqs

