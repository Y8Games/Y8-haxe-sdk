package idnet.flash;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;
import haxe.Json;
import idnet.common.events.IDNetEvent;
import openfl.display.Sprite;

typedef Idnet = {
	>DisplayObject,
	
	//
	// Public properties
	//
	var data(default, default):Dynamic;		// data from last response
	var isLoggedIn(default, null):Bool;		// is user logged in
	var type(default, default):String;		// last type of response
	var userdata(default, null):Dynamic;	// last saved user data w/o connecting
	var _protection(default, null):Dynamic;
	var _cloudStorage(default, default):Dynamic;	// cloud saves
	
	//
	// Public methods
	//
	function getPlayersScore():Void;
	function init(stageRef:Stage, appId:String, appSecret:String, verbose:Bool, showPreloader:Bool, protection:Bool):Void;
	function InterfaceOpen():Bool;		 							// if interface is visible
	function removeUserData(key:String):Dynamic;					// 
	function retrieveUserData(key:String):Dynamic;					// 
//	function sessionTestResponse(_data:Dynamic):Dynamic;			// GR:TODO:some debug function i guess
	function submitScore(score:Int):Void;							// submit user score to scoreboard
	function submitUserData(key:String, data:Dynamic):Dynamic;		// submit user data
	function submitProfileImage(picture:Sprite, type:String):Void;	// picture profile
	function toggleInterface(type:String):Void;						// 'login', 'registration', 'scoreboard', or null
	function logout():Void;											// 
	function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool, allowDuplicates:Bool):Void;
}


class _Social extends SocialBase {
    
	//
	// Static helper variables
	//
	private static inline var EVENT:String = 'IDNET';
	private static inline var EVENT_LOGIN:String = 'login';
	private static inline var EVENT_SUBMIT:String = 'submit';
	private static inline var EVENT_RETRIEVE:String = 'retrieve';
	
	
	//
	// Constructor
	//
	public function new() {
		super();
    }

	
	//
	// Variables
	//
	private var _idnet:Idnet;
	private var _saveData:Dynamic;
	
	//
	// API
	//
	override public function init():Void 
	{
		//super.init();
		Security.allowInsecureDomain('*');
		Security.allowDomain('*');
		
		var context:LoaderContext = new LoaderContext();
		context.applicationDomain = ApplicationDomain.currentDomain;
		if (Security.sandboxType != 'localTrusted') {
			context.securityDomain = SecurityDomain.currentDomain;
		}
		
		var sdkUrl:String = "https://www.id.net/swf/idnet-client.swc?=" + Date.now();
		//var sdkUrl:String = "_";
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSWCLoaded);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onSWCLoadingFailed);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, onSWCLoadingFailed);
		loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSWCLoadingFailed);
		
		try
		{
			var request:URLRequest = new URLRequest(sdkUrl);
			loader.load(request, context);
		}
		catch (e:Dynamic) 
		{
			trace ('WARNING: e: ' + e);
		}
	}
	
	override public function register():Void 
	{
		if (_idnet.isLoggedIn) {
			d.dispatch(IDNetEvent.ID_AUTH_COMPLETE);
		} else {
			_idnet.toggleInterface('registration');
		}
	}
	
	override public function loginPopup():Void 
	{
		if (_idnet.isLoggedIn) {
			d.dispatch(IDNetEvent.ID_AUTH_COMPLETE);
		} else {
			_idnet.toggleInterface('login');
		}
	}
	
	override public function logout() 
	{
		if (_idnet.isLoggedIn) {
			this.authorized = false;
			_idnet.logout();
			d.dispatch(IDNetEvent.ID_LOGOUT);
		} else {
			//trace('already logged out');
		}
	}
	
	override public function sendImage(myImage:Sprite, imageType:String):Void 
	{
		if ((imageType == 'jpg') || (imageType == 'png'))
		{
			_idnet.submitProfileImage(myImage, imageType);
		}
	}
	
	//
	// ID.net sdk callbacks
	//
	
	private function onSWCLoaded(e:Event):Void 
	{
		//trace("onSWCLoaded");
		var loader = e.target.loader;
		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSWCLoaded);
		loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onSWCLoadingFailed);
		loader.contentLoaderInfo.removeEventListener(IOErrorEvent.NETWORK_ERROR, onSWCLoadingFailed);
		loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSWCLoadingFailed);
		
		if (e.target.content == null) 
		{
			d.dispatch(IDNetEvent.ID_INITIALIZE_FAILED);
			return;
		}
		
		_idnet = e.target.content;
		_idnet.addEventListener(EVENT, handleIDnetEvents);
		
		params.stageRef.addChild(_idnet);
		_idnet.init(
			params.stageRef, 
			params.appId, 
			params.appSecret, 
			params.verbose,
			params.showPreloader,
			params.protection
		);
		
		d.dispatch(IDNetEvent.ID_INITIALIZE_COMPLETE);
	}
	
	private function onSWCLoadingFailed(e:Event):Void 
	{
		trace("onSWCLoadingFailed");
		d.dispatch(IDNetEvent.ID_INITIALIZE_FAILED);
		
		//stub
		//throw e;
	}
	
	override public function setUseLocalStorage(value = false):Void
	{
		_idnet._cloudStorage.useLocalStorage = value;
	}
	
	override public function seSaveData(field:String, value:Dynamic):Void
	{
		_idnet._cloudStorage.setData(field, value);
	}
	
	override public function getSaveData(field:String, callback:Dynamic->Dynamic):Void
	{
		_saveData = null;
		
		try{
			_saveData = _idnet._cloudStorage.getData(field);
		} catch(e:Dynamic) {
			d.dispatch(IDNetEvent.GET_SAVE_FAIL);
		}
		Reflect.callMethod(this, callback, [_saveData]);
	}
	
	override public function clearSaveData(field:String):Void
	{
		try{
			_idnet._cloudStorage.clearData(field);
		} catch(e:Dynamic) {
			d.dispatch(IDNetEvent.GET_SAVE_FAIL);
		}
	}
	
	override public function achievementsSave(achName:String, achKey:String, playerName:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void
	{
		_idnet.achievementsSave(achName, achKey, playerName, overwrite, allowDuplicates);
	}
	
	private function handleIDnetEvents(e:Event):Void
	{
		switch(_idnet.type)
		{
			case 'achievementsSave':
			{
                if (_idnet.data.errorcode == 0) {
					d.dispatch(IDNetEvent.ACHIEVEMENT_UNLOCKED);
                }
            }		
			case 'cloudStorageReady':
			{
				d.dispatch(IDNetEvent.ID_SAVE_STORAGE_READY);
			}
			case 'login':
			{
				if (isError()) 
				{
					if (_idnet.data.error == 'Key not found' ) 
					{
						//stub
						return;
					}
					this.authorized = false;
					d.dispatch(IDNetEvent.ID_AUTH_FAIL);
					trace('Error: ' + _idnet.data.error);
				} 
				else 
				{
					Reg.userName = _idnet.data.user.nickname;
					Reg.sessionKey = _idnet.data.sessionKey;
					trace('logged in');
					this.authorized = true;
					d.dispatch(IDNetEvent.ID_AUTH_COMPLETE);
				}
			}
			case 'submit':
			{
				if (isError()) 
				{
					trace('Error: '+_idnet.data.error);
				} 
				else 
				{
					trace('Status: ' + _idnet.data.status);
					_idnet.toggleInterface('scoreboard');
				}
			}
			case 'retrieve':
			{
				if (isError()) 
				{
					trace('Error: '+_idnet.data.error);
				} 
				else 
				{
					trace('Key '+_idnet.data.key);
					trace('Data: '+_idnet.data.jsondata);
				}
			}
			case 'score':
			{
				if (isError()) 
				{
					trace('Error: '+_idnet.data.error);
				} 
				else 
				{
					trace(_idnet.data.error);
				}
			}
			case 'protection':
			{
				if (_idnet._protection.isBlacklisted()) 
				{
					d.dispatch(IDNetEvent.ID_BLACKLISTED);
				}
			}
			case 'profileImage':
			{
				var _json:Dynamic = Json.parse(_idnet.data);
			
				if (_json.success == true)
				{
					d.dispatch(IDNetEvent.ID_SEND_COMPLETE);
				}
				else if (_json.success == false)
				{
					d.dispatch(IDNetEvent.ID_SEND_FAIL);
				}
			}
			default:
			{
				trace('unhandled event type: ' + _idnet.type);
			}
		}
	}
	
	/*private function handleIDnetEvents(e:Event):Void
	{
		if (_idnet.type == 'login') {
			if (isError()) {
				if (_idnet.data.error == 'Key not found' ) {
					//stub
					return;
				}
				this.authorized = false;
				d.dispatch(IDNetEvent.ID_AUTH_FAIL);
				trace('Error: ' + _idnet.data.error);
			} else {
				Reg.userName = _idnet.data.user.nickname;
				Reg.sessionKey = _idnet.data.sessionKey;
				//trace('is logged in: ' + _idnet.isLoggedIn);
				//trace('Session Key: '+_idnet.data.sessionKey);
				//trace('Email: '+_idnet.data.user.email);
				//trace('Nickname: '+_idnet.data.user.nickname);
				//trace('Pid: ' + _idnet.data.user.pid);
				trace('logged in');
				this.authorized = true;
				d.dispatch(IDNetEvent.ID_AUTH_COMPLETE);
			}
		} else 
		if (_idnet.type == 'submit') {
			if (isError()) {
				trace('Error: '+_idnet.data.error);
			} else {
				trace('Status: ' + _idnet.data.status);
				_idnet.toggleInterface('scoreboard');
			}
		} else 
		if (_idnet.type == 'retrieve') {
			if (isError()) {
				trace('Error: '+_idnet.data.error);
			} else {
				trace('Key '+_idnet.data.key);
				trace('Data: '+_idnet.data.jsondata);
			}
		} else 
		if (_idnet.type == 'score') {
			if (isError()) {
				trace('Error: '+_idnet.data.error);
			} else {
				trace(_idnet.data.error);
			}
		} else
		if (_idnet.type == 'profileImage') {
			var _json:Dynamic = Json.parse(_idnet.data);
			
			if (_json.success == true)
			{
				d.dispatch(IDNetEvent.ID_SEND_COMPLETE);
			}
			else if (_json.success == false)
			{
				d.dispatch(IDNetEvent.ID_SEND_FAIL);
			}
		} else
		{
			trace('unhandled event type: ' + _idnet.type);
		}
	}*/
	
	private function isError():Bool { return _idnet.data.error != null && _idnet.data.error.length != 0; }
}
