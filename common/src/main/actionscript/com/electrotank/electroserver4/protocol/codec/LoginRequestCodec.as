package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.entities.Protocol;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class LoginRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:LoginRequest = LoginRequest(mess);
            var userName:String = request.getUserName();
            var password:String = request.getPassword();
    
            if(userName != null && userName.length != 0) {
                // user name is supplied
                writer.writeBoolean(true);
    
                // write the user name
                writer.writePrefixedString(userName, MessageConstants.USER_NAME_PREFIX_LENGTH);
    
                if(password != null && password.length != 0) {
                    // password is supplied
                    writer.writeBoolean(true);
    
                    // write the password
                    writer.writePrefixedString(password, MessageConstants.PASSWORD_PREFIX_LENGTH);
                } else {
                    // no password given
                    writer.writeBoolean(false);
                }
            } else {
                // no user name given
                writer.writeBoolean(false);
            }
    
            
            // Handle the esobject
            var esObject:EsObject = request.getEsObject();
            if(esObject == null) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                EsObjectCodec.encode(writer, esObject);
            }
    
            // Handle the name value pairs
            var userVariables:Array = request.getUserVariables();
            if (userVariables == null || userVariables.length == 0) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                EsObjectCodec.encodeMap(writer, userVariables);
            }
            
            
            /*
            // Handle the login variable name value pairs
           var pairs:Array = request.getPairs();
            if(pairs == null || pairs.length == 0) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                NameValuePairCodec.encode(writer, pairs);
            }
            
            // Handle the user variable name value pairs
           var uvs:Array = request.getUserVariablePairs();
            if(uvs == null || uvs.length == 0) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                NameValuePairCodec.encode(writer, uvs);
            }*/
            
            
            // setting protocols only happens on the initial login
            var additionalLogin:Boolean = request.getSharedSecret() != null;
            if (additionalLogin) {
                writer.writePrefixedString(request.getSharedSecret(), MessageConstants.SHARED_SECRET_LENGTH);
            } else {
                // write out the auto discover protocol boolean
                writer.writeBoolean(request.getIsAutoDiscoverProtocol());
    
                // if the server is not to auto discover the protocol, then the user is telling us the
                // protocols they support
                //!!! TODO -- need to create class(es) for the protocol stuff below
                if (!request.getIsAutoDiscoverProtocol()) {
                    var supportedProtocols:Array = request.getProtocols();
                    writer.writeInteger(supportedProtocols.length, MessageConstants.PROTOCOL_COUNT_LENGTH);
                    for (var i:Number=0;i<supportedProtocols.length;++i) {
                        var protocol:Protocol = supportedProtocols[i];
                        writer.writeInteger(protocol.getProtocolId(), MessageConstants.PROTOCOL_LENGTH);
                    }
                }
            }
        }
    }
}
