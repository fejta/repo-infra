#!/usr/bin/env bash
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

if [[ -n "${TEST_WORKSPACE:-}" ]]; then # Running inside bazel
  echo "Validating bazel rules..." >&2
elif ! command -v bazel &> /dev/null; then
  echo "Install bazel at https://bazel.build" >&2
  exit 1
else
  (
    set -o xtrace
    bazel test --test_output=streamed //hack:verify-bazel
  )
  exit 0
fi

gazelle=$1
kazel=$2

export GO111MODULE=on
export GOPROXY=https://proxy.golang.org
export GOSUMDB=sum.golang.org
gazelle_diff=$("$gazelle" fix --mode=diff --external=external || true)
kazel_diff=$("$kazel" --dry-run --print-diff --cfg-path=./hack/.kazelcfg.json 2>&1 || true)

if [[ -n "${gazelle_diff}${kazel_diff}" ]]; then
  echo "Current rules (-) do not match expected (+):" >&2
  echo "gazelle diff:"
  echo "${gazelle_diff}"
  echo "kazel diff:"
  echo "${kazel_diff}"
  echo
  echo "ERROR: bazel rules out of date. Fix with bazel run @io_k8s_repo_infra//hack:update-bazel" >&2
  exit 1
fi
