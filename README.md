# Switchboard Applications Plug

## Building and Installation

You'll need the following dependencies:

* libswitchboard-2.0-dev
* libgranite-dev
* libgtk-3-dev
* meson
* valac

It's recommended to create a clean build environment

    mkdir build
    cd build/
    
Run `cmake` to configure the build environment and then `make all test` to build and run automated tests

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    
To install, use `make install`, then execute with `switchboard`

    sudo make install
    switchboard
