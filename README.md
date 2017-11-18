# Haxe classNames

Haxe utility for conditionally joining classNames together.
Inspired by npm package [classnames](https://github.com/JedWatson/classnames) by [JedWatson](https://github.com/JedWatson/classnames).

## Getting Started

### Installing

```
haxelib install classnames
```

### Usage with React

Example usage with a react component:

```haxe
class Bar extends ReactComponentOfProps<BarProps> {
	override public function render() {
		var classNames = ClassNames.fast(
			"base",
			props.className,
			{
				disabled: props.disabled,
				checked: !props.disabled && props.checked
			}
		);

		return jsx('<div className=$classNames />');
	}
}
```

Variant with `fastAsObject()` for destructuring props:
```haxe
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
```

Usage:
```haxe
// className="base myclass checked"
jsx('<$Bar className="myclass" checked=$true />');

// className="base myclass1 myclass2 disabled"
jsx('<$Bar className="myclass1 myclass2" disabled=$true />');

// className="base disabled"
jsx('<$Bar className="checked" disabled=$true />');
```

Simple use cases will be optimized at compile time:
```haxe
var classNames = ClassNames.fast(
	"base",
	{
		disabled: props.disabled,
		checked: !props.disabled && props.checked
	}
);

// Will be transpiled to:
var classNames = "base" + (props.disabled?" disabled":"") + (!props.disabled && props.checked?" checked":"");
```

Or even be inlined:
```haxe
var classNames = ClassNames.fast("btn", "btn--large");
var classNames = ClassNames.fast(["btn", "btn--large"]);
var classNames = ClassNames.fast({"btn": true, "btn--large": true});

// Will all be transpiled to:
var classNames = "btn btn--large";
```

## Running the tests

To run all tests except React-related tests:
```
npm run test
```

To run all tests, including React-related tests:
```
npm run test:including-react
```

## Future releases

There are still some features under way:
* Helpers for working with css modules (see [bind() in classnames npm package](https://github.com/JedWatson/classnames#alternate-bind-version-for-css-modules))
* Helpers for working with BEM
* Better compile-time error messages

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
