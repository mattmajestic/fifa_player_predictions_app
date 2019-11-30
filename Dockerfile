FROM rocker/r-ver:3.6.1
LABEL maintainer="Matt"
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update \
  && apt-get install -y libcurl4-openssl-dev \
	libssl-dev \
	make \
	zlib1g-dev
RUN ["install2.r", "assertthat", "backports", "colorspace", "crayon", "crosstalk", "curl", "data.table", "desc", "digest", "dplyr", "DT", "formatR", "fs", "futile.logger", "futile.options", "ggplot2", "glue", "gtable", "htmltools", "htmlwidgets", "httpuv", "httr", "jsonlite", "lambda.r", "later", "lazyeval", "magrittr", "mime", "miniUI", "munsell", "pacman", "pillar", "pkgconfig", "plotly", "promises", "purrr", "R6", "Rcpp", "rhandsontable", "rlang", "rprojroot", "rsconnect", "rstudioapi", "scales", "semver", "shiny", "shinydashboard", "shinyFiles", "shinyWidgets", "stevedore", "stringi", "stringr", "tibble", "tidyr", "tidyselect", "versions", "viridisLite", "withr", "xtable", "yaml"]
WORKDIR /payload/
COPY [".RData", ".RData"]
CMD ["R"]
