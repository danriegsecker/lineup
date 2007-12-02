package com.adobe.lineup.views.pages
{
	import flash.html.HTMLHost;
	import flash.html.HTMLWindowCreateOptions;
	import flash.html.HTMLLoader;
	
	public class HTMLBrowserCustomHost extends HTMLHost
	{
		public override function createWindow(options:HTMLWindowCreateOptions):HTMLLoader
		{
			var browser:HTMLBrowser = new HTMLBrowser();
			browser.open(true);
			return browser.html.htmlLoader;
		}
	}
}