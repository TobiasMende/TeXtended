#!/bin/sh

#  lualatexDraft.sh
#  TeXtended
#
#  Created by Max Bannach on 09.06.13.
#  Copyright (c) 2013 Tobias Mende. All rights reserved.

if [ $# -lt 2 ]
then
echo "usage: <file-to-compile> <working-directory> (<num compile> <do bibtex>)"
exit
fi

# Executable values
PATH=/usr/texbin:/usr/local/bin:$PATH
ENGINE=/usr/texbin/xelatex
BIBTEX=/usr/texbin/bibtex

# Process inputs.
# TeXtended passes the file to be processed as the first input to this
# script and the working directory as the second input. Other options follow.
mainFile=$1
outputPath=$2
nCompile=$3
compileBib=$4
custom=$5

outputDir=$(dirname "$outputPath")

echo "****************************"
echo "*** Compiling $mainFile ***"
echo "*** Output path:\t\t$outputPath"
echo "*** Output dir:\t\t$outputDir"
echo "*** Number of compiles:\t$nCompile"
echo "*** Compile bib:\t\t$compileBib"
echo "*** Custom parameter:\t$custom"
echo "****************************"

# Go to the working directory
cd "$outputDir"

# Do the correct number of typesetting runs
count=1
while [ $count -le $nCompile ]
do
echo " "
echo "***------------------------------------------------------------"
echo "*** Run $count..."
echo "***------------------------------------------------------------"
$ENGINE -synctex=1 -file-line-error "$mainFile"

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

echo "*** xelatex compile flow has completed."

# END