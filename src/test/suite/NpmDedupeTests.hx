package test.suite;

import buddy.SingleSuite;
import classnames.ClassNames;
import test.JSClassNames.JSClassNamesDedupe;

using buddy.Should;

class NpmDedupeTests extends SingleSuite {
	public function new() {
		describe("Npm lib tests for dedupe()", {
			it("keeps object keys with truthy values", function () {
				JSClassNamesDedupe.dedupe({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("should dedupe dedupe", function () {
				JSClassNamesDedupe.dedupe("foo", "bar", "foo", "bar", { foo: true }).should.be("foo bar");
			});

			it("should make sure subsequent objects can remove/add classes", function () {
				JSClassNamesDedupe.dedupe("foo", { foo: false }, { foo: true, bar: true }).should.be("foo bar");
			});

			it("should make sure object with falsy value wipe out previous classes", function () {
				JSClassNamesDedupe.dedupe("foo foo", 0, null, true, 1, "b", { "foo": false }).should.be("1 b");
				JSClassNamesDedupe.dedupe("foo", "foobar", "bar", { foo: false }).should.be("foobar bar");
				JSClassNamesDedupe.dedupe("foo", "foo-bar", "bar", { foo: false }).should.be("foo-bar bar");
				JSClassNamesDedupe.dedupe("foo", "-moz-foo-bar", "bar", { foo: false }).should.be("-moz-foo-bar bar");
			});

			it("joins arrays of class names and ignore falsy values", function () {
				JSClassNamesDedupe.dedupe("a", 0, null, true, 1, "b").should.be("1 a b");
			});

			it("supports heterogenous arguments", function () {
				JSClassNamesDedupe.dedupe({a: true}, "b", 0).should.be("a b");
			});

			it("should be trimmed", function () {
				JSClassNamesDedupe.dedupe("", "b", {}, "").should.be("b");
			});

			it("returns an empty string for an empty configuration", function () {
				JSClassNamesDedupe.dedupe({}).should.be("");
			});

			it("supports an array of class names", function () {
				JSClassNamesDedupe.dedupe(["a", "b"]).should.be("a b");
			});

			it("joins array arguments with string arguments", function () {
				JSClassNamesDedupe.dedupe(["a", "b"], "c").should.be("a b c");
				JSClassNamesDedupe.dedupe("c", ["a", "b"]).should.be("c a b");
			});

			it("handles multiple array arguments", function () {
				JSClassNamesDedupe.dedupe(["a", "b"], ["c", "d"]).should.be("a b c d");
			});

			it("handles arrays that include falsy and true values", function () {
				JSClassNamesDedupe.dedupe(["a", 0, null, false, true, "b"]).should.be("a b");
			});

			it("handles arrays that include arrays", function () {
				JSClassNamesDedupe.dedupe(["a", ["b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", function () {
				JSClassNamesDedupe.dedupe(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", function () {
				JSClassNamesDedupe.dedupe(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});
		});

		describe("Npm lib tests for dedupe() with fast()", {
			it("keeps object keys with truthy values", function () {
				ClassNames.fast({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("should dedupe dedupe", function () {
				ClassNames.fast("foo", "bar", "foo", "bar", { foo: true }).should.be("foo bar");
			});

			it("should make sure subsequent objects can remove/add classes", function () {
				ClassNames.fast("foo", { foo: false }, { foo: true, bar: true }).should.be("foo bar");
			});

			it("should make sure object with falsy value wipe out previous classes", function () {
				ClassNames.fast("foo foo", 0, null, true, 1, "b", { "foo": false }).should.be("1 b");
				ClassNames.fast("foo", "foobar", "bar", { foo: false }).should.be("foobar bar");
				ClassNames.fast("foo", "foo-bar", "bar", { foo: false }).should.be("foo-bar bar");
				ClassNames.fast("foo", "-moz-foo-bar", "bar", { foo: false }).should.be("-moz-foo-bar bar");
			});

			it("joins arrays of class names and ignore falsy values", function () {
				ClassNames.fast("a", 0, null, true, 1, "b").should.be("a 1 b");
			});

			it("supports heterogenous arguments", function () {
				ClassNames.fast({a: true}, "b", 0).should.be("a b");
			});

			it("should be trimmed", function () {
				ClassNames.fast("", "b", {}, "").should.be("b");
			});

			it("returns an empty string for an empty configuration", function () {
				ClassNames.fast({}).should.be("");
			});

			it("supports an array of class names", function () {
				ClassNames.fast(["a", "b"]).should.be("a b");
			});

			it("joins array arguments with string arguments", function () {
				ClassNames.fast(["a", "b"], "c").should.be("a b c");
				ClassNames.fast("c", ["a", "b"]).should.be("c a b");
			});

			it("handles multiple array arguments", function () {
				ClassNames.fast(["a", "b"], ["c", "d"]).should.be("a b c d");
			});

			it("handles arrays that include falsy and true values", function () {
				ClassNames.fast(["a", 0, null, false, true, "b"]).should.be("a b");
			});

			it("handles arrays that include arrays", function () {
				ClassNames.fast(["a", ["b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", function () {
				ClassNames.fast(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", function () {
				ClassNames.fast(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});
		});

		describe("Npm lib tests for dedupe() with fastNull()", {
			it("keeps object keys with truthy values", function () {
				ClassNames.fastNull({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("should dedupe dedupe", function () {
				ClassNames.fastNull("foo", "bar", "foo", "bar", { foo: true }).should.be("foo bar");
			});

			it("should make sure subsequent objects can remove/add classes", function () {
				ClassNames.fastNull("foo", { foo: false }, { foo: true, bar: true }).should.be("foo bar");
			});

			it("should make sure object with falsy value wipe out previous classes", function () {
				ClassNames.fastNull("foo foo", 0, null, true, 1, "b", { "foo": false }).should.be("1 b");
				ClassNames.fastNull("foo", "foobar", "bar", { foo: false }).should.be("foobar bar");
				ClassNames.fastNull("foo", "foo-bar", "bar", { foo: false }).should.be("foo-bar bar");
				ClassNames.fastNull("foo", "-moz-foo-bar", "bar", { foo: false }).should.be("-moz-foo-bar bar");
			});

			it("joins arrays of class names and ignore falsy values", function () {
				ClassNames.fastNull("a", 0, null, true, 1, "b").should.be("a 1 b");
			});

			it("supports heterogenous arguments", function () {
				ClassNames.fastNull({a: true}, "b", 0).should.be("a b");
			});

			it("should be trimmed", function () {
				ClassNames.fastNull("", "b", {}, "").should.be("b");
			});

			it("returns null for an empty configuration", function () {
				(ClassNames.fastNull({}) == null).should.be(true);
			});

			it("supports an array of class names", function () {
				ClassNames.fastNull(["a", "b"]).should.be("a b");
			});

			it("joins array arguments with string arguments", function () {
				ClassNames.fastNull(["a", "b"], "c").should.be("a b c");
				ClassNames.fastNull("c", ["a", "b"]).should.be("c a b");
			});

			it("handles multiple array arguments", function () {
				ClassNames.fastNull(["a", "b"], ["c", "d"]).should.be("a b c d");
			});

			it("handles arrays that include falsy and true values", function () {
				ClassNames.fastNull(["a", 0, null, false, true, "b"]).should.be("a b");
			});

			it("handles arrays that include arrays", function () {
				ClassNames.fastNull(["a", ["b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", function () {
				ClassNames.fastNull(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", function () {
				ClassNames.fastNull(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});
		});
	}
}
