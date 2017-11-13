package test.suite;

import buddy.SingleSuite;
import classnames.ClassNames;

using buddy.Should;

class NpmIndexTests extends SingleSuite {
	public function new() {
		describe("Npm lib tests for classNames()", {
			it("keeps object keys with truthy values", {
				JSClassNames.classNames({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("joins arrays of class names and ignore falsy values", {
				JSClassNames.classNames("a", 0, null, true, 1, "b")
				.should.be("a 1 b");
			});

			it("supports heterogenous arguments", {
				JSClassNames.classNames({a: true}, "b", 0)
				.should.be("a b");
			});

			it("should not repeat spaces", {
				JSClassNames.classNames("", "b", {}, "").should.be("b");
			});

			it("returns an empty string for an empty configuration", {
				JSClassNames.classNames({}).should.be("");
			});

			it("supports an array of class names", {
				JSClassNames.classNames(["a", "b"]).should.be("a b");
			});

			it("joins array arguments with string arguments", {
				JSClassNames.classNames(["a", "b"], "c").should.be("a b c");
				JSClassNames.classNames("c", ["a", "b"]).should.be("c a b");
			});

			it("handles multiple array arguments", {
				JSClassNames.classNames(["a", "b"], ["c", "d"]).should.be("a b c d");
			});

			it("handles arrays that include falsy and true values", {
				JSClassNames.classNames(["a", 0, null, false, true, "b"])
				.should.be("a b");
			});

			it("handles arrays that include arrays", {
				JSClassNames.classNames(["a", ["b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", {
				JSClassNames.classNames(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", {
				JSClassNames.classNames(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});

			// Will not pass until 2.2.6+ release
			xit("handles arrays that are empty", {
				JSClassNames.classNames("a", []).should.be("a");
			});

			// Will not pass until 2.2.6+ release
			xit("handles nested arrays that have empty nested arrays", {
				JSClassNames.classNames("a", [[]]).should.be("a");
			});

			it("handles all types of truthy and falsy property values as expected", {
				var obj = {foo: null, bar: true};
				JSClassNames.classNames({
					// falsy:
					"null": null,
					emptyString: "",
					zero: 0,
					negativeZero: -0,
					"false": false,

					// truthy (literally anything else):
					nonEmptyString: "foobar",
					whitespace: " ",
					"function": NpmIndexTests.testFunction,
					emptyObject: {},
					nonEmptyObject: {a: 1, b: 2},
					emptyList: [],
					nonEmptyList: [1, 2, 3],
					greaterZero: 1
				})
				.should.be("nonEmptyString whitespace function emptyObject nonEmptyObject emptyList nonEmptyList greaterZero");
			});
		});

		describe("Npm lib tests for classNames() with fast()", {
			it("keeps object keys with truthy values", {
				ClassNames.fast({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("joins arrays of class names and ignore falsy values", {
				ClassNames.fast("a", 0, null, true, 1, "b")
				.should.be("a 1 b");
			});

			it("supports heterogenous arguments", {
				ClassNames.fast({a: true}, "b", 0)
				.should.be("a b");
			});

			it("should not repeat spaces", {
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
				ClassNames.fast(["a", 0, null, false, true, "b"])
				.should.be("a b");
			});

			it("handles arrays that include arrays", {
				ClassNames.fast([{a: false}, "a", ["a", "b", "c"]]).should.be("a b c");
			});

			it("handles arrays that include objects", {
				ClassNames.fast(["a", {b: true, c: false}]).should.be("a b");
			});

			it("handles deep array recursion", {
				ClassNames.fast(["a", ["b", ["c", {d: true}]]]).should.be("a b c d");
			});

			it("handles arrays that are empty", {
				ClassNames.fast("a", []).should.be("a");
			});

			it("handles nested arrays that have empty nested arrays", {
				ClassNames.fast("a", [[]]).should.be("a");
			});

			it("handles all types of truthy and falsy property values as expected", {
				var obj = {foo: null, bar: true};
				ClassNames.fast({
					// falsy:
					"null": null,
					emptyString: "",
					zero: 0,
					negativeZero: -0,
					"false": false,

					// truthy (literally anything else):
					nonEmptyString: "foobar",
					whitespace: " ",
					"function": NpmIndexTests.testFunction,
					emptyObject: {},
					nonEmptyObject: {a: 1, b: 2},
					emptyList: [],
					nonEmptyList: [1, 2, 3],
					greaterZero: 1
				})
				.should.be("nonEmptyString whitespace function emptyObject nonEmptyObject emptyList nonEmptyList greaterZero");
			});
		});

		describe("Npm lib tests for classNames() with fastNull()", {
			it("keeps object keys with truthy values", {
				ClassNames.fastNull({
					a: true,
					b: false,
					c: 0,
					d: null,
					e: 1
				}).should.be("a e");
			});

			it("joins arrays of class names and ignore falsy values", {
				ClassNames.fastNull("a", 0, null, true, 1, "b")
				.should.be("a 1 b");
			});

			it("supports heterogenous arguments", {
				ClassNames.fastNull({a: true}, "b", 0)
				.should.be("a b");
			});

			it("should not repeat spaces", {
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
				ClassNames.fastNull(["a", 0, null, false, true, "b"])
				.should.be("a b");
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

			it("handles arrays that are empty", {
				ClassNames.fastNull("a", []).should.be("a");
			});

			it("handles nested arrays that have empty nested arrays", {
				ClassNames.fastNull("a", [[]]).should.be("a");
			});

			it("handles all types of truthy and falsy property values as expected", {
				var obj = {foo: null, bar: true};
				ClassNames.fastNull({
					// falsy:
					"null": null,
					emptyString: "",
					zero: 0,
					negativeZero: -0,
					"false": false,

					// truthy (literally anything else):
					nonEmptyString: "foobar",
					whitespace: " ",
					"function": NpmIndexTests.testFunction,
					emptyObject: {},
					nonEmptyObject: {a: 1, b: 2},
					emptyList: [],
					nonEmptyList: [1, 2, 3],
					greaterZero: 1
				})
				.should.be("nonEmptyString whitespace function emptyObject nonEmptyObject emptyList nonEmptyList greaterZero");
			});
		});
	}

	static function testFunction():Void {}
}
