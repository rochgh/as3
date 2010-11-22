////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-11-19
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.ByteArray;
    import flash.utils.getDefinitionByName;
    
	/**
	 * 此类用于载入外部可视化资源，并转换成可以AS支持的资源的功能。
	 * */
    public class VisualLoader extends EventDispatcher
    {
	 	/**
		 * 指示载入的类型为png图片的常量。
		 * */
		public static const TYPE_PNG:String = 'png';
		
		/**
		 * 指示在如类型为swf动画的常量。
		 * */
		public static const TYPE_SWF:String = 'swf';
		
		/**
		 * 指示载入类型为jpeg图片的常量。
		 * */
		public static const TYPE_JPG:String = 'jpg';
		
		/**
		 * 载入完毕后，会发送这个事件。
		 * */
		public static const EVENT_COMPLETE:String = 'completeEvent';
		
        private var _loader:Loader;
		private var _type:String;
		
        public function VisualLoader()
        {
        }
		
		/**
		 * 返回当前载入的文件类型
		 * */
		public function get type():String
		{
			return _type;
		}

        private function handler_loaded(evt:Event):void
        {
			trace('载入swf完成：', _loader.contentLoaderInfo.url)
            dispatchEvent(evt);
        }

        private function handler_progress(evt:ProgressEvent):void
        {
            dispatchEvent(evt);
        }
		
		private function handler_ioError(evt:IOErrorEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function initLoader():void
		{
			if (_loader == null)
			{
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handler_loaded);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
				_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handler_progress);
			}
		}
		
		/**
		 * 载入字节数组，字节数组必须是swf、png或者jpg类型。
		 * @param $bytes 要载入的字节数组
		 * @param $type 要载入的字节数组的类型
		 * */
		public function loadBytes($bytes:ByteArray, $type:String="png"):void
		{
			_type = $type;
			initLoader();
			_loader.loadBytes($bytes);
		}

		/**
		 * 从外部URL载入可视对象，可是对象必须是swf、png或者jpg类型。
		 * @param $bytes 要载入的字节数组
		 * @param $type 要载入的字节数组的类型
		 * */
        public function load($url:String, $type:String="png") : void
        {
			_type = $type;
			initLoader();
            _loader.load(new URLRequest($url));
        }

		public function getClass($className:String):Class
		{
			if(_type == TYPE_SWF)
				return _loader.contentLoaderInfo.applicationDomain.getDefinition($className) as Class;
			else
				throw new Error('载入的可视对象不是SWF类型，不能返回Class');
		}
		
		/**
		 * 根据载入的可视对象的类型返回AS对象。
		 * 如果type的值为swf，则返回的是Flash库中支持的类的对象，例如MovieClip、Sprite、Bitmap、Sound、Font
		 * 如果type的值为png或者jpg，则返回的是一个Bitmap对象
		 * @param $className 要获取的对象的类名
		 * @param ...args 类的构建参数
		 * @see #type
		 * */
        public function getObject($className:String, ... args):*
        {
            if (_loader == null)
                return null;
            if (args == null)
                return null;
			if(_type == TYPE_SWF)
			{
				var __class:Class = getClass($className);
	            switch(args.length)
	            {
	                case 0:
	                    return new __class;
	                case 1:
	                    return new __class(args[0]);
	                case 2:
	                    return new __class(args[0], args[1]);
	                default:
	                    break;
	            }
			}
			else if(_type == TYPE_JPG || _type == TYPE_PNG)
			{
				return Bitmap(_loader.content);
			}
            return null;
        }

    }
}