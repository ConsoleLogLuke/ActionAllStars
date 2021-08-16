package com.sdg.components.controls
{
	import mx.controls.ComboBox;
	import mx.core.ClassFactory;
	import mx.styles.CSSStyleDeclaration;

	public class CustomComboBox extends ComboBox
	{
		[Embed(source="swfs/turf/default.png")]
		public static var defaultSkin:Class;

		[Embed(source="swfs/turf/over.png")]
		public static var overSkin:Class;

		public function CustomComboBox()
		{
			super();

			width = 237;
			height = 25;
			dropdownWidth = 200;

			setStyle("fontWeight", "bold");
			setStyle("fontSize", 13);
			setStyle("fontFamily", "EuroStyle");
			setStyle("color", 0xffffff);

			setStyle("disabledSkin", defaultSkin);
			setStyle("downSkin", defaultSkin);
			setStyle("overSkin", overSkin);
			setStyle("upSkin", defaultSkin);

			var classFactory:ClassFactory = new ClassFactory(CustomDropdown);
			classFactory.properties = {parentDisplay:this};
			dropdownFactory = classFactory;
		}
	}
}
