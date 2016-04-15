package;

import flash.events.Event;
import idnet.common.events.IDNetEvent;
import idnet.Social;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author Codir
 */

class Test extends Sprite 
{

	public function new() 
	{
		super();
		Social.get_i().init("55af9f5b7765623f71000433", "9129ecc6335935a4350f84fab7fdfcd9acf15e56398678ee77d77e1e03a0d6e2"); //Initialization app with appKey and appSecret from https://www.id.net/applications/
		Social.get_i().addEventListener(IDNetEvent.ID_INITIALIZE_COMPLETE, onIDInitComplete); //Callback on successful initialization
		Social.get_i().addEventListener(IDNetEvent.ID_INITIALIZE_FAILED, onIDInitFailed); //Callback on failed initialization
		
		//--------Authorization--------//
		Social.get_i().addEventListener(IDNetEvent.ID_AUTH_COMPLETE, onIDAuthComplete); //Callback calling, when authorization is complete successfully
		
		Social.get_i().loginPopup(); //Show IDNet UI - Login popup
		Social.get_i().register(); //Show IDNet UI - Register popup
		
		Social.get_i().get_username(); //Return username {String}
		
		Social.get_i().isAuthorized(); //Return true if, user authorized {Bool}
		Social.get_i().logout(); //Logout
		
		//--------Protection API--------//
		Social.get_i().addEventListener(IDNetEvent.ID_BLACKLISTED, onIDBlacklisted); //Callback calling, if domain in blacklist
		Social.get_i().addEventListener(IDNetEvent.IS_SPONSOR, onIDSponsor); //Callback calling, if domain in sponsor list
		
		//--------Leaderboards--------//
		Social.get_i().submitScore("Leaderboard", 1, Social.get_i().get_username()); //Submit score to leaderboard with "Leaderboard" name from https://www.id.net/applications/
		Social.get_i().showLeaderBoard("Leaderboard"); //Show IDNet UI - Leaderboard with "Leaderboard" name from https://www.id.net/applications/
	
		//--------Cloud saves--------//
		Social.get_i().setSaveData("field", "value"); //Save data "value" to cloud saves with "field" name
		Social.get_i().getSaveData("field", function(responce:Dynamic) { } ); //Return data from cloud saves with "field" name
		Social.get_i().clearSaveData("field"); //Clear data in cloud saves with "field" name
		
		//--------Achievements--------//
		Social.get_i().achievementsSave("achievementName", "achievementKey", Social.get_i().get_username()); //Unlock achievement with "achievementName" name and "achievementKey" key
		Social.get_i().addEventListener(IDNetEvent.ACHIEVEMENT_UNLOCKED, onIDAchiviementUnlocked); //Callback calling, after unlocking achievement
		
		Social.get_i().achievementsList(); //Show IDNet UI - Achievements list
	}
	
	private function onIDAuthComplete(e:Event):Void 
	{
		trace("IDNetEvent.ID_AUTH_COMPLETE");
		trace("Nickname: "+Social.get_i().get_username());
	}
	
	private function onIDInitFailed(e:Event):Void 
	{
		trace("IDNetEvent.ID_INITIALIZE_FAILED");
	}
	
	private function onIDInitComplete(e:Event):Void 
	{
		trace("IDNetEvent.ID_INITIALIZE_COMPLETE");
	}
	
	private function onIDSponsor(e:Event):Void 
	{
		trace("Domain in sponsor list");
	}
	
	private function onIDBlacklisted(e:Event):Void 
	{
		trace("Domain in blacklist");
	}

	private function onIDAchiviementUnlocked(e:Event):Void 
	{
		trace("IDNetEvent.ACHIEVEMENT_UNLOCKED");
	}
}
