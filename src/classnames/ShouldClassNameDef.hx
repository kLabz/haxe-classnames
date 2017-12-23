package classnames;

import haxe.PosInfos;
import buddy.Should;

class ShouldClassNameDef extends Should<ClassNameDef> {
	static public function should(wrapper:ClassNameDef) {
		return new ShouldClassNameDef(wrapper);
	}

	public function new(value:ClassNameDef, inverse = false) {
		super(value, inverse);
	}

	public var not(get, never):ShouldClassNameDef;
	private function get_not() { return new ShouldClassNameDef(value, !inverse); }

	private function wasNull(msg:String, ?p:PosInfos) {
		return fail(
			'Expected ClassNameDef $msg but was null',
			'Expected ClassNameDef not $msg but was null',
			p
		);
	}

	public function match(classNames:String, ?p:PosInfos) {
		if (value == null || value.className == null) return wasNull('to match classNames "$classNames"', p);

		test(
			StringTools.trim(value.className) == classNames,
			p,
			'Expected "${value.className}" to match classNames "$classNames"',
			'Expected "${value.className}" not to match classNames "$classNames"'
		);
	}

	public function beEmpty(?p:PosInfos) {
		test(
			value == null || value.className == null,
			p,
			'Expected "${value.className}" to be null',
			'Expected "${value.className}" not to be null'
		);
	}

	public function contain(className:String, ?p:PosInfos) {
		if (value == null || value.className == null) return wasNull('to contain "$className"', p);

		var classes = ~/\s+/.split(value.className);

		test(
			Lambda.find(classes, function(cls) return cls == className) != null,
			p,
			'Expected "${value.className}" to contain "$className"',
			'Expected "${value.className}" not to contain "$className"'
		);
	}

	public function containAll(classNames:Array<String>, ?p:PosInfos) {
		if (value == null || value.className == null)
			return wasNull('to contain all classes from "${classNames.join(" ")}"', p);

		var classes = ~/\s+/.split(value.className);
		for (cls in classes) classNames.remove(cls);

		test(
			classNames.length == 0,
			p,
			'Expected "${value.className}" to contain all classes from "${classNames.join(" ")}"',
			'Expected "${value.className}" not to contain all classes from "${classNames.join(" ")}"'
		);
	}

	public function containAny(classNames:Array<String>, ?p:PosInfos) {
		if (value == null || value.className == null)
			return wasNull('to contain any classes from "${classNames.join(" ")}"', p);

		var classes = ~/\s+/.split(value.className);
		var nbClasses = classes.length;
		for (cls in classNames) classes.remove(cls);

		test(
			nbClasses != classes.length,
			p,
			'Expected "${value.className}" to contain any classes from "${classNames.join(" ")}"',
			'Expected "${value.className}" not to contain any classes from "${classNames.join(" ")}"'
		);
	}
}
