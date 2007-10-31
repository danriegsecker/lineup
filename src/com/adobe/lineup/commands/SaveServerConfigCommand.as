package com.adobe.lineup.commands
{
	import com.adobe.air.preferences.Preference;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.events.GetAppointmentsEvent;
	import com.adobe.lineup.events.SaveServerConfigEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.events.StartServerMonitorEvent;
	
	public class SaveServerConfigCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ssce:SaveServerConfigEvent = ce as SaveServerConfigEvent;

			// Get server configuration
			var pref:Preference = new Preference();
			pref.load();
			pref.setValue("exchangeServer", ssce.exchangeServer);
			pref.setValue("exchangeUsername", ssce.exchangeUsername);
			pref.save();

			var ml:ModelLocator = ModelLocator.getInstance();
			ml.serverInfo.exchangeServer = ssce.exchangeServer;
			ml.serverInfo.exchangeUsername = ssce.exchangeUsername;
			ml.serverConfigOpen = false;

			var ssme:StartServerMonitorEvent = new StartServerMonitorEvent();
			ssme.dispatch();

			var gae:GetAppointmentsEvent = new GetAppointmentsEvent();
			gae.startDate = new Date();
			gae.endDate = new Date(gae.startDate.time + (60 * 60 * 24 * 7 * 1000)); // One week
			gae.updateUI = true;
			gae.dispatch();
		}
	}
}
