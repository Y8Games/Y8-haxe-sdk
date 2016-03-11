package idnet;
import idnet.common.FeedParameters;
import idnet.common.InitParameters;
import idnet.Social.IDispatcher;
import openfl.display.Sprite;

class SocialBase
{
	public function new() {	}
	
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
	
	public function setUseLocalStorage(value = false):Void
	{
		//stub
	}
	
	public function seSaveData(field:String, value:Dynamic):Void
	{
		//stub
	}
	
	public function getSaveData(field:String, callback:Dynamic->Dynamic):Void
	{
		//stub
	}
	
	public function clearSaveData(field:String):Void
	{
		//stub
	}
	
	public function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void
	{
		//stub
	}
	
	public function achievementsList():Void
	{
		//stub
	}
}