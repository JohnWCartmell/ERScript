/* Global */
var svgDoc


var resetArray = [] ;
var currentlySelectedRelationshipId = undefined;

window.addEventListener("load", function() {
   const svgObject = document.getElementById('svg-object');
   svgDoc = svgObject.contentDocument; 
   const popoutButtons = document.querySelectorAll(".popout");
   for (let i = 0; i < popoutButtons.length; i++) {
      popoutButtons[i].onclick=showAttributeDetailAtCursor;
   };
   const attributes = svgDoc.querySelectorAll(".idattrname");
   console.log("Number of id attributes",attributes.length)
   for (let i = 0; i < attributes.length; i++) {
      attributes[i].onclick=showAttributeDetailAtCursor;
   };
  });


function showEntityTypeDetail(id){
   const divElement = document.getElementById(id + "_text");
   divElement.style.visibility = 'visible';
   divElement.style.pointerEvents = 'auto';
   //divElement.style.opacity = 1;
   }

function closePopUp(id){
   console.log('close call')
   const divElement = document.getElementById(id + "_text");
   divElement.style.visibility = 'hidden';
   divElement.style.pointerEvents = 'none';

  }

function showAttributeDetailAtCursor(e){
   console.log('myevent ',e);
   console.log('pos: ',e.clientX,e.clientY);
   e = e || window.event;
   const attributeElmnt = e.currentTarget;
   const id = attributeElmnt.id;
   const infoboxDivElement = document.getElementById(id + "_text");
   infoboxDivElement.style.left=e.clientX;
   infoboxDivElement.style.top=e.clientY;
   infoboxDivElement.style.visibility = 'visible';
   infoboxDivElement.style.pointerEvents = 'auto';
};

function showAttributeDetail(id){
   const divElement = document.getElementById(id + "_text");
   divElement.style.visibility = 'visible';
   divElement.style.pointerEvents = 'auto';
   }

function clickRelationship(id){
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
   const divElement = document.getElementById(id + "_text");
   divElement.style.visibility = 'visible';
   divElement.style.pointerEvents = 'auto';
  
   var hitAreaElement = svgDoc.getElementById(id + "_hitarea");
   hitAreaElement.classList.add("relationshippopped");
   console.log('after pop class List',hitAreaElement.classList);
   console.log('after pop class List',hitAreaElement.classList);
   var rel_ids = [];
   var colours = [];
   var directions = [];
   // diagonal
   const diagonal_ids = diagonal_elements[id] ;
   if (diagonal_ids !== undefined){
      rel_ids = rel_ids.concat(diagonal_ids) ;
      directions = directions.concat(diagonal_element_directions[id]) ;
      colours=colours.concat(diagonal_ids.map(id => 'red')) ;
   };
   // now for subject rel itself
   rel_ids = rel_ids.concat([id]) ;
   directions = directions.concat([1]) ;
   colours = colours.concat(['#15D4FA']) ;
   //riser 
   const riser_ids = riser_elements[id] ;
   if (riser_ids !== undefined) {
      rel_ids = rel_ids.concat(riser_ids) ;
      directions = directions.concat(riser_element_directions[id]) ;
      colours = colours.concat(riser_ids.map(id => '#15D4FA')) ;
   } ;

   animatePath(rel_ids,
               directions,
               colours
               );
} ;

function animatePath(pathElementIds,pathElementDirections,colourArray){
   const pathComponentElements = pathElementIds.map(id => svgDoc.getElementById(id + "_hitarea"));
   //console.log(pathComponentElements);
   const pathComponentLengths = pathComponentElements.map(pathElement => pathElement.getTotalLength());
   //console.log(pathComponentLengths);
   const totalLength = pathComponentLengths.reduce((total,num) => total + num, 0);
   const durationMillisecs = totalLength * 1000 / pathVelocity ;
   var proportionSoFar = 0 ;
   for (let i = 0; i < pathComponentElements.length; i++) {
      let thisComponent = pathComponentElements[i] ;
      let thisLength = pathComponentLengths [i] ;
      let proportionThisComponent = thisLength / totalLength ;
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
var pathVelocity = 20; // meaning 3 units (cm?) per second


function resetDisplay () {
   resetArray.forEach(id => resetRelationship(id));
   resetArray = [];
}

function resetRelationship(id){
   var relHitArea = svgDoc.getElementById(id + "_hitarea");
// see https://www.petercollingridge.co.uk/tutorials/svg/interactive/mouseover-effects/
   relHitArea.style.strokeOpacity = "" ;
   relHitArea.style.stroke="" ;
   relHitArea.classList.remove("relationshippopped");
} ;


function animateRel(relHitArea,timing,length,duration,direction,colour){
   // direction is either 1 for animate forward along path or -1 for animate in reverse direction
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

/* This below will need changing to new display,visibility scheme if used in future */
function closeallinfoboxes(){
   const textboxes = document.getElementsByClassName("infobox");
   for(var i=0; i<textboxes.length; i++){
             textboxes[i].style.display='none';
   }  
   const infolist = document.getElementById("infolist");
   infolist.style.display = 'none';
                           }