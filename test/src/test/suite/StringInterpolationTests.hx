package test.suite;

import buddy.CompilationShould;
import buddy.SingleSuite;
import classnames.ClassNames.fast;
import classnames.ClassNames.fastNull;
import classnames.ClassNames.fastAsObject;

using StringTools;
using buddy.Should;

/*
	A little brainstorming first...

	String interpolation has been enabled (so far) with:
	fast(EObjectDecl)
	fastAsObject(EObjectDecl)
	fastNull(EObjectDecl)

	What needs to be tested:
	- standard use (with a variable)
	- use with random expressions
	- compilation errors when dealing with syntax errors or undefined variables
	- (?) clash between expressions resolving to the same value (at least to see what happens)
*/

class StringInterpolationTests extends SingleSuite {
	public function new() {
		var a = "a";
		var b = "b";
		var c = "c";
		var test_1 = a == a;
		var test_2 = a == b;

		var simpleKeys = {
			'$a': true,
			'${b}': test_1,
			'${c}': test_2
		};

		describe("ClassNames.fast() and string interpolation", {
			it("should be applied when dealing with objects literals", {
				var cls = fast({
					'$a': true,
					'${b}': test_1,
					'${c}': test_2
				});

				cls.trim().should.be('a b');
			});

			it("should be ignored when dealing with objects references", {
				var cls = fast(simpleKeys);
				cls.trim().should.be("$a ${b}");
			});

			it("should work with object keys being more than identifiers", {
				var answer = "answer";
				var cls = fast({
					'${21 * 2}': true,
					'${"is" + "-the-" + answer}': true
				});

				cls.trim().should.be("42 is-the-answer");
			});

			xit("[TODO] should someday handle object keys resolving to the same value", {
				var answer = "answer";
				var cls = fast({
					'${21 * 2}': true,
					'42': false,
					'is-the-answer': true,
					'${"is" + "-the-" + answer}': false
				});

				cls.trim().should.be("");
			});

			// Works, but CompilationShould doesn't catch the errors, which are:
			// test/src/test/suite/StringInterpolationTests.hx:XX: lines XX-XX : Unknown identifier : unknownVariable
			// test/src/test/suite/StringInterpolationTests.hx:XX: lines XX-XX : Unknown identifier : z
			// it("should produce explicit errors when misused", {
			// 	CompilationShould.failFor({
			// 		var cls = fast({
			// 			'${unknownVariable}': true,
			// 			'$z': true
			// 		});
			// 	});
			// });
		});

		describe("ClassNames.fastNull() should handle string interpolation", {
			it("should be applied when dealing with objects literals", {
				var cls = fastNull({
					'$a': true,
					'${b}': test_1,
					'${c}': test_2
				});

				cls.trim().should.be('a b');
			});

			it("should be ignored when dealing with objects references", {
				var cls = fastNull(simpleKeys);
				cls.trim().should.be("$a ${b}");
			});

			it("should work with object keys being more than identifiers", {
				var answer = "answer";
				var cls = fastNull({
					'${21 * 2}': true,
					'${"is" + "-the-" + answer}': true
				});

				cls.trim().should.be("42 is-the-answer");
			});

			xit("[TODO] should someday handle object keys resolving to the same value", {
				var answer = "answer";
				var cls = fastNull({
					'${21 * 2}': true,
					'42': false,
					'is-the-answer': true,
					'${"is" + "-the-" + answer}': false
				});

				cls.trim().should.be(null);
			});

			// Works, but CompilationShould doesn't catch the errors, which are:
			// test/src/test/suite/StringInterpolationTests.hx:XX: lines XX-XX : Unknown identifier : unknownVariable
			// test/src/test/suite/StringInterpolationTests.hx:XX: lines XX-XX : Unknown identifier : z
			// it("should produce explicit errors when misused", {
			// 	CompilationShould.failFor({
			// 		var cls = fastNull({
			// 			'${unknownVariable}': true,
			// 			'$z': true
			// 		});
			// 	});
			// });

			it("should still return null if nothing matches", {
				var answer = "answer";
				var cls = fastNull({
					'${21 * 2}': false,
					'${"is" + "-the-" + answer}': false
				});

				(cls == null).should.be(true);
			});
		});

		describe("ClassNames.fastAsObject() should handle string interpolation", {
			it("should be applied when dealing with objects literals", {
				var cls = fastAsObject({
					'$a': true,
					'${b}': test_1,
					'${c}': test_2
				});

				cls.className.trim().should.be('a b');
			});

			it("should be ignored when dealing with objects references", {
				var cls = fastAsObject(simpleKeys);
				cls.className.trim().should.be("$a ${b}");
			});

			it("should work with object keys being more than identifiers", {
				var answer = "answer";
				var cls = fastAsObject({
					'${21 * 2}': true,
					'${"is" + "-the-" + answer}': true
				});

				cls.className.trim().should.be("42 is-the-answer");
			});

			xit("[TODO] should someday handle object keys resolving to the same value", {
				var answer = "answer";
				var cls = fastAsObject({
					'${21 * 2}': true,
					'42': false,
					'is-the-answer': true,
					'${"is" + "-the-" + answer}': false
				});

				cls.className.trim().should.be("");
			});

			// Works, but CompilationShould doesn't catch the errors, which are:
			// test/src/test/suite/StringInterpolationTests.hx:XX: lines XX-XX : Unknown identifier : unknownVariable
			// test/src/test/suite/StringInterpolationTests.hx:XX: lines XX-XX : Unknown identifier : z
			// it("should produce explicit errors when misused", {
			// 	CompilationShould.failFor({
			// 		var cls = fastAsObject({
			// 			'${unknownVariable}': true,
			// 			'$z': true
			// 		});
			// 	});
			// });
		});
	}
}
