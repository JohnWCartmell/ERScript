/* Global */
var svgDoc ;

var popupboxContainerOffsetX ;
var popupboxContainerOffsetY ;

var currentlyRoute = undefined;

//Wait for document load
if (document.readyState === 'loading') {  // Loading hasn't finished yet
  console.log("Adding initialiseInteraction event listener")
  document.addEventListener('DOMContentLoaded', initialiseDocumentInteraction);
} else {  // `DOMContentLoaded` has already fired
  initialiseDragging();
}

//Wait to be sure enbedded svg loaded  
window.addEventListener("load",initialiseSvgInteraction);

function initialiseDocumentInteraction() {
   console.info('initialising Document interaction');
   const popupboxContainer = document.querySelector(".svganddivcontainer");
   console.log("conatiner",popupboxContainer);
   popupboxContainerOffsetX = popupboxContainer.getBoundingClientRect().x + window.pageXOffset;
   popupboxContainerOffsetY = popupboxContainer.getBoundingClientRect().y + window.pageYOffset;
   console.log('popupboxContainerOffsetX',popupboxContainerOffsetX)
   console.log('popupboxContainerOffsetY',popupboxContainerOffsetY)
   /* TBD
   const popoutButtons = document.querySelectorAll(".popout");
   for (let i = 0; i < popoutButtons.length; i++) {
      popoutButtons[i].onclick=showInfoboxAtCursorFromInfobox;
   };
   */
};

function initialiseSvgInteraction(){
   console.info('initialising svg interaction');
   const svgObject = document.getElementById('svg-object');
   svgDoc = svgObject.contentDocument; 

   const svgElements = svgDoc.querySelectorAll(".gradient, .outline, .outlinedebug, .margin, .padding, .routehitarea");
   console.log("Number of infoable svgElements",svgElements.length)
   for (let i = 0; i < svgElements.length; i++) {
      svgElements[i].onclick=showInfoboxAtCursorFromSVG;
   };
   /* TBD
   const relHitAreaElements = svgDoc.querySelectorAll(".relationshiphitarea");
   console.log("Number of relationships",relHitAreaElements.length)
   for (let i = 0; i < relHitAreaElements.length; i++) {
      relHitAreaElements[i].onclick=clickRelationshipAtCursor;
   };
   */
} ;

function closePopUp(id){
   console.log('close call')
   const divElement = document.getElementById(id + "_text");
   divElement.style.visibility = 'hidden';
   divElement.style.pointerEvents = 'none';

  } ;

function showInfoboxAtCursorFromSVG(e){
   positionInfoboxAtCursor(e, 0, 0);
} ;

function showInfoboxAtCursorFromInfobox(e){
   positionInfoboxAtCursor(e,popupboxContainerOffsetX, popupboxContainerOffsetY);
} ;

function positionInfoboxAtCursor(e,offsetX,offsetY){
   e = e || window.event;
   const elmnt = e.currentTarget; /* may be svg element or button element*/
   const id = elmnt.id;
   const infoboxDivElement = document.getElementById(id + "_text");
   infoboxDivElement.style.left=e.pageX - offsetX; 
   infoboxDivElement.style.top=e.pageY - offsetY;  
   infoboxDivElement.style.visibility = 'visible';
   infoboxDivElement.style.pointerEvents = 'auto';
};


function clickRelationshipAtCursor(e){
   console.log('myevent ',e);
   console.log('pos: ',e.pageX,e.pageY);
   e = e || window.event;
   const elmnt = e.currentTarget; /* may be svg element or button element*/
   const relid = elmnt.getAttribute('data-relid');
   console.log('rel id',relid) ;
   resetDisplay();
   if (currentlySelectedRelationshipId ==relid) {
      currentlySelectedRelationshipId = undefined ;
      // do nothing so that click on currently selected relationship deselects
   } else {
      currentlySelectedRelationshipId = relid 
      const infoboxDivElement = document.getElementById(relid + "_text");
      infoboxDivElement.style.left=e.pageX;
      infoboxDivElement.style.top=e.pageY;
      infoboxDivElement.style.visibility = 'visible';
      infoboxDivElement.style.pointerEvents = 'auto';
     
      var hitAreaElement = svgDoc.getElementById(relid + "_hitarea");
      hitAreaElement.classList.add("relationshippopped");
      animateRelationship(relid) ;
   }
};


function animateRelationship(id){   
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
} ;

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
} ;

/* This below will need changing to new display,visibility scheme if used in future */
function closeallinfoboxes(){
   const textboxes = document.getElementsByClassName("infobox");
   for(var i=0; i<textboxes.length; i++){
             textboxes[i].style.display='none';
   }  
   const infolist = document.getElementById("infolist");
   infolist.style.display = 'none';
} ;