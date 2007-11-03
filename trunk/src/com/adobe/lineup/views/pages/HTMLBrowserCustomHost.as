package com.adobe.lineup.views.pages
{
	import flash.html.HTMLHost;
	import flash.html.HTMLWindowCreateOptions;
	import flash.html.HTMLControl;
	
	public class HTMLBrowserCustomHost extends HTMLHost
	{
		public override function createWindow(options:HTMLWindowCreateOptions):HTMLControl
		{
			var browser:HTMLBrowser = new HTMLBrowser();
			browser.open(true);
			return browser.html.htmlControl;
		}
	}
}