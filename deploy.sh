#!/usr/bin/env bash

set +o nounset
set +o pipefail

: ${ONIER_FLAKE_PATH:="github:kinday/onier"}
: ${ONIER_NIXOS_CONFIG:="nixos"}
: ${ONIER_SSH_HOSTNAME:=}
: ${ONIER_SSH_USERNAME:="root"}

while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--config)
      ONIER_NIXOS_CONFIG="$2"
      shift # past argument
      shift # past value
      ;;
    -f|--force)
      echo "WARN: Running without confirmation"
      ONIER_FORCE_RUN="true"
      shift # past argument
      ;;
    -h|--hostname)
      ONIER_SSH_HOSTNAME="$2"
      shift # past argument
      shift # past value
      ;;
    -l|--local)
      ONIER_FLAKE_PATH="."
      shift # past argument
      ;;
    *|-*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

if [[ -z "${ONIER_SSH_HOSTNAME}" ]]; then
  echo "ERROR: No target machine hostname was given"
  echo "To provide hostname either:"
  echo "  - set ONIER_SSH_HOSTNAME environment variable; or"
  echo "  - use -h (--hostname) CLI flag to provide a value."
  exit 1
fi

ONIER_FLAKE="${ONIER_FLAKE_PATH}#${ONIER_NIXOS_CONFIG}"

if [[ -z "${ONIER_FORCE_RUN}" ]]; then
  echo "Ready to apply flake '${ONIER_FLAKE}' to host at '${ONIER_SSH_HOSTNAME}' as '${ONIER_SSH_USERNAME}'"
  read -p "Continue? (y/N) " CONFIRMATION
  case "$CONFIRMATION" in
    y|Y)
      echo "Running..."
      ;;
    *)
      echo "Execution cancelled by user"
      exit 1
      ;;
  esac
fi

nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  --flake "${ONIER_FLAKE}" \
  --target-host "${ONIER_SSH_USERNAME}@${ONIER_SSH_HOSTNAME}"

