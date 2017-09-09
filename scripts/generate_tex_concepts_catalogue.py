#!/usr/bin/env python
import os
import sys
#path="C:\\somedirectory"  # insert the path to the directory of interest here
maintex = sys.stdout

texhead = open('tools/texhead.txt','r')
for line in texhead:
    maintex.write(line)

dirList=os.listdir('conceptualModels')
dirList.sort()
for filename in dirList:
  if filename[-4:] == '.xml':
    maintex.write('\section{' + filename[:-4] + '}' + '\n')
    maintex.write('\input{conceptualModels/' + filename[:-4] + '.tex}' + '\n')
    maintex.write('\\newline' + '\n')
#
textail = open('tools/textail.txt','r')
for line in textail:
    maintex.write(line)
