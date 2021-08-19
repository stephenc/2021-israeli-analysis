#   Copyright 2021 Stephen Connolly
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

override rwildcard = $(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
override FIGURES = $(patsubst %.R,%.eps,$(subst common.R,,$(subst bootstrap.R,,$(wildcard *.R))))
override IMAGES = $(patsubst %.dot,%.eps,$(wildcard *.dot))
override ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: all
all: $(patsubst %.tex,target/%.pdf,$(wildcard *.tex)) $(patsubst %.R,%.R.d,$(wildcard *.R))

.PHONY: visuals
visuals: $(IMAGES) $(FIGURES) 

paper.zip: all
	zip -j $@ *.tex *.eps *.jpg *.png target/*.pdf target/*.bbl *.csv

%.csv: %.R
	Rscript $<

.PHONY: init
init:
	Rscript -e 'if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv");renv::restore()'

texmf/ls-R: $(call rwildcard,texmf/tex/,*) $(call rwildcard,texmf/bibtex/,*)
	texhash "texmf"    

.PHONY: clean
clean:
	rm -rf "target" $(IMAGES) $(FIGURES) *.tex.d *-eps-converted-to.pdf *.csv *.R.d *.png

.PHONY: distclean
distclean: clean
	rm -f "texmf/ls-R"

target:
	@mkdir -p "target"

target/%.pdf: %.tex %.tex.d texmf/ls-R target
	TEXMFHOME="$(ROOT_DIR)/texmf" latexmk "-outdir=$(ROOT_DIR)/target" -bibtex -cd -pdf -file-line-error -halt-on-error -interaction=nonstopmode $<
	@rm -f *-eps-converted-to.pdf

%.eps: %.dot
	dot -Teps -o$@ $<

%.eps: %.R bootstrap.R
	Rscript $< -- --eps

%.tex.d: %.tex
	@perl texdep.pl $< $(patsubst %.tex,target/%.pdf,$<)

-include $(patsubst %.tex,%.tex.d,$(wildcard *.tex))

%.R.d: %.R
	@perl rdep.pl $< $(patsubst %.R,%.eps,$<)

-include $(patsubst %.R,%.R.d,$(wildcard *.R))


