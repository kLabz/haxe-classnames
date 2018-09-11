package test;

import buddy.Buddy;
import test.suite.*;

class ClassNamesTests implements Buddy<[
	NpmIndexTests,
	NpmDedupeTests,
	NpmBindTests,
	#if react
	ReactTests,
	#end
	FastReferencesTests,
	StringInterpolationTests,
	AsObjectTests
]> {}
