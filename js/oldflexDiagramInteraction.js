/* Global */
var svgDoc ;

var popupboxContainerOffsetX ;
var popupboxContainerOffsetY ;


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

   const svgElements = svgDoc.querySelectorAll("[data-infoBoxId]");
   console.log("Number of infoable svgElements",svgElements.length)
   for (let i = 0; i < svgElements.length; i++) {
      svgElements[i].onclick=showInfoboxAtCursorFromSVG;
   };
   
   /*change of 25th Oct 2024
   {
   const routeHitAreaElements = svgDoc.querySelectorAll(".routehitarea");
   console.log("Number of relationships",routeHitAreaElements.length)
   for (let i = 0; i < routeHitAreaElements.length; i++) {
      routeHitAreaElements[i].onclick=clickRelationshipAtCursor;
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
   const elmnt = e.currentTarget; 
   const id = elmnt.dataset.infoBoxId; /* note this is way to read the custom attribute data-infoBoxId*/
   console.log('infoBoxId ', id)
   const infoboxDivElement = document.getElementById(id + "_text");
   infoboxDivElement.style.left=e.pageX - offsetX; 
   infoboxDivElement.style.top=e.pageY - offsetY;  
   infoboxDivElement.style.visibility = 'visible';
   infoboxDivElement.style.pointerEvents = 'auto';
};

/* I guess the following is not used */
/* This below will need changing to new display,visibility scheme if used in future */
function closeallinfoboxes(){
   const textboxes = document.getElementsByClassName("infobox");
   for(var i=0; i<textboxes.length; i++){
             textboxes[i].style.display='none';
   }  
   const infolist = document.getElementById("infolist");
   infolist.style.display = 'none';
} ;


