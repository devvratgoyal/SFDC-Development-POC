public with sharing class GenericParser {
	
	private Map<String,String> responseMap {get;set;}
	
	public GenericParser(){
		responseMap = new Map<String,String>();
	}
	
	public Map<String,String> parseXMLResponse(String responseStr){
		
		Dom.Document doc = new Dom.Document(); 
        doc.load(responseStr);
		
		System.debug('doc.toXmlString():: Response XML' + doc.toXmlString());
		
		Dom.XMLNode rootElement = doc.getRootElement();
		
		System.debug('rootElement ' + rootElement);
		
		return parseXMLResponse(rootElement);	
	}
	
	public Map<String,String> parseXMLResponse(Dom.XMLNode rootElement){
		
		for(Dom.Xmlnode childElement : rootElement.getChildElements()){
			if(childElement.getText() != null && childElement.getText().trim() != '') {
				responseMap.put(childElement.getName(),childElement.getText());
			}
			if(childElement.getChildElements() != null && childElement.getChildElements().size() > 0){
				parseChildElement(childElement);
			}
		}
		
		return responseMap;
	}
	
	public Map<String,String> parseChildElement(Dom.XMLNode rootElement){
		
		for(Dom.Xmlnode childElement : rootElement.getChildElements()){
			if(childElement.getText() != null && childElement.getText().trim() != '') {
				responseMap.put(rootElement.getName()+'.'+childElement.getName(),childElement.getText());
			}
			if(childElement.getChildElements() != null && childElement.getChildElements().size() > 0){
				parseChildElement(childElement);
			}
		}		
		return responseMap;
	}
}