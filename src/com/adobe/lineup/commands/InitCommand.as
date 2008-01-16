package com.adobe.lineup.commands
{
	import com.adobe.air.notification.Purr;
	import com.adobe.air.preferences.Preference;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.database.Database;
	import com.adobe.lineup.events.GetAppointmentsEvent;
	import com.adobe.lineup.events.StartServerMonitorEvent;
	import com.adobe.lineup.events.UpdateIconsEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.ServerInfo;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import mx.collections.ArrayCollection;
	import flash.desktop.SystemTrayIcon;
	
	public class InitCommand implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();

			// Initialize variables
			ml.appointments = new ArrayCollection();
			ml.purr = new Purr(15);
			ml.selectedDate = new Date();

			// Create icons.
			new UpdateIconsEvent().dispatch();
			
			// Manage clicks on the system tray icon.
			if (NativeApplication.supportsSystemTrayIcon)
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).addEventListener(MouseEvent.CLICK,
					function(e:MouseEvent):void
					{
						NativeApplication.nativeApplication.activate();
					});
			}

			// Set up the database
			var sqlFile:File = File.applicationDirectory.resolvePath("sql.xml");
			var sqlFileStream:FileStream = new FileStream();
			sqlFileStream.open(sqlFile, FileMode.READ);
			var sql:XML = new XML(sqlFileStream.readUTFBytes(sqlFileStream.bytesAvailable));
			sqlFileStream.close();
			var db:Database = new Database(sql);
			db.initialize();
			ml.db = db;

			// Get server configuration
			var pref:Preference = new Preference();
			pref.load();
			ml.serverInfo = new ServerInfo();
			ml.serverInfo.exchangeServer = (pref.getValue("exchangeServer") == null) ? "" : pref.getValue("exchangeServer");
			ml.serverInfo.exchangeUsername = (pref.getValue("exchangeUsername") == null) ? "" : pref.getValue("exchangeUsername");
			ml.serverInfo.exchangePassword = (pref.getValue("exchangePassword") == null) ? "" : pref.getValue("exchangePassword");
			ml.serverInfo.useHttps = (pref.getValue("useHttps") == null) ? true : pref.getValue("useHttps");
			
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
				gae.endDate = new Date();
				gae.updateUI = true;
				gae.dispatch();
			}
		}
	}
}
