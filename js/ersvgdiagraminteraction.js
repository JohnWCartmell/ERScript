function notify(id){
 var divElement = document.getElementById(id);
   divElement.style.display = 'block';
   divElement.style.visibility = 'visible';
   divElement.style.opacity = 1;
   var yinfolist = document.getElementById('infolist');
   yinfolist.style.display = 'block';}

function closeallinfotextboxes(){
   var textboxes = document.getElementsByClassName("infotextbox");
   for(var i=0; i<textboxes.length; i++){
             textboxes[i].style.display='none';
   }  
   var infolist = document.getElementById("infolist");
   infolist.style.display = 'none';
                           }