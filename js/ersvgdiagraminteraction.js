/* Global */
var svgObject
var myHTMLDoc

  window.addEventListener("load", function() {
    myHTMLDoc = document ; 
    svgObject = document.getElementById('svg-object');
    console.log("svgObject: " + svgObject);
    svgDoc = svgObject.contentDocument;
    console.log("svgDoc" + svgDoc)
    var svgR3 = svgDoc.getElementById('R3_hitarea');
    console.log("R3 is:",svgR3);
  });

/*function notify(id){
 var divElement = document.getElementById(id);
   divElement.style.display = 'block';
   divElement.style.visibility = 'visible';
   divElement.style.opacity = 1;} */


function showEntityTypeDetail(id){
   console.log('showEntityTypeDetail');
 var divElement = myHTMLDoc.getElementById(id + "_text");
 console.log(divElement);
 //divElement.setAttributeNS(null,'class', 'infotextboxpopped');
    //divElement.class='infotextboxpopped';
   divElement.style.display = 'block';
   divElement.style.visibility = 'visible';
   divElement.style.opacity = 1;
  }

function showAttributeDetail(id){
   console.log(id)
 var divElement = document.getElementById(id + "_text");

   divElement.setAttributeNS(null,'class', 'display:block;visibility:visible;opacity:1');
   //divElement.style.display = 'block';
   //divElement.style.visibility = 'visible';
      //divElement.style.opacity = 1;
  }

function showRelationshipDetail(id){
 var divElement = document.getElementById(id + "_text");
   divElement.style.display = 'block';
   divElement.style.visibility = 'visible';
   divElement.style.opacity = 1;
   var hitAreaElement = svgDoc.getElementById(id + "_hitarea");
   hitAreaElement.setAttributeNS(null,'class', 'relationshippopped');
   theseDiagonalElements = diagonal_elements[id];
   theseDiagonalElements.forEach(id => 
      svgDoc.getElementById(id + "_hitarea").setAttributeNS(null,'class', 'relationshipdiagonal')) ;
   theseRiserElements = riser_elements[id];
   theseRiserElements.forEach(id =>
      svgDoc.getElementById(id + "_hitarea").setAttributeNS(null,'class', 'relationshipriser')) ;
}

function closeallinfotextboxes(){
   var textboxes = document.getElementsByClassName("infotextbox");
   for(var i=0; i<textboxes.length; i++){
             textboxes[i].style.display='none';
   }  
   var infolist = document.getElementById("infolist");
   infolist.style.display = 'none';
                           }