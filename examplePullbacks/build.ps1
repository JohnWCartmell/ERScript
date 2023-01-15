$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder +'\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from  $SOURCE examplePullbacks folder")

$SOURCEXML = $SOURCE + '\examplePullbacks'
$TARGETXML = $TARGET + '\examplePullbacks\xml'

$tripFollowsItineraryMappingTable = @{
            'genericPullback' = 'tripFollowsItinerary'
            'E1' = 'trip' 
            'E2' = 'itinerary'    
            'E3' = 'visit'
            'E4' = 'place'   
            'R1' = 'follows'          
            'R2' = 'to' 
}

$castOfPlayMappingTable = @{
            'genericPullback' = 'castOfPlay'
            'E1' = 'performance' 
            'E2' = 'play'    
            'E3' = 'cast member'
            'E4' = 'character'   
            'R1' = 'of'          
            'R2' = 'plays_part of' 
}

$recitalOfScriptMappingTable = @{
            'genericPullback' = 'recitalOfScript'
            'E1' = 'recital' 
            'E2' = 'script'    
            'E3' = 'spoken_line'
            'E4' = 'line'   
            'R1' = 'of'          
            'R2' = 'articulation of' 
}
$hearingofRecitalMappingTable = @{
            'genericPullback' = 'hearingofRecital'
            'E1' = 'hearing' 
            'E2' = 'recital'    
            'E3' = 'heard_line'
            'E4' = 'spoken_line'   
            'R1' = 'of'          
            'R2' = 'hearing of' 
}
$functionCallMappingTable = @{
            'genericPullback' = 'functionCall'
            'E1' = 'call' 
            'E2' = 'function'    
            'E3' = 'actual param'
            'E4' = 'formal param'   
            'R1' = 'of'          
            'R2' = 'value of' 
}

$coordinateSystemMappingTable = @{
            'genericPullback' = 'coordinateSystem'
            'E1' = 'coordinate system' 
            'E2' = 'space'    
            'E3' = 'coordinate'
            'E4' = 'point'   
            'R1' = 'for'          
            'R2' = 'identifies' 
}
$shuffledPackOfCardsMappingTable = @{
            'genericPullback' = 'shuffledPackOfCards'
            'E1' = 'shuffle' 
            'E2' = 'pack'    
            'E3' = 'card(2)'
            'E4' = 'card'   
            'R1' = 'of'          
            'R2' = 'is' 
}

$diagramOfEntityModelMappingTable = @{
            'genericPullback' = 'diagramOfEntityModel'
            'E1' = 'diagram' 
            'E2' = 'entity model'    
            'E3' = 'box'
            'E4' = 'entity type'   
            'R1' = 'represents'          
            'R2' = 'represents' 
}

function CopyAndSubstituteForGenerics
{
param($infilename,$outname, $lookupTable)
$CONTENT = (Get-Content $infilename) 

    $lookupTable.GetEnumerator() | ForEach-Object {
        if ($CONTENT -match $_.Key)
        {
            $CONTENT = $CONTENT -replace $_.Key, $_.Value
        }
    }
Set-Content -Path ($SOURCEXML + '\' + $outname) -Value $CONTENT
}

function ThriceCopyAndSubstituteForGenerics
{
      param($fileprefix,$lookuptable)
      CopyAndSubstituteForGenerics 'genericPullback..logical.xml' ($fileprefix + '..logical.xml') $lookuptable
      CopyAndSubstituteForGenerics 'genericPullback..presentation.xml' ($fileprefix + '..presentation.xml') $lookuptable
      CopyAndSubstituteForGenerics 'genericPullback..diagram.xml' ($fileprefix + '..diagram.xml') $lookuptable
}

ThriceCopyAndSubstituteForGenerics 'tripFollowsItinerary' $tripFollowsItineraryMappingTable
ThriceCopyAndSubstituteForGenerics 'castOfPlay'           $castOfPlayMappingTable
ThriceCopyAndSubstituteForGenerics 'recitalOfScript'      $recitalOfScriptMappingTable 
ThriceCopyAndSubstituteForGenerics 'hearingOfRecital'     $hearingofRecitalMappingTable
ThriceCopyAndSubstituteForGenerics 'functionCall'         $functionCallMappingTable
ThriceCopyAndSubstituteForGenerics 'coordinateSystem'     $coordinateSystemMappingTable
ThriceCopyAndSubstituteForGenerics 'shuffledPackOfCards'  $shuffledPackOfCardsMappingTable
ThriceCopyAndSubstituteForGenerics 'diagramOfEntityModel' $diagramOfEntityModelMappingTable

# CREATE target folder if it doesn't already exist
If(!(test-path -PathType container $TARGETXML))
{
      echo ('CREATING target folder ' + $TARGETXML)
      New-Item -ItemType Directory -Path $TARGETXML
}

# COPY xml files
attrib -R $TARGETXML\*.xml
copy-item -Path $SOURCEXML\*.xml -Destination $TARGETXML
attrib +R $TARGETXML\*.xml

pushd $TARGETXML

. $TARGET\scripts\buildExampleSVG.ps1 genericPullback -animate 
. $TARGET\scripts\buildExampleSVG.ps1 tripFollowsItinerary -animate
. $TARGET\scripts\buildExampleSVG.ps1 castOfPlay -animate
. $TARGET\scripts\buildExampleSVG.ps1 recitalOfScript -animate 
. $TARGET\scripts\buildExampleSVG.ps1 hearingOfRecital -animate
. $TARGET\scripts\buildExampleSVG.ps1 functionCall -animate 
. $TARGET\scripts\buildExampleSVG.ps1 coordinateSystem -animate
. $TARGET\scripts\buildExampleSVG.ps1 shuffledPackOfCards -animate 
. $TARGET\scripts\buildExampleSVG.ps1 diagramOfEntityModel -animate 
popd 




