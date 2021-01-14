if ! installed brew; then
    return
fi

BREW_PREFIX="/usr/local"
export PATH="$PATH:${BREW_PREFIX}/sbin"

# OpenSSL
OPENSSL_PATH="${BREW_PREFIX}/opt/openssl"
if [[ -d "${OPENSSL_PATH}" ]]; then
    export LDFLAGS="$LDFLAGS -L${OPENSSL_PATH}/lib"
    export CFLAGS="$CFLAGS -I${OPENSSL_PATH}/include"
    export PKG_CONFIG_PATH="${OPENSSL_PATH}/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# Qt
QT_PATH="${BREW_PREFIX}/opt/qt"
if [[ -d "${QT_PATH}" ]]; then
    export CMAKE_PREFIX_PATH="${QT_PATH}:$CMAKE_PREFIX_PATH"
    export PATH="$PATH:${QT_PATH}/bin"
fi
