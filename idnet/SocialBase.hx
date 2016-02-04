package idnet;
import idnet.common.FeedParameters;
import idnet.common.InitParameters;
import idnet.Social.IDispatcher;
import openfl.display.Sprite;

class SocialBase
{
	public function new() { }
	
	private var params:InitParameters;
	private var d:IDispatcher;
	
	@:allow(idnet.Social)
	private var authorized:Bool = false;
	
	@:allow(idnet.Social)
	private function injectInitParams(params:InitParameters):Void
	{
		this.params = params;
	}
	
	@:allow(idnet.Social)
	private function injectDispatcher(dispatcher:IDispatcher):Void 
	{
		this.d = dispatcher;
	}
	
    public function init():Void 
	{
		//stub
    }

	public function register():Void 
	{
		//stub
	}
	
	public function loginPopup():Void 
	{
		//stub
	}
	
	public function sendImage(myImage:Sprite, imageType:String):Void 
	{
		//stub
	}
	
	public function postToFeed(params:FeedParameters):Void 
	{
		//stub
	}
	
	public function logout() 
	{
		//stub
	}
}