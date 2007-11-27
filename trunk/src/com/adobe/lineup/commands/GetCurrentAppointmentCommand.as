package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.CalendarEntry;

	public class GetCurrentAppointmentCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var date: Date = new Date();
			if (ml.events.length > 0)
			{
				for each (var entry: CalendarEntry in ml.events)
				{
					if (entry.start >= date)
					{
						ml.currentAppointment = entry;
						break;
					}
				}
			}
		}		
	}
}