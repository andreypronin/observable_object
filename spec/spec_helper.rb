require 'coveralls'
Coveralls.wear!

require 'observable_object'

module ObservableObjectTest
  BasicObjects = [ BasicObject.new ]
  DelegatorObjects = [ SimpleDelegator.new("string"), SimpleDelegator.new(1.0) ]

  # NOTE: using wrapped objects as keys doesn't work for Floats and Symbols, althouth works for Fixnums, Rationals, Strings, etc!
  # NOTE: one way hash key equivalency only, we don't patch eql? in other classes
  NonHashKeyObjects = [ 0.0, 3.1415926, :symbol ]
  
  HashKeyObjects = [
    [1,2,"3"],
    {a:1,"a"=>1,1=>2,"1"=>"2"},
    Set['x','y','z'],
    "Some string",
    %w(Array of strings),
    [:one, :two, :three],
    true,
    false,
    nil,
    "",
    1.0.to_c,
    1.0.to_r,
    [nil],
    [],
    Hash.new,
    Set.new,
    0,
    123,
    1234567890987654321,
    StringIO.new("String IO"),
    Exception.new("Some exception"),
    Object.new,
    Class.new,  
    Module.new,
    lambda { 10 },
    Proc.new { |x| x },
    Mutex.new,
    [ [1,2,3], "bebe", {"key"=>"value", key: :value}, Time.now, -> { puts "Line" }, Set['a','c'] ],
    Time.now,
    ENV,
    ARGV
  ]
  NonBasicObjects = HashKeyObjects + NonHashKeyObjects
  AllObjects = NonBasicObjects + BasicObjects + DelegatorObjects
end