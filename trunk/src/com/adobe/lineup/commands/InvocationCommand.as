package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.system.Shell;
	
	public class InvocationCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			if (Shell.shell.openedWindows == null || Shell.shell.openedWindows.length == 0) return;
			var win:NativeWindow = NativeWindow(Shell.shell.openedWindows[0]);
			if (win.displayState == NativeWindowDisplayState.MINIMIZED)
			{
				win.maximize();
			}
		}
	}
}
