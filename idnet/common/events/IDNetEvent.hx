package idnet.common.events;

class IDNetEvent
{
	
	public static inline var ID_INITIALIZE_COMPLETE:String = 'id.init';
	public static inline var ID_INITIALIZE_FAILED:String = 'id.init.fail';
	public static inline var ID_AUTH_RESPONSE_CHANGE:String = 'auth.authResponseChange';
	
	public static inline var ID_AUTH_FAIL:String = 'auth.fail'; // user closed auth window
	public static inline var ID_AUTH_COMPLETE:String = 'auth.complete'; // authorize was a success
	public static inline var ID_LOGOUT:String = 'logout.complete'; // logout was a success
	
	public static inline var ID_SEND_FAIL:String = 'image.send.fail'; // image send failed
	public static inline var ID_SEND_COMPLETE:String = 'image.send.complete'; // image send was a success
	
	public static inline var ID_BLACKLISTED:String = 'blacklisted'; // this site is blacklisted
	public static inline var IS_SPONSOR:String = 'is_sponsor'; // this site is sponsor
	
	public static inline var ID_SAVE_STORAGE_READY:String = 'cloudStorageReady';
	public static inline var GET_SAVE_FAIL:String = 'save.get.fail';
	
	public static inline var ACHIEVEMENT_UNLOCKED:String = 'achievement.unlocked';

	public function new() { }
}