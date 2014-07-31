find_package (PkgConfig)

# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED
    gtk+-3.0>=3.12
    switchboard-2.0
    granite
)

add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.22.0" MINIMUM)

include (ValaPrecompile)
# Add all your vala files and requires packages to the List below to include them in the build
vala_precompile (VALA_C ${PLUGNAME}
    Plug.vala

    Defaults/DefaultPlug.vala
    Defaults/Utils.vala

    Startup/Startup.vala
    Startup/Utils.vala
    Startup/Controller.vala

    Startup/Backend/KeyFile.vala
    Startup/Backend/KeyFileFactory.vala
    Startup/Backend/DesktopFileEnumerator.vala
    Startup/Backend/Monitor.vala

    Startup/Widgets/List.vala
    Startup/Widgets/Scrolled.vala
    Startup/Widgets/AppRow.vala

    Startup/Dialogs/AppChooser.vala

    Startup/Entities/AppInfo.vala
    
    ${CMAKE_CURRENT_BINARY_DIR}/config.vala
PACKAGES
    switchboard-2.0
    granite
OPTIONS
    --target-glib=2.32
)

add_library (${PLUGNAME} MODULE ${VALA_C})
target_link_libraries (${PLUGNAME} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${PLUGNAME} DESTINATION ${PKGDATADIR})