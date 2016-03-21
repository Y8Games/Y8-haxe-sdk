package idnet.js;
import haxe.ds.Option;
import haxe.Http;
import haxe.Json;
import haxe.Timer;
import haxe.Utf8;
import idnet.common.events.IDNetEvent;
import idnet.common.events.PostStatusEvent;
import idnet.common.FeedParameters;
import js.Browser;
import js.html.Document;
import js.html.ScriptElement;
import openfl.Lib;

class _Social extends SocialBase {
	
	//
	// Static helper variables
	//
	private static inline var SCRIPT_ID:String = 'id-jssdk';
	private static inline var HTTP_API_PATH:String = 'http://cdn.id.net/api/sdk.js';
	private static inline var HTTPS_API_PATH:String = 'https://scdn.id.net/api/sdk.js';
	
	//
	// Constructor
	//
	
    public function new() { 
		super();
		
		_document = Browser.document; 
		_unsafeWindow = cast _document.defaultView;
	}

	
	//
	// Variables
	//
	
	private var _document:Document;
	private var _unsafeWindow:Dynamic;
	private var _ID:Dynamic;
	
	//
	// API
	//
	/**
	 * This code will insert into dom a loader script for id net SDK
	 * 
	 * In the same moment a callback to 'window' will be set, for idnet SDK
	 * to call when it's ready
	 */
    override public function init():Void 
	{
		if (_document.getElementById(SCRIPT_ID) != null) {
			throw 'Error: Double id.net initialization';
			return;
		}
		
		var idnetSDKloader = _document.createScriptElement();
		idnetSDKloader.id = SCRIPT_ID;
		
		idnetSDKloader.src = _document.location.protocol == 'https:' ? HTTPS_API_PATH : HTTP_API_PATH;
		_document.head.insertBefore(idnetSDKloader, _document.getElementsByTagName('script')[0]);
		
		_unsafeWindow.idAsyncInit = asyncInit;
    }
	
	/**
	 * Make register attempt to ID. If sdk finds a cookie, it will 
	 * attempt to authorize instead.
	 */
	override public function register():Void 
	{
		_ID.register(registerCallback);
	}
	
	override public function loginPopup():Void 
	{
		_ID.login(registerCallback);
	}
	
	/**
	 * Post to you feed via ID.ui
	 */
	override public function postToFeed(params:FeedParameters):Void 
	{
		if (!authorized) {
			d.dispatchPostStatus(PostStatusEvent.FEED_POST_FAIL, null, PostStatusEvent.REASON_NOT_AUTHORIZED);
			return;
		}
		
		//todo: parameters should be validated here:
		
		_ID.ui(params.serialize(), feedPostCallback); 
	}
	
	
	//
	// ID.net sdk callbacks
	//
	/**
	 * At this point idnet SDK is fully loaded and ready to be called.
	 */
	private function asyncInit():Void 
	{
		_ID = _unsafeWindow.ID;
		
		_ID.Event.subscribe(IDNetEvent.ID_INITIALIZE_COMPLETE, onIDInitializeComplete);
		_ID.Event.subscribe(IDNetEvent.ID_AUTH_RESPONSE_CHANGE, onIDAuthResponseChange);
		
		_ID.init(this.params);
		_ID.GameAPI.init(params.appId, null, function(data, response) 
		{
			trace("GameAPI.initialize_complete, data: " + data);
		});
	}
	
	/**
	 * Notify completing/failing registration
	 */
	private function registerCallback(response:Dynamic):Void 
	{
		if (response == null) {
			d.dispatch(IDNetEvent.ID_AUTH_FAIL);
		} else {
			d.dispatch(IDNetEvent.ID_AUTH_COMPLETE);
		}
	}
	
	/**
	 * Notify completing/failing posting to feed
	 */
	private function feedPostCallback(response:Dynamic):Void
	{
		if (response == null || response.post_id == null) {
			d.dispatchPostStatus(PostStatusEvent.FEED_POST_FAIL, null, PostStatusEvent.REASON_UNKNOWN);
			
			// stub
			_document.defaultView.alert('post failed');
		} else {
			d.dispatchPostStatus(PostStatusEvent.FEED_POST_SUCCESS, response.post_id);
			
			// stub
			_document.defaultView.alert('successfully posted. check your feed.');
		}
	}
	
	
	//
	// Event listeners
	//
	private function onIDInitializeComplete():Void 
	{		
		trace('ID.initialize_complete');
		d.dispatch(IDNetEvent.ID_INITIALIZE_COMPLETE);
	}
	
	
	override public function setUseLocalStorage(value = false):Void
	{
		
	}
	
	override public function showLeaderBoard(table:String, highest:Bool = true, allowDuplicates:Bool = false, useMilliseconds:Bool = false):Void
	{
		var tableData:{table:String, highest:Bool, allowDuplicates:Bool, useMilliseconds:Bool};
		tableData = {
			table: table,
			highest: highest,
			allowDuplicates: allowDuplicates,
			useMilliseconds: useMilliseconds
		};
		
		_ID.GameAPI.Leaderboards.list(tableData);
	}
	
	override public function submitScore(table:String, score:Int, playerName:String, highest:Bool = true, allowDuplicates:Bool = false):Void
	{
		var scoreData: {table:String, points:Int, playerName:String, highest:Bool, allowDuplicates:Bool};
		scoreData = {
			table: table,
			points: score,
			playerName: playerName,
			highest: highest,
			allowDuplicates: allowDuplicates
		};
		_ID.GameAPI.Leaderboards.save(scoreData);
	}
	
	/*private function sendCallback(e:Dynamic):Void
	{
		if (e != null)
		{
			trace("data send callback");
			trace("e: " + e);
		}
		else
		{
			trace("for generation js code");
		}
	}	
	private function sendError(e:Dynamic):Void
	{
		if (e != null)
		{
			trace("data send error");
			trace("e: " + e);
		}
		else
		{
			trace("for generation js code");
		}
	}*/
	
	override public function setSaveData(field:String, myValue:Dynamic):Void
	{
		trace("[j] seSaveData: " + field + ": " + myValue);
		
		_ID.api('user_data/submit', 'POST', {key: field, value: myValue}, function(response){
			trace(response);
		});
	}	
	override public function getSaveData(field:String, callback:Dynamic->Dynamic):Void
	{
		trace("[j] getSaveData: " + field);
		
		_ID.api('user_data/retrieve', 'POST', {key: field}, callback);
	}
	override public function clearSaveData(field:String):Void
	{
		trace("[j] clearSaveData: " + field);
		
		_ID.api('user_data/remove', 'POST', {key: field}, function(response){
			trace(response);
		});
	}
	
	override public function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void
	{
		var achievement: {achievement:String, achievementkey:String, playerName:String, overwrite:Bool, allowDuplicates:Bool};
		
		achievement = {
			achievement: achName,
			achievementkey: achKey,
			playerName: playerName,
			overwrite: overwrite,
			allowDuplicates: allowDuplicates
		}
		
		_ID.GameAPI.Achievements.save(achievement, achievementsSaveCallback);
	}
	
	override public function achievementsList():Void
	{
		_ID.GameAPI.Achievements.list();
	}
	
	function achievementsSaveCallback():Void
	{
		d.dispatch(IDNetEvent.ACHIEVEMENT_UNLOCKED);
	}
	
	private function onIDAuthResponseChange(response:Dynamic):Void 
	{		
		Social.get_i().set_username("empty_name");
		Social.get_i().set_sessionKey("empty_key");
		
		untyped __js__('window.idnet_autologin = function(response){');
		untyped __js__('idnet.Social.get_i().set_username(response.user.nickname)');
		untyped __js__('idnet.Social.get_i().set_sessionKey(response.sessionKey)');
		//untyped __js__('console.log(idnet.Social.get_i().get_username())');
		//untyped __js__('console.log(idnet.Social.get_i().get_sessionKey())');
		//untyped __js__('Reg.stateManager.getCurrentState()._login();');
		untyped __js__('}');
		
		var autologinElement:ScriptElement = _document.createScriptElement();
		autologinElement.src = "https://www.id.net/api/user_data/autologin?app_id=" + params.appId + "&callback=idnet_autologin";
		_document.head.insertBefore(autologinElement, _document.getElementsByTagName('script')[0]);
		
		var autologinElement:ScriptElement = _document.createScriptElement();
		autologinElement.src = "//code.jquery.com/jquery-1.11.2.min.js";
		_document.head.insertBefore(autologinElement, _document.getElementsByTagName('script')[0]);
		
		
		authorized = response.status == 'ok';
		trace('ID.authResponse: isAuthorized: ' + authorized);
		d.dispatch(IDNetEvent.ID_AUTH_RESPONSE_CHANGE);
	}
}
