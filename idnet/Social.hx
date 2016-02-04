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
    public static var i(get, never):Social;
    private static function get_i():Social {

        if (_instance == null) _instance = new Social();
        return _instance;
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
