package idnet.common;

class InitParameters
{

	public var appId:String;

#if js
	public function new(
		appId:String,
		status:Bool,
		responseType:String,
		redirectUri:String,
		channelUrl:String = null,
		meta:Dynamic = null
	)
	{
		this.appId = appId;
		this.status = status;
		this.responseType = responseType;
		this.redirectUri = redirectUri;
		this.channelUrl = channelUrl;
		this.meta = meta;
	}
	public var status:Bool;
	public var responseType:String;
	public var redirectUri:String;
	public var channelUrl:String;
	public var meta:Dynamic;
	
	public function serialize():Dynamic
	{
		var serialized:Dynamic = 
		{
			appId: appId,
			status: status,
			responseType: responseType,
			redirectUri: redirectUri,
		}
		
		if (channelUrl != null) serialized.channelUrl = channelUrl;
		if (meta != null) serialized.meta = meta;
		
		return serialized;
	}
	
#elseif flash
	
	public function new(
		stageRef:openfl.display.Stage,
		appId:String,
		appSecret:String,
		verbose:Bool,
		showPreloader:Bool,
		protection:Bool
	) 
	{
		this.stageRef = stageRef;
		this.appId = appId;
		this.appSecret = appSecret;
		this.verbose = verbose;
		this.showPreloader = showPreloader;
		this.protection = protection;
	}
	public var stageRef:openfl.display.Stage;
	public var appSecret:String;
	public var verbose:Bool;
	public var showPreloader:Bool;
	public var protection:Bool;
#end
}