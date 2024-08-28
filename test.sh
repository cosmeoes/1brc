#!/bin/bash
#
#  Copyright 2023 The original authors
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

set -euo pipefail

DEFAULT_INPUT="testfiles/*.txt"
POSTFIX=${1:-""}
INPUT=${2:-$DEFAULT_INPUT}

if [ "$#" -eq 0 ] || [ "$#" -gt 2 ] || [ "$POSTFIX" = "-h" ]; then
  echo "Usage: ./test.sh <your name> [input file pattern]"
  echo
  echo "For each test sample matching <input file pattern> (default '$DEFAULT_INPUT')"
  echo "runs <fork name> implementation and diffs the result with the expected output."
  echo "Note that optional <input file pattern> should be quoted if contains wild cards."
  echo
  echo "Examples:"
  echo "./test.sh baseline"
  echo "./test.sh baseline testfiles/measurements-1.txt"
  echo "./test.sh baseline 'testfiles/measurements-*.txt'"
  exit 1
fi

if [ ! -x ./calculate_average_$POSTFIX.sh ]; then
    echo "./calculate_average_$POSTFIX.sh is not executable, please run:"
    echo "chmod +x calculate_average_$POSTFIX.sh"
    exit 1
fi

if [ -f "./prepare_$POSTFIX.sh" ]; then
  if [ ! -x ./prepare_$POSTFIX.sh ]; then
    echo "./prepare_$POSTFIX.sh is not executable, please run:"
    echo "chmod +x prepare_$POSTFIX.sh"
    exit 1
  fi
  "./prepare_$POSTFIX.sh"
fi

for sample in $(ls $INPUT); do
  echo "Validating calculate_average_$POSTFIX.sh -- $sample"

  rm -f measurements.txt
  ln -s $sample measurements.txt

  diff --color=always <("./calculate_average_$POSTFIX.sh" | ./tocsv.sh) <(./tocsv.sh < ${sample%.txt}.out)
done

rm measurements.txt
