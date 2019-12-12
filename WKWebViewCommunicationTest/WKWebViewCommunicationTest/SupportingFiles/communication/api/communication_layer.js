function communicate(dataToSend)
{
	var responseText;
	responseText = toLMS(dataToSend);
	return responseText;
}

function toLMS(request) 
{
   if(navigator.userAgent.indexOf("iPhone")!=-1 || navigator.userAgent.indexOf("iPad")!=-1 || navigator.userAgent.indexOf("AppleWebKit")!=-1)
   {
       jsToNativeBridge.call(request);
       return jsToNativeBridgeResponse.responseText;
   }
   else{
      return window.android.sendToAndroid(encodeURIComponent(request));
     }
}

var jsToNativeBridgeResponse =
{
    responseText:'Blank'
};
                     
var jsToNativeBridge = 
{
    call:function call(args) 
    {        
        var iframe = document.createElement('iframe');
        iframe.setAttribute('src', 'tonative:::' + '' + ':::' + 'callback' + ':::' + encodeURIComponent(args));
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
        
        //For WKWebView uncomment this if need to use post message. Above code will execute for both UIWebView and WKWebView
        //window.webkit.messageHandlers.nativeCallback.postMessage('tonative:::' + '' + ':::' + 'callback' + ':::' + encodeURIComponent(args));
    },
    callFunction:function callFunction(functionName, args, callback)
    {        
        var iframe = document.createElement('iframe');
        iframe.setAttribute('src', 'tonative:::' + functionName + ':::' + callback+ ':::' + encodeURIComponent(JSON.stringify(args)));
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
    },
    callback : function jsToNativeBridgeCallback(response)
    {
        jsToNativeBridgeResponse.responseText = response;
    }
};

function getQueryStringValue (key)
{
  return decodeURIComponent(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURIComponent(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));
}

function EncodeText(value)
{
    return encodeURI(value).replace(/\%/g, '%25')
            .replace(/\&/g, '%26')
            .replace(/\`/g, '%60')
            .replace(/\+/g, '%2B')
            .replace(/\\/g, '%5C')
            .replace(/\{/g, '%7B')
            .replace(/\}/g, '%7D')
            .replace(/\[/g, '%5B')
            .replace(/\]/g, '%5D')
            .replace(/\"/g, '%22')
            .replace(/\;/g, '%3B')
            .replace(/\</g, '%3C')
            .replace(/\>/g, '%3E');
}
    
