<?php

/*
+===========================================+
| Error Page File for WidgetFX.org by Stephen Chin                               |
| Adapted from Error Page File for Q-Zone by Quatrax                             |
| see: http://www.astahost.com/htaccess-files-usage-t9526.html                   |
+===========================================+
*/

/* Check Input */
$code = isset($_GET['error']) ? $_GET['error'] : '404';
/* Parse Error */
error_page($code);
exit;

function error_page($code = '404') {
/* Client Error 4xx */
$e['400'] = array('400 Bad Request', 'The request could not be understood by the server due to malformed syntax. The client should not repeat the request without modifications.');
$e['401'] = array('401 Unauthorized', 'The request requires user authentication. The client may repeat the request with a suitable Authorization. If the request already included Authorization credentials, then the this response indicates that authorization has been refused.');
$e['402'] = array('402 Payment Required', 'This code is reserved for future use.');
$e['403'] = array('403 Forbidden', 'The server understood the request, but is refusing to fulfill it. Authorization will not help and the request should not be repeated.');
$e['404'] = array('404 Not Found', 'The server has not found anything matching the requested url "'.$_SERVER['REQUEST_URI'].'" and no indication is given of whether the condition is temporary or permanent.');
$e['405'] = array('405 Method Not Allowed', 'The method specified in the Request-Line is not allowed for the resource identified by the requested url "'.$_SERVER['REQUEST_URI'].'" and the response must include an Allow header containing a list of valid methods for the requested resource.');
$e['406'] = array('406 Not Acceptable', 'The server has found a resource matching the requested url "'.$_SERVER['REQUEST_URI'].'" but not one that satisfies the conditions identified by the Accept and Accept-Encoding request headers.');
$e['407'] = array('407 Proxy Authentication Required', 'The client must first authenticate itself with the proxy. The proxy must return a Proxy-Authenticate header field containing a challenge applicable to the proxy for the requested resource. The client may repeat the request with a suitable Proxy-Authorization header field.');
$e['408'] = array('408 Request Timeout', 'The client did not produce a request within the time that the server was prepared to wait. The client may repeat the request without modifications at any later time.');
$e['409'] = array('409 Conflict', 'The request could not be completed due to a conflict with the current state of the resource.');
$e['410'] = array('410 Gone', 'The requested resource is no longer available at the server and no forwarding address is known. This condition is considered permanent. Clients with link editing capabilities delete references to the requested url "'.$_SERVER['REQUEST_URI'].'" after user approval.');
$e['411'] = array('411 Length Required', 'The server refuses to accept the request without a defined Content-Length. The client may repeat the request if it adds a valid Content-Length header field containing the length of the entity body in the request message.');
$e['412'] = array('412 Unless True', 'The condition given in the Unless request-header field evaluated to true when it was tested on the server');
$e['413'] = array('413 Request Entity Too Large', 'The requested document is bigger than the server wants to handle now. If the server thinks it can handle it later, it should include a Retry-After header.');
$e['414'] = array('414 Request URI Too Long', 'The URI is too long.');
$e['415'] = array('415 Unsupported Media Type', 'Request is in an unknown format.');
$e['416'] = array('416 Requested Range Not Satisfiable', 'Client included an unsatisfiable Range header in request.');
$e['417'] = array('417 Expectation Failed', 'Value in the Expect request header could not be met.');
/* Server Error 5xx */
$e['500'] = array('500 Internal Server Error', 'The server encountered an unexpected condition which prevented it from fulfilling the request.');
$e['501'] = array('501 Not Implemented', 'The server does not support the functionality required to fulfill the request. This is the appropriate response when the server does not recognize the request method and is not capable of supporting it for any resource.');
$e['502'] = array('502 Bad Gateway', 'The server, while acting as a gateway or proxy, received an invalid response from the upstream server it accessed in attempting to fulfill the request.');
$e['503'] = array('503 Service Unavailable', 'The server is currently unable to handle the request due to a temporary overloading or maintenance of the server. The implication is that this is a temporary condition which will be alleviated after some delay.');
$e['504'] = array('504 Gateway Timeout', 'The server, while acting as a gateway or proxy, did not receive a timely response from the upstream server it accessed in attempting to complete the request.');
$e['505'] = array('505 HTTP Version Not Supported', 'The server, while acting as a gateway or proxy, does not support version of HTTP indicated in request line.');
/* Check, default is 404 Not Found */
  $e[$code] = isset($e[$code]) ? $e[$code] : $e['404'];
/*  Remove the output buffer and turn off output buffering */
ob_get_clean(); set_time_limit(0);
/* Create Output */
$output = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<HTML><HEAD>
<META NAME="ROBOTS" CONTENT="NOINDEX, FOLLOW, NOARCHIVE">
<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; CHARSET=ISO-8859-1">
<META HTTP-EQUIV="CONTENT-STYLE-TYPE" CONTENT="text/css">
<META NAME="DESCRIPTION" CONTENT="'.$e[$code][0].'">
<TITLE>'.$e[$code][0].'</TITLE>
<STYLE>
body {
padding: 6px 24px 6px 14px;
font-family: Verdana, sans-serif;
}
a {
text-decoration: none;
}
a:hover {
text-decoration: underline;
}
p {
font-size: 15px;
}
h1 {
font-size: 32px;
}
small {
font-size: 11px;
}
address {
font-size: 13px;
}
hr {
border-style: dashed;
border-width: 2px 4px;
border-color: #8f8f8f;
margin-left: 0;
text-align: left;
width: 60%;
}
</STYLE>
</HEAD><BODY>
<H1>'.substr($e[$code][0], 4, strlen($e[$code][0])).'</H1>
&nbsp; '.wordwrap($e[$code][1], 64, "<BR>\n").'
<P>Go back &raquo; <A HREF="http://'.str_replace('http://', '', $_SERVER['SERVER_NAME']).'">WidgetFX.org</A> the Main Web Site</P>
<HR>
'.$_SERVER['SERVER_SIGNATURE'].'</BODY></HTML>';

/* Send the Headers */
if (!headers_sent()) {
 header("Content-Encoding: none");
 header("Cache-Control: no-store, no-cache");
 header("Cache-Control: post-check=0, pre-check=0");
 header("Pragma: no-cache");
 header("HTTP/1.1 ".$e[$code][0]);
 header("Status: ".substr($e[$code][0], 0, 3));
 header("Content-type: text/html");
 header("Content-Length: ".strlen($output));
}
/* Display Error */
echo $output;
return TRUE;
}

?>
