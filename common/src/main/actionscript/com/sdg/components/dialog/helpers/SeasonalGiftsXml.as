package com.sdg.components.dialog.helpers
{
	public class SeasonalGiftsXml
	{
			//  test stub xml - input

			public var seasonalData:XML =  
			 <SDGResponse status="1">
				<seasonal>
					<prizes>
						<prize><orderId>2</orderId><itemId>3126</itemId><owned>1</owned><permanentFlag>0</permanentFlag><name>Blue Shirt</name></prize>
						<prize><orderId>3</orderId><itemId>3129</itemId><owned>1</owned><permanentFlag>0</permanentFlag><name>Giant Yellow Squash</name></prize>
						<prize><orderId>4</orderId><itemId>3199</itemId><owned>0</owned><permanentFlag>0</permanentFlag><name>Red Chair</name></prize>
						<prize><orderId>5</orderId><itemId>3004</itemId><owned>1</owned><permanentFlag>0</permanentFlag><name>Blue T-Shirt</name></prize>
						<prize><orderId>6</orderId><itemId>3020</itemId><owned>0</owned><permanentFlag>0</permanentFlag><name>Bone Shirt</name></prize>
					    <prize><orderId>1</orderId><itemId>3133</itemId><owned>1</owned><permanentFlag>0</permanentFlag><name>Blue Chair</name></prize>
						<prize><orderId>7</orderId><itemId>3947</itemId><owned>0</owned><permanentFlag>1</permanentFlag><name>Tower of Power</name></prize>
					</prizes>
					<survey>
						<question>
							<orderId>2</orderId>
							<questionId>201</questionId>
							<text>How do you eat a turkey?</text>
           					<answers>
									<answer><answerId>21</answerId><orderId>1</orderId><text>Q order 1 answer 21 With your hands</text></answer>
									<answer><answerId>23</answerId><orderId>3</orderId><text>Q order 3 answer 23 With your feet</text></answer>
									<answer><answerId>22</answerId><orderId>2</orderId><text>Q order 2 answer 22 With a fork</text></answer>
									<answer><answerId>24</answerId><orderId>4</orderId><text>Q order 4 answer 24 With a knife</text></answer>
							</answers>
						</question>
						<question>
							<orderId>1</orderId>
							<questionId>400</questionId>
							<text>How do you eat a chicken?</text>
           					<answers>
									<answer><answerId>14</answerId><orderId>4</orderId><text>Q order 4 answer 14 With your chicken</text></answer>
									<answer><answerId>13</answerId><orderId>3</orderId><text>Q order 3 answer 13 With your duck</text></answer>
									<answer><answerId>11</answerId><orderId>1</orderId><text>Q order 1 answer 11 With a spoon</text></answer>
									<answer><answerId>12</answerId><orderId>2</orderId><text>Q order 2 answer 12 With a auger</text></answer>
							</answers>
						</question>
						<prizeThumbnail>http://192.168.0.223/test/inventoryThumbnail?itemId=3020</prizeThumbnail>
					</survey>
				</seasonal>
			 </SDGResponse>;
			 
			//  test stub xml - output

			public var seasonalDataOutput:XML =  
			    <SDGRequest>
        			<RequestParameters>
            			<avatarId>123</avatarId>
            			<itemId>123</itemId>
            			<answerId>0,0</answerId>
            			<additionalComments></additionalComments>
        			</RequestParameters>
    			</SDGRequest>; 
    			
   // 		public var params:Object = {avatarId:123, itemId:123, answerId:"0,0", additionalComments:"blah"};	
    						 

		public function SeasonalGiftsXml()
		{
		}

	}
}