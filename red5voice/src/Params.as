package
{
	public class Params
	{
		public var param_msg_serveur:Boolean=true;
		public var param_prives:Boolean=true;
		public var param_sounds:Boolean=true;
		public var param_music:Boolean=true;
		public var param_fontSize:String="11";
		public var param_mywebcam:Boolean=true;
		public function Params(param_msg_serveur:Boolean,param_prives:Boolean,param_sounds:Boolean,
		param_music:Boolean,param_fontSize:String,param_mywebcam:Boolean):void {
			this.param_msg_serveur=param_msg_serveur;
			this.param_prives=param_prives;
			this.param_sounds=param_sounds;
			this.param_music=param_music;
			this.param_fontSize=param_fontSize;
			this.param_mywebcam=param_mywebcam;
		}
									
		
	}
}