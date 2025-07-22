detachAllPackages <- function() {

    basic_packages <- c('stats', 'graphics', 'grDevices', 'utils',
                        'datasets', 'methods', 'base')
    attached_packages <- search()[grepl('package:', search())]
    detach_packages <- setdiff(attached_packages, paste0('package:', basic_packages))

    if (length(detach_packages) > 0) {
        for (package in detach_packages) detach(package, character.only = T)
    }
}

detachAllPackages()
rm(list = ls())

