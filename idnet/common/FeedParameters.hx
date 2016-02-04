package idnet.common;

class FeedParameters
{

	/**
	 * @param	link 			URL path to the game in the header of message
	 * @param	description		Post description
	 * @param	picture			URL to picture attached to post
	 * @param	name			Title of the post
	 * @param	caption			Sub-title of the post
	 * @param	message			If passed, will appear in the textInput at once
	 * @param	source			todo:unknown effect
	 * @param	redirect_uri	todo:unknown effect
	 */
	public function new(
		link:String,
		description:String,
		picture:String,
		name:String,
		caption:String,
		message:String = null,
		source:String = null,
		redirect_uri:String = null
	) 
	{
		this.link = link;
		this.description = description;
		this.picture = picture;
		this.name = name;
		this.caption = caption;
		this.message = message;
		this.source = source;
		this.redirect_uri = redirect_uri;
	}
	
	private var link:String;
	private var description:String;
	private var picture:String;
	private var name:String;
	private var caption:String;
	private var message:String;
	private var source:String;
	private var redirect_uri:String;
	
	#if js
	public function serialize():Dynamic
	{
		var serialized:Dynamic = 
		{
			method: "feed",
			link: this.link,
			description: this.description,
			picture: this.picture,
			name: this.name,
			caption: this.caption,
		};
		
		if (message != null) serialized.message = message;
		if (source != null) serialized.source = source;
		if (redirect_uri != null) serialized.redirect_uri = redirect_uri;
		
		return serialized;
	}
	#end
}