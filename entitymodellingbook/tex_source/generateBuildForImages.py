
import os

import sys


preambleFile = open('preamble.txt','r')
preambleText = preambleFile.read()
preambleFile.close()
postambleFile = open('postamble.txt','r')
postambleText = postambleFile.read()
postambleFile.close()

dirList=os.listdir('.')
dirList.sort()

folderPrefix = r'temp\\'
for filename in dirList:
  if filename[-4:] == '.tex':
    pictureName = filename[:-4] 
    mainName = folderPrefix + 'main'+ pictureName+'.tex'
    outFile=open(mainName,'w')
    outFile.write(preambleText)
    outFile.write('\n')
    outFile.write('\input{../' + pictureName+'}')
    outFile.write('\n')
    outFile.write(postambleText)
    outFile.close()

outPrefix = r'..\..\testwebsite\images\\'
batchFile = open(folderPrefix + 'buildAll.bat','w')
for filename in dirList:
  if filename[-4:] == '.tex':
    pictureName = filename[:-4]         
    mainName = 'main'+ pictureName
    batchFile.write('latex ' + mainName + '.tex\n')
    batchFile.write('dvips -P pdf "' +'main'+pictureName+'.dvi"\n')
    batchFile.write('ps2pdf main'+pictureName+'.ps\n')
    batchFile.write('convert -density 1000x1000 main'+pictureName+ '.pdf -quality 95 ' + outPrefix  +pictureName+'.png\n')

batchFile.close()


