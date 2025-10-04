# A very cut down copy fo the Bluefin system.just file
just := just_executable()

[private]
default:
    @{{ just }} -f ./bluefin-system.just --list

# Ptyxis terminal transparency
[group('System')]
ptyxis-transparency opacity="0.95":
    #!/usr/bin/env bash
    set -euxo pipefail
    if [[ -n "$(echo "{{ opacity }}" | grep -v '^[.0-9]*$')" ]]; then
        printf "Value must be numeric: %s.\n" "{{ opacity }}"
    elif [[ $(echo "0<{{ opacity }} && 1>={{ opacity }}" | bc -q) -eq 1 ]]; then
        raw="$(/usr/bin/gsettings get org.gnome.Ptyxis profile-uuids)"
        uuids="$(sed -En 's|[^0-9a-z]*||g; s|([0-9a-z]{32})|\1\n|gp' <<<${raw})"
        for i in ${uuids}; do
            location="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${i}/"
            /usr/bin/gsettings set "${location}" opacity "{{ opacity }}"; done
        printf "Ptyxis opacity is now %s.\n" "{{ opacity }}"
    else
        printf "Value must be greater than 0 and less than or equal to 1: %s.\n" "{{ opacity }}"
    fi


# Install system flatpaks for rebasers
[group('System')]
install-system-flatpaks:
    #!/usr/bin/bash
    flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak --system -y install --or-update flathub \
                                                    com.valvesoftware.Steam \
                                                    com.heroicgameslauncher.hgl \
                                                    com.valvesoftware.Steam.CompatibilityTool.Proton-GE \
                                                    de.leopoldluley.Clapgrep \
                                                    io.podman_desktop.PodmanDesktop \
                                                    com.github.tchx84.Flatseal \
                                                    com.mattjakeman.ExtensionManager \
                                                    com.ranfdev.DistroShelf \
                                                    io.github.flattool.Ignition \
                                                    io.github.flattool.Warehouse \
                                                    org.gnome.FileRoller \
                                                    org.gnome.Firmware \
                                                    org.gnome.Logs \
                                                    org.gnome.Loupe \
                                                    org.gnome.NautilusPreviewer \
                                                    org.gnome.SimpleScan \
                                                    org.gnome.baobab \
                                                    org.gnome.DejaDup \
                                                    org.gimp.GIMP \
                                                    org.darktable.Darktable \
                                                    io.github.shiftey.Desktop \
                                                    io.kinvolk.Headlamp \
                                                    io.github.dvlv.boxbuddyrs \
                                                    fr.handbrake.ghb \
                                                    com.transmissionbt.Transmission \
                                                    com.spotify.Client \
                                                    com.stremio.Stremio \
                                                    com.slack.Slack \
                                                    com.microsoft.Edge \
                                                    com.google.Chrome \
                                                    com.github.unrud.VideoDownloader \
                                                    com.github.johnfactotum.Foliate \
                                                    com.discordapp.Discord \
                                                    org.videolan.VLC \
                                                    org.gnome.Showtime

# alias for install-jetbrains-toolbox
[group('Apps')]
jetbrains-toolbox:
    @ujust install-jetbrains-toolbox

# Install JetBrains Toolbox | https://www.jetbrains.com/toolbox-app/
[group('Apps')]
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    pushd "$(mktemp -d)"
    echo "Get latest JetBrains Toolbox version"
    # Get the json with latest releases
    curl -sSfL -o releases.json "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    # Extract information
    BUILD_VERSION=$(jq -r '.TBA[0].build' ./releases.json)
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' ./releases.json)
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' ./releases.json)
    echo "Installing JetBrains Toolbox ${BUILD_VERSION}"
    curl -sSfL -O "${DOWNLOAD_LINK}"
    curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c
    tar zxf jetbrains-toolbox-"${BUILD_VERSION}".tar.gz
    mkdir -p $HOME/.local/share/JetBrains/ToolboxApp/
    mv jetbrains-toolbox-"${BUILD_VERSION}"/* $HOME/.local/share/JetBrains/ToolboxApp/
    echo "Launching JetBrains Toolbox"
    $HOME/.local/share/JetBrains/ToolboxApp/bin/jetbrains-toolbox

[group('Apps')]
install-oh-my-posh:
    #!/usr/bin/env bash
    # Install Oh My Posh (there is no package for this yet)
    curl -s https://ohmyposh.dev/install.sh | bash -s
