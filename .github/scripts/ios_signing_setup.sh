#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${BUILD_CERTIFICATE_BASE64:-}" || -z "${P12_PASSWORD:-}" || -z "${BUILD_PROVISION_PROFILE_BASE64:-}" || -z "${KEYCHAIN_PASSWORD:-}" ]]; then
  echo "Missing one or more signing environment variables."
  exit 1
fi

CERTIFICATE_PATH="${RUNNER_TEMP}/build_certificate.p12"
PP_PATH="${RUNNER_TEMP}/build_pp.mobileprovision"
KEYCHAIN_PATH="${RUNNER_TEMP}/app-signing.keychain-db"

decode_base64() {
  if base64 --help 2>&1 | grep -q -- '--decode'; then
    base64 --decode
  else
    base64 -D
  fi
}

echo -n "${BUILD_CERTIFICATE_BASE64}" | decode_base64 > "${CERTIFICATE_PATH}"
echo -n "${BUILD_PROVISION_PROFILE_BASE64}" | decode_base64 > "${PP_PATH}"

security create-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"
security set-keychain-settings -lut 21600 "${KEYCHAIN_PATH}"
security unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"

security import "${CERTIFICATE_PATH}" -P "${P12_PASSWORD}" -A -t cert -f pkcs12 -k "${KEYCHAIN_PATH}"
security list-keychain -d user -s "${KEYCHAIN_PATH}"
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"

mkdir -p "${HOME}/Library/MobileDevice/Provisioning Profiles"
cp "${PP_PATH}" "${HOME}/Library/MobileDevice/Provisioning Profiles"
