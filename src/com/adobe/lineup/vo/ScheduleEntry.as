package com.adobe.lineup.vo
{
	import com.adobe.exchange.Appointment;
	
	import flexlib.scheduling.scheduleClasses.SimpleScheduleEntry;

	public class ScheduleEntry
		extends SimpleScheduleEntry
	{
		private var _appt:Appointment;
		
		public function ScheduleEntry(appt:Appointment)
		{
			this._appt = appt;
			super.label = appt.subject;
		}

		public override function set startDate(startDate:Date):void
		{
		}

		public override function get startDate():Date
		{
			return this._appt.startDate;
		}

		public override function set endDate(startDate:Date):void
		{
		}

		public override function get endDate():Date
		{
			return this._appt.endDate;
		}

		public function get subject():String
		{
			return this._appt.subject;
		}

		public function get textDescription():String
		{
			return this._appt.textDescription;
		}

		public function get htmlDescription():String
		{
			return this._appt.htmlDescription;
		}

		public function get location():String
		{
			return this._appt.location;
		}

		public function get allDay():Boolean
		{
			return this._appt.allDay;
		}

		public function get url():String
		{
			return this._appt.url;
		}
	}
}
