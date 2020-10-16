/* REXX */
/*
 * httpsput: Securely connect to a server and issue a PUT request
 * For syntax: httpsput -?
 */
trace 'o'

verbose=0
user=''
password=''
url=''
infile=''
outfile=''
keyring='*AUTH*/*'
clientauthlabel=''
tracefile=''

argc=__argv.0
firstAfter=argc+1
__argv.firstAfter=''
urlIndex=firstAfter
do i= 2 to argc
  opt=__argv.i
  if (SUBSTR(opt,1,1) <> '-') then do
    urlIndex=i
    leave
  end
  select
    when opt='-v' then do
      verbose=1
      next=i+1
      tracefile=__argv.next
      i=next
    end
    when opt='-?' then do
      Call Syntax
    end
    when opt='-V' then do
      call SayErr 'httpsput V101' 
      Return 0
    end
    when opt='-l' then do
      next=i+1
      clientauthlabel=__argv.next
      i=next
    end
    when opt='-r' then do
      next=i+1
      keyring=__argv.next
      i=next
    end
    when opt='-i' then do
      next=i+1
      infile=__argv.next
      i=next
    end
    when opt='-o' then do
      next=i+1
      outfile=__argv.next
      i=next
    end
    when opt='-u' then do
      next=i+1
      userpassword=__argv.next
      parse var userpassword user':'password 
      i=next
    end
    otherwise do
      call SayErr 'Unknown Option: ' opt ' ignored'
    end
  end
end
if password <> '' then do
  clientauthlabel=''
end 
url=__argv.urlIndex

if url == '' then do
  call Syntax
end

parse var url 'https://'connection'/'requestPath .

if connection == '' || requestPath == '' then do
  call SayErr 'URL not in valid format.'
  call Syntax
end

parse var connection connectionURI':'connectionPort

if connectionPort == '' then do
  connectionPort = 443
end

 call readData infile

 call HTTP_getToolkitConstants

 connectionHandle=HTTP_hwthinit(verbose, HWTH_HANDLETYPE_CONNECTION)
 call HTTP_setupConnection verbose, connectionURI, connectionPort, tracefile, keyring, clientauthlabel
 call HTTP_connect verbose

 requestHandle=HTTP_hwthinit(verbose, HWTH_HANDLETYPE_HTTPREQUEST)
 call HTTP_setupRequest verbose, user, password, requestPath, connectionURI, "HWTH_HTTP_REQUEST_PUT", requestBody

 ExpectedResponseStatus = 200
 EmptyResponseStatus = 204
 responseBody = ''
 responseStatusCode=HTTP_request(verbose)

 if ResponseStatusCode == ExpectedResponseStatus then do
    call writeData outfile
 end
 else do
    If ResponseStatusCode <> EmptyResponseStatus then do
      call SayErr 'Bad response received: ' ResponseStatusCode ' from http request.' 
      exit 16
    End
 end

 call HTTP_terminate verbose, requestHandle, HWTH_NOFORCE
 call HTTP_disconnect verbose
 call HTTP_terminate verbose, connectionHandle, HWTH_NOFORCE
 call closeToolkitTrace verbose, traceDD

 exit 0

Syntax:Procedure
Trace 'o'
  call SayErr "Syntax: httpsput [-i <infile>|-o <outfile>|-v <tracefile>|-u <user:password>|-l <client-certificate-label>|-r <key-ring>]* <url>"
  call SayErr "  -V  : print out the version of httpsput in the form: httpsput Vvrm (currently V101)"
  call SayErr "  -i  : location to read input from (default is stdin). No data translation performed"
  call SayErr "  -o  : location to write output to (default is stdout). No data translation performed"
  call SayErr "  -v  : verbose output to stderr and detailed trace file written to <tracefile>"
  call SayErr "  -u  : user and password to be passed to <url>. Defaults to no userid or password"
  call SayErr "  -l  : client certificate label to use instead of general SSL CA lookup"
  call SayErr "  -r  : SSL keyring to use instead of default AUTH*/*"
  call SayErr " <url>: web location, in the form https://<uri>/<path>" 
exit 4
