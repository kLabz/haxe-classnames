package classnames;

@:jsRequire('classnames')
extern class JSClassNames {
	@:selfCall
	public static function classNames(args:haxe.extern.Rest<Dynamic>):String;
}

class ClassNames {
	/**
	 * /!\ JS-only for now
	 *
	 * Macro implementation of classNames(), doing most of the work at compile-time.
	 * Falls back to npm extern for objects it cannot handle (e.g. object as ref instead of inline).
	 *
	 * Since the npm version accepts pretty much anything as input, so does this version.
	 */
	macro public static inline function fast(args:Array<haxe.macro.Expr>):ExprOf<String> {
		return FastMacro.fast(args);
	}

	/**
	 * With -D classnames_no_trim, an unnecessary first space will be added as first character
	 * of the string returned by fast() in almost every case.
	 *
	 * This saves runtime execution time, while not having any impact on usage with DOM.
	 *
	 * However, your tests will need to have a way to predict the outcome of fast(),
	 * so this function will prepend a space to the string you are testing against if
	 * fast() will be doing so.
	 */
	public static inline function getExpectedFast(expected:String):String {
		#if classnames_no_trim
		if (expected == "") return "";
		return " " + expected;
		#else
		return expected;
		#end
	}
}
