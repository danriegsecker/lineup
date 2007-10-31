package com.adobe.lineup.commands
{

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	import mx.controls.Alert;
	
	public class NoAppointmentsFoundCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var message:String;
			if (ModelLocator.getInstance().online)
			{
				message = "No appointments found.";
			}
			else
			{
				message = "No cached appointments found. If possible, connect to the network and try again.";
			}
			Alert.show(message);
		}
	}
}
