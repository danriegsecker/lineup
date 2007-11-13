package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetCurrentAppointmentEvent extends CairngormEvent
	{
		public static var GET_CURRENT_APPOINTMENT_EVENT:String = "getCurrentAppointmentEvent";

		public function GetCurrentAppointmentEvent()
		{
			super(GET_CURRENT_APPOINTMENT_EVENT);
		}
	}
}