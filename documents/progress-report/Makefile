rscripts = figs/plots.R figs/tables.R ../../src/assess/ass_spec.R\
	../../src/train/model_spec.R
csvs = ../../results/schmitz/auc.csv ../../results/schmitz/ei_auc.csv

.PHONY: main.pdf all clean

all: main.pdf

# CUSTOM BUILD RULES

figs/auc_table.tex: $(rscripts) $(csvs)
	Rscript figs/plots.R
	Rscript figs/tables.R

# MAIN LATEXMK RULE

main.pdf: main.tex figs/auc_table.tex
	latexmk -pdf -xelatex -use-make main.tex

clean:
	latexmk -CA