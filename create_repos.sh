#!/bin/bash

echo "Name:"
read NAME

echo "Email:"
read EMAIL

KEYID=$(cat <<EOF |
    %no-ask-passphrase
    %no-protection
    Key-Type: RSA
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Length: 4096
    Name-Real: ${NAME}
    Name-Email: ${EMAIL}
    Expire-Date: 0
EOF
    gpg --batch --gen-key 2>&1 | grep "gpg: key" | awk '{print substr($3, length($3) - 7, 8)}')

gpg --armor --export ${KEYID} > public.key
gpg --armor --export-secret-key ${KEYID} > private.key

echo "Origin:"
read ORIGIN

echo "Label:"
read LABEL

echo "Description:"
read DESCRIPTION

while : ; do
    echo "OS:"
    read OS

    if [ -z "${OS}" ]; then
        break
    fi

    echo "Dist:"
    read DIST

    echo "Architectures:"
    read ARCH

    mkdir -p apt/${OS}/${DIST}/conf

cat <<EOF > apt/${OS}/${DIST}/conf/distributions
Origin: ${ORIGIN}
Label: ${LABEL}
Codename: ${DIST}
Architectures: ${ARCH}
Components: main
Description: ${DESCRIPTION}
SignWith: ${KEYID}
EOF

done
