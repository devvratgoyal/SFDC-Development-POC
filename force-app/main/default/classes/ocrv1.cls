public class ocrv1 {            

    //read file contents, sent to http://www.ocrwebservice.com/api/restguide and get ocr response                       

    public static void func1() {                
        StaticResource sr = [SELECT Id, name, Body FROM StaticResource where name = 'Simple_Survey_Intro' LIMIT 1];             
        String b64String = EncodingUtil.base64Encode(sr.Body);              
        String hexString = EncodingUtil.convertToHex(sr.Body);              
        system.debug('\n= '+b64String +'\n hex= '+hexString);                               
        
        Http http = new Http();             
        HttpRequest  request = new HttpRequest();               
        request.setMethod('POST');              
        request.setEndpoint('http://www.ocrwebservice.com/restservices/processDocument?language=english&pagerange=1-5&gettext=true&outputformat=doc');              
        request.setHeader('Authorization', 'Basic TUFOTkhBUkxFRU46OUVFRkMwRjEtREQ1RC00QUYxLUFGMzMtRDQ4MzhGQUU4MERE');               
        request.setBody(b64String);             
        HttpResponse response = http.send(request);             
        system.debug('\nponse = ' + response.getBody());                
        }       
}