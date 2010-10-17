		import flash.events.Event;
		import flash.events.NetStatusEvent;
		import flash.external.*;
		import flash.net.NetStream;
		import flash.net.SharedObject;
		import flash.net.URLRequest;
		
		import mx.collections.ArrayCollection;
		import mx.core.Application; 

		[Bindable] public var res:XML;

		NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF0;
		SharedObject.defaultObjectEncoding  = flash.net.ObjectEncoding.AMF0;

        public var nc:NetConnection;
        public var ns:NetStream;
        [Bindable] public var myuser:User;
        public var so_chat:SharedObject;
        [Bindable] public var users_dp:ArrayCollection = new ArrayCollection();
        public var nsInGoing:NetStream;

        [Bindable] public var canSendAgain:Boolean=true;
        public var myConfig:Config = new  Config();
		



public function userJoinNew(anuser:Object):void {
	//addUser(anuser);
}
public function userRemove(user:Object):void {
	//var username:String = user.username;
}


public function streamStatus(e:NetStatusEvent):void {	

}		


public function prepareStreams():void {
	so_chat = SharedObject.getRemote(myuser.channel, nc.uri,false);
	if (so_chat) {
		so_chat.client = this; // refers to the scope of application and public funtions
		so_chat.addEventListener(SyncEvent.SYNC, OnSync);
		so_chat.connect(nc);
	}
	nsInGoing = new NetStream(nc);
	nsInGoing.client = this;      
	nsInGoing.addEventListener(NetStatusEvent.NET_STATUS , streamStatus);
	nsInGoing.play(myuser.channel);
	listen_btn.enabled = true;
}
public function swicthListen():void {
	var vol:int = 1;
	if (listen_btn.selected) vol=0;
	if (nsInGoing) nsInGoing.soundTransform = new SoundTransform(vol);
}


public function removeUser(toWho:String , username:String):void {
}

public function onPlayStatus(info:Object):void {
}



private function loadResources(xmlURL : String) : void {  
	var myXMLURL:URLRequest = new URLRequest(xmlURL);  
	var myLoader:URLLoader = new URLLoader(myXMLURL);  
	myLoader.addEventListener("complete", xmlLoaded);  
}  
private function xmlLoaded(e:Event) : void {  
	res = XML( URLLoader(e.target).data); 
	initialiser2(); 
} 
public function initialiser():void {
	if(Config.DEBUG) {
		Application.application.parameters.channel = "Welcome";
	}
	ExternalInterface.addCallback("startListening" , startListening);
	ExternalInterface.addCallback("stopListening" , stopListening);
	ExternalInterface.addCallback("receive" , receive);

	var username:String = "user"+ Math.random();
	var admin:Boolean = false
	myuser = new User(username, admin);	
	myuser.channel = Application.application.parameters.channel;	
	loadResources(myConfig.xmlURL);		
}
public function startListening():void {
	listen_btn.selected = false;
	swicthListen();
}
public function stopListening():void {
	listen_btn.selected = true;
	swicthListen();
}
public function receive(txt:String):void {
	ExternalInterface.call("received",txt);
}

public function initialiser2():void {
	if (nc && nc.connected) {
		nc.close();
	}
  	nc = new NetConnection();			
	nc.client = this;
	var s:String = res.server + myuser.channel;
	nc.connect(s , myuser.id , myuser.username , myuser.channel);
	nc.addEventListener(NetStatusEvent.NET_STATUS , netStatusHandler);
}		



public function netStatusHandler(event:NetStatusEvent):void {
	switch (event.info.code) {
    	case "NetConnection.Connect.Success":
       		prepareStreams();
           	break;
	default:
		break;
    }
}


private function OnSync(event:SyncEvent):void {

}
public function getUserList(users:Object):void {
	
}

	
				