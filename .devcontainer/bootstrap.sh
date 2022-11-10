#!/bin/sh

set -e

VARIANT="$1"
VERSION="$2"

if [ -z "${VERSION}" -o "${VERSION}" = "latest" ]
then
    echo "Determining latest release version of hugo"
    VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}')
fi
echo "Hugo version: ${VERSION}"

case "$(uname -m)" in
    aarch64)
        ARCH=arm64
        ;;
    *)
        ARCH=amd64
        ;;
esac

if [ -z "$ARCH" ]
then
    echo "ARCH is empty"
    exit 1
fi

echo "ARCH: ${ARCH}"

BINARY="hugo"
ARCHIVE="${VERSION}.tar.gz"
DST=/usr/bin/

URL="https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${VARIANT}_${VERSION}_Linux-${ARCH}.tar.gz"

echo "Fetching hugo release from $URL"
curl -s -L -o "$ARCHIVE" "$URL"

echo "Unpacking $ARCHIVE"
tar -xzf $ARCHIVE $BINARY

echo "Installing $BINARY binary to $DST"
mv $BINARY ${DST}/$BINARY