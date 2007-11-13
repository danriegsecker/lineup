package com.adobe.lineup.commands
{

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.air.alert.NativeAlert;
	import flash.system.Shell;
	
	public class NoAppointmentsFoundCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var message:String;
			if (ModelLocator.getInstance().online)
			{
				message = "No appointments were found for the specified date range.";
			}
			else
			{
				message = "No cached appointments were found for the specified date range. If possible, connect to the network and try again.";
			}
			NativeAlert.show(message, "No Appointments Found", NativeAlert.OK, true, Shell.shell.openedWindows[0], null, ModelLocator.getInstance().alertIcon);
		}
	}
}
