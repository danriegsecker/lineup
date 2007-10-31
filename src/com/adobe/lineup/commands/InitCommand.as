package com.adobe.lineup.commands
{
	import com.adobe.air.notification.Purr;
	import com.adobe.air.preferences.Preference;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.database.Database;
	import com.adobe.lineup.events.GetAppointmentsEvent;
	import com.adobe.lineup.events.StartServerMonitorEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.ServerInfo;
	import com.adobe.utils.DateUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Shell;
	
	import mx.collections.ArrayCollection;
	
	public class InitCommand implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();

			// Set up the database
			var sqlFile:File = File.applicationResourceDirectory.resolvePath("sql.xml");
			var sqlFileStream:FileStream = new FileStream();
			sqlFileStream.open(sqlFile, FileMode.READ);
			var sql:XML = new XML(sqlFileStream.readUTFBytes(sqlFileStream.bytesAvailable));
			sqlFileStream.close();
			var db:Database = new Database(sql);
			db.initialize();
			ml.db = db;

			// Initialize variables
			ml.appointments = new ArrayCollection();
			ml.purr = new Purr(15);
			
			// Figure out the alert icon
			var scaledAlert:BitmapData;
			var scaledApp:BitmapData;
			
			if (Shell.supportsDockIcon)
			{
				var alertTmp:Bitmap = new ml.alertIconClass();
				alertTmp.scaleX = 64 / alertTmp.width;
				alertTmp.scaleY = 64 / alertTmp.height;

				scaledAlert = new BitmapData(alertTmp.width, alertTmp.height, true, 0xffffff);
				scaledAlert.draw(alertTmp, alertTmp.transform.matrix, null, null, null, true);

				var appData:BitmapData = new ml.appIconClass().bitmapData;
				
				appData.copyPixels(scaledAlert,
								   new Rectangle(0, 0, scaledAlert.width, scaledAlert.height),
								   new Point(appData.width-scaledAlert.width, 0),
								   null, null, true);
				ml.alertIcon = new Bitmap(appData);
				ml.appIcon = new ml.appIconClass();
			}
			else if (Shell.supportsSystemTrayIcon)
			{
				ml.appIcon = new ml.appIconClass();
				ml.alertIcon = new ml.alertIconClass();

				ml.appIcon.scaleX = 16 / ml.appIcon.width;
				ml.appIcon.scaleY = 16 / ml.appIcon.height;

				ml.alertIcon.scaleX = 16 / ml.alertIcon.width;
				ml.alertIcon.scaleY = 16 / ml.alertIcon.height;

				scaledApp = new BitmapData(ml.appIcon.width, ml.appIcon.height, true, 0xffffff);
				scaledAlert = new BitmapData(ml.alertIcon.width, ml.alertIcon.height, true, 0xffffff);
				
				scaledApp.draw(ml.appIcon, ml.appIcon.transform.matrix, null, null, null, true);
				scaledAlert.draw(ml.alertIcon, ml.appIcon.transform.matrix, null, null, null, true);

				ml.appIcon = new Bitmap(scaledApp);
				ml.alertIcon = new Bitmap(scaledAlert);
			}

			// Set app icons
			ml.purr.setIcons([ml.appIcon]);

			// Get server configuration
			var pref:Preference = new Preference();
			pref.load();
			ml.serverInfo = new ServerInfo();
			ml.serverInfo.exchangeServer = (pref.getValue("exchangeServer") == null) ? "" : pref.getValue("exchangeServer");
			ml.serverInfo.exchangeUsername = (pref.getValue("exchangeUsername") == null) ? "" : pref.getValue("exchangeUsername");
			
			if (ml.serverInfo.exchangeServer == "" || ml.serverInfo.exchangeUsername == "")
			{
				ml.serverConfigOpen = true;
			}
			else
			{
				// Set up the service monitor
				var ssme:StartServerMonitorEvent = new StartServerMonitorEvent();
				ssme.dispatch();

				// Get the default appointment date range.
				var gae:GetAppointmentsEvent = new GetAppointmentsEvent();
				gae.startDate = new Date();
				gae.endDate = new Date(gae.startDate.time + (60 * 60 * 24 * 7 * 1000)); // One week
				gae.updateUI = true;
				gae.dispatch();
			}
		}
	}
}
