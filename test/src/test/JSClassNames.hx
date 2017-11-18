package test;

@:jsRequire('classnames')
extern class JSClassNames {
	@:selfCall
	public static function classNames(args:haxe.extern.Rest<Dynamic>):String;
}

@:jsRequire('classnames/dedupe')
extern class JSClassNamesDedupe {
	@:selfCall
	public static function dedupe(args:haxe.extern.Rest<Dynamic>):String;
}

@:jsRequire('classnames/bind')
extern class JSClassNamesBind {
	@:selfCall
	public static function classNames(args:haxe.extern.Rest<Dynamic>):String;
}
