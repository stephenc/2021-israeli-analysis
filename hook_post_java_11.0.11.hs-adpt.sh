#!/bin/bash
#Post Hook: linux-java-tarball
function __sdkman_post_installation_hook {
    __sdkman_echo_debug "A Linux post-install hook was found for Java 11.0.11.hs-adpt."

    __sdkman_validate_binary_input "$binary_input" || return 1

    local present_dir="$(pwd)"
    local work_dir="${SDKMAN_DIR}/tmp/out"

    echo ""
    echo "Repackaging Java 11.0.11.hs-adpt..."

    mkdir -p "$work_dir"
    /usr/bin/env tar zxf "$binary_input" -C "$work_dir"

    cd "$work_dir"
    /usr/bin/env zip -qyr "$zip_output" .
    cd "$present_dir"

    echo ""
    echo "Done repackaging..."

    __sdkman_echo_debug "Cleaning up residual files..."
    rm -f "$binary_input"
    rm -rf "$work_dir"
}

function __sdkman_validate_binary_input {
    if ! tar tzf "$1" &> /dev/null; then
        echo "Download has failed, aborting!"
        echo ""
        echo "Can not install java 11.0.11.hs-adpt at this time..."
        return 1
    fi
}
