

var toggler;

//Wait for document load
if (document.readyState === 'loading') {  // Loading hasn't finished yet
  console.log("Adding initialiseInteraction event listener")
  document.addEventListener('DOMContentLoaded', initialiseDocumentInteraction);
} else {  // `DOMContentLoaded` has already fired
  initialiseDocumentInteraction();
}


function initialiseDocumentInteraction(){
    toggler = document.getElementsByClassName("box");
    
    var i;
    for (i = 0; i < toggler.length; i++) {
      toggler[i].addEventListener("click", function() {
        this.parentElement.querySelector(".nested").classList.toggle("active");
        this.classList.toggle("check-box");
      });
    }
}