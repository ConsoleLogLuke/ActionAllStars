package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class represents a highly flexible server request. With it you can create a room, join that room if it already exists, set properties on that room (if it is being created), and set your own subscription properties for that room/zone.
     * <br><br>Things to know about creating and joining rooms:<ul><li>If you create a new room you are automatically joined to that room. You cannot create a room without also being joined to that room. 
     * <li>When a room is created it is always created in a zone. If the zone name specified does not currently exist then it is created. Zones have no properties other than its name on the room list.
     * <li>When you join a room via the CreateRoomRequest, the JoinRoomRequest, or by some other method (such as joining a game or through the work of a plugin) you have the opportunity to subscript to certain events. Please see below for more information on this.
     * <li>When creating a room you have the opportunity to set many initial properties such as its password, description, and inital room variables. All of these can be changed later.
     * <li>Rooms can be hidden. A hidden room does not show up in the room list. When a room is flagged as not hidden, then users see it appear in the list as if it were just added. When a room is flagged as hidden, users see the room removed as if it just died. User sin that hidden room see their own room.
     * </ul>
     * <br>When joining a room there are many things that you can be subscribed to receive events. <br><br>Subscription properties when joining a room (all of the following default to true):
     * <ul><li><code>setIsReceivingRoomListUpdates(boolean)</code> - If true, you receive ZoneUpdateEvent events when rooms are added to or removed from this zone, or when the the total count of users in one of those rooms changes.
     * <li><code>setIsReceivingUserListUpdates(boolean)</code> - If true, you receive UserListUpdateEvent events when the user list in your room changes.
     * <li><code>setIsReceivingRoomVariableUpdates(boolean)</code> - If true, you receive the initial room variable list for your room and RoomVariableUpdateEvent events when room variables in your room are created, removed, or modified.
     * <li><code>setIsReceivingUserVariableUpdates(boolean)</code> - If true, you receive the initial user variable list for new users joinin your room as well as UserVariableUpdateEvent events when new user variables are created, removed, or modified on a user.
     * <li><code>setIsReceivingVideoEvents(boolean)</code> - If true, you receive UserListUpdateEvent event when users in the room start or stop streaming live video to the server. The stream name is part of that event.
     * <li><code>setIsReceivingRoomDetailUpdates(boolean)</code> - If true, you receive UpdateRoomDetailsEvent events when room properties such as capacity, description, or the password changes.
     * </ul>
     * @example 
     *     Shows the most simple example of how to create a new room with all default properties.
     * <listing>
     * 
    //Import the needed classes
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.CreateRoomRequest;
    import com.electrotank.electroserver4.message.event.JoinRoomEvent;
    import com.electrotank.electroserver4.user.User;
    //
    //create the request
    var crr:CreateRoomRequest = new CreateRoomRequest();
    crr.setRoomName("Some Room");
    crr.setZoneName("Some Zone");
    //
    //Send the request
    es.send(crr);
    //
    //Configure the JoinRoomEvent so you know when you've been joined.
    es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
    function onJoinRoomEvent(e:JoinRoomEvent):void {
        var roomId:Number = e.getRoomId();
        var zoneId:Number = e.getZoneId();
        //trace the users in your room
        for (var i:int=0;i&gte.getUsers().length;++i) {
            var u:User = e.getUsers()[i];
            trace(u.getUserName());
        }
    }
    </listing>
    Here is a thorough example that uses room variables, changes room proprties, applies join subscriptions, and uses plugins.
    <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.entities.RoomVariable;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.request.CreateRoomRequest;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.plugin.Plugin;
    
    var es:ElectroServer;
    es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
    function createRoom():void {
        var crr:CreateRoomRequest = new CreateRoomRequest();
        crr.setRoomName("Some room");
        crr.setZoneName("Some zone");
        //Set a few properties
        crr.setCapacity(10);
        crr.setRoomDescription("This is a my room");
        crr.setPassword("secret");
        //create two room variables
        //room var 1
        var ob1:EsObject = new EsObject();
        ob1.setString("Test_String", "blah");
        ob1.setInteger("Test_int", 3);
        var rv1:RoomVariable = new RoomVariable("test1", ob1, true, false);
        //room var 2
        var ob2:EsObject = new EsObject();
        ob1.setString("Test_String2", "blah2");
        ob1.setInteger("Test_int2", 12);
        var rv2:RoomVariable = new RoomVariable("test2", ob2, false, false);
        //add the room variables to the request
        crr.setRoomVariables([rv1, rv2]);
        //Create a new plugin for this room
        var pl:Plugin = new Plugin();
        pl.setExtensionName("ExamplePluginExtension");
        pl.setPluginHandle("ExamplePlugin");
        pl.setPluginName("ExamplePlugin");
        //add the plugin to the request
        crr.setPlugins([pl]);
        //Now configure some of the user's subscription properties
        crr.setIsReceivingRoomDetailUpdates(false);//Don't want to receive updates about other rooms
        crr.setIsReceivingRoomListUpdates(false);//Don't want to receive updates about when other rooms are created or destroyed
        crr.setIsReceivingUserListUpdates(true);//true is the default. When true you will receive user list updates for your room.
        //
        //Now send the request to the server
        es.send(crr);
    }
    function onJoinRoomEvent(e:JoinRoomEvent):void {
        var roomId:Number = e.getRoomId();
        var zoneId:Number = e.getZoneId();
        //trace the users in your room
        for (var i:int=0;i&gte.getUsers().length;++i) {
            var u:User = e.getUsers()[i];
            trace(u.getUserName());
        }
    }
    
    </listing>
     * 
     */
    
    public class CreateRoomRequest extends RequestImpl {

        private var zoneId:Number;
        private var zoneName:String;
        private var roomName:String;
        private var roomDescription:String;
        private var capacity:Number;
        private var password:String;
        //START user subscription properties
        private var isReceivingRoomListUpdates:Boolean;
        private var isReceivingUserListUpdates:Boolean;
        private var isReceivingRoomVariableUpdates:Boolean;
        private var isReceivingUserVariableUpdates:Boolean;
        private var isReceivingVideoEvents:Boolean;
        private var isReceivingRoomDetailUpdates:Boolean;
        //END user subscription properties
        private var isNonOperatorUpdateAllowed:Boolean;
        private var isNonOperatorVariableUpdateAllowed:Boolean;
        private var isPersistent:Boolean;
        private var isHidden:Boolean;
        private var isCreateOrJoinRoom:Boolean;
        private var plugins:Array;
        private var variables:Array;
        private var isUsingLanguageFilter:Boolean;
        private var languageFilterName:String;
        private var isDeliverMessageOnFailure:Boolean;
        private var failuresBeforeKick:Number;
        private var kicksBeforeBan:Number;
        private var banDuration:Number;
        private var isResetAfterKick:Boolean;
        private var isUsingFloodingFilter:Boolean;
        private var isFloodingFilterSpecified:Boolean;
        private var floodingFilterName:String;
        private var floodingFilterFailuresBeforeKick:Number;
        private var floodingFilterKicksBeforeBan:Number;
        private var floodingFilterBanDuration:Number;
        private var isFloodingFilterResetAfterKick:Boolean;
        private var isLanguageFilterSpecified:Boolean;
        /**
         * Creates a new instance of the CreateRoomRequest object.
         */
        public function CreateRoomRequest() {
            setMessageType(MessageType.CreateRoomRequest);
            setZoneId(-1);
            setCapacity(-1);
            setIsCreateOrJoinRoom(true);
            //ROOM PROPERTIES
            setRoomDescription("");
            setIsNonOperatorUpdateAllowed(true);
            setIsNonOperatorVariableUpdateAllowed(true);
            setIsPersistent(false);
            setIsHidden(false);
            setPlugins(new Array());
            setRoomVariables(new Array());
            //USER SUBSCRIPTIONS
            setIsReceivingRoomListUpdates(true);
            setIsReceivingRoomDetailUpdates(true);
            setIsReceivingUserListUpdates(true);
            setIsReceivingRoomVariableUpdates(true);
            setIsReceivingUserVariableUpdates(true);
            setIsReceivingVideoEvents(true);
            //FLOODING FILTER SETTINGS
            setIsUsingFloodingFilter(false);
            setIsFloodingFilterSpecified(false);
            setIsFloodingFilterResetAfterKick(false);
            setFloodingFilterBanDuration(-1);
            setFloodingFilterKicksBeforeBan(3);
            setFloodingFilterFailuresBeforeKick(1);
            //LANGUAGE FILTER SETTINGS
            setIsUsingLanguageFilter(false);
            setIsLanguageFilterSpecified(false);
            setIsDeliverMessageOnFailure(false);
            setFailuresBeforeKick(3);
            setKicksBeforeBan(3);
            setBanDuration(-1);
            setIsResetAfterKick(false);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * The default is true. If true, you will receive UpdateRoomDetailsEvent events for all rooms in your zone. That includes description, capacity, password status, and room name.
         * @param    Set to true if you want to receive these updates.
         */
        public function setIsReceivingRoomDetailUpdates(isReceiving:Boolean):void {

            this.isReceivingRoomDetailUpdates = isReceiving;
        }
        /**
         * Returns the isReceivingRoomDetailUpdates property.
         * @return Returns the isReceivingRoomDetailUpdates property.
         */
        public function getIsReceivingRoomDetailUpdates():Boolean {
            return isReceivingRoomDetailUpdates;
        }
        /**
         * Returns the isReceivingVideoUpdates property.
         * @return Returns the isReceivingVideoUpdates property.
         */
        public function getIsReceivingVideoEvents():Boolean {
            return this.isReceivingVideoEvents;
        }
        /**
         * Default is true. If true, you will receive UserListUpdateEvent events when users in your room start or stop publishing live streams to the server.
         * @param    Set to true if you want to receive these events.
         */
        public function setIsReceivingVideoEvents(isReceiving:Boolean):void {

            this.isReceivingVideoEvents = isReceiving;
        }
        /**
         * @private
         */
        private function setIsLanguageFilterSpecified(val:Boolean):void {

            isLanguageFilterSpecified = val;
        }
        /**
         * If a custom language filter was specified by name using setLanguageFilterName, then this method returns true. Otherwise it returns false.
         * @return Returns true if a custom language filter was specified to be used by name.
         */
        public function getIsLanguageFilterSpecified():Boolean {
            return isLanguageFilterSpecified;
        }
        /**
         * If using a custom flooding filter then this property is used. The default is false. The user is kicked after a number of flood failures has been reached. That number is reset after kick if this property is set to true. You can configure the number of failures before kick with setFloodingFilterFailuresBeforeKick.
         * @param    Set to true to erase the number of flooding failures detected on kick.
         */
        public function setIsFloodingFilterResetAfterKick(isResetAfterKick:Boolean):void {

            isFloodingFilterResetAfterKick = isResetAfterKick;
        }
        /**
         * If a custom flooding filter was specified by name then this property is used by the room. The default is false.
         * @return True or false
         */
        public function getIsFloodingFilterResetAfterKick():Boolean {
            return isFloodingFilterResetAfterKick;
        }
        /**
         * This property is used if a custom flooding filter has been specified. The default is -1, which is an indefinate ban (until server reboot). The ban duration can be set with this method. The value is in seconds. A banned user cannot log back in.
         * @param    Time in seconds of the ban. Use -1 to ban indefinately (or until server reboot).
         */
        public function setFloodingFilterBanDuration(banDuration:Number):void {

            floodingFilterBanDuration = banDuration;
        }
        /**
         * Returns the amount of time in seconds that a user will be banned if ban due to flooding.
         * @return The amount of time in seconds of the ban.
         */
        public function getFloodingFilterBanDuration():Number {
            return floodingFilterBanDuration;
        }
        /**
         * This property is used if a custom flooding filter has been specified. The default is 3. The amount of times a user is kicked due to the flooding filter is tracked. When the user reaches the number specified here that user is banned. The duration of that ban is set with setFloodingFilterBanDuration.
         * @param    The number of times to kick
         */
        public function setFloodingFilterKicksBeforeBan(kicksBeforeBan:Number):void {

            floodingFilterKicksBeforeBan = kicksBeforeBan;
        }
        /**
         * Returns the amount of times a user can be kicked due to flooding before being banned.
         * @return The number of times the user can be kicked before getting banned.
         */
        public function getFloodingFilterKicksBeforeBan():Number {
            return floodingFilterKicksBeforeBan;
        }
        /**
         * This property is used if a custom flooding filter has been specified. The default is 1. When flooding has been detected it counts as 1 failure. When a user has caused the number of failures specified by this property that user is then kicked from the room.
         * @param    The number of flooding failures before the user is kicked.
         */
        public function setFloodingFilterFailuresBeforeKick(failuresBeforeKick:Number):void {

            floodingFilterFailuresBeforeKick = failuresBeforeKick;
        }
        /**
         * Returns the number of flooding failures allowed before the user is kicked.
         * @return The number of flooding failures before the user is kicked.
         */
        public function getFloodingFilterFailuresBeforeKick():Number {
            return floodingFilterFailuresBeforeKick;
        }
        /**
         * The name of the custom flooding filter to use. The custom flooding filter is defined via the web-based administrator and given a name. That name is used here. In order to use a custom flooding filter in a room you must use this method and also use setIsUsingFloodingFilter to enabled flooding filters for the room.
         * @param    The name of the custom flooding filter.
         */
        public function setFloodingFilterName(filterName:String):void {

            setIsFloodingFilterSpecified(true);
            floodingFilterName = filterName;
        }
        /**
         * Returns the name of the custom flooding filter.
         * @return Returns the name of the custom flooding filter.
         */
        public function getFloodingFilterName():String {
            return floodingFilterName;
        }
        /**
         * Returns true if a custom flooding filter name has been specified.
         * @return Returns true if a custom flooding filter name has been specified.
         */
        public function getIsFloodingFilterSpecified():Boolean {
            return isFloodingFilterSpecified;
        }
        /**
         * @private
         */
        private function setIsFloodingFilterSpecified(val:Boolean):void {

            isFloodingFilterSpecified = val;
        }
        /**
         * The default if false. If set to true then flood filtering is enabled for the room using the server-defined default flooding filter. You can view and edit the properties of the default flooding filter through the web-based administrator. If you want to specify a custom flooding filter then use the setFloodingFilterName method.
         * @param    Pass in true if you want to flood filtering enabled in this room.
         */
        public function setIsUsingFloodingFilter(useFloodingFilter:Boolean):void {

            isUsingFloodingFilter = useFloodingFilter;
        }
        /**
         * Returns true if flood filtering has been enabled for this room.
         * @return Returns true if flood filtering has been enabled for this room.
         */
        public function getIsUsingFloodingFilter():Boolean {
            return isUsingFloodingFilter;
        }
        /**
         * This is used if a custom language filter has been specified. When a language filter failure occurs it is stored and associated with that user. When the amount specified by the setFailuresBeforeKick method is reached the user is kicked from the room. If this property is true then that number is reset to 0 when the user comes back in the room. If false, then that number is not reset.
         * @param    Pass in true to resent the number of language filter failures associated with a user after they are kicked.
         */
        public function setIsResetAfterKick(resetAfterKick:Boolean):void {

            isResetAfterKick = resetAfterKick;
        }
        /**
         * Returns true if the number of language filter failures is to be reset after a user is kicked.
         * @return Returns true if the number of language filter failures is to be reset after a user is kicked.
         */
        public function getIsResetAfterKick():Boolean {
            return isResetAfterKick;
        }
        /**
         * Custom language filters can be defined and given a name through the web-based administrator. This method allows you to use one in this room. In addition to this method you must also use the setIsUsingLanguageFilter method to enable language filtering in this room.
         * @param    The name of the custom language filter to use.
         */
        public function setLanguageFilterName(filterName:String):void {

            setIsLanguageFilterSpecified(true);
            languageFilterName = filterName;
        }
        /**
         * The name of the custom language filter used in this room, if any.
         * @return The name of the custom language filter used in this room, if any.
         */
        public function getLanguageFilterName():String {
            return languageFilterName;
        }
        /**
         * This is used only if a custom language filter is being used. The default is false. If true, then a message that fails language filter validation is still deliverd to the room.
         * @param    Pass in true if you want a failed message to still be delivered.
         */
        public function setIsDeliverMessageOnFailure(val:Boolean):void {

            isDeliverMessageOnFailure = val;
        }
        /**
         * Returns true if a message is supposed to be delivered even if it fails language filter validation.
         * @return Returns true if a message is supposed to be delivered even if it fails language filter validation.
         */
        public function getIsDeliverMessageOnFailure():Boolean {
            return isDeliverMessageOnFailure;
        }
        /**
         * This is used only with a custom language filter. The default is 3. Use this method to set the number of times a language filter failure is allowed before the user is kicked from the room.
         * @param    The number of times a user can send a message that fails language filter validation before being kicked.
         */
        public function setFailuresBeforeKick(failuresBeforeKick:Number):void {

            failuresBeforeKick = failuresBeforeKick;
        }
        /**
         * Returns the number of language filter failures before the user is kicked.
         * @return Returns the number of language filter failures before the user is kicked.
         */
        public function getFailuresBeforeKick():Number {
            return failuresBeforeKick;
        }
        /**
         * This is used with a custom language filter. The default is 3. This sets the number of times a user can be kicked due to language filter violations before that user is banned.
         * @param    The number of times a user can be kicked before getting banned.
         */
        public function setKicksBeforeBan(kicksBeforeBan:Number):void {

            kicksBeforeBan = kicksBeforeBan;
        }
        /**
         * Returns the number of times a user can be kicked before getting banned.
         * @return Returns the number of times a user can be kicked before getting banned.
         */
        public function getKicksBeforeBan():Number {
            return kicksBeforeBan;
        }
        /**
         * This is used with a custom language filter. The default is -1, which is indefinate. If a user is kicked the number of times specified with the setKicksBeforeBan method, then the user is banned from the server. The amount of time (in seconds) a user should be banned for is set with this method.
         * @param    The amount of time in seconds to ban the user that abused the language filter.
         */
        public function setBanDuration(duration:Number):void {

            banDuration = duration;
        }
        /**
         * Returns the amount of time in seconds that a user will be banned if banned due to language fitler violation.
         * @return Returns the amount of time in seconds that a user will be banned if banned due to language fitler violation.
         */
        public function getBanDuration():Number {
            return banDuration;
        }
        /**
         * The default is false. Use this method to enable language filtering for this room. If you enable language filtering and do nothing else, then the default language filter is used. That is defined in the web-based administrator. You can also create custom language filters through the web-based administrator and use them in a room. To use a custom language filter, assign it using the setLanguageFilterName method. When a message fails language filter validation several actions can be taken. The default actions (for the default filter) are defined on the server. If you specify a custom filter then the actions are configurable here. The configuration allows you to control the delivery of a failed message and the punishment given to the user (kick, ban, nothing).
         * @param    Pass in true to enable language filtering.
         */
        public function setIsUsingLanguageFilter(useLanguageFilter:Boolean):void {

            isUsingLanguageFilter = useLanguageFilter;
        }
        /**
         * Returns true if language filtering is enabled.
         * @return Returns true if language filtering is enabled.
         */
        public function getIsUsingLanguageFilter():Boolean {
            return isUsingLanguageFilter;
        }
        /**
         * @private
         */
        public function setIsCreateOrJoinRoom(val:Boolean):void {

            isCreateOrJoinRoom = val;
        }
        /**
         * @private
         * @return
         */
        public function getIsCreateOrJoinRoom():Boolean {
            return isCreateOrJoinRoom;
        }
        /**
         * Sets an array of RoomVariable objects to be used in the new room that is being created.
         * @param    roomVariables
         */
        public function setRoomVariables(roomVariables:Array):void {

            variables = roomVariables;
        }
        /**
         * Returns an array of RoomVariable objecs that represent room variables to be created in the new room.
         * @return Returns an array of RoomVariable objecs that represent room variables to be created in the new room.
         */
        public function getRoomVariables():Array {
            return variables;
        }
        public function setIsNonOperatorUpdateAllowed(val:Boolean):void {

            isNonOperatorUpdateAllowed = val;
        }
        public function getIsNonOperatorUpdateAllowed():Boolean {
            return isNonOperatorUpdateAllowed;
        }
        public function setIsNonOperatorVariableUpdateAllowed(val:Boolean):void {

            isNonOperatorVariableUpdateAllowed = val;
        }
        public function getIsNonOperatorVariableUpdateAllowed():Boolean {
            return isNonOperatorVariableUpdateAllowed;
        }
        /**
         * Sets an array of Plugin objects that represent the plugins that need to be created with this room.
         * @param    arr
         */
        public function setPlugins(plugins:Array):void {

            this.plugins = plugins;
        }
        /**
         * Returns the array of Plugin objects that represent plugins to be created in this new room.
         * @return Returns the array of Plugin objects that represent plugins to be created in this new room.
         */
        public function getPlugins():Array {
            return plugins;
        }
        /**
         * The default is false. When false, a room will automatically be removed from the server when there are no more users in it. When set to true, the room will not be removed when empty. Persistent rooms should be used wisely since that can cause a memory leak by leaving dangling rooms.
         * @param    Pass in true to keep a room around even if empty, false if you want it to get cleaned up when empty.
         */
        public function setIsPersistent(persistent:Boolean):void {

            isPersistent = persistent;
        }
        /**
         * Returns false if the room is set to automatically be removed when the user list is 0. Returns true when it is set to never die.
         * @return Returns false if the room is set to automatically be removed when the user list is 0. Returns true when it is set to never die.
         */
        public function getIsPersistent():Boolean {
            return isPersistent;
        }
        /**
         * The default is false. If set to true, then the room will not show up in the room list for the zone in which the room was created. Users can still join the room if they know the room and zone names. The hidden property of a room can be changed later using the UpdateRoomDetailsRequest.
         * @param    Pass in true if you want the room to not show up in the room list.
         */
        public function setIsHidden(hidden:Boolean):void {

            isHidden = hidden;
        }
        /**
         * Returns false if the room is set to be hidden on create. A hidden room does not show up in the room list.
         * @return Returns false if the room is set to be hidden on create. A hidden room does not show up in the room list.
         */
        public function getIsHidden():Boolean {
            return isHidden;
        }
        /**
         * The default is true. This is a user-level property used when joining a room. You will find this property in the JoinRoomRequest as well. If true, the user will receive add/remove updaes to the room list for the current zone. This is part of the ZoneUpdateEvent.
         * @param    Pass in true to receive room list updates with the ZoneUpdateEvent.
         */
        public function setIsReceivingRoomListUpdates(receivingRoomListUpdates:Boolean):void {

            isReceivingRoomListUpdates = receivingRoomListUpdates;
        }
        /**
         * Returns true if the user will receive room list updates.
         * @return Returns true if the user will receive room list updates.
         */
        public function getIsReceivingRoomListUpdates():Boolean {
            return isReceivingRoomListUpdates;
        }
        /**
         * The default is true. This is a user-level property used when joining a room. You will find this property in the JoinRoomRequest as well. If true, the user will receive updates to the user list for this room through the UserListUpdateEvent.
         * @param    Pass in true to receive UserListUpdateEvent events for this new room.
         */
        public function setIsReceivingUserListUpdates(receivingUserListUpdates:Boolean):void {

            isReceivingUserListUpdates = receivingUserListUpdates;
        }
        /**
         * Returns true if the user is set up to receive UserListUpdateEvent events for the new room.
         * @return Returns true if the user is set up to receive UserListUpdateEvent events for the new room.
         */
        public function getIsReceivingUserListUpdates():Boolean {
            return isReceivingUserListUpdates;
        }
        /**
         * The default is true. This is a user-level property used when joining a room. You will find this property in the JoinRoomRequest as well. If true, the user will receive RoomVariableUpdateEvent events for the newly created room.
         * @param    Pass in true to receive RoomVariableUpdateEvent events.
         */
        public function setIsReceivingRoomVariableUpdates(receivingRoomVariableUpdates:Boolean):void {

            isReceivingRoomVariableUpdates = receivingRoomVariableUpdates;
        }
        /**
         * Returns true if the user is set to receive RoomVariableUpdateEvent events.
         * @return Returns true if the user is set to receive RoomVariableUpdateEvent events.
         */
        public function getIsReceivingRoomVariableUpdates():Boolean {
            return isReceivingRoomVariableUpdates;
        }
        /**
         * The default is true. This is a user-level property used when joining a room. You will find this property in the JoinRoomRequest as well. If true, the user will receive UserVariableUpdateEvent events.
         * @param    Pass in true to receive UserVariableUpdateEvent events for the newly created room.
         */
        public function setIsReceivingUserVariableUpdates(receivingUserVariableUpdates:Boolean):void {

            isReceivingUserVariableUpdates = receivingUserVariableUpdates;
        }
        /**
         * Returns true if the user is set to receive UserVariableUpdateEvent events in the new room.
         * @return Returns true if the user is set to receive UserVariableUpdateEvent events in the new room.
         */
        public function getIsReceivingUserVariableUpdates():Boolean {
            return isReceivingUserVariableUpdates;
        }
        /**
         * Sets the id of the zone in which you want to create the room. A zone must be specified, but it is usually done by name using the setZoneName method. The setZoneId method is rarely used.
         * @param    The id of the zone in which to create the room.
         */
        public function setZoneId(id:Number):void {

            zoneId = id;
        }
        /**
         * Returns the id of the zone in which to create the room. If none has been specified then -1 is returned.
         * @return
         */
        public function getZoneId():Number {
            return zoneId;
        }
        /**
         * Sets the name of the zone in which to create the new room. If a zone of that name doesn't exist, then it will be created. Either a zone name or a zone id must be specified. Usually it is the zone name.
         * @param    The name of the zone in which to create the room.
         */
        public function setZoneName(name:String):void {

            zoneName = name;
        }
        /**
         * Returns the name of the zone in which the room will be created.
         * @return Returns the name of the zone in which the room will be created.
         */
        public function getZoneName():String {
            return zoneName;
        }
        /**
         * Sets the name of the new room. If a room of this name already exists in the specified zone, then you will be joined to that room. If you are joined to an existing room then none of the room-level properties specified here will be used. However, all of the user-subscription properies will be used.
         * @param    The name of the room to be created.
         */
        public function setRoomName(name:String):void {

            roomName = name;
        }
        /**
         * Returns the name of the room to be created.
         * @return Returns the name of the room to be created.
         */
        public function getRoomName():String {
            return roomName;
        }
        /**
         * This is an optional public room-level property. By setting a string value here anyone that can see this room in a room list will see the description property.
         * @param    The optional string description of the room.
         */
        public function setRoomDescription(description:String):void {

            roomDescription = description;
        }
        /**
         * Returns the optional string description of the room.
         * @return Returns the optional string description of the room.
         */
        public function getRoomDescription():String {
            return roomDescription;
        }
        /**
         * A room can be given a hard cap of the maximum number of users allowed in it at once. This method is used to do that. The default is -1, which means that there is no limit.
         * @param    The maximum number of users allowed in the room at once.
         */
        public function setCapacity(capacity:Number):void {

            this.capacity = capacity;
        }
        /**
         * Returns the maximum number of users allowed in this room at once.
         * @return Returns the maximum number of users allowed in this room at once.
         */
        public function getCapacity():Number {
            return capacity;
        }
        /**
         * This is optional. The room can be password protected. To do that, set a password using this method. Users that attempt to join this room will need to use the password.
         * @param    The optional password used to protect the room.
         */
        public function setPassword(password:String):void {

            this.password = password;
        }
        /**
         * Returns the optional password used to protect the room.
         * @return Returns the optional password used to protect the room.
         */
        public function getPassword():String {
            return password;
        }
    }
}
