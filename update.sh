#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq ripgrep gawk

set -eux

readarray -t RELEASES <<<"$(curl https://api.github.com/repos/openhab/openhab-distro/tags | jq -r '.[].name' | rg '^\d+\.\d+\.\d+*$')"
MOST_RECENT=${RELEASES[0]}

echo -n "$MOST_RECENT" > version
curl -L https://github.com/openhab/openhab-distro/releases/download/"$MOST_RECENT"/openhab-"$MOST_RECENT".tar.gz \
    | sha256sum \
    | cut -d" " -f1 \
    | tr -d '\n' \
    > openhab.sha256

curl -L https://github.com/openhab/openhab-distro/releases/download/"$MOST_RECENT"/openhab-addons-"$MOST_RECENT".kar \
    | sha256sum \
    | cut -d" " -f1 \
    | tr -d '\n' \
    > openhab-addons.sha256

if ! git diff --quiet "version"; then
    if [[ -v GITHUB_OUTPUT ]]; then
        echo "version=$MOST_RECENT" >> $GITHUB_OUTPUT
        echo "changed=true" >> $GITHUB_OUTPUT
    fi
else
    exit 0
fi
