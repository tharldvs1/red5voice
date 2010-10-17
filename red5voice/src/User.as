package
{

	[Bindable] public class User {
		public var id:int;
		public var username:String;
		public var admin:Boolean;
		public var channel:String="friends";	
		public var webcam:Boolean;

		public function User(username:String , admin:Boolean):void {
			this.username=username;
			this.admin=admin;

		}	
	}

}	
