#!/usr/bin/env bash

set -exuo pipefail

PACKER_VERSION="$1"

ARCH="linux_amd64"

URL_BASE="https://releases.hashicorp.com/packer"
VERSION_BASE="${URL_BASE}/${PACKER_VERSION}/terraform_${PACKER_VERSION}"
SHA_URL="${VERSION_BASE}_SHA256SUMS"
SIG_URL="${SHA_URL}.sig"
ZIP_URL="${VERSION_BASE}_${ARCH}.zip"

TMP_DIR="$(mktemp -d)"
SHA_PATH="${TMP_DIR}/checksums"
SIG_PATH="${SHA_PATH}.sig"
ZIP_FILE="packer_${PACKER_VERSION}_${ARCH}.zip"
ZIP_PATH="${TMP_DIR}/${ZIP_FILE}"

curl -sLo "${SHA_PATH}" "${SHA_URL}"
curl -sLo "${SIG_PATH}" "${SIG_URL}"
curl -sLo "${ZIP_PATH}" "${ZIP_URL}"

rm -rf ~/.gnupg
gpg --import scripts/hashicorp.asc
gpg --verify "${SIG_PATH}" "${SHA_PATH}"
grep "${ZIP_FILE}" "${SHA_PATH}" > "${SHA_PATH}.version"
pushd "$TMP_DIR"
shasum -a 256 -c "${SHA_PATH}.version"
popd

mkdir -p "${PACKERBIN_DIR}"
unzip -d "${PACKERBIN_DIR}" "${ZIP_PATH}"

