package test.suite;

import buddy.SingleSuite;
import classnames.ClassNames;

using buddy.Should;

class FastReferencesTests extends SingleSuite {
	public function new() {
		describe("ClassNames.fast() should handle references", {
			it("handles reference to Dynamic<Bool>", function () {
				var obj = {a: true, b: false, e: true};

				ClassNames.fast(obj).should.be("a e");
			});

			it("handles mixed String/Dynamic<Bool>, and dedupes", function () {
				var foo = "foo";
				var fooObj = {foo: true};
				ClassNames.fast(foo, "bar", foo, "bar", fooObj).should.be("foo bar");

				var fooFalse = {foo: false};
				var fooBar = {foo: true, bar: true};
				ClassNames.fast(foo, fooFalse, fooBar).should.be("foo bar");

				var aTrue = {a: true};
				var b = "b";
				ClassNames.fast(aTrue, "b").should.be("a b");
				ClassNames.fast({a: true}, b).should.be("a b");
				ClassNames.fast(aTrue, b).should.be("a b");
			});

			it("handles multiple strings, wipe, and null references", function () {
				var foo = "foo";
				var foobar = "foobar";
				var fooBar = "foo-bar";
				var foofoo = "foo foo";
				var fooFalse = {foo: false};
				var nullVar = null;

				ClassNames.fast(foofoo, nullVar, "b", fooFalse).should.be("b");
				ClassNames.fast(foo, foobar, "bar", fooFalse).should.be("foobar bar");
				ClassNames.fast(foo, fooBar, "bar", { foo: false }).should.be("foo-bar bar");
				ClassNames.fast(foo, "-moz-foo-bar", "bar", fooFalse).should.be("-moz-foo-bar bar");
			});

			it("handles mixed String/Dynamic<Bool>/Array<String>", function () {
				var a = "a";
				var b = "b";
				var arr1 = ["a", "b"];
				var arr2 = [a, "b"];
				var arr3 = ["a", b];
				var arr4 = [a, b];
				var cTrue = {c: true};

				ClassNames.fast(arr1).should.be("a b");
				ClassNames.fast(arr2).should.be("a b");
				ClassNames.fast(arr3).should.be("a b");
				ClassNames.fast(arr4).should.be("a b");
				ClassNames.fast(arr4, cTrue).should.be("a b c");
			});

			it("joins array arguments with string arguments", function () {
				var ab = ["a", "b"];
				var c = "c";

				ClassNames.fast(ab, c).should.be("a b c");
				ClassNames.fast(["a", "b"], c).should.be("a b c");
				ClassNames.fast(ab, "c").should.be("a b c");
				ClassNames.fast(c, ["a", "b"]).should.be("c a b");
				ClassNames.fast("c", ab).should.be("c a b");
				ClassNames.fast(c, ab).should.be("c a b");
			});

			it("handles multiple array arguments", function () {
				var ab = ["a", "b"];
				var cd = ["c", "d"];

				ClassNames.fast(ab, cd).should.be("a b c d");
			});
		});
	}
}
