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

echo "ERICKo"
cd $(git rev-parse --show-toplevel)
echo "ERICKA"
gazelle_diff=$(bazel run //:gazelle -- fix -mode=diff || true)
echo "ERICKB"
kazel_diff=$(bazel run //:kazel -- -dry-run -print-diff -cfg-path=./.kazelcfg.json || true)

echo "ERICKC"
if [[ -n "${gazelle_diff}" || -n "${kazel_diff}" ]]; then
  echo "ERICKD"
  echo "${gazelle_diff}"
  echo "ERICKE"
  echo "${kazel_diff}"
  echo "ERICKF"
  echo
  echo "Run ./verify/update-bazel.sh"
  exit 1
fi
echo "ERICKg"
