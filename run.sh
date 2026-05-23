#!/usr/bin/env bash
set -euo pipefail

nix run .#llama-server-cuda -- \
  -hf unsloth/Qwen3.6-27B-GGUF \
  --no-mmproj-offload \
  --host 0.0.0.0 \
  --port 8080 \
  --jinja \
  -fa on \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min_p 0.0 \
  --presence-penalty 1.5 \
  --repeat-penalty 1.0 \
  --cache-ram 0 \
  --fit on \
  -np 2 \
  --fit-ctx 32000 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --cache-type-k-draft q8_0 \
  --cache-type-v-draft q8_0 \
  --log-verbosity 4 \
  --chat-template-kwargs '{"preserve_thinking": true}' \
  --spec-draft-n-max 2 \
  --ctx-size 262144
