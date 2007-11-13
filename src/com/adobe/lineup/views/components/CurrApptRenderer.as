package com.adobe.lineup.views.components
{
	import com.adobe.lineup.model.ModelLocator;
	
	import mx.controls.treeClasses.*;

	public class CurrApptRenderer extends TreeItemRenderer
	{
		public function CurrApptRenderer() 
		{
			super();
		}

		override public function set data(value:Object):void 
		{
			super.data = value;
			var _oTreeListData:TreeListData = TreeListData(super.listData);
			var ml: ModelLocator = ModelLocator.getInstance();
			if (_oTreeListData != null && ml.currentAppointment != null)
			{
				var itm: XML = _oTreeListData.item as XML;
				if (itm.attribute("startDate") == ml.currentAppointment.startDate.toString() &&
					itm.attribute("endDate") == ml.currentAppointment.endDate.toString() &&
					itm.attribute("data") == ml.currentAppointment.subject)
				{
					setStyle("fontWeight", 'bold');
				}
				else 
				{
					setStyle("fontWeight", 'normal');
				}
			}
		}
	}
}