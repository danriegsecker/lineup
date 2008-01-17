package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.events.OpenDetailsEvent;
	import com.adobe.lineup.views.pages.AppointmentDetails;
	import com.adobe.lineup.vo.CalendarEntry;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.geom.Rectangle;

	public class OpenDetailsCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ode:OpenDetailsEvent = ce as OpenDetailsEvent;
			var event:CalendarEntry = ode.event;
			var details:AppointmentDetails = new AppointmentDetails();
			details.entry = event;
			// Close any windows that are already open
			for (var i:uint = 1; i < NativeApplication.nativeApplication.openedWindows.length; ++i)
			{
				NativeWindow(NativeApplication.nativeApplication.openedWindows[i]).close();
			}

			var appBounds:Rectangle = NativeApplication.nativeApplication.openedWindows[0].bounds;
			var winX:uint = appBounds.x + ode.clickX;
			var winY:uint = appBounds.y + ode.clickY - 40;
			
			var currentScreen:Screen = Screen.getScreensForRectangle(appBounds).pop();

			var actualWidth:uint = currentScreen.bounds.width + currentScreen.bounds.x;			
			var actualHeight:uint = currentScreen.bounds.height + currentScreen.bounds.y;			

			details.open(true);
			
			if ((winX + details.width) >= actualWidth)
			{
				winX = actualWidth - details.width;
			}
			
			var newBounds:Rectangle = new Rectangle(winX, winY, appBounds.width, appBounds.height);
			details.nativeWindow.bounds = newBounds;
		}
	}
}