package idnet.common.events;
import openfl.events.Event;

class PostStatusEvent extends Event
{
	public static inline var FEED_POST_SUCCESS:String = 'feed.post.success';
	public static inline var FEED_POST_FAIL:String = 'feed.post.fail';
	
	public static inline var REASON_NOT_AUTHORIZED:String = 'not.authorized';
	public static inline var REASON_UNKNOWN:String = 'unknown';
	
	public function new(type:String, postId:String = null, failReason:String = null)
	{
		super(type);
		
		if (postId == null && failReason == null) {
			throw "PostStatusEvent: Either postId or failReason should be supplied";
		}
		
		_postId = postId;
		_failReason = failReason;
	}
	
	private var _postId:String;
	public var postId(get, never):String;
	private function get_postId():String { return _postId; }
	
	private var _failReason:String = null;
	public var failReason(get, never):String;
	private function get_failReason():String { return _failReason; }
}