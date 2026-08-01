#!/usr/bin/env bash
# The audit gate travels with the plugin, because in a takeover the target repo cannot
# already carry a preflight — the constrained party would have to install its own constraint.
exec python3 "$(cd "$(dirname "$0")" && pwd)/audit-gate.py"
