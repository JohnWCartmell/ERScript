/* Global */
var svgDoc ;

var currentlySelectedRelationshipId = undefined;
var resetArray = [] ;


//Wait to be sure enbedded svg loaded  
window.addEventListener("load",initialiseSvgInteraction);


function initialiseSvgInteraction(){
   console.info('initialising svg interaction');
   const svgObject = document.getElementById('svg-object');
   svgDoc = svgObject.contentDocument; 
   
   const routeHitAreaElements = svgDoc.querySelectorAll(".routehitarea");
   console.log("Number of relationships",routeHitAreaElements.length)
   for (let i = 0; i < routeHitAreaElements.length; i++) {
      routeHitAreaElements[i].onclick=clickRelationshipAtCursor;
   };
   
} ;


function clickRelationshipAtCursor(e){
   console.log('myevent ',e);
   console.log('pos: ',e.pageX,e.pageY);
   e = e || window.event;
   const elmnt = e.currentTarget; /* may be svg element or button element*/
   const relid = elmnt.getAttribute('data-infoBoxId');   /*XXXXXXXXXXXXXXXXXX*/
   console.log('rel id',relid) ;
   resetDisplay();
   if (currentlySelectedRelationshipId ==relid) {
      currentlySelectedRelationshipId = undefined ;
      // do nothing so that click on currently selected relationship deselects
   } else {
      currentlySelectedRelationshipId = relid 
    /*  const infoboxDivElement = document.getElementById(relid + "_text");
      infoboxDivElement.style.left=e.pageX;
      infoboxDivElement.style.top=e.pageY;
      infoboxDivElement.style.visibility = 'visible';
      infoboxDivElement.style.pointerEvents = 'auto';*/
     
      var hitAreaElement = svgDoc.getElementById(relid + "_hitarea");   /*cannot find this since not having id anymore */
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
