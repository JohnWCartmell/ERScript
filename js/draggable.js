// Make the DIV elements of class infoboxContainer draggable by its header of class infoboxHeader.


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

  const freeStandingInfoBlocks = document.querySelectorAll(".infoboxHeader");
  console.log("topblocls:" + freeStandingInfoBlocks.length )
  for (let i = 0; i < freeStandingInfoBlocks.length; i++) {
    freeStandingInfoBlocks[i].onmousedown=dragMouseDown;
  }
}

/*Globals */
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
  var infoboxElmnt ="" ;

  function dragMouseDown(e) {
    e = e || window.event;
    e.preventDefault();  /* why? */
    infoboxElmnt = e.currentTarget.parentNode;
    console.log("start drag myclass '" + infoboxElmnt.className + "'' id: " + infoboxElmnt.id)
    console.log("visibility",infoboxElmnt.style.visibility)

    // get the mouse cursor position at startup:
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    // call a function whenever the cursor moves:
    document.onmousemove = elementDrag;
    console.log("continue drag myclass " + infoboxElmnt.className + "id" + infoboxElmnt.id)
    svgContainerElement.style.pointerEvents = "none";
  }


  function elementDrag(e) {
    e = e || window.event;
    e.preventDefault();
    // calculate the new cursor position:
    pos1 = pos3 - e.clientX
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    // set the element's new position: avoid going negative
    infoboxElmnt.style.top = Math.max(infoboxElmnt.offsetTop - pos2,0) + "px";  
    infoboxElmnt.style.left = Math.max(infoboxElmnt.offsetLeft - pos1,0) + "px";
  }

  function closeDragElement() {
    // stop moving when mouse button is released:
    document.onmouseup = null;
    document.onmousemove = null;
    svgContainerElement.style.pointerEvents = "auto";
  }
