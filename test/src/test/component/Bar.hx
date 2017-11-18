package test.component;

import classnames.ClassNames;
import react.ReactComponent;
import react.ReactMacro.jsx;

typedef BarProps = {
	var className:String;
	var disabled:Bool;
	var checked:Bool;
}

class Bar extends ReactComponentOfProps<BarProps> {
	override public function render() {
		var classes = ClassNames.fastAsObject(
			"base",
			props.className,
			{
				disabled: props.disabled,
				checked: !props.disabled && props.checked
			}
		);

		return jsx('<div {...classes} />');
	}
}
