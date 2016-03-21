package idnet;
import idnet.common.events.PostStatusEvent;
import idnet.common.FeedParameters;
import idnet.common.InitParameters;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.Lib;

interface IDispatcher {
	function dispatch(evName:String):Void;
	function dispatchPostStatus(evName:String, postId:String = null, failReason:String = null):Void;
}

class Social extends EventDispatcher implements IDispatcher {
	
	//
	// Singleton routines
	//
	
    private static var _instance:Social;
    private static var i(get, never):Social;
    public static function get_i():Social {

        if (_instance == null) _instance = new Social();
        return _instance;
    }
	
	@:isVar public var username(get, set):String;
	@:isVar public var sessionKey(get, set):String;
	
	public function set_username(newName)  
	{ 
		username = newName;
		return username;
	}
	public function get_username()  
	{ 
		return username;
	}
	public function set_sessionKey(newKey) 
	{ 
		sessionKey = newKey;
		return sessionKey;
	}
	public function get_sessionKey() 
	{ 
		return sessionKey;
	}	
	
	//
	// Constructor
	//

    public function new() {
		super();
		
        #if js
        _social = new idnet.js._Social();
        #elseif flash
        _social = new idnet.flash._Social();
        #end
    }

    private var _social:SocialBase;

	
	//
	// API
	//
	
    public function init(
			appId:String,
			appSecret:String, 
			verbose:Bool			= true,		// Display idnet messages
			showPreloader:Bool		= false,	// Display Traffic Flux preloader ad
			protection:Bool			= true,		// Enable information about sites that block links
			status:Bool 			= true, 
			responseType:String 	= 'code',
			redirectUri:String 		= 'https://mocksite.com/auth/idnet/callback',
			channelUrl:String 		= null,
			meta:Dynamic 			= null
		):Void
    {
		_social.injectDispatcher(this);
		#if js
		_social.injectInitParams(new InitParameters(appId, status, responseType, redirectUri, channelUrl, meta));
		#elseif flash
		//_social.injectInitParams(new InitParameters(Lib.current.stage, appId, appSecret, debug));
		_social.injectInitParams(new InitParameters(Lib.current.stage, appId, appSecret, verbose, showPreloader, protection));
		#end
		
        _social.init();
    }
	
	public function isAuthorized():Bool { return _social.authorized; }

	public function register():Void { _social.register(); }
	
	public function loginPopup():Void  {_social.loginPopup(); }
	
	public function postToFeed(params:FeedParameters):Void { _social.postToFeed(params); }
	
	public function logout():Void { _social.logout();  }
	
	#if flash
	public function sendImage(myImage:Sprite, imageType:String):Void { _social.sendImage(myImage, imageType); }
	#end
	
	public function setUseLocalStorage(value = false):Void
	{
		_social.setUseLocalStorage(value);
	}
	
	public function setSaveData(field:String, value:Dynamic):Void
	{
		_social.setSaveData(field, value);
	}
	
	public function getSaveData(field:String, callback:Dynamic->Dynamic):Void
	{
		_social.getSaveData(field, callback);
	}
	
	public function clearSaveData(field:String):Void
	{
		_social.clearSaveData(field);
	}
	
	public function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void
	{
		_social.achievementsSave(achName, achKey, playerName, overwrite, allowDuplicates);
	}
	
	public function achievementsList():Void
	{
		_social.achievementsList();
	}
	
	public function showLeaderBoard(table:String, highest:Bool = true, allowDuplicates:Bool = false, useMilliseconds:Bool = false):Void
	{
		_social.showLeaderBoard(table, highest, allowDuplicates, useMilliseconds);
	}
	
	public function submitScore(table:String, score:Int, playerName:String, highest:Bool = true, allowDuplicates:Bool = false):Void
	{
		_social.submitScore(table, score, playerName, highest, allowDuplicates);
	}
	
	//
	// Implemented from IDispatcher:
	//
	
	public function dispatch(evName:String):Void 
	{
		this.dispatchEvent(new Event(evName));
	}
	
	public function dispatchPostStatus(evName:String, postId:String = null, failReason:String = null):Void
	{
		this.dispatchEvent(new PostStatusEvent(evName, postId, failReason));
	}
}
