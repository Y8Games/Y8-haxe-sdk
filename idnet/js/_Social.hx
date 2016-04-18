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
import js.html.HTMLDocument;
import js.html.Event;
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
	
	private var _document:HTMLDocument;
	private var _unsafeWindow:Dynamic;
	
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
		_unsafeWindow.ID.register(registerCallback);
	}
	
	override public function loginPopup():Void 
	{
		_unsafeWindow.ID.login(registerCallback);
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
		
		_unsafeWindow.ID.ui(params.serialize(), feedPostCallback); 
	}
	
	
	//
	// ID.net sdk callbacks
	//
	/**
	 * At this point idnet SDK is fully loaded and ready to be called.
	 */
	private function asyncInit():Void 
	{		
		_unsafeWindow.ID.Event.subscribe(IDNetEvent.ID_INITIALIZE_COMPLETE, onIDInitializeComplete);
		//_unsafeWindow.ID.Event.subscribe(IDNetEvent.ID_AUTH_RESPONSE_CHANGE, onIDAuthResponseChange);
		
		_unsafeWindow.ID.init({appId: this.params.appId});
	}
	
	/**
	 * Notify completing/failing registration
	 */
	private function registerCallback(response:Dynamic):Void 
	{
		if (response != null && response.authResponse  != null && response.authResponse.details != null) {
			trace(response.authResponse.details.nickname);
			Social.get_i().set_username(response.authResponse.details.nickname );
		}
		
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
		
		_unsafeWindow.ID.GameAPI.init(params.appId, null, function(data, response) 
		{
			trace("GameAPI.initialize_complete, data: " + data);
		});
		_unsafeWindow.ID.Protection.isBlacklisted(function(blacklisted){
			trace("ID.isBlacklisted " + blacklisted);
			if(cast blacklisted) {
				d.dispatch(IDNetEvent.ID_BLACKLISTED);
			}
		});
		
		_unsafeWindow.ID.Protection.isSponsor(function(sponsor){
			trace("ID.isSponsor " + sponsor);
			if(cast sponsor) {
				d.dispatch(IDNetEvent.IS_SPONSOR);
			}
		});

		Social.get_i().set_username("empty_name");
		Social.get_i().set_sessionKey("empty_key");
		
		_unsafeWindow.window.idnet_autologin = function(response:Dynamic) {
			if(response != null && response.user != null) {
				Social.get_i().set_username(response.user.nickname);
				Social.get_i().set_sessionKey(response.sessionKey);
				Social.get_i().setAuthorized(true);
				Social.get_i().dispatch(IDNetEvent.ID_AUTH_COMPLETE);
				trace('ID.authResponse: isAuthorized: ' + authorized);
			}
		}
		
		/*untyped __js__('window.idnet_autologin = function(response){');
		untyped __js__('idnet.Social.get_i().set_username(response.user.nickname)');
		untyped __js__('idnet.Social.get_i().set_sessionKey(response.sessionKey)');
		authorized = true;
		idnet.Social.get_i().dispatch(IDNetEvent.ID_AUTH_COMPLETE);
		trace('ID.authResponse: isAuthorized: ' + authorized);

		untyped __js__('}');*/
		
		var autologinElement:ScriptElement = _document.createScriptElement();
		autologinElement.src = "https://www.id.net/api/user_data/autologin?app_id=" + params.appId + "&callback=window.idnet_autologin";
		_document.head.insertBefore(autologinElement, _document.getElementsByTagName('script')[0]);
				
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
		
		_unsafeWindow.ID.GameAPI.Leaderboards.list(tableData);
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
		_unsafeWindow.ID.GameAPI.Leaderboards.save(scoreData, onSubmitScoresCallback);
	}
	
	function onSubmitScoresCallback(aData: Dynamic) 
	{
		d.dispatch(IDNetEvent.ID_SCORES_SENDED);
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
		
		_unsafeWindow.ID.api('user_data/submit', 'POST', {key: field, value: myValue}, function(response){
			trace(response);
		});
	}	
	override public function getSaveData(field:String, callback:Dynamic->Dynamic):Void
	{
		trace("[j] getSaveData: " + field);
		
		_unsafeWindow.ID.api('user_data/retrieve', 'POST', {key: field}, callback);
	}
	override public function clearSaveData(field:String):Void
	{
		trace("[j] clearSaveData: " + field);
		
		_unsafeWindow.ID.api('user_data/remove', 'POST', {key: field}, function(response){
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
		
		_unsafeWindow.ID.GameAPI.Achievements.save(achievement, achievementsSaveCallback);
	}
	
	override public function achievementsList():Void
	{
		_unsafeWindow.ID.GameAPI.Achievements.list();
	}
	
	function achievementsSaveCallback():Void
	{
		d.dispatch(IDNetEvent.ACHIEVEMENT_UNLOCKED);
	}
	
	/*private function onIDAuthResponseChange(response:Dynamic):Void 
	{		
		Social.get_i().set_username("empty_name");
		Social.get_i().set_sessionKey("empty_key");
		
		trace("idnet_autologin");
		_unsafeWindow.idnet_autologin = function(response) {
			trace(response);
		}
		
		untyped __js__('window.idnet_autologin = function(response){');
		untyped __js__('idnet.Social.get_i().set_username(response.user.nickname)');
		untyped __js__('idnet.Social.get_i().set_sessionKey(response.sessionKey)');
		untyped __js__('}');
		
		var autologinElement:ScriptElement = _document.createScriptElement();
		autologinElement.src = "https://www.id.net/api/user_data/autologin?app_id=" + params.appId + "&callback=idnet_autologin";
		_document.head.insertBefore(autologinElement, _document.getElementsByTagName('script')[0]);
		
		
		authorized = response.status == 'ok';
		trace('ID.authResponse: isAuthorized: ' + authorized);
		d.dispatch(IDNetEvent.ID_AUTH_RESPONSE_CHANGE);
	}*/
}
