package test.suite;

import buddy.SingleSuite;
import classnames.ClassNames;
import test.JSClassNames.JSClassNamesDedupe;

using buddy.Should;

class NpmDedupeTests extends SingleSuite {
	public function new() {
		describe("Npm lib tests for dedupe()", {
			it("keeps object keys with truthy values", {
				JSClassNamesDedupe.dedupe({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("should dedupe dedupe", {
				JSClassNamesDedupe.dedupe("foo", "bar", "foo", "bar", {foo: true}).should.be("foo bar");
			});

			it("should make sure subsequent objects can remove/add classes", {
				JSClassNamesDedupe.dedupe("foo", {foo: false}, {foo: true, bar: true}).should.be("foo bar");
			});

			it("should make sure object with falsy value wipe out previous classes", {
				JSClassNamesDedupe.dedupe("foo foo", 0, null, true, 1, "b", {"foo": false}).should.be("1 b");
				JSClassNamesDedupe.dedupe("foo", "foobar", "bar", {foo: false}).should.be("foobar bar");
				JSClassNamesDedupe.dedupe("foo", "foo-bar", "bar", {foo: false}).should.be("foo-bar bar");
				JSClassNamesDedupe.dedupe("foo", "-moz-foo-bar", "bar", {foo: false}).should.be("-moz-foo-bar bar");
			});

			it("joins arrays of class names and ignore falsy values", {
				JSClassNamesDedupe.dedupe("a", 0, null, true, 1, "b").should.be("1 a b");
			});

			it("supports heterogenous arguments", {
				JSClassNamesDedupe.dedupe({a: true}, "b", 0).should.be("a b");
			});

			it("should be trimmed", {
				JSClassNamesDedupe.dedupe("", "b", {}, "").should.be("b");
			});

			it("returns an empty string for an empty configuration", {
				JSClassNamesDedupe.dedupe({}).should.be("");
			});

			it("supports an array of class names", {
				JSClassNamesDedupe.dedupe(["a", "b"]).should.be("a b");
			});

			it("joins array arguments with string arguments", {
				JSClassNamesDedupe.dedupe(["a", "b"], "c").should.be("a b c");
				JSClassNamesDedupe.dedupe("c", ["a", "b"]).should.be("c a b");
			});

			it("handles multiple array arguments", {
				JSClassNamesDedupe.dedupe(["a", "b"], ["c", "d"]).should.be("a b c d");
			});

			it("handles arrays that include falsy and true values", {
				JSClassNamesDedupe.dedupe(["a", 0, null, false, true, "b"]).should.be("a b");
			});

			it("handles arrays that include arrays", {
				JSClassNamesDedupe.dedupe(["a", ["b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", {
				JSClassNamesDedupe.dedupe(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", {
				JSClassNamesDedupe.dedupe(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});
		});

		describe("Npm lib tests for dedupe() with fast()", {
			it("keeps object keys with truthy values", {
				ClassNames.fast({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("should dedupe dedupe", {
				ClassNames.fast("foo", "bar", "foo", "bar", {foo: true}).should.be("foo bar");
			});

			it("should make sure subsequent objects can remove/add classes", {
				ClassNames.fast("foo", {foo: false}, {foo: true, bar: true}).should.be("foo bar");
			});

			it("should make sure object with falsy value wipe out previous classes", {
				ClassNames.fast("foo foo", 0, null, true, 1, "b", {"foo": false}).should.be("1 b");
				ClassNames.fast("foo", "foobar", "bar", {foo: false}).should.be("foobar bar");
				ClassNames.fast("foo", "foo-bar", "bar", {foo: false}).should.be("foo-bar bar");
				ClassNames.fast("foo", "-moz-foo-bar", "bar", {foo: false}).should.be("-moz-foo-bar bar");
			});

			it("joins arrays of class names and ignore falsy values", {
				ClassNames.fast("a", 0, null, true, 1, "b").should.be("a 1 b");
			});

			it("supports heterogenous arguments", {
				ClassNames.fast({a: true}, "b", 0).should.be("a b");
			});

			it("should be trimmed", {
				ClassNames.fast("", "b", {}, "").should.be("b");
			});

			it("returns an empty string for an empty configuration", {
				ClassNames.fast({}).should.be("");
			});

			it("supports an array of class names", {
				ClassNames.fast(["a", "b"]).should.be("a b");
			});

			it("joins array arguments with string arguments", {
				ClassNames.fast(["a", "b"], "c").should.be("a b c");
				ClassNames.fast("c", ["a", "b"]).should.be("c a b");
			});

			it("handles multiple array arguments", {
				ClassNames.fast(["a", "b"], ["c", "d"]).should.be("a b c d");
			});

			it("handles arrays that include falsy and true values", {
				ClassNames.fast(["a", 0, null, false, true, "b"]).should.be("a b");
			});

			it("handles arrays that include arrays", {
				ClassNames.fast(["a", ["b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", {
				ClassNames.fast(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", {
				ClassNames.fast(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});
		});

		describe("Npm lib tests for dedupe() with fastNull()", {
			it("keeps object keys with truthy values", {
				ClassNames.fastNull({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("should dedupe dedupe", {
				ClassNames.fastNull("foo", "bar", "foo", "bar", {foo: true}).should.be("foo bar");
			});

			it("should make sure subsequent objects can remove/add classes", {
				ClassNames.fastNull("foo", {foo: false}, {foo: true, bar: true}).should.be("foo bar");
			});

			it("should make sure object with falsy value wipe out previous classes", {
				ClassNames.fastNull("foo foo", 0, null, true, 1, "b", {"foo": false}).should.be("1 b");
				ClassNames.fastNull("foo", "foobar", "bar", {foo: false}).should.be("foobar bar");
				ClassNames.fastNull("foo", "foo-bar", "bar", {foo: false}).should.be("foo-bar bar");
				ClassNames.fastNull("foo", "-moz-foo-bar", "bar", {foo: false}).should.be("-moz-foo-bar bar");
			});

			it("joins arrays of class names and ignore falsy values", {
				ClassNames.fastNull("a", 0, null, true, 1, "b").should.be("a 1 b");
			});

			it("supports heterogenous arguments", {
				ClassNames.fastNull({a: true}, "b", 0).should.be("a b");
			});

			it("should be trimmed", {
				ClassNames.fastNull("", "b", {}, "").should.be("b");
			});

			it("returns null for an empty configuration", {
				(ClassNames.fastNull({}) == null).should.be(true);
			});

			it("supports an array of class names", {
				ClassNames.fastNull(["a", "b"]).should.be("a b");
			});

			it("joins array arguments with string arguments", {
				ClassNames.fastNull(["a", "b"], "c").should.be("a b c");
				ClassNames.fastNull("c", ["a", "b"]).should.be("c a b");
			});

			it("handles multiple array arguments", {
				ClassNames.fastNull(["a", "b"], ["c", "d"]).should.be("a b c d");
			});

			it("handles arrays that include falsy and true values", {
				ClassNames.fastNull(["a", 0, null, false, true, "b"]).should.be("a b");
			});

			it("handles arrays that include arrays", {
				ClassNames.fastNull(["a", ["b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", {
				ClassNames.fastNull(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", {
				ClassNames.fastNull(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});
		});
	}
}
