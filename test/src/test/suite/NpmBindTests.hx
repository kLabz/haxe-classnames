package test.suite;

import buddy.SingleSuite;
import classnames.ClassNames;
import test.JSClassNames.JSClassNamesBind;

using buddy.Should;

class NpmBindTests extends SingleSuite {
	public function new() {
		var cssModulesMock = {
			a: "#a",
			b: "#b",
			c: "#c",
			d: "#d",
			e: "#e",
			f: "#f"
		};

		var classNamesBound:haxe.Constraints.Function = (untyped JSClassNamesBind.classNames.bind)(cssModulesMock);

		describe("Npm: usage as classNames()", {
			it("keeps object keys with truthy values", {
				JSClassNamesBind.classNames({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("joins arrays of class names and ignore falsy values", {
				JSClassNamesBind.classNames("a", 0, null, true, 1, "b").should.be("a 1 b");
			});

			it("supports heterogenous arguments", {
				JSClassNamesBind.classNames({a: true}, "b", 0).should.be("a b");
			});

			it("should be trimmed", {
				JSClassNamesBind.classNames("", "b", {}, "").should.be("b");
			});

			it("returns an empty string for an empty configuration", {
				JSClassNamesBind.classNames({}).should.be("");
			});

			it("supports an array of class names", {
				JSClassNamesBind.classNames(["a", "b"]).should.be("a b");
			});

			it("joins array arguments with string arguments", {
				JSClassNamesBind.classNames(["a", "b"], "c").should.be("a b c");
				JSClassNamesBind.classNames("c", ["a", "b"]).should.be("c a b");
			});

			it("handles multiple array arguments", {
				JSClassNamesBind.classNames(["a", "b"], ["c", "d"]).should.be("a b c d");
			});

			it("handles arrays that include falsy and true values", {
				JSClassNamesBind.classNames(["a", 0, null, false, true, "b"]).should.be("a b");
			});

			it("handles arrays that include arrays", {
				JSClassNamesBind.classNames(["a", ["b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", {
				JSClassNamesBind.classNames(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", {
				JSClassNamesBind.classNames(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});
		});

		describe("Npm classNames.bind()", {
			it("keeps object keys with truthy values", {
				classNamesBound({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("#a #e");
			});

			it("keeps class names undefined in bound hash", {
				classNamesBound({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1,
					x: true,
					y: null,
					z: 1
				}).should.be("#a #e x z");
			});

			it("joins arrays of class names and ignore falsy values", {
				classNamesBound("a", 0, null, true, 1, "b").should.be("#a 1 #b");
			});

			it("supports heterogenous arguments", {
				classNamesBound({a: true}, "b", 0).should.be("#a #b");
			});

			it("should be trimmed", {
				classNamesBound("", "b", {}, "").should.be("#b");
			});

			it("returns an empty string for an empty configuration", {
				classNamesBound({}).should.be("");
			});

			it("supports an array of class names", {
				classNamesBound(["a", "b"]).should.be("#a #b");
			});

			it("joins array arguments with string arguments", {
				classNamesBound(["a", "b"], "c").should.be("#a #b #c");
				classNamesBound("c", ["a", "b"]).should.be("#c #a #b");
			});

			it("handles multiple array arguments", {
				classNamesBound(["a", "b"], ["c", "d"]).should.be("#a #b #c #d");
			});

			it("handles arrays that include falsy and true values", {
				var arr:Array<Dynamic> = ["a", 0, null, false, true, "b"];
				classNamesBound(arr).should.be("#a #b");
			});

			it("handles arrays that include arrays", {
				var arr:Array<Dynamic> = ["a", ["b", "c"]];
				classNamesBound(arr).should.be("#a #b #c");
			});

			it("handles arrays that include objects", {
				var arr:Array<Dynamic> = ["a", {b: true, c: false}];
				classNamesBound(arr).should.be("#a #b");
			});

			it("handles deep array recursion", {
				var arr1:Array<Dynamic> = ["c", {d: true}];
				var arr2:Array<Dynamic> = ["b", arr1];
				var arr3:Array<Dynamic> = ["a", arr2];
				classNamesBound(arr3).should.be("#a #b #c #d");
			});
		});

		// TODO: same tests for haxe version
	}
}
