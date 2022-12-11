/* Global */
var svgObject
var myHTMLDoc

var resetArray = [] ;
var currentlySelectedRelationshipId = undefined;

  window.addEventListener("load", function() {
    myHTMLDoc = document ; 
    svgObject = document.getElementById('svg-object');
    svgDoc = svgObject.contentDocument;
  });


function showEntityTypeDetail(id){
 var divElement = myHTMLDoc.getElementById(id + "_text");
 //divElement.setAttributeNS(null,'class', 'infotextboxpopped');
    //divElement.class='infotextboxpopped';
   divElement.style.display = 'block';
   divElement.style.visibility = 'visible';
   divElement.style.opacity = 1;
  }

function showAttributeDetail(id){
 var divElement = document.getElementById(id + "_text");
   divElement.setAttributeNS(null,'class', 'display:block;visibility:visible;opacity:1');
   //divElement.style.display = 'block';
   //divElement.style.visibility = 'visible';
      //divElement.style.opacity = 1;
  }

function clickRelationship(id){
   var hitAreaElement = svgDoc.getElementById(id + "_hitarea");
   resetDisplay();
   if (currentlySelectedRelationshipId ==id) {
      currentlySelectedRelationshipId = undefined ;
      // do nothing so that click on currently selected relationship deselects
   } else {
      currentlySelectedRelationshipId = id ;
      showRelationshipDetail(id) ;
   }
} ;

function showRelationshipDetail(id){   
   var divElement = document.getElementById(id + "_text");
   divElement.style.display = 'block';
   divElement.style.visibility = 'visible';
   divElement.style.opacity = 1;
  
   var hitAreaElement = svgDoc.getElementById(id + "_hitarea");
   hitAreaElement.classList.add("relationshippopped");
   console.log('after pop class List',hitAreaElement.classList);
   console.log('after pop class List',hitAreaElement.classList);
   diagonal_ids = diagonal_elements[id] ;
   diagonal_directions = diagonal_element_directions[id] ;
   diagonal_colours = diagonal_ids.map(id => 'red') ;
   subject_id = id;
   subject_colour='#15D4FA';
   subject_direction = 1;
   riser_ids = riser_elements[id] ;
   riser_colours = riser_ids.map(id => '#15D4FA') ;
   riser_directions = riser_element_directions[id]

   animatePath(diagonal_ids.concat([subject_id],riser_ids),
               diagonal_directions.concat([subject_direction],riser_directions),
               diagonal_colours.concat([subject_colour],riser_colours)
               );
} ;

function animatePath(pathElementIds,pathElementDirections,colourArray){
   pathComponentElements = pathElementIds.map(id => svgDoc.getElementById(id + "_hitarea"));
   //console.log(pathComponentElements);
   pathComponentLengths = pathComponentElements.map(pathElement => pathElement.getTotalLength());
   //console.log(pathComponentLengths);
   totalLength = pathComponentLengths.reduce((total,num) => total + num, 0);
   durationMillisecs = totalLength * 1000 / pathVelocity ;
   var proportionSoFar = 0 ;
   for (let i = 0; i < pathComponentElements.length; i++) {
      thisComponent = pathComponentElements[i] ;
      thisLength = pathComponentLengths [i] ;
      proportionThisComponent = thisLength / totalLength ;
      animateRel(thisComponent,
                 [0,proportionSoFar,proportionSoFar + proportionThisComponent,1],
                 thisLength,
                 durationMillisecs, 
                 pathElementDirections[i],
                 colourArray[i]);
      proportionSoFar += proportionThisComponent ;
      } 
   resetArray = pathElementIds;
} ;

// Globals
var pathVelocity = 3; // meaning 3 units (cm?) per second

 

function resetDisplay () {
   console.log('Resetting display --- length', resetArray.length)
   resetArray.forEach(id => resetRelationship(id));
   resetArray = [];
}

function resetRelationship(id){
   var relHitArea = svgDoc.getElementById(id + "_hitarea");
   //relHitArea.style.strokeOpacity = 0 ;

// see https://www.petercollingridge.co.uk/tutorials/svg/interactive/mouseover-effects/
   relHitArea.style.strokeOpacity = "" ;
   relHitArea.style.stroke="" ;
   relHitArea.classList.remove("relationshippopped");
} ;


function animateRel(relHitArea,timing,length,duration,direction,colour){
   // direction is either 1 for animate forward along path or -1 for animate in reverse direction
   console.log(relHitArea.style);
   relHitArea.style.strokeWidth = 0.2 ;
   relHitArea.style.strokeOpacity = 0.5 ;
   relHitArea.style.stroke=colour ;
   relHitArea.style.strokeDasharray = length ;

   animation=relHitArea.animate({strokeDashoffset:[direction * length, direction * length,0,0],
                                 offset:timing                        
                                 },
                                 duration) ; //time in millisec
   //console.log(animation) ;
}

function closeallinfotextboxes(){
   var textboxes = document.getElementsByClassName("infotextbox");
   for(var i=0; i<textboxes.length; i++){
             textboxes[i].style.display='none';
   }  
   var infolist = document.getElementById("infolist");
   infolist.style.display = 'none';
                           }