package test.suite;

import buddy.SingleSuite;
import enzyme.Enzyme.mount;
import enzyme.Enzyme.configure;
import enzyme.adapter.React16Adapter as Adapter;
import jsdom.Jsdom;
import react.ReactMacro.jsx;
import test.component.Bar;

using enzyme.EnzymeMatchers;

class ReactTests extends SingleSuite {
	static function __init__() {
		configure({
			adapter: new Adapter()
		});
	}

	public function new() {
		JsdomSetup.init();

		describe("Real world react example", {
			it("handles joining string, prop and conditional classes", {
				var wrapper = mount(jsx('
					<$Bar
						className="a b c"
						disabled=$true
						checked=$true
					/>
				'));

				wrapper.find("div").should.haveClassName("base a b c disabled");

				var wrapper = mount(jsx('
					<$Bar
						className="d"
						checked=$true
					/>
				'));

				wrapper.find("div").should.haveClassName("base d checked");
			});

			// TODO: more tests
		});
	}
}
