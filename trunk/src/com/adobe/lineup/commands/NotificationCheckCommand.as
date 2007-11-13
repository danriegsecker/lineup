package com.adobe.lineup.commands
{
	import com.adobe.air.notification.AbstractNotification;
	import com.adobe.air.notification.Notification;
	import com.adobe.air.notification.NotificationClickedEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.ScheduleEntry;
	
	import flash.display.NotificationType;
	import flash.system.Shell;
	
	import mx.formatters.DateFormatter;

	public class NotificationCheckCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var appts:Array = ml.db.getReminders();

			if (appts != null && appts.length > 0)
			{
				var alerts:Array = new Array();
				for each (var a:Object in appts)
				{
					if (ml.db.countAlerts(a.start_date as Date, a.end_date as Date, a.subject) == 0)
					{
						alerts.push(a);
					}
				}				

				if (alerts.length == 0) return;

				var notificationDateFormatter:DateFormatter = new DateFormatter();
				notificationDateFormatter.formatString = "L:NN A";

				if (Shell.shell.activeWindow == null)
				{
					ml.purr.setIcons([ml.alertIcon], "Upcoming appointment");
				}
				
				ml.purr.alert(NotificationType.CRITICAL, Shell.shell.openedWindows[0]);

				for each (var appt:Object in alerts)
				{
					var notification:Notification = new Notification(notificationDateFormatter.format(appt.start_date) +
													  " - " +
													  notificationDateFormatter.format(appt.end_date),
													  appt.subject, null, 5, new ml.appIconClass());
					notification.id = appt.url;
					notification.addEventListener(NotificationClickedEvent.NOTIFICATION_CLICKED_EVENT,
						function(e:NotificationClickedEvent):void
						{
							var url:String = AbstractNotification(e.target).id;
							var ml:ModelLocator = ModelLocator.getInstance();
							for each (var se:ScheduleEntry in ml.appointments)
							{
								if (se.url == url)
								{
									Shell.shell.activateApplication();
									ml.selectedAppointment = null;
									ml.selectedAppointment = se;
									break;
								}
							}
						});
					ml.purr.addNotification(notification);
					ml.db.insertAlert(appt.start_date, appt.end_date, appt.subject);	
				}
			}
		}
	}
}