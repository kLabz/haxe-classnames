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

class FastMacro {
	/*
		TODO: possible optimizations
		- group duplicates, hardcode when it will always be included
		- use array + join instead of concatenation when there is enough classes
		  to concatenate for it to be more effective

		TODO: options
		- dedupe
		- return null if empty string (for use in react)
		- (?) trim result

		TODO: misc
		- error messages for invalid arguments
	*/
	public static function fast(args:Array<Expr>) {
		var classes:ExprOf<String> = null;
		for (arg in args) classes = parseFastArg(arg, classes);
		if (classes == null) classes = macro "";

		#if classnames_no_trim
		var trimExpr = macro ${classes};
		#else
		var trimExpr;
		var pos = Context.currentPos();
		var trim = tryTrimClasses(classes, pos);
		if (trim.trimmed) {
			classes = trim.expr;
			trimExpr = macro ${trim.expr};
		} else {
			trimExpr = macro ${classes}.substr(1);
		}
		#end

		return macro ${trimExpr};
	}

	static function parseFastArg(arg:Expr, classes:Expr) {
		var pos = arg.pos;

		switch (arg.expr) {
			case EObjectDecl(fields):
			for (f in fields) {
				var fieldName = f.field;
				if (fieldName.startsWith("@$__hx__")) fieldName = fieldName.substr(8);
				var fname = ' $fieldName';

				switch (f.expr.expr) {
					case EConst(CIdent("false")):
					#if classnames_fast_infos
					Context.warning('[Info] ClassNames: class "$fieldName" safely ignored', pos);
					#end

					case EConst(CIdent("true")), EObjectDecl(_), EArrayDecl(_), EBlock([]):
					#if classnames_fast_infos
					Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
					#end
					classes = appendClassExpr(classes, macro $v{fname}, pos);

					default:
					try {
						var value:Dynamic = ExprTools.getValue(f.expr);

						switch (value) {
							case false, 0, "", null:
							#if classnames_fast_infos
							Context.warning('[Info] ClassNames: class "$fieldName" safely ignored', pos);
							#end

							case true:
							#if classnames_fast_infos
							Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
							#end
							classes = appendClassExpr(classes, macro $v{fname}, pos);

							case s if (Std.is(s, String)):
							#if classnames_fast_infos
							Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
							#end
							classes = appendClassExpr(classes, macro $v{fname}, pos);

							case i if (Std.is(i, Int) && i != 0):
							#if classnames_fast_infos
							Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
							#end
							classes = appendClassExpr(classes, macro $v{fname}, pos);

							case f if (Std.is(f, Float) && f != 0):
							#if classnames_fast_infos
							Context.warning('[Info] ClassNames: class "$fieldName" hardcoded', pos);
							#end
							classes = appendClassExpr(classes, macro $v{fname}, pos);

							default:
							throw "Fallback to runtime";
						}
					} catch(e:Dynamic) {
						#if classnames_fast_infos
						Context.warning('[Info] ClassNames: class "$fieldName" added with runtime check', pos);
						#end
						var cls = macro {
							// Ensure haxe compiler checks this expression, but let dce remove this line
							${f.expr};

							// Real check
							((untyped ${f.expr}) ? $v{fname} : "");
						};
						classes = appendClassExpr(classes, cls, pos);
					}
				}
			}

			case EConst(CString("")):
			#if classnames_fast_infos
			Context.warning('[Info] ClassNames: empty class safely ignored', pos);
			#end

			case EConst(CString(s)):
			#if classnames_fast_infos
			Context.warning('[Info] ClassNames: class "$s" hardcoded', pos);
			#end
			classes = appendClassExpr(classes, macro $v{" " + s}, pos);

			case EConst(CIdent(i)), EConst(CInt(i)) if (i == "true" || i == "false" || i == "0" || i == "null"):
			#if classnames_fast_infos
			Context.warning('[Info] ClassNames: class "$i" safely ignored', pos);
			#end

			case EConst(CInt(i)):
			#if classnames_fast_infos
			Context.warning('[Info] ClassNames: class "$i" hardcoded', pos);
			#end
			classes = appendClassExpr(classes, macro ' $i', pos);

			case EConst(CIdent(i)):
			switch (Context.typeExpr(arg).t) {
				case t if (isDynamicBool(t)):
				#if classnames_fast_warnings
				Context.warning('[Warn] ClassNames: falling back to runtime implementation.', pos);
				#end
				classes = appendClassExpr(
					classes,
					macro {
						var a:String;
						((untyped (a = classnames.JSClassNames.classNames($i{i}))) ? " " + a : "");
					},
					pos
				);

				case t if (isString(t)):
				#if classnames_fast_infos
				Context.warning('[Info] ClassNames: hardcoded string reference', pos);
				#end
				classes = appendClassExpr(classes, macro " " + $i{i}, pos);

				default:
				// TODO: explicit error message
				trace(arg);
				Context.error('Unsupported argument (Econst(CIdent(i)))', pos);
			}

			case EArrayDecl(args):
			for (arg in args) classes = parseFastArg(arg, classes);

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

	static function appendClassExpr(classes:Expr, cls:Expr, pos:Position):Expr {
		if (classes != null) {
			switch (cls.expr) {
				case EConst(CString(str)):
				switch (classes.expr) {
					case EBinop(OpAdd, left, right):
					switch (right.expr) {
						case EConst(CString(str1)):
						classes = makeBinAdd(left, {expr: EConst(CString(str1 + str)), pos: pos}, pos);
						return classes;

						default:
					}

					case EConst(CString(str1)):
					classes = {expr: EConst(CString(str1 + str)), pos: pos};
					return classes;

					default:
				}

				default:
			}
		}

		if (classes == null) classes = cls;
		else classes = makeBinAdd(classes, cls, pos);

		return classes;
	}

	static function makeBinAdd(left:Expr, right:Expr, pos:Position):Expr {
		return {expr: EBinop(OpAdd, left, right), pos: pos};
	}

	static function tryTrimClasses(classes:Expr, pos:Position):{expr: Expr, trimmed: Bool} {
		var trimmed = false;

		if (classes != null) {
			switch (classes.expr) {
				case EBinop(OpAdd, left, right):
				switch (left.expr) {
					case EConst(CString(str)):
					trimmed = true;
					if (str == " ")
						classes = right;
					else
						classes = makeBinAdd(
							{expr: EConst(CString(str.substr(1))), pos: pos},
							right,
							pos
						);

					case EBinop(OpAdd, _, _):
						var sub = tryTrimClasses(left, pos);
						if (sub.trimmed) {
							trimmed = true;
							classes = makeBinAdd(sub.expr, right, pos);
						}

					default:
				}

				case EConst(CString(str)):
				trimmed = true;
				classes = {expr: EConst(CString(str.substr(1))), pos: pos};

				default:
			}
		}

		return {expr: classes, trimmed: trimmed};
	}
}
#end
