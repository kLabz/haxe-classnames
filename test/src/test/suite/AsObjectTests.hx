package test.suite;

import buddy.SingleSuite;
import classnames.ClassNames;
import test.JSClassNames.JSClassNamesDedupe;

using classnames.ShouldClassNameDef;

class AsObjectTests extends SingleSuite {
	public function new() {
		describe("Npm dedupe() tests with fastAsObject()", {
			it("keeps object keys with truthy values", {
				ClassNames.fastAsObject({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.match("a e");
			});

			it("should dedupe dedupe", {
				ClassNames.fastAsObject("foo", "bar", "foo", "bar", {foo: true}).should.match("foo bar");
				ClassNames.fastAsObject("foo", "bar", "foo", "bar", {foo: true}).should.contain("foo");
				ClassNames.fastAsObject("foo", "bar", "foo", "bar", {foo: true}).should.not.contain("foobar");
				ClassNames.fastAsObject("foo", "bar", "foo", "bar", {foo: true}).should.containAll(["bar", "foo"]);
				ClassNames.fastAsObject("foo", "bar", "foo", "bar", {foo: true}).should.containAny(["baz", "foobar", "bar"]);
				ClassNames.fastAsObject("foo", "bar", "foo", "bar", {foo: true}).should.not.containAll(["a", "b", "c"]);
				ClassNames.fastAsObject("foo", "bar", "foo", "bar", {foo: true}).should.not.containAny(["a", "b", "c"]);
			});

			it("should make sure subsequent objects can remove/add classes", {
				ClassNames.fastAsObject("foo", {foo: false}, {foo: true, bar: true}).should.match("foo bar");
			});

			it("should make sure object with falsy value wipe out previous classes", {
				ClassNames.fastAsObject("foo foo", 0, null, true, 1, "b", {"foo": false}).should.match("1 b");
				ClassNames.fastAsObject("foo", "foobar", "bar", {foo: false}).should.match("foobar bar");
				ClassNames.fastAsObject("foo", "foo-bar", "bar", {foo: false}).should.match("foo-bar bar");
				ClassNames.fastAsObject("foo", "-moz-foo-bar", "bar", {foo: false}).should.match("-moz-foo-bar bar");
			});

			it("joins arrays of class names and ignore falsy values", {
				ClassNames.fastAsObject("a", 0, null, true, 1, "b").should.match("a 1 b");
			});

			it("supports heterogenous arguments", {
				ClassNames.fastAsObject({a: true}, "b", 0).should.match("a b");
			});

			it("should be trimmed", {
				ClassNames.fastAsObject("", "b", {}, "").should.match("b");
			});

			it("returns null for an empty configuration", {
				ClassNames.fastAsObject({}).should.beEmpty();
			});

			it("supports an array of class names", {
				ClassNames.fastAsObject(["a", "b"]).should.match("a b");
			});

			it("joins array arguments with string arguments", {
				ClassNames.fastAsObject(["a", "b"], "c").should.match("a b c");
				ClassNames.fastAsObject("c", ["a", "b"]).should.match("c a b");
			});

			it("handles multiple array arguments", {
				ClassNames.fastAsObject(["a", "b"], ["c", "d"]).should.match("a b c d");
			});

			it("handles arrays that include falsy and true values", {
				ClassNames.fastAsObject(["a", 0, null, false, true, "b"]).should.match("a b");
			});

			it("handles arrays that include arrays", {
				ClassNames.fastAsObject(["a", ["b", "c"]]).should.match("a b c");
			});

			it("handles arrays that include objects", {
				ClassNames.fastAsObject(["a", {b: true, c: false}]).should.match("a b");
			});

			it("handles deep array recursion", {
				ClassNames.fastAsObject(["a", ["b", ["c", {d: true}]]]).should.match("a b c d");
			});
		});
	}
}
