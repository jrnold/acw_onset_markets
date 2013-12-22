# -- BEGIN PACKRAT --
# Use private package library
local({
  # Create the private package library if it doesn't already exist
  appRoot <- normalizePath('.', winslash='/')
  libRoot <- file.path(appRoot, 'library')
  localLib <- file.path(libRoot, R.version$platform, getRversion())
  newLocalLib <- FALSE
  if (!file.exists(localLib)) {
    message("Creating private package library at ", localLib)
    dir.create(localLib, recursive=TRUE)
    newLocalLib <- TRUE
  }

  # If there's a new library (created to make changes to packages loaded in the
  # last R session), remove the old library and replace it with the new one. 
  newLibRoot <- file.path(appRoot, 'library.new', 'library')
  if (file.exists(newLibRoot)) {
    message("Applying Packrat library updates ... ", appendLF = FALSE)
    succeeded <- FALSE
    if (file.rename(libRoot, file.path(appRoot, 'library.old'))) {
      if (file.rename(newLibRoot, libRoot)) {
        succeeded <- TRUE
      } else {
        # Moved the old library out of the way but couldn't move the new 
        # in its place; move the old library back 
        file.rename(file.path(appRoot, 'library.old'), libRoot)
      }
    }
    if (succeeded) {
      message("OK")
    } else {
      message("FAILED")
      cat("Packrat was not able to make changes to its local library at\n", 
          localLib, ". Check this directory's permissions and run\n",
          "packrat::restore() to try again.\n", sep = "")
    }
  }
  
  # If the new library temporary folder exists, remove it now so we don't
  # attempt to reapply the same failed changes 
  if (file.exists(file.path(appRoot, 'library.new'))) {
    unlink(file.path(appRoot, 'library.new'), recursive = TRUE)
  }
  if (file.exists(file.path(appRoot, 'library.old'))) {
    unlink(file.path(appRoot, 'library.old'), recursive = TRUE)
  }
  
  .libPaths(localLib)

  # If the local library is empty, offer to bootstrap it. 
  if (length(list.files(localLib)) == 0) {
    packratBootstrap <- new.env(parent=emptyenv())
    assign("initPackrat", function() {
      message("Initializing packrat... ", appendLF = FALSE)
      pkgPath <- file.path(appRoot, "packrat.sources", "packrat")
      srcPkg <- file.path(pkgPath, list.files(pkgPath)[1])
      utils::install.packages(srcPkg, type = "source", repos = NULL, 
                              verbose = FALSE, dependencies = FALSE, 
                              quiet = TRUE)
      message("OK", appendLF = TRUE)
      packrat:::annotatePkgs("packrat", appRoot)
      packrat::restore(appRoot)
      detach("packratBootstrap")
    }, envir = packratBootstrap)
    attach(packratBootstrap)
     
    cat("\n--\n",
        "This project uses Packrat, a tool for managing package dependencies.\n", 
        "Run initPackrat() to install the packages this project needs.\n",
        sep = "")
  }

  # Remind the user to snapshot after making changes to the package library.
  addTaskCallback(function(expr, result, ok, printed) {
    if (length(expr) > 0 && 
        is(expr[[1]], "language")) {
      name <- deparse(expr[[1]])
      if (identical(name, "install.packages") || 
          identical(name, "remove.packages") ||
          identical(name, "update.packages")) {
        cat("Changes made to this project's private library may need to be\n",
            "snapshotted. Run packrat::status() to see differences since\n",
            "the last snapshot.\n", 
            sep = "")
      }
    }
    return(TRUE)
  }) 
  
  invisible()
})
# -- END PACKRAT --
source("R/project.R")
