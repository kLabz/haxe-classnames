package classnames;

class ClassNames {
#if !macro
	#if js
	static var hasOwnProperty;

	public static function fromMaps(
		classMaps:Array<Dynamic<Bool>>,
		?nullIfEmpty:Bool = false
	):String {
		var o = {};

		if (hasOwnProperty == null)
			hasOwnProperty = untyped __js__('Object').prototype.hasOwnProperty;

		for (classMap in classMaps) untyped {
			__js__("for (var k in classMap) {");
				if (hasOwnProperty.call(classMap, k)) {
					var val = classMap[k];
					Reflect.setField(o, k, val);
				}
			__js__("}");
		}

		return fromMap(o, nullIfEmpty);
	}

	public static function fromMap(
		classMap:Dynamic<Bool>,
		?nullIfEmpty:Bool = false
	):String {
		var classNames = [];
		var hasClassNames = false;

		if (hasOwnProperty == null)
			hasOwnProperty = untyped __js__('Object').prototype.hasOwnProperty;

		untyped {
			__js__("for (var k in classMap) {");
				if (hasOwnProperty.call(classMap, k)) {
					if (classMap[k]) {
						classNames.push(k);
						hasClassNames = true;
					}
				}
			__js__("}");
		};

		if (hasClassNames) return classNames.join(" ");
		return nullIfEmpty ? null : "";
	}
	#else
	public static function fromMaps(
		classMaps:Array<Dynamic<Bool>>,
		?nullIfEmpty:Bool = false
	):String {
		var o = {};

		for (classMap in classMaps) untyped {
			for (k in Reflect.fields(classMap)) {
				var val = Reflect.field(classMap, k);
				Reflect.setField(o, k, val);
			}
		}

		fromMap(o, nullIfEmpty);
	}

	public static function fromMap(
		classMap:Dynamic<Bool>,
		?nullIfEmpty:Bool = false
	):String {
		var classNames = [];
		var hasClassNames = false;

		for (k in Reflect.fields(classMap)) {
			if (Reflect.field(classMap, k)) {
				classNames.push(k);
				hasClassNames = true;
			}
		}

		if (hasClassNames) return classNames.join(" ");
		return nullIfEmpty ? null : "";
	}
	#end
#end

	/**
	 * Macro implementation of classNames(), doing most of the work at compile-time.
	 * Falls back to runtime code for objects it cannot handle (e.g. object as ref instead of inline).
	 *
	 * Since the npm version accepts pretty much anything as input, so does this version.
	 * Accepted argument types are (mainly) String, Dynamic<String>, and [mixed] Arrays of these.
	 */
	macro public static inline function fast(args:Array<haxe.macro.Expr>):ExprOf<String> {
		return FastMacro.fast([], args);
	}

	/**
	 * Same as fast(), but will return null instead of an empty string.
	 * This is useful when dealing with React, which will ignore the className attribute if null.
	 */
	macro public static inline function fastNull(args:Array<haxe.macro.Expr>):ExprOf<String> {
		return FastMacro.fast([NullIfEmpty], args);
	}
}
