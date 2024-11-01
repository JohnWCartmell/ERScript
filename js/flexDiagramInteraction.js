
/* Maintenance Box
26-Oct-2024  Changes to how elements having Information Boxes are recognised.
            No longer relies in styling of svg elements (does rely on styling of surrounding generic html.)
            Introduces a context menu so that can extend later to support era method information.
            Supports multiple svg sub documents on a single html page.
/* 

/* Global */

var popupboxContainerOffsetX ;
var popupboxContainerOffsetY ;
var svgElementClickedToBringUpMenu = null;

//Wait for document load
if (document.readyState === 'loading') {  // Loading hasn't finished yet
  console.log("Adding initialiseInteraction event listener")
   document.addEventListener('DOMContentLoaded', initialiseDocumentInteraction);
} else {  // `DOMContentLoaded` has already fired
  initialiseDragging();
}

//Wait to be sure enbedded svg loaded  
window.addEventListener("load",initialiseSvgInteraction);


function initialiseDocumentInteraction()
{
   console.info('initialising Document interaction');
   /* Initialise the context menu*/
   const contextMenu = document.getElementById('contextMenu');
   // Hide the context menu on a click outside the context menu 
   // Note: This doesn't fire when the click is inside a nested object.
   document.addEventListener('click', (event) => {
      console.log('click');
      if (!contextMenu.contains(event.target)) {
         console.log('click outside');
         contextMenu.style.display = 'none';  
      }
   });

   /* program the menu options */
   // need add select here.
   // View flex source 
   document.getElementById('flexsource')
                       .addEventListener('click', showInfoboxAtCursorFromMenu);
   /* Initialise the info box text popouts */
   //The following isn't doing anything currently because there are no popout buttons in the info boxes currently */
   const popupboxContainer = document.querySelector(".svganddivcontainer");
   console.log("container",popupboxContainer);
   popupboxContainerOffsetX = popupboxContainer.getBoundingClientRect().x + window.pageXOffset;
   popupboxContainerOffsetY = popupboxContainer.getBoundingClientRect().y + window.pageYOffset;
   const popoutButtons = document.querySelectorAll(".popout");
   for (let i = 0; i < popoutButtons.length; i++) {
      popoutButtons[i].onclick=showInfoboxAtCursorFromInfobox;
   };
};

function initialiseSvgInteraction(){
   console.info('initialising svg interaction');

   const modelObjects = document.querySelectorAll('object[data-type="flex"]');
   console.log("Number of objects of type ERmodel",modelObjects.length)
   for (let i = 0; i < modelObjects.length; i++) {
      let svgDoc = modelObjects[i].contentDocument; 


   svgDoc.addEventListener('click', (event) => {
      console.log('click');
      if (!contextMenu.contains(event.target)) {
         console.log('click outside');
         contextMenu.style.display = 'none';  
      }
   });


      let svgElements = svgDoc.querySelectorAll("[data-infoBoxId]");
      console.log("Number of svgElements",svgElements.length)
      for (let i = 0; i < svgElements.length; i++) {
         svgElements[i].addEventListener('contextmenu',displayContextMenu);
      };
   };
} ;

function displayContextMenu(event){
   console.log('myevent ',event);
   console.log('pos: ',event.pageX,event.pageY);
   event.preventDefault(); // Prevent the default browser context menu
   /*event = event || window.event;*/
    const elmnt = event.currentTarget; 
    svgElementClickedToBringUpMenu =elmnt;
    console.log("set clickedElement",svgElementClickedToBringUpMenu) ;
    const svgObject = getObjectElementThatContainsThisSVG(elmnt);
    const scrollTop = window.scrollY || document.documentElement.scrollTop;
    const scrollLeft = window.scrollX || document.documentElement.scrollLeft;
    console.log("svgObject.getBoundingClientRect().y",svgObject.getBoundingClientRect().y);
    console.log("svgObject.getBoundingClientRect().top",svgObject.getBoundingClientRect().top);
            contextMenu.style.top = 
                     event.pageY + svgObject.getBoundingClientRect().top + scrollTop;
            contextMenu.style.left = 
                     event.pageX + svgObject.getBoundingClientRect().x + scrollLeft;
            contextMenu.style.display = 'block';
};


function showInfoboxAtCursorFromMenu(e){
   console.log("use clickedElement",svgElementClickedToBringUpMenu) ;
   let infoBoxElement = getInfoboxElementFromGivenSvgElement(svgElementClickedToBringUpMenu) ;
   positionInfoboxAtCursor(e,infoBoxElement, 0, 0);
   /* Dismiss the menu */
   contextMenu.style.display = 'none';  
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

function getObjectElementThatContainsThisSVG(svgElmnt)
{
   const rootSvgElement = getRootSVGElement(svgElmnt);
   const parentHTMLelement = document.getElementById(rootSvgElement.id);
   return parentHTMLelement;
};

function getInfoboxElementFromGivenSvgElement(svgElmnt)
{
   let id = svgElmnt.dataset.infoBoxId;
   const parentHTMLelement = getObjectElementThatContainsThisSVG(svgElmnt) ;
   /*console.log("parentElement", parentHTMLelement, "nodename", parentHTMLelement.nodeName) ;*/
   const greatgrandParentHTMLelement = parentHTMLelement.parentNode.parentNode ;
   /*console.log("greatgrandParentElement", greatgrandParentHTMLelement, "class", greatgrandParentHTMLelement.class) ;*/
   const selector = '#' + id + '_text' ;
   /*console.log("selector", selector);*/
   const infoboxDivElement = greatgrandParentHTMLelement.querySelector(selector);
   return infoboxDivElement;
}

function positionInfoboxAtCursor(event, infoboxDivElement,offsetX,offsetY){
   console.log('infoboxDivElement', infoboxDivElement)
   infoboxDivElement.style.left=event.pageX - offsetX; 
   infoboxDivElement.style.top=event.pageY - offsetY;  
   infoboxDivElement.style.visibility = 'visible';
   infoboxDivElement.style.pointerEvents = 'auto';
};

function closePopUp(button){
   console.log('close call')
   const divElement = button.parentNode.parentNode.parentNode;
   console.log("divElement",divElement) ;
   divElement.style.visibility = 'hidden';
   divElement.style.pointerEvents = 'none';
  } ;

/* not used currently */
function closeallinfoboxes(){
   const textboxes = document.getElementsByClassName("infobox");
   for(var i=0; i<textboxes.length; i++){
             textboxes[i].style.display='none';
   }  
} ;




