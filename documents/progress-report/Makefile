rscripts = figs/plots.R figs/tables.R
csvs = ../../results/schmitz/auc.csv ../../results/schmitz/ei_auc.csv
rdss = ../../models/schmitz/logistic/0-vanilla/zerosum/1-75/fit_obj.rds

.PHONY: main.pdf all clean

all: main.pdf

# CUSTOM BUILD RULES

figs/auc_table.tex: $(rscripts) $(csvs) $(rdss)
	Rscript figs/plots.R
	Rscript figs/tables.R 

# MAIN LATEXMK RULE

main.pdf: main.tex figs/auc_table.tex
	latexmk -pdf -xelatex -use-make main.tex

clean:
	latexmk -CA