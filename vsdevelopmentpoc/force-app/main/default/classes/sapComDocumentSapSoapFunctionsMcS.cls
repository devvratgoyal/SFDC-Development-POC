//Generated by wsdl2apex

public class sapComDocumentSapSoapFunctionsMcS {
    public class Bapiret2 {
        public String Type_x;
        public String Id;
        public String Number_x;
        public String Message;
        public String LogNo;
        public String LogMsgNo;
        public String MessageV1;
        public String MessageV2;
        public String MessageV3;
        public String MessageV4;
        public String Parameter;
        public Integer Row;
        public String Field;
        public String System_x;
        private String[] Type_x_type_info = new String[]{'Type','urn:sap-com:document:sap:rfc:functions','char1','1','1','false'};
        private String[] Id_type_info = new String[]{'Id','urn:sap-com:document:sap:rfc:functions','char20','1','1','false'};
        private String[] Number_x_type_info = new String[]{'Number','urn:sap-com:document:sap:rfc:functions','numeric3','1','1','false'};
        private String[] Message_type_info = new String[]{'Message','urn:sap-com:document:sap:rfc:functions','char220','1','1','false'};
        private String[] LogNo_type_info = new String[]{'LogNo','urn:sap-com:document:sap:rfc:functions','char20','1','1','false'};
        private String[] LogMsgNo_type_info = new String[]{'LogMsgNo','urn:sap-com:document:sap:rfc:functions','numeric6','1','1','false'};
        private String[] MessageV1_type_info = new String[]{'MessageV1','urn:sap-com:document:sap:rfc:functions','char50','1','1','false'};
        private String[] MessageV2_type_info = new String[]{'MessageV2','urn:sap-com:document:sap:rfc:functions','char50','1','1','false'};
        private String[] MessageV3_type_info = new String[]{'MessageV3','urn:sap-com:document:sap:rfc:functions','char50','1','1','false'};
        private String[] MessageV4_type_info = new String[]{'MessageV4','urn:sap-com:document:sap:rfc:functions','char50','1','1','false'};
        private String[] Parameter_type_info = new String[]{'Parameter','urn:sap-com:document:sap:rfc:functions','char32','1','1','false'};
        private String[] Row_type_info = new String[]{'Row','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] Field_type_info = new String[]{'Field','urn:sap-com:document:sap:rfc:functions','char30','1','1','false'};
        private String[] System_x_type_info = new String[]{'System','urn:sap-com:document:sap:rfc:functions','char10','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'Type_x','Id','Number_x','Message','LogNo','LogMsgNo','MessageV1','MessageV2','MessageV3','MessageV4','Parameter','Row','Field','System_x'};
    }
    public class binding {
        public String endpoint_x = 'http://125.18.111.84:8000/sap/bc/srt/rfc/sap/zwbs_vendor_insert/800/zwbs_vendor_insert/binding';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style', 'sapComDocumentSapSoapFunctionsMcS', 'urn:sap-com:document:sap:rfc:functions', 'sapComDocumentSapRfcFunctions'};
        public sapComDocumentSapSoapFunctionsMcS.Bapiret2 ZvendorInsert(String Address,String City,String CountryKey,String District,String Lifnr,String Name1,String Name2,String Name3,String Name4,String PoBox1,String PoBox2,String PostalCode,String Regio,String Street) {
            sapComDocumentSapSoapFunctionsMcS.ZvendorInsert_element request_x = new sapComDocumentSapSoapFunctionsMcS.ZvendorInsert_element();
            sapComDocumentSapSoapFunctionsMcS.ZvendorInsertResponse_element response_x;
            request_x.Address = Address;
            request_x.City = City;
            request_x.CountryKey = CountryKey;
            request_x.District = District;
            request_x.Lifnr = Lifnr;
            request_x.Name1 = Name1;
            request_x.Name2 = Name2;
            request_x.Name3 = Name3;
            request_x.Name4 = Name4;
            request_x.PoBox1 = PoBox1;
            request_x.PoBox2 = PoBox2;
            request_x.PostalCode = PostalCode;
            request_x.Regio = Regio;
            request_x.Street = Street;
            Map<String, sapComDocumentSapSoapFunctionsMcS.ZvendorInsertResponse_element> response_map_x = new Map<String, sapComDocumentSapSoapFunctionsMcS.ZvendorInsertResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZvendorInsert',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZvendorInsertResponse',
              'sapComDocumentSapSoapFunctionsMcS.ZvendorInsertResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Return_x;
        }
    }
    public class ZvendorInsert_element {
        public String Address;
        public String City;
        public String CountryKey;
        public String District;
        public String Lifnr;
        public String Name1;
        public String Name2;
        public String Name3;
        public String Name4;
        public String PoBox1;
        public String PoBox2;
        public String PostalCode;
        public String Regio;
        public String Street;
        private String[] Address_type_info = new String[]{'Address','urn:sap-com:document:sap:rfc:functions','char10','0','1','false'};
        private String[] City_type_info = new String[]{'City','urn:sap-com:document:sap:rfc:functions','char35','0','1','false'};
        private String[] CountryKey_type_info = new String[]{'CountryKey','urn:sap-com:document:sap:rfc:functions','char3','0','1','false'};
        private String[] District_type_info = new String[]{'District','urn:sap-com:document:sap:rfc:functions','char35','0','1','false'};
        private String[] Lifnr_type_info = new String[]{'Lifnr','urn:sap-com:document:sap:rfc:functions','char10','0','1','false'};
        private String[] Name1_type_info = new String[]{'Name1','urn:sap-com:document:sap:rfc:functions','char35','0','1','false'};
        private String[] Name2_type_info = new String[]{'Name2','urn:sap-com:document:sap:rfc:functions','char35','0','1','false'};
        private String[] Name3_type_info = new String[]{'Name3','urn:sap-com:document:sap:rfc:functions','char35','0','1','false'};
        private String[] Name4_type_info = new String[]{'Name4','urn:sap-com:document:sap:rfc:functions','char35','0','1','false'};
        private String[] PoBox1_type_info = new String[]{'PoBox1','urn:sap-com:document:sap:rfc:functions','char10','0','1','false'};
        private String[] PoBox2_type_info = new String[]{'PoBox2','urn:sap-com:document:sap:rfc:functions','char10','0','1','false'};
        private String[] PostalCode_type_info = new String[]{'PostalCode','urn:sap-com:document:sap:rfc:functions','char10','0','1','false'};
        private String[] Regio_type_info = new String[]{'Regio','urn:sap-com:document:sap:rfc:functions','char3','0','1','false'};
        private String[] Street_type_info = new String[]{'Street','urn:sap-com:document:sap:rfc:functions','char35','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'Address','City','CountryKey','District','Lifnr','Name1','Name2','Name3','Name4','PoBox1','PoBox2','PostalCode','Regio','Street'};
    }
    public class ZvendorInsertResponse_element {
        public sapComDocumentSapSoapFunctionsMcS.Bapiret2 Return_x;
        private String[] Return_x_type_info = new String[]{'Return','urn:sap-com:document:sap:soap:functions:mc-style','Bapiret2','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'Return_x'};
    }
}