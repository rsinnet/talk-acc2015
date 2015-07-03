TALKNAME := acc2015
LATEX_CMD := latex -interaction=nonstopmode
PDFLATEX_CMD := pdflatex -interaction=nonstopmode

TALKSRC := $(TALKNAME).tex $(wildcard sections/*.tex) rsinnet.sty

EPS_ALL := $(wildcard figs/*.eps)
EPS_TEX := $(wildcard figs/*.eps_tex)

MP4_VIDS := $(wildcard figs/*.mp4)
IMG_FIGS := $(wildcard figs/*.jpg) $(wildcard figs/*.png) $(wildcard figs/*.pdf)

EPS_LATEX := $(subst .eps_tex,.eps_latex,$(EPS_TEX))
EPS_NO_LATEX := $(filter-out $(subst .eps_tex,.eps,$(EPS_TEX)), $(EPS_ALL))

ifeq ($(OS),Windows_NT)
  CP:=copy
  RM:=del
else
  CP:=cp
  RM:=rm -f
endif

all: $(TALKNAME).pdf

%.pdf: %.ps
	ps2pdf $<

%.ps: %.dvi
	dvips $<

%.dvi: %.aux
	$(LATEX_CMD) $(basename $<)
	$(LATEX_CMD) $(basename $<)

$(PROJNAME).aux: $(PROJNAME).tex $(EPS_LATEX) $(EPS_NO_LATEX) myrefs.bib
	$(LATEX_CMD) $<
	bibtex $(basename $<)

$(TALKNAME).pdf: $(TALKSRC) $(EPS_LATEX) $(EPS_NO_LATEX) $(IMG_FIGS)
	$(PDFLATEX_CMD) $<
	$(PDFLATEX_CMD) $<

myrefs.bib: refs.bib format_bibtex_months
	./format_bibtex_months refs.bib myrefs.bib

figs/%.eps_latex: figs/%.eps_tex figs/%.eps figs/do_latex_subs.py figs/latex_subs.json
	$(MAKE) -C figs/ $(notdir $@)

.PHONY: all clean

clean:
	$(RM) myrefs.bib $(TALKNAME).pdf *.dvi *.ps *.bbl *.aux *.out *.snm *.nav *.toc
	$(MAKE) -C figs/ clean
