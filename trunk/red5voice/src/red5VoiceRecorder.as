		import flash.events.Event;
		import flash.events.NetStatusEvent;
		import flash.external.*;
		import flash.media.Microphone;
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

       	public var mic:Microphone;
        public var nsInGoing:NetStream,nsOutGoing:NetStream;

        [Bindable] public var canSendAgain:Boolean=true;
        public var myConfig:Config = new  Config();
		
		[Bindable] public var xml: XML;
		public var loader:URLLoader = new URLLoader();

		
private function drawMicLevel():void {
	if(!mic) return;
	micLevel.setProgress(mic.activityLevel , 100);
	setTimeout(drawMicLevel,50);
}

public function getUserByUsername(username:String):Object {
	for (var i:int=0;i<users_dp.length;i++)	{
		if (users_dp.getItemAt(i).username==username) {
			return (users_dp.getItemAt(i));
		}
     }	
     return null;
}
		
public function getUserIndex(username:String):int {
	for (var i:int=0;i<users_dp.length;i++)	{
		if (users_dp.getItemAt(i).username==username) return i;
     }	
     return -1;
}




public function userJoinNew(anuser:Object):void {
	addUser(anuser);
}
public function userRemove(user:Object):void {
	var username:String = user.username;
	var i:int = getUserIndex(user.username);
	if (i>=0) users_dp.removeItemAt(i);
}
public function paramWebcam():void {
	Security.showSettings(SecurityPanel.DEFAULT);
}


public function streamStatus(e:NetStatusEvent):void {	
}		


public function prepareStreams():void {
	record_btn.enabled = true;
	nsOutGoing = new NetStream(nc);	
	mic = Microphone.getMicrophone(0);
	if(mic!=null) {
		mic.rate=22;
		nsOutGoing.attachAudio(mic);
	}
	
	so_chat = SharedObject.getRemote(myuser.channel, nc.uri,false);
	if (so_chat) {
		so_chat.client = this; // refers to the scope of application and public funtions
		so_chat.addEventListener(SyncEvent.SYNC, OnSync);
		so_chat.connect(nc);
	}
	drawMicLevel();	
}


public function roomChange(channel:String):void {
	users_dp.removeAll();
	myuser.channel = channel;
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
	myuser.channel = channel_txt.text;
} 
public function initialiser():void {
	Application.application.parameters.username="admin";
	Application.application.parameters.admin = true;

	var username:String = Application.application.parameters.username;
	var admin:Boolean = Application.application.parameters.admin;
			
	myuser = new User(username, admin);	
	loadResources(myConfig.xmlURL);		
}		


public function login():void {
	record_btn.label = res.start;
	record_btn.selected = false
	myuser.channel = channel_txt.text;
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
		//nc.close();
		//Alert.show("connection error");
		break;
    }
}

private function mic_status(evt:StatusEvent):void {
try {
	switch (evt.code) {
	case "Camera.Muted":
		myuser.webcam = false
		break;
	case "Camera.Unmuted":
		myuser.webcam = true;
	break;
    }
 }
 finally{
 }
}
public function recordClick():void {
	if (record_btn.selected) {
		record_btn.label = res.stop;
		nsOutGoing.publish(myuser.channel);
		ExternalInterface.call("recordStarted" , myuser.username , myuser.channel);
	} else {
		record_btn.label = res.start;
		nsOutGoing.close();
		ExternalInterface.call("recordStopped" , myuser.username , myuser.channel);
	}
}

public function microDetect():Boolean {
	var res:Boolean=false;
	mic=Microphone.getMicrophone();
	if (mic!=null) {
		mic.addEventListener(StatusEvent.STATUS, mic_status);
		if (mic.muted) {
			Security.showSettings(SecurityPanel.DEFAULT);
		}		
		if (mic.muted==false) res=true
	}
	return res;	
}	





private function OnSync(event:SyncEvent):void {

}
public function getUserList(users:Object):void {
	var username:String;;
	for (username in users) {
		addUser(users[username]);
	}		
}
public function addUser(anuser:Object): void{ 
	var username:String = anuser.username;
	var i:int = getUserIndex(username);
	if (i>=0) return;
    users_dp.addItem(anuser); 
}
	
				