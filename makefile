.ONESHELL:
all:
	pandoc \
	  --filter pandoc-include-code \
	  -t beamer \
	  --toc \
	  --slide-level 2 \
	  --include-in-header preamble.tex \
	  -o slides.pdf \
	  -i slides.md
