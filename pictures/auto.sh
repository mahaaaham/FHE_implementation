#!/bin/bash

cat header_begin.tex $1 header_end.tex > full_$1;
latexmk -pdf full_$1;
latexmk -c;
