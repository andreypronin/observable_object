# ObservableObject

This gem provides a delegator class that wraps around an object and triggers events on modification of that object. 
It is useful for objects that serve as accessors to external storage - when an modification to the object should trigger
the database update, for example.

One example of a gem that benefits from ObservableObject is [store_complex](https://github.com/moonfly/store_complex).

[![Build Status](https://travis-ci.org/moonfly/observable_object.svg?branch=master)](https://travis-ci.org/moonfly/observable_object)
[![Coverage Status](https://img.shields.io/coveralls/moonfly/observable_object.svg)](https://coveralls.io/r/moonfly/observable_object?branch=master)

## Installation

Add this line to your application's Gemfile:

    gem 'observable_object'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install observable_object

## Usage

### Shallow wrapper

Create an ObservableObject for your existing object using this syntax:

```ruby
ObservableObject.wrap(your_object[, list_of_methods], &event_callback)
```

Here:

- `your_object` is the object that you need to wrap
- `list_of_methods` (optional) is the list of your object's methods that change its internal state and should lead to triggering the event
- `event_callback` is the block to be called when the object is modified, it accepts a single parameter - the object itself

The resulting object is a thin delegator around your object, so the ObservableObject will behave almost exactly as your object. That includes results of such methods as `class`, `hash`, `<=>`. It is still a separate object, so it will have it's own `__id__`, and `eql?` will act accordingly. Here is an example:

```ruby
s = ObservableObject.wrap("some string",[:capitalize!,:downcase!]) do |obj|
  puts "The observed string is now #{obj}"
end

s.class             # => String
s == 'some string'  # => true
h = {}
h[s] = 100500
h['some string']    # => 100500

s.capitalize!       # Will print "The observed string is now Some string"
```

#### Special options for the list of methods

It is also possible to pass `:detect` in place of the list of methods that change the internal state. In this case `ObservableObject` will try to auto-detect such methods. That is also the default behavior. If you don't provide the second parameter, this auto-detection method will be used. Auto-detection works as follows:

- It considers the state-changing methods of widely-used classes to be state-changing for this object as well. The widely used classes include `Array`, `Hash`, `Set`, `String`. Please note that `ObservableObject` knows only about the standard methods provided by Ruby. If you have your custom methods defined for these widely-used classes they will not be recognized by the observing wrapper as something that changes the object's state.
- It considers all methods with a `!` at the end as changing the internal state.

Besides auto-detection, there is another method that attempts to automatically determine if the object has changed. It relies on making a clone of an object (using `clone` method) before calling any method and then comparing this copied object with the resulting object after the method call (using `eql?`). This method can be invoked by providing `:compare` in place of the list of methods that change the internal state. Please note that this method has obvious drawbacks and limitations: 

- it relies on the assumption that cloning the object doesn't have side effects and doesn't change its internal state
- it relies on the `eql?` operator to compare the object internal states rather than checking the objects' identity
- it has additional performance drawbacks as cloning an object (especially a complex on) takes time and memory

Bottomline: know your object before you wrap it in `ObservableObject` and think several times before using it with 
something complex when a mere operation of cloning an object may have side effects.

### Deep wrapper

In addition to the shallow wrapper (`ObservableObject.wrap`) this gem also provides a deep wrapper: `ObservableObject.deep_wrap`.
A deep wrapper not only wraps the object itself, but in case of Hashes, Arrays, Sets goes ahead and wraps each of its elements in an ObservableObject. Moreover, it repeats the deap wrapping on all nested Arrays, Hashes and Sets. Regardless of which of the nested wrapped object has caused the event, the upper-level object will always be passed as the parameter to the event handler block.

For deeply-wrapped objects the following situations will also trigger events:

```ruby
arr = ObservableObject.deep_wrap([[1,2,3],{a:10,b:10},"string"]) do |obj|
  # Here obj is always arr, never a nested wrapped object
  puts "Event triggered on #{obj}!"
end

arr[0][0] = 100       # Triggers an event
arr[0].push(7)        # Triggers an event
arr[1].merge!({c:50}) # Triggers an event
arr[2].upcase!        # Triggers an event
```

Please note that there is a certain additional performance penalty if using deep wrapping since the object is re-wrapped after 
every method that changes its internal state. This re-wrapping is done because methods like `<<` and `unshift` can add new 
nested objects that must be wrapped.

## Versioning

Semantic versioning (http://semver.org/spec/v2.0.0.html) is used. 

For a version number MAJOR.MINOR.PATCH, unless MAJOR is 0:

1. MAJOR version is incremented when incompatible API changes are made,
2. MINOR version is incremented when functionality is added in a backwards-compatible manner, 
3. PATCH version is incremented when backwards-compatible bug fixes are made.

Major version "zero" (0.y.z) is for initial development. Anything may change at any time. 
The public API should not be considered stable. 

## Dependencies

- Ruby >= 2.1

## Contributing

1. Fork it ( https://github.com/moonfly/observable_object/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
