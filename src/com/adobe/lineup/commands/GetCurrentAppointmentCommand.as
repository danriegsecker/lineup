package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.ScheduleEntry;

	public class GetCurrentAppointmentCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var date: Date = new Date();
			if (ml.appointments.length > 0)
			{
				for each (var entry: ScheduleEntry in ml.appointments)
				{
					if (entry.startDate >= date)
					{
						ml.currentAppointment = entry;
						break;
					}
				}
			}
		}		
	}
}