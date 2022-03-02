public with sharing class FB_JSONParser_WrapperClass
{
	public class Albums
	{
		public Data[] datas;
		public Albums()
		{
			this.datas = new List<Data>();
		}
	}	
	public class Data
	{
         public String id{get;set;}
         public String name{get;set;}
         public String location{get;set;}
         public String link{get;set;}
         public String cover_photo{get;set;}
         public String privacy{get;set;}
         public Integer count{get;set;}
         public String type{get;set;}
         public String created_time{get;set;}
         public String updated_time{get;set;}
         public Boolean can_upload{get;set;}
    	 public Likes[] UserLike;
    	 public Comments[] UserComments;
         
         public Data(String Id,String name,String loc,String link,String covpic,String privacy,Integer noscount,String albumtype,String createdtime,String updttime,Boolean canupload)
         {
         	this.id = Id;
         	this.name = name;
         	this.location = loc;
         	this.link = link;
         	this.cover_photo = covpic;
         	this.privacy = privacy;
         	this.count = noscount;
         	this.type = albumtype;
         	this.created_time = createdtime;
         	this.updated_time = updttime;
         	this.can_upload = canupload;
         	this.UserLike = new List<Likes>(); 
         	this.UserComments = new List<Comments>();
         }
	}
	
	public class Likes
	{
		public String id{get;set;}
		public String name{get;set;}
		
		public Likes(String id,String name)
		{
			this.id = id;
			this.name = name;		
		}
	}
	
	public class Comments
	{
		public String id{get;set;}
		public String message{get;set;}
		public String can_remove{get;set;}
		public String created_time{get;set;}
		public Integer like_count{get;set;}
		public Boolean user_likes{get;set;}
		
		public Comments(String id,String message,String canrem,String crtdtime,Integer likecount,Boolean userlike)
		{
			this.id = id;
			this.message = message;
			this.can_remove = canrem;
			this.created_time = crtdtime;
			this.like_count = likecount;
			this.user_likes = userlike;
		}
	
	}
	
	
	public Boolean JSONParsing(String JSONData)
	{
	/*	//Map<String, Object> frMap = (Map<String, Object>)JSON.deserializeUntyped(JSONdata);
		//List<Object> frObj = (List<Object>)frMap.get('data');
		//system.debug('-----frObj-------'+frObj[0]);
		//Albums al = (Albums)JSON.deserialize(JSONData,FB_JSONParser_WrapperClass.Albums.class);
		
		Map<String, Object> frMap = (Map<String, Object>)JSON.deserializeUntyped(JSONdata);
		system.debug('-----frMap-------'+frMap);
		List<Object> frObj = (List<Object>)frMap.get('data');
		system.debug('----------------- LIST SIZE = frObj ----------------------' +frObj.size());
		system.debug('------------- KEY ID --------------' +frMap.keySet());
		
		for(integer i=0;i<5;i++)
		{
			system.debug('---INSIDE LOOP--frObj-------'+frObj[i]);
		}
		
		system.debug('-----frObj-------'+frObj[0]);
		
		Map<String, Object> frMapFinal = (Map<String, Object>) frObj[0];
		system.debug('-----frMapFinal-------'+frMapFinal);		
		//List<Object> commentList = (List<Object>)frMapFinal.get('comments');
		//system.debug('----------------- commentList-----------------'+commentList);			
		
	
	
		Map<String, Object> commentmap = (Map<String, Object>)JSON.deserializeUntyped(JSONdata);
		List<Object> commentObj = (List<Object>)commentmap.get('comments');
		system.debug('-----commentObj-------'+commentObj[0]);
		
			
		if(al != null)
		{
			system.debug('<<<<<<<<<<<<<<<<<< al is full >>>>>>>>>>>>>>>>>>>>>');
			return true;
		}
		else
		{
			system.debug('<<<<<<<<<<<<<<<<<< al is empty >>>>>>>>>>>>>>>>>>>>>');
			return false;
		}*/
		
		
		
		
		
		return true;
	}
	

}