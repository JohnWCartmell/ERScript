// Make the DIV element draggable:
//dragElement(document.getElementById("E1_info"));

/* function dragElement(elmnt) {
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
  if (document.getElementById(elmnt.id + "header")) {
    // if present, the header is where you move the DIV from:
    document.getElementById(elmnt.id + "header").onmousedown = dragMouseDown;
  } else {
    // otherwise, move the DIV from anywhere inside the DIV:
    elmnt.onmousedown = dragMouseDown;
  }
  */

/*Globals */
var svgContainerElement;

if (document.readyState === 'loading') {  // Loading hasn't finished yet
  console.log("Adding initialisation event listener")
  document.addEventListener('DOMContentLoaded', initialise);
} else {  // `DOMContentLoaded` has already fired
  initialise();
}



function initialise() {
  console.info('initialising');
  svgContainerElement = document.querySelector("#svgcontainer");
  console.log("svg container" + svgContainerElement) ;
  /*svgContainerElement.style.pointerEvents = "none";*/

  const freeStandingInfoBlocks = document.querySelectorAll(".infolevel1");
  console.log("topblocls:" + freeStandingInfoBlocks.length )
  for (let i = 0; i < freeStandingInfoBlocks.length; i++) {
    freeStandingInfoBlocks[i].onmousedown=dragMouseDown;
  }
}


/*Globals */
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
  var elmnt ="" ;



  function dragMouseDown(e) {
    e = e || window.event;
    e.preventDefault();  /* why? */
    elmnt = e.currentTarget;
    // get the mouse cursor position at startup:
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    // call a function whenever the cursor moves:
    document.onmousemove = elementDrag;
    console.log("start drag myclass " + elmnt.className + "id" + elmnt.id)
    svgContainerElement.style.pointerEvents = "none";
  }


  function elementDrag(e) {
    e = e || window.event;
    e.preventDefault();
    // calculate the new cursor position:
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    // set the element's new position: avoid going negative
    elmnt.style.top = Math.max(elmnt.offsetTop - pos2,0) + "px";  
    elmnt.style.left = Math.max(elmnt.offsetLeft - pos1,0) + "px";
    //console.log(" dragging myclass " + elmnt.className + "id" + elmnt.id)
  }

  function closeDragElement() {
     //console.log("close drag myclass " + elmnt.className + "id" + elmnt.id)
    // stop moving when mouse button is released:
    document.onmouseup = null;
    document.onmousemove = null;
    svgContainerElement.style.pointerEvents = "auto";
  }
