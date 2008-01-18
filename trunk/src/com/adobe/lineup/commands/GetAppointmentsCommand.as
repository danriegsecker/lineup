package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.exchange.Calendar;
	import com.adobe.exchange.RequestConfig;
	import com.adobe.exchange.events.ExchangeAppointmentListEvent;
	import com.adobe.lineup.events.GetAppointmentsEvent;
	import com.adobe.lineup.events.NoAppointmentsFoundEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.CalendarEntry;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	
	public class GetAppointmentsCommand implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var gae:GetAppointmentsEvent = GetAppointmentsEvent(e);
			var ml:ModelLocator = ModelLocator.getInstance();

			ml.busy = true;

			URLRequestDefaults.setLoginCredentialsForHost(ml.serverInfo.exchangeServer, ml.serverInfo.exchangeUsername, ml.serverInfo.exchangePassword);

			var rc:RequestConfig = new RequestConfig();
			rc.username = ml.serverInfo.exchangeUsername;
			rc.server = ml.serverInfo.exchangeServer;
			rc.secure = ml.serverInfo.useHttps;
			
			var cal:Calendar = new Calendar();
			cal.requestConfig = rc;
			cal.addEventListener(IOErrorEvent.IO_ERROR,
				function(e:IOErrorEvent):void
				{
					ml.online = false;
					if (gae.updateUI)
					{
						populateFromDatabase(gae.startDate, gae.endDate);
					}
				});
			cal.addEventListener(ExchangeAppointmentListEvent.EXCHANGE_APPOINTMENT_LIST_EVENT,
				function onAppointmentList(exchangeEvent:ExchangeAppointmentListEvent):void
				{
					ml.online = true;
					ml.lastSynchronized = new Date();
		
					var appointments:Array = exchangeEvent.appointments;					
					ml.db.deleteAppointments(gae.startDate, gae.endDate);
					if (appointments != null && appointments.length > 0)
					{
						ml.db.insertAppointments(appointments);
					}
					if (gae.updateUI)
					{
						populateFromDatabase(gae.startDate, gae.endDate);
					}
					else
					{
						ml.busy = false;
					}
				});
			var start:Date = gae.startDate;
			var end:Date = gae.endDate;
			end = new Date(end.time + (60*60*24*1000));
			cal.getAppointments(new Date(start.time + (start.timezoneOffset * 60000) - (60*1000)),
								new Date(end.time + (end.timezoneOffset * 60000)));
			// For testing purposes only
			//this.populateFromDatabase(gae.startDate, gae.endDate);
		}

		private function populateFromDatabase(startDate:Date, endDate:Date):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var appointments:Array = ml.db.getAppointments(startDate, endDate);

			ml.busy = false;

			ml.appointments = new ArrayCollection();

			if (appointments == null || appointments.length == 0)
			{
				new NoAppointmentsFoundEvent().dispatch();
				return;
			}

			var newAppts:ArrayCollection = new ArrayCollection();
			for each (var row:Object in appointments)
			{
				var e:CalendarEntry = new CalendarEntry();
				e.subject = row.subject;
				e.description = row.text_description;
				e.start = row.start_date;
				e.end = row.end_date;
				e.allDay = row.all_day_event;
				e.location = row.location;
				e.textDescription = row.text_description;
				e.htmlDescription = row.html_description;
				e.url = row.url;
				newAppts.addItem(e);
			}
			newAppts.source.sortOn("start", Array.NUMERIC);
			ml.appointments = newAppts;
			refreshIconMenu();
		}
		
		private function refreshIconMenu():void
		{
			var iconMenu:NativeMenu = new NativeMenu();
			var ml:ModelLocator = ModelLocator.getInstance();
			for each (var entry:CalendarEntry in ml.appointments)
			{
				var menuItem:NativeMenuItem = new NativeMenuItem(entry.subject, false);
				menuItem.data = entry;
				menuItem.addEventListener(Event.SELECT,
					function(e:Event):void
					{
						if (e.target.data.url != null)
						{
							navigateToURL(new URLRequest(e.target.data.url));
						}
					});
				iconMenu.addItem(menuItem);
			}
			ml.purr.setMenu(iconMenu);
		}
	}
}
