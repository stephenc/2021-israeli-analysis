# Copyright 2021 Stephen Connolly
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
#

# Load all the libraries we are using
library('methods', warn.conflicts = FALSE, character.only = TRUE)
library('tidyverse', warn.conflicts = FALSE, character.only = TRUE)
library('ggthemes', warn.conflicts = FALSE, character.only = TRUE)
library('gridExtra', warn.conflicts = FALSE, character.only = TRUE)
library('zoo', warn.conflicts = FALSE, character.only = TRUE)
library('dplyr', warn.conflicts = FALSE, character.only = TRUE)
library('lubridate', warn.conflicts = FALSE, character.only = TRUE)
library('xtable', warn.conflicts = FALSE, character.only = TRUE)
library('expint', warn.conflicts = FALSE, character.only = TRUE)
library('deSolve', warn.conflicts = FALSE, character.only = TRUE)

# Populate the running script name in script.name
initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
rm(initial.options, file.arg.name)
