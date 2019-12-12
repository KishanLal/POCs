function loadPage(){
    var result = parent.adaptor.communicate("Current Player is: ")
    alert("Response from Swift \n"+result)
}
