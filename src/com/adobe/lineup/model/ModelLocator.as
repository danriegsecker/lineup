

package com.adobe.lineup.model
{
	import air.net.ServiceMonitor;
	
	import com.adobe.air.notification.Purr;
	import com.adobe.cairngorm.model.IModelLocator;
	import com.adobe.lineup.database.Database;
	import com.adobe.lineup.vo.CalendarEntry;
	import com.adobe.lineup.vo.ServerInfo;
	
	import flash.display.Bitmap;
	
	import mx.collections.ArrayCollection;
	
	public class ModelLocator implements com.adobe.cairngorm.model.IModelLocator
	{
		protected static var inst:ModelLocator;

		[Bindable] public var dateRange:Object = {"rangeStart":new Date(), "rangeEnd":new Date()};
		[Bindable] public var events:ArrayCollection;
		[Bindable] public var serverInfo:ServerInfo;
		[Bindable] public var serverConfigOpen:Boolean;
		[Bindable] public var online:Boolean;
		[Bindable] public var selectedAppointment:CalendarEntry;
		[Bindable] public var currentAppointment:CalendarEntry;
		[Bindable] public var busy:Boolean;

		[Embed(source="assets/application.png")]
		public var appIconClass:Class;

		[Embed(source="assets/alert.png")]
		public var alertIconClass:Class;

		public var appIcon:Bitmap;
		public var alertIcon:Bitmap;

		public var db:Database;
		public var serverMonitor:ServiceMonitor;
		public var purr:Purr;
		
		public function ModelLocator()
		{
		}
		
		public static function getInstance():ModelLocator
		{
			if (inst == null)
			{
				inst = new ModelLocator();
			}
			return inst;
		}

	}
}
