
/* Maintenance Box

25-Oct-2024 Changes to how relationship data used in animation is accessed.
            Changes to how elements having Information Boxes are recognised.

/* 


/* Global */

var popupboxContainerOffsetX ;
var popupboxContainerOffsetY ;

var resetArray = [] ;
var currentlySelectedRelationshipId = undefined;

var counter = 1;

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
   console.log("container",popupboxContainer);
   popupboxContainerOffsetX = popupboxContainer.getBoundingClientRect().x + window.pageXOffset;
   popupboxContainerOffsetY = popupboxContainer.getBoundingClientRect().y + window.pageYOffset;
   console.log('popupboxContainerOffsetX',popupboxContainerOffsetX)
   console.log('popupboxContainerOffsetY',popupboxContainerOffsetY)
   const popoutButtons = document.querySelectorAll(".popout");
   for (let i = 0; i < popoutButtons.length; i++) {
      popoutButtons[i].onclick=showInfoboxAtCursorFromInfobox;
   };
};

function initialiseSvgInteraction(){
   console.info('initialising svg interaction');
   /*const svgObject = document.getElementById('svg-object');*/

   const modelObjects = document.querySelectorAll('object[data-type="ERmodel"]');
   console.log("Number of objects of type ERmodel",modelObjects.length)
   for (let i = 0; i < modelObjects.length; i++) {
      let svgDoc = modelObjects[i].contentDocument; 
      let svgElements = svgDoc.querySelectorAll(".eteven,.etodd,.idattrname,.attrname");
      console.log("Number of svgElements",svgElements.length)
      for (let i = 0; i < svgElements.length; i++) {
         svgElements[i].onclick=showInfoboxAtCursorFromSVG;
      };
      let relHitAreaElements = svgDoc.querySelectorAll(".relationshiphitarea");
      console.log("Number of relationships",relHitAreaElements.length)
      for (let i = 0; i < relHitAreaElements.length; i++) {
         relHitAreaElements[i].onclick=clickRelationshipAtCursor;
      };
   };
} ;

function getRootSVGElement(elmnt)
{
   let currentElement = elmnt; // Start from any  SVG element 
   /*Navigate up the tree as far as is possible*/
   while (currentElement.ownerSVGElement) {
     currentElement = currentElement.ownerSVGElement;
   }
   return currentElement;
};

function infoboxElementFromGivenSvgElementFromId(svgElmnt, id)
{
   /* root svg element has been given same id as the containing svg <object/> element -- 25-Oct-2024 */
   const rootSvgElement = getRootSVGElement(svgElmnt);
   const parentHTMLelement = document.getElementById(rootSvgElement.id)
   console.log("parentElement", parentHTMLelement, "nodename", parentHTMLelement.nodeName) ;
   const greatgrandParentHTMLelement = parentHTMLelement.parentNode.parentNode ;
   console.log("greatgrandParentElement", greatgrandParentHTMLelement, "class", greatgrandParentHTMLelement.class) ;
   const selector = '#' + id + '_text' ;
   console.log("selector", selector);
   const infoboxDivElement = greatgrandParentHTMLelement.querySelector(selector);
   return infoboxDivElement;
}

function infoboxElementFromGivenSvgElement(svgElmnt)
{
   return infoboxElementFromGivenSvgElementFromId(svgElmnt, svgElmnt.id);
}
function showInfoboxAtCursorFromSVG(e){
   positionInfoboxAtCursor(e, 0, 0);
} ;

function showInfoboxAtCursorFromInfobox(e){
   positionInfoboxAtCursor(e,popupboxContainerOffsetX, popupboxContainerOffsetY);
} ;

function positionInfoboxAtCursor(e,offsetX,offsetY){
   e = e || window.event;
   const elmnt = e.currentTarget; /* may be svg element or button element*/
   const infoboxDivElement = infoboxElementFromGivenSvgElement(elmnt) ;
   infoboxDivElement.style.left=e.pageX - offsetX; 
   infoboxDivElement.style.top=e.pageY - offsetY;  
   infoboxDivElement.style.visibility = 'visible';
   infoboxDivElement.style.pointerEvents = 'auto';
   infoboxDivElement.style.zIndex = ++counter;
};

/*function closePopUp(id){
   console.log('close call')
   const divElement = document.getElementById(id + "_text");
   divElement.style.visibility = 'hidden';
   divElement.style.pointerEvents = 'none';
  } ;*/

function closePopUp(button){
   console.log('close call')
   const divElement = button.parentNode.parentNode.parentNode;
   console.log("divElement",divElement) ;
   divElement.style.visibility = 'hidden';
   divElement.style.pointerEvents = 'none';
  } ;


function clickRelationshipAtCursor(e){
   console.log('myevent ',e);
   console.log('pos: ',e.pageX,e.pageY);
   e = e || window.event;
   const elmnt = e.currentTarget; /* may be svg element or button element*/
   const rootSvgForThisClickedElement = getRootSVGElement(elmnt);
   const methodData = rootSvgForThisClickedElement.dataset.methodData;
   const methodDataObj = JSON.parse(methodData);
   const relid = elmnt.getAttribute('data-relid');
   console.log('rel id',relid) ;
   resetDisplay(rootSvgForThisClickedElement);
   if (currentlySelectedRelationshipId ==relid) {
      currentlySelectedRelationshipId = undefined ;
      // do nothing so that click on currently selected relationship deselects
   } else {
      currentlySelectedRelationshipId = relid ;
      const infoboxDivElement = infoboxElementFromGivenSvgElementFromId(elmnt, relid) ;
      /*const infoboxDivElement = document.getElementById(relid + "_text");*/
      infoboxDivElement.style.left=e.pageX;
      infoboxDivElement.style.top=e.pageY;
      infoboxDivElement.style.visibility = 'visible';
      infoboxDivElement.style.pointerEvents = 'auto';
      infoboxDivElement.style.zIndex = ++counter;
     
      var hitAreaElement = rootSvgForThisClickedElement.getElementById(relid + "_hitarea");
      hitAreaElement.classList.add("relationshippopped");
      animateRelationship(rootSvgForThisClickedElement,methodDataObj,relid) ;
   }
};


function animateRelationship(svgRoot,methodDataObj, id){   
   var rel_ids = [];
   var colours = [];
   var directions = [];
   console.log('methodData is', methodDataObj)
   console.log('id is', id)
   // diagonal
   const diagonal_ids = methodDataObj.diagonal_elements[id] ;
   console.log("methodDataObj.diagonal_elements",methodDataObj.diagonal_elements)
   console.log("diagonal_ids",diagonal_ids)
   if (diagonal_ids !== undefined){
      rel_ids = rel_ids.concat(diagonal_ids) ;
      directions = directions.concat(methodDataObj.diagonal_element_directions[id]) ;
      colours=colours.concat(diagonal_ids.map(id => 'red')) ;
   };
   // now for subject rel itself
   rel_ids = rel_ids.concat([id]) ;
   directions = directions.concat([1]) ;
   colours = colours.concat(['#15D4FA']) ;
   //riser 
   const riser_ids = methodDataObj.riser_elements[id] ;
   if (riser_ids !== undefined) {
      rel_ids = rel_ids.concat(riser_ids) ;
      directions = directions.concat(methodDataObj.riser_element_directions[id]) ;
      colours = colours.concat(riser_ids.map(id => '#15D4FA')) ;
   } ;

   animatePath(svgRoot,
               rel_ids,
               directions,
               colours
               );
} ;

function animatePath(svgRoot, pathElementIds,pathElementDirections,colourArray){
   console.log("animatePath pathElementIds",pathElementIds) ;
   const pathComponentElements = pathElementIds.map(id => svgRoot.getElementById(id + "_hitarea"));
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


function resetDisplay (svgRoot) {
   resetArray.forEach(id => resetRelationship(svgRoot,id));
   resetArray = [];
} ;

function resetRelationship(svgRoot,id){
   var relHitArea = svgRoot.getElementById(id + "_hitarea");
// see https://www.petercollingridge.co.uk/tutorials/svg/interactive/mouseover-effects/
   relHitArea.style.strokeOpacity = "" ;
   relHitArea.style.stroke="" ;
   relHitArea.classList.remove("relationshippopped");
} ;


function animateRel(relHitArea,timing,length,duration,direction,colour){
   // direction is either 1 for animate forward along path or -1 for animate in reverse direction
   console.log("animateRel")
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


function closeallinfoboxes(){
   const textboxes = document.getElementsByClassName("infobox");
   for(var i=0; i<textboxes.length; i++){
             textboxes[i].style.display='none';
   }  
} ;