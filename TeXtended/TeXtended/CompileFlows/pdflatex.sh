#!/bin/sh

#  pdflatex.sh
#  TeXtended
#
#  Created by Tobias Mende on 15.05.13.
#  Copyright (c) 2013 Tobias Mende. All rights reserved.

if [ $# -lt 2 ]
then
echo "usage: <file-to-compile> <working-directory> (<num compile> <do bibtex>)"
exit
fi

# Executable values
PATH=/usr/texbin:/usr/local/bin:$PATH
ENGINE=/usr/texbin/pdflatex
BIBTEX=/usr/texbin/bibtex

# Process inputs.
# TeXtended passes the file to be processed as the first input to this
# script and the working directory as the second input. Other options follow.
mainFile=$1
outputPath=$2
nCompile=$3
compileBib=$4
custom=$5

echo "****************************"
echo "*** Compiling $mainFile ***"
echo "*** Output path:\t$outputPath"
echo "*** Number of compiles:\t$nCompile"
echo "*** Compile bib:\t$compileBib"
echo "*** Custom parameter:\t$custom"
echo "****************************"

# Go to the working directory
cd "$outputPath"

# Do the correct number of typesetting runs
count=1
while [ $count -le $nCompile ]
do
echo " "
echo "***------------------------------------------------------------"
echo "*** Run $count..."
echo "***------------------------------------------------------------"
$ENGINE -synctex=1 -file-line-error -interaction=nonstopmode "$mainFile"

# if this is after the first run, run bibtex if requested
if [ $count -eq 1 ]
then
if [ $compileBib -eq 1 ]
then
echo "*** Running bibtex..."
$BIBTEX "$mainFile"
fi
fi

count=$(( $count + 1 ))
done

echo "*** pdflatex compile flow has completed."

# END