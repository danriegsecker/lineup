package com.adobe.lineup.vo
{
	import qs.calendar.CalendarEvent;

	public class CalendarEntry extends CalendarEvent
	{
		public function set label(value: String):void
		{
		}

		public function get label():String
		{
			return this.summary;
		}
		
		public function get subject():String
		{
			return this.summary;
		}

		public function set url(value: String): void
		{
			this.properties['url'] = value;
		}

		public function get url(): String
		{
			return this.properties['url'];
		}
		
		public function set htmlDescription(value: String): void
		{
			this.properties['htmlDescription'] = value;
		}

		public function get htmlDescription(): String
		{
			return this.properties['htmlDescription'];
		}

		public function set textDescription(value: String): void
		{
			this.properties['textDescription'] = value;
		}

		public function get textDescription(): String
		{
			return this.properties['textDescription'];
		}
	}
}