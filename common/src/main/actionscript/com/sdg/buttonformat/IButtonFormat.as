package com.sdg.buttonformat
{
	import flash.text.TextFormat;
	
	public interface IButtonFormat
	{
		function get offFormat():TextFormat;
		function get overFormat():TextFormat;
		function get downFormat():TextFormat;
	}
}