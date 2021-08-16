package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class GetZonesRequestCodec extends MessageCodecImpl {

        override public function encode(msw:MessageWriter, mess:Message):void {

            var message:GetZonesRequest = GetZonesRequest(mess);
        }
    }
}
