package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class NoAppointmentsFoundEvent extends CairngormEvent
	{

		public static var NO_APPOINTMENTS_FOUND_EVENT:String = "noAppointmentsFoundEvent";
		
		public function NoAppointmentsFoundEvent()
		{
			super(NO_APPOINTMENTS_FOUND_EVENT);
		}
		
	}
}
