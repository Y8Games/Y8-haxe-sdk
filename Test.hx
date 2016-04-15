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
		Social.get_i().init("55af9f5b7765623f71000433", "9129ecc6335935a4350f84fab7fdfcd9acf15e56398678ee77d77e1e03a0d6e2");
		Social.get_i().addEventListener(IDNetEvent.ID_INITIALIZE_COMPLETE, onIDInitComplete);
		Social.get_i().addEventListener(IDNetEvent.ID_INITIALIZE_FAILED, onIDInitFailed);
		Social.get_i().addEventListener(IDNetEvent.ID_AUTH_COMPLETE, onIDAuthComplete);
		Social.get_i().addEventListener(IDNetEvent.ID_BLACKLISTED, onIDBlacklisted);
		Social.get_i().addEventListener(IDNetEvent.IS_SPONSOR, onIDSponsor);
		Social.get_i().addEventListener(IDNetEvent.ACHIEVEMENT_UNLOCKED, onIDAchiviementUnlocked);
	}
	
	private function onIDAchiviementUnlocked(e:Event):Void 
	{
		trace("IDNetEvent.ACHIEVEMENT_UNLOCKED");
	}
	
	private function onIDSponsor(e:Event):Void 
	{
		trace("Domain in sponsor list");
	}
	
	private function onIDBlacklisted(e:Event):Void 
	{
		trace("Domain in blacklist");
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
	
	//Leaderboard
}
