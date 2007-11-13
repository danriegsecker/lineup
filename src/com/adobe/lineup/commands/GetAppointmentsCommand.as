package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.events.GetAppointmentsEvent;
	import com.adobe.lineup.events.NoAppointmentsFoundEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.ScheduleEntry;
	import com.adobe.exchange.Appointment;
	import com.adobe.exchange.Calendar;
	import com.adobe.exchange.RequestConfig;
	import com.adobe.exchange.events.ExchangeAppointmentListEvent;
	import com.adobe.exchange.events.ExchangeErrorEvent;
	import com.adobe.lineup.events.GetCurrentAppointmentEvent;
	import com.adobe.utils.DateUtil;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.collections.ArrayCollection;
	
	public class GetAppointmentsCommand implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var gae:GetAppointmentsEvent = GetAppointmentsEvent(e);
			var ml:ModelLocator = ModelLocator.getInstance();

			ml.busy = true;

			var rc:RequestConfig = new RequestConfig();
			rc.username = ml.serverInfo.exchangeUsername;
			rc.server = ml.serverInfo.exchangeServer;
			// TBD: Make this a config option
			rc.secure = true;
			
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
			ml.calStartDate = startDate;
			ml.calEndDate = endDate;

			if (appointments == null || appointments.length == 0)
			{
				new NoAppointmentsFoundEvent().dispatch();
				return;
			}

			ml.appointments.removeAll();
			var newAppointments:ArrayCollection = new ArrayCollection();
			for each (var row:Object in appointments)
			{
				var a:Appointment = new Appointment();
				a.startDate = row.start_date;
				a.endDate = row.end_date;
				a.subject = row.subject;
				a.textDescription = row.text_description;
				a.htmlDescription = row.html_description;
				a.allDay = row.all_day_event;
				a.location = row.location;
				a.url = row.url;
				var entry:ScheduleEntry = new ScheduleEntry(a);
	            newAppointments.addItem(entry);
			}
			newAppointments.source.sortOn("startDate", Array.NUMERIC);
			ml.appointments = newAppointments;
			new GetCurrentAppointmentEvent().dispatch();			
			this.refreshIconMenu();
		}
		
		private function refreshIconMenu():void
		{
			var iconMenu:NativeMenu = new NativeMenu();
			var ml:ModelLocator = ModelLocator.getInstance();
			for each (var entry:ScheduleEntry in ml.appointments)
			{
				var menuItem:NativeMenuItem = new NativeMenuItem(entry.label, false);
				menuItem.data = entry;
				menuItem.addEventListener(Event.SELECT,
					function(e:Event):void
					{
						ModelLocator.getInstance().selectedAppointment = NativeMenuItem(e.target).data as ScheduleEntry;
					});
				iconMenu.addItem(menuItem);
			}
			ml.purr.setMenu(iconMenu);
		}
	}
}
