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

#if (haxe_ver < 4)
typedef ObjectField = {field:String, expr:Expr};
#end

enum FastOption {
	NullIfEmpty;
	AsObject;
	Bind(classMap:Dynamic<String>); // Can be an ExprOf<Dynamic<String>>
}

typedef FastOptions = {
	?NullIfEmpty:Bool,
	?AsObject:Bool,
	?Bind:Dynamic<String>
}

enum ClassDefinition {
	CompileTime(key:String, condition:ClassCondition);
	Runtime(expr:Expr);
	RuntimeArray(expr:Expr);
	Fallback(expr:Expr);
}

enum ClassCondition {
	Hardcoded;
	Ignored;
	Runtime(checkExpr:Expr, runtimeExpr:Expr);
}

class FastMacro {
	/*
		TODO: handle options
		- Bind for css modules (how do we handle them in haxe?)
			- Fully compile-time when possible
			- "Semi compile-time" if contains runtime/fallback
			- Runtime if map is a reference

		TODO: misc
		- Useful error messages for invalid arguments
		- BEM helpers?
	*/
	public static function fast(opt:Array<FastOption>, args:Array<Expr>) {
		var classes:Array<ClassDefinition> = [];

		var options:FastOptions = {};
		if (opt != null) {
			for (o in opt) {
				switch (o) {
					case NullIfEmpty: options.NullIfEmpty = true;
					case AsObject: options.AsObject = true;
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

		if (hasFallback || options.Bind != null) {
			var exprs = classesToMaps(classes, options, pos);
			var maps = exprs.maps;

			var retExpr = switch (maps.length) {
				case 0:
				returnVoid(options);

				case 1:
				// TODO: pass bind map
				if (options.AsObject)
					macro {className: classnames.ClassNames.fromMap(${maps[0]})};
				else
					macro classnames.ClassNames.fromMap(${maps[0]});

				default:
				// TODO: pass bind map
				if (options.AsObject)
					macro {className: classnames.ClassNames.fromMaps([$a{maps}])};
				else
					macro classnames.ClassNames.fromMaps([$a{maps}]);
			};

			if (exprs.head.length > 0)
				return macro {
					$a{exprs.head};
					${retExpr};
				};
			else
				return retExpr;

		} else {
			var classesInfos = flattenClasses(classes, options, pos);
			if (classesInfos.expr == null) return returnVoid(options);

			var trimmedExpr = macro ${classesInfos.expr};
			if (classesInfos.needsTrim) {
				trimmedExpr = macro ${classesInfos.expr}.substr(1);
			}

			var retExpr= options.AsObject
				? macro {className: ${trimmedExpr}}
				: macro ${trimmedExpr};

			if (classesInfos.head.length > 0)
				return macro {
					$a{classesInfos.head};
					${retExpr};
				};
			else
				return retExpr;
		}
	}

	static function returnVoid(options:FastOptions):Expr {
		if (options.AsObject && options.NullIfEmpty) return macro {className: null};
		else if (options.NullIfEmpty) return macro null;
		else if (options.AsObject) return macro {className: ""};
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
					classes = appendClassExpr(classes, options, fieldName, Ignored);

					case EConst(CIdent("true")), EObjectDecl(_), EArrayDecl(_), EBlock([]):
					classes = appendClassExpr(classes, options, fieldName, Hardcoded);

					default:
					try {
						var value:Dynamic = ExprTools.getValue(f.expr);

						// Workaround for haxe 4 rc2 and rc3, awaiting next release
						if (value == 0) {
							classes = appendClassExpr(classes, options, fieldName, Ignored);
							continue;
						}

						switch (value) {
							// case false, 0, "", null: // Doesn't work in haxe 4 rc2 and rc3, fixed in dev builds
							case false, "", null:
							classes = appendClassExpr(classes, options, fieldName, Ignored);

							case true:
							classes = appendClassExpr(classes, options, fieldName, Hardcoded);

							case s if (Std.is(s, String)):
							classes = appendClassExpr(classes, options, fieldName, Hardcoded);

							case i if (Std.is(i, Int) && i != 0):
							classes = appendClassExpr(classes, options, fieldName, Hardcoded);

							case f if (Std.is(f, Float) && f != 0):
							classes = appendClassExpr(classes, options, fieldName, Hardcoded);

							default:
							throw "Fallback to runtime";
						}
					} catch(e:Dynamic) {
						var c = macro ${f.expr};
						var f = macro $v{fname};
						classes = appendClassExpr(classes, options, fieldName, Runtime(c, f));
					}
				}
			}

			case EConst(CString("")):
			// Ignored

			case EConst(CString(s)):
			for (c in ~/\s+/.split(s))
				classes = appendClassExpr(classes, options, c, Hardcoded);

			case EConst(CIdent(i)), EConst(CInt(i)) if (i == "true" || i == "false" || i == "0" || i == "null"):
			// Ignored

			case EConst(CInt(i)):
			classes = appendClassExpr(classes, options, i, Hardcoded);

			case EArrayDecl(args):
			for (arg in args) classes = parseFastArg(arg, classes, options);

			case EBlock([]):
			// Ignored

			case EParenthesis(e):
			return parseFastArg(e, classes, options);

			case EUntyped(_):
			Context.error("Use of untyped is not allowed here", pos);

			default:
			switch (Context.typeExpr(arg).t) {
				case t if (isDynamicBool(t)):
				appendFallback(classes, arg);

				case t if (isInstOf(t, "String")):
				appendRuntime(classes, arg);

				case TInst(arrInst, [TInst(strInst, [])])
				if (arrInst.toString() == "Array" && strInst.toString() == "String"):
				appendRuntimeArray(classes, arg);

				// Unsupported types

				case TAnonymous(_):
				Context.error("Reference to object should be of type Dynamic<Bool>", pos);

				case t if (isInstOf(t, "Int")):
				Context.error("Reference to int not allowed. Use string instead?", pos);

				case t if (isInstOf(t, "Bool")):
				Context.error("Reference to boolean not allowed. Use string instead?", pos);

				case TInst(arrInst, params) if (arrInst.toString() == "Array"):
				Context.error("Reference to non-string Array not allowed. Use Array<String> instead?", pos);

				case typed:
				#if classnames_fast_infos
				trace(arg);
				trace(typed);
				#end
				Context.error("Unsupported argument", pos);
			}
		}

		return classes;
	}

	static function isInstOf(type:Type, of:String):Bool {
		return switch(type) {
			case TType(_.get() => {name: "Null", pack: []}, [TInst(a, _)]) if (a.toString() == of): true;
			case TType(_.get() => {name: "Null", pack: []}, [TAbstract(a, _)]) if (a.toString() == of): true;
			case TInst(a, _) if (a.toString() == of): true;
			case TAbstract(a, _) if (a.toString() == of): true;
			default: false;
		};
	}

	static function isDynamicBool(type:Type):Bool {
		var ctDynamicBool = macro :Dynamic<Bool>;
		var tDynamicBool = ctDynamicBool.toType();
		return TypeTools.unify(type, tDynamicBool);
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
				case CompileTime(prevKey, prevCondition) if (prevKey == key):
				var newCondition = switch (prevCondition) {
					case Hardcoded if (condition == Ignored): Ignored;
					case Hardcoded: Hardcoded;

					case Ignored: condition;

					case Runtime(checkExpr, runtimeExpr):
					switch (condition) {
						case Runtime(_): condition;
						default: prevCondition;
					}
				}
				notFound = false;
				CompileTime(prevKey, newCondition);

				default: c;
			};
		});

		if (notFound) {
			classes.push(CompileTime(key, condition));
		}

		return classes;
	}

	static function appendFallback(
		classes:Array<ClassDefinition>,
		expr:Expr
	):Void {
		classes.push(Fallback(expr));
	}

	static function appendRuntime(
		classes:Array<ClassDefinition>,
		expr:Expr
	):Void {
		classes.push(Runtime(expr));
	}

	static function appendRuntimeArray(
		classes:Array<ClassDefinition>,
		expr:Expr
	):Void {
		classes.push(RuntimeArray(expr));
	}

	static function getMappedKey(map:Dynamic<String>, key:String):Null<String> {
		if (Reflect.hasField(map, key)) return Reflect.field(map, key);
		return null;
	}

	static function flattenClasses(
		classes:Array<ClassDefinition>,
		options:FastOptions,
		pos:Position
	):{expr:Expr, head:Null<Array<Expr>>, needsTrim:Bool} {
		var needsTrim = false;
		var head:Array<Expr> = [];

		var expr:Expr = Lambda.fold(classes, function(cdef, expr) {
			return switch (cdef) {
				case CompileTime(key, condition):
				switch (condition) {
					case Hardcoded:
					concatExprs(expr, macro $v{key}, pos);

					case Ignored:
					expr;

					case Runtime(checkExpr, runtimeExpr):
					head.push(checkExpr);
					if (expr == null) needsTrim = true;
					concatExprs(expr, macro ((untyped ${checkExpr}) ? ${runtimeExpr} : ""), pos);
				}

				case Runtime(runtimeExpr):
				if (expr == null) needsTrim = true;
				concatExprs(expr, macro " " + ${runtimeExpr}, pos);

				case RuntimeArray(runtimeExpr):
				if (expr == null) needsTrim = true;
				concatExprs(expr, macro " " + ${runtimeExpr}.join(" "), pos);

				case Fallback(fallbackExpr):
				if (expr == null) needsTrim = true;
				concatExprs(
					expr,
					macro {
						var a:String;
						((untyped (a = classnames.ClassNames.fromMap(${fallbackExpr}))) ? " " + a : "");
					},
					pos
				);
			};
		}, null);

		return {expr: expr, head: head, needsTrim: needsTrim};
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
	):{head: Array<Expr>, maps: Array<Expr>} {
		var maps = [];
		var head = [];
		var currentMap:Array<ObjectField> = [];
		var hasRuntimeOrFallback = false;

		for (cdef in classes) {
			switch (cdef) {
				case CompileTime(key, condition):
				switch (condition) {
					case Hardcoded:
					currentMap.push({field: key, expr: macro true});

					case Ignored:
					if (hasRuntimeOrFallback) currentMap.push({field: key, expr: macro false});

					case Runtime(checkExpr, runtimeExpr):
					head.push(checkExpr);
					currentMap.push({field: key, expr: macro untyped ${checkExpr}});
				}

				case Runtime(expr):
				closeMap(maps, currentMap, pos);
				maps.push(macro {
					var a = {};
					for (f in ~/\s+/.split(${expr})) Reflect.setField(a, f, true);
					a;
				});
				currentMap = [];
				hasRuntimeOrFallback = true;

				case RuntimeArray(expr):
				closeMap(maps, currentMap, pos);
				maps.push(macro classnames.ClassNames.arrayToMap(${expr}));
				currentMap = [];
				hasRuntimeOrFallback = true;
				hasRuntimeOrFallback = true;

				case Fallback(expr):
				closeMap(maps, currentMap, pos);
				maps.push(macro ${expr});
				currentMap = [];
				hasRuntimeOrFallback = true;
			}
		}

		closeMap(maps, currentMap, pos);

		return {head: head, maps: maps};
	}

	static function closeMap(
		maps:Array<Expr>,
		currentMap:Array<ObjectField>,
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
