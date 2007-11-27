package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.exchange.Calendar;
	import com.adobe.exchange.RequestConfig;
	import com.adobe.exchange.events.ExchangeAppointmentListEvent;
	import com.adobe.lineup.events.GetAppointmentsEvent;
	import com.adobe.lineup.events.GetCurrentAppointmentEvent;
	import com.adobe.lineup.events.NoAppointmentsFoundEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.CalendarEntry;
	import com.adobe.utils.DateUtil;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequestDefaults;
	
	import mx.collections.ArrayCollection;
	
	import qs.utils.DateRange;
	
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
			cal.getAppointments(DateUtil.getUTCDate(gae.startDate),
								DateUtil.getUTCDate(gae.endDate));
		}

		private function populateFromDatabase(startDate:Date, endDate:Date):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var appointments:Array = ml.db.getAppointments(startDate, endDate);

			ml.busy = false;
			ml.dateRange = {"rangeStart":startDate, "rangeEnd":endDate};

			if (appointments == null || appointments.length == 0)
			{
				new NoAppointmentsFoundEvent().dispatch();
				return;
			}

			ml.events.removeAll();
			var newApts: ArrayCollection = new ArrayCollection();
			for each (var row:Object in appointments)
			{
				var e:CalendarEntry = new CalendarEntry();
				e.summary = row.subject;
				e.description = row.text_description;
				e.start = row.start_date;
				e.end = row.end_date;
				e.range = new DateRange(row.start_date, row.end_date);
				e.allDay = row.all_day_event;
				e.location = row.location;
				e.textDescription = row.text_description;
				e.htmlDescription = row.html_description;
				e.url = row.url;
				newApts.addItem(e);
			}
			ml.events = newApts;
			ml.events.source.sortOn("start", Array.NUMERIC);
			new GetCurrentAppointmentEvent().dispatch();			
			this.refreshIconMenu();
		}
		
		private function refreshIconMenu():void
		{
			var iconMenu:NativeMenu = new NativeMenu();
			var ml:ModelLocator = ModelLocator.getInstance();
			for each (var entry:CalendarEntry in ml.events)
			{
				var menuItem:NativeMenuItem = new NativeMenuItem(entry.label, false);
				menuItem.data = entry;
				menuItem.addEventListener(Event.SELECT,
					function(e:Event):void
					{
						ModelLocator.getInstance().selectedAppointment = NativeMenuItem(e.target).data as CalendarEntry;
					});
				iconMenu.addItem(menuItem);
			}
			ml.purr.setMenu(iconMenu);
		}
	}
}
