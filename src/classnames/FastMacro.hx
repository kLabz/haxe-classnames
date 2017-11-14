#if macro
package classnames;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.PositionTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;

using StringTools;
using haxe.macro.ComplexTypeTools;

enum FastOption {
	NullIfEmpty;
	Bind(classMap:Dynamic<String>); // Can be an ExprOf<Dynamic<String>>
}

typedef FastOptions = {
	?NullIfEmpty:Bool,
	?Bind:Dynamic<String>
}

enum ClassDefinition {
	CompileTime(key:String, mappedKey:Null<String>, condition:ClassCondition);
	Runtime(ident:String);
	Fallback(ident:String);
}

enum ClassCondition {
	Hardcoded;
	Ignored;
	Runtime(expr:Expr);
}

class FastMacro {
	/*
		TODO: handle options
		- bind for css modules
			- Fully compile-time when possible
			- "Semi compile-time" if contains runtime/fallback
			- Runtime if map is a reference

		TODO: misc
		- error messages for invalid arguments
		- (?) debug infos with positions
	*/
	public static function fast(opt:Array<FastOption>, args:Array<Expr>) {
		var classes:Array<ClassDefinition> = [];

		var options:FastOptions = {};
		if (opt != null) {
			for (o in opt) {
				switch (o) {
					case NullIfEmpty: options.NullIfEmpty = true;
					case Bind(classMap): options.Bind = classMap;
				}
			}
		}

		for (arg in args) classes = parseFastArg(arg, classes, options);
		if (classes.length == 0) returnVoid(options);

		var pos = Context.currentPos();
		var hasFallback = Lambda.find(classes, function(c) {
			return switch (c) {
				case Fallback(_), Runtime(_): true;
				default: false;
			};
		}) != null;

		if (hasFallback) {
			var maps = classesToMaps(classes, options, pos);

			return switch (maps.length) {
				case 0:
				returnVoid(options);

				case 1:
				macro classnames.ClassNames.fromMap(${maps[0]});

				default:
				macro classnames.ClassNames.fromMaps([$a{maps}]);
			};
		} else {
			var classesInfos = flattenClasses(classes, options, pos);
			if (classesInfos.expr == null) return returnVoid(options);

			var trimmedExpr = macro ${classesInfos.expr};
			if (classesInfos.needsTrim) {
				trimmedExpr = macro ${classesInfos.expr}.substr(1);
			}

			return macro ${trimmedExpr};
		}
	}

	static function returnVoid(options:FastOptions):Expr {
		if (options.NullIfEmpty) return macro null;
		else return macro "";
	}

	static function parseFastArg(
		arg:Expr,
		classes:Array<ClassDefinition>,
		options:FastOptions
	):Array<ClassDefinition> {
		var pos = arg.pos;

		switch (arg.expr) {
			case EObjectDecl(fields):
			for (f in fields) {
				var fieldName = f.field;
				if (fieldName.startsWith("@$__hx__")) fieldName = fieldName.substr(8);
				var fname = ' $fieldName';

				switch (f.expr.expr) {
					case EConst(CIdent("false")):
					// #if classnames_fast_infos
					// Context.warning('[Info] ClassNames: class "$fieldName" safely ignored', pos);
					// #end
					classes = appendClassExpr(classes, options, fieldName, Ignored);

					case EConst(CIdent("true")), EObjectDecl(_), EArrayDecl(_), EBlock([]):
					// #if classnames_fast_infos
					// Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
					// #end
					classes = appendClassExpr(classes, options, fieldName, Hardcoded);

					default:
					try {
						var value:Dynamic = ExprTools.getValue(f.expr);

						switch (value) {
							case false, 0, "", null:
							// #if classnames_fast_infos
							// Context.warning('[Info] ClassNames: class "$fieldName" safely ignored', pos);
							// #end
							classes = appendClassExpr(classes, options, fieldName, Ignored);

							case true:
							// #if classnames_fast_infos
							// Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
							// #end
							classes = appendClassExpr(classes, options, fieldName, Hardcoded);

							case s if (Std.is(s, String)):
							// #if classnames_fast_infos
							// Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
							// #end
							classes = appendClassExpr(classes, options, fieldName, Hardcoded);

							case i if (Std.is(i, Int) && i != 0):
							// #if classnames_fast_infos
							// Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
							// #end
							classes = appendClassExpr(classes, options, fieldName, Hardcoded);

							case f if (Std.is(f, Float) && f != 0):
							// #if classnames_fast_infos
							// Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
							// #end
							classes = appendClassExpr(classes, options, fieldName, Hardcoded);

							default:
							throw "Fallback to runtime";
						}
					} catch(e:Dynamic) {
						// #if classnames_fast_infos
						// Context.warning('[Info] ClassNames: class "$fieldName" added with runtime check', pos);
						// #end
						var clsExpr = macro {
							// Ensure haxe compiler checks this expression, but let dce remove this line
							${f.expr};

							// Real check
							((untyped ${f.expr}) ? $v{fname} : "");
						};
						classes = appendClassExpr(classes, options, fieldName, Runtime(clsExpr));
					}
				}
			}

			case EConst(CString("")):
			#if classnames_fast_infos
			Context.warning('[Info] ClassNames: empty class safely ignored', pos);
			#end

			case EConst(CString(s)):
			// #if classnames_fast_infos
			// Context.warning('[Info] ClassNames: class "$s" hardcoded', pos);
			// #end
			for (c in ~/\s+/.split(s))
				classes = appendClassExpr(classes, options, c, Hardcoded);

			case EConst(CIdent(i)), EConst(CInt(i)) if (i == "true" || i == "false" || i == "0" || i == "null"):
			#if classnames_fast_infos
			Context.warning('[Info] ClassNames: class "$i" safely ignored', pos);
			#end

			case EConst(CInt(i)):
			// #if classnames_fast_infos
			// Context.warning('[Info] ClassNames: class "$i" hardcoded', pos);
			// #end
			classes = appendClassExpr(classes, options, i, Hardcoded);

			case EConst(CIdent(i)):
			switch (Context.typeExpr(arg).t) {
				case t if (isDynamicBool(t)):
				// #if classnames_fast_warnings
				// Context.warning('[Warn] ClassNames: falling back to runtime implementation.', pos);
				// #end
				appendFallback(classes, i);

				case t if (isString(t)):
				// #if classnames_fast_infos
				// Context.warning('[Info] ClassNames: hardcoded string reference', pos);
				// #end
				appendRuntime(classes, i);

				default:
				// TODO: explicit error message
				trace(arg);
				Context.error('Unsupported argument (Econst(CIdent(i)))', pos);
			}

			case EArrayDecl(args):
			for (arg in args) classes = parseFastArg(arg, classes, options);

			// Ignored expressions
			case EBlock([]):
			// Nothing to do

			default:
			// TODO: explicit error message
			trace(arg);
			Context.error('Unsupported argument', pos);
		}

		return classes;
	}

	static function isDynamicBool(type:Type):Bool {
		var ctDynamicBool = macro :Dynamic<Bool>;
		var tDynamicBool = ctDynamicBool.toType();
		return TypeTools.unify(type, tDynamicBool);
	}

	static function isString(type:Type):Bool {
		var ctString = macro :String;
		var tString = ctString.toType();
		return TypeTools.unify(type, tString);
	}

	static function appendClassExpr(
		classes:Array<ClassDefinition>,
		options:FastOptions,
		key:String,
		condition:ClassCondition
	):Array<ClassDefinition> {
		var notFound = true;

		classes = classes.map(function(c) {
			return switch(c) {
				case CompileTime(prevKey, prevMappedKey, prevCondition) if (prevKey == key):
				var newCondition = switch (prevCondition) {
					case Hardcoded if (condition == Ignored): Ignored;
					case Hardcoded: Hardcoded;

					case Ignored: condition;

					case Runtime(expr):
					switch (condition) {
						case Runtime(_): condition;
						default: prevCondition;
					}
				}
				notFound = false;
				CompileTime(prevKey, prevMappedKey, newCondition);

				default: c;
			};
		});

		if (notFound) {
			var mappedKey = options.Bind != null ? getMappedKey(options.Bind, key) : null;
			classes.push(CompileTime(key, mappedKey == null ? key : mappedKey, condition));
		}

		return classes;
	}

	static function appendFallback(
		classes:Array<ClassDefinition>,
		ident:String
	):Void {
		classes.push(Fallback(ident));
	}

	static function appendRuntime(
		classes:Array<ClassDefinition>,
		ident:String
	):Void {
		classes.push(Runtime(ident));
	}

	static function getMappedKey(map:Dynamic<String>, key:String):Null<String> {
		if (Reflect.hasField(map, key)) return Reflect.field(map, key);
		return null;
	}

	static function flattenClasses(
		classes:Array<ClassDefinition>,
		options:FastOptions,
		pos:Position
	):{expr:Expr, needsTrim:Bool} {
		var needsTrim = false;

		var expr:Expr = Lambda.fold(classes, function(cdef, expr) {
			return switch (cdef) {
				case CompileTime(key, mappedKey, condition):
				switch (condition) {
					case Hardcoded:
					concatExprs(expr, macro $v{mappedKey}, pos);

					case Ignored:
					expr;

					case Runtime(runtimeExpr):
					if (expr == null) needsTrim = true;
					concatExprs(expr, runtimeExpr, pos);
				}

				case Runtime(ident):
				if (expr == null) needsTrim = true;
				concatExprs(expr, macro " " + $i{ident}, pos);

				case Fallback(ident):
				if (expr == null) needsTrim = true;
				concatExprs(
					expr,
					macro {
						var a:String;
						((untyped (a = classnames.ClassNames.fromMap($i{ident}))) ? " " + a : "");
					},
					pos
				);
			};
		}, null);

		return {expr: expr, needsTrim: needsTrim};
	}

	static function concatExprs(prevExpr:Expr, newExpr:Expr, pos:Position):Expr {
		if (prevExpr != null) {
			switch (newExpr.expr) {
				case EConst(CString(newStr)):
				switch (prevExpr.expr) {
					case EBinop(OpAdd, left, right):
					switch (right.expr) {
						case EConst(CString(rightStr)):
						return makeBinAdd(left, {expr: EConst(CString(rightStr + " " + newStr)), pos: pos}, pos);

						default:
						newExpr = {expr: EConst(CString(" " + newStr)), pos: pos};
					}

					case EConst(CString(prevStr)):
					return {expr: EConst(CString(prevStr + " " + newStr)), pos: pos};

					default:
					newExpr = {expr: EConst(CString(" " + newStr)), pos: pos};
				}

				default:
			}
		}

		if (prevExpr == null) return newExpr;
		return makeBinAdd(prevExpr, newExpr, pos);
	}

	static function makeBinAdd(left:Expr, right:Expr, pos:Position):Expr {
		return {expr: EBinop(OpAdd, left, right), pos: pos};
	}

	static function classesToMaps(
		classes:Array<ClassDefinition>,
		options:FastOptions,
		pos:Position
	):Array<Expr> {
		var maps = [];
		var currentMap:Array<{field:String, expr:Expr}> = [];
		var hasRuntimeOrFallback = false;

		for (cdef in classes) {
			switch (cdef) {
				case CompileTime(key, mappedKey, condition):
				switch (condition) {
					case Hardcoded:
					currentMap.push({field: mappedKey, expr: macro true});

					case Ignored:
					if (hasRuntimeOrFallback) currentMap.push({field: mappedKey, expr: macro false});

					case Runtime(runtimeExpr):
					currentMap.push({field: mappedKey, expr: runtimeExpr});
				}

				case Runtime(ident):
				closeMap(maps, currentMap, pos);
				maps.push(macro {
					var a = {};
					for (f in ~/\s+/.split($i{ident})) Reflect.setField(a, f, true);
					a;
				});
				currentMap = [];
				hasRuntimeOrFallback = true;

				case Fallback(ident):
				closeMap(maps, currentMap, pos);
				maps.push(macro $i{ident});
				currentMap = [];
				hasRuntimeOrFallback = true;
			}
		}

		closeMap(maps, currentMap, pos);

		return maps;
	}

	static function closeMap(
		maps:Array<Expr>,
		currentMap:Array<{field:String, expr:Expr}>,
		pos:Position
	):Void {
		if (currentMap.length > 0) {
			maps.push({
				expr: EObjectDecl(currentMap),
				pos: pos
			});
		}
	}
}
#end
