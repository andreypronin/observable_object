require 'spec_helper'

describe ObservableObject do
  let(:event_obj_list) { Array.new }
  let(:event) { Proc.new { |obj| event_obj_list << obj } }

  it 'has version (smoke test)' do
    expect(ObservableObject::VERSION).to be_a(String)
  end
  it 'returns the object itself for unwrappable objects' do
    [:symbol, 1, 1.0, true, false, nil].each do |obj|
      expect(ObservableObject.wrap(obj).__id__).to eq(obj.__id__)
      expect(ObservableObject.deep_wrap(obj).__id__).to eq(obj.__id__)
    end
  end
  
  it 'is "equal to" the original object (wrap)' do
    ObservableObjectTest::NonBasicObjects.each do |obj|
      wrapped = ObservableObject.wrap(obj) { |p| ; }
      expect(wrapped).to eq(obj)
    end
  end
  it 'is "equal to" the original object (deep_wrap)' do
    ObservableObjectTest::NonBasicObjects.each do |obj|
      wrapped = ObservableObject.deep_wrap(obj) { |p| ; }
      expect(wrapped).to eq(obj)
    end
  end

  it 'provides correct "!" operator' do
    ObservableObjectTest::NonBasicObjects.each do |obj|
      wrapped = ObservableObject.wrap(obj) { |p| ; }
      expect(!wrapped).to eq(!obj)
    end
  end
  it 'provides correct "!=" operator' do
    ObservableObjectTest::NonBasicObjects.each do |obj|
      wrapped = ObservableObject.wrap(obj) { |p| ; }
      expect(wrapped != obj).to be false
    end
  end
  it 'provides correct methods' do
    ObservableObjectTest::NonBasicObjects.each do |obj|
      # puts "-> #{obj}" 
      wrapped = ObservableObject.wrap(obj) { |p| ; }
      
      expect(obj.class.instance_methods.all? do |mname| 
        # puts "----> #{mname}" 
        wrapped.respond_to?(mname) == obj.respond_to?(mname)
      end).to be true
    end
  end

  it 'can be used as a key in Hashes instead of the original object (wrap)' do
    hash = Hash.new
    ObservableObjectTest::NonBasicObjects.each do |obj|
      # puts "-> #{obj}"
      wrapped = ObservableObject.wrap(obj) { |p| ; }
      expect(wrapped.hash).to eq(obj.hash)
      expect(wrapped.eql?(obj)).to be true

      hash[obj] = obj.__id__
      expect(hash[wrapped]).to eq(obj.__id__)
    end
  end
  it 'can be used as a key in Hashes instead of the original object (deep_wrap)' do
    hash = Hash.new
    ObservableObjectTest::NonBasicObjects.each do |obj|
      # puts "-> #{obj}"
      wrapped = ObservableObject.deep_wrap(obj) { |p| ; }
      expect(wrapped.hash).to eq(obj.hash)
      expect(wrapped.eql?(obj)).to be true

      hash[obj] = obj.__id__
      expect(hash[wrapped]).to eq(obj.__id__)
    end
  end
  
  it 'calls event handler when the object is modified' do
    obj = [[1],[2]]
    wrapped = ObservableObject.deep_wrap(obj,&event)
    wrapped[0] << 100
    wrapped[0] << 50
    wrapped[0].sort!
    expect(event_obj_list.count).to eq(3)
    expect(event_obj_list.all? { |x| x == wrapped }).to be true
  end

  it 'calls event handler after a sub-object is replaced and then modified' do
    obj = [[1],[2]]
    wrapped = ObservableObject.deep_wrap(obj,&event)
    wrapped[0] = [3]
    wrapped[0] << 50
    wrapped[0].sort!
    wrapped[1] = [['a','b'],'c']
    wrapped[1][0][1] = 'd'
    expect(event_obj_list.count).to eq(5)
    expect(event_obj_list.all? { |x| x == wrapped }).to be true
  end

  it 'calls event handler after a sub-object is added and then modified' do
    obj = [[1],[2]]
    wrapped = ObservableObject.deep_wrap(obj,&event)
    wrapped[1] << ['a','b']
    wrapped[1].last.push('c')
    expect(event_obj_list.count).to eq(2)
    expect(event_obj_list.all? { |x| x == wrapped }).to be true
  end
  
  it 'works with Array()' do
    obj = [1,2,3]
    wrapped = ObservableObject.deep_wrap(obj,&event)
    expect( Array(wrapped) ).to eq obj
  end
  it 'works with Hash()' do
    obj = {'a'=>1}
    wrapped = ObservableObject.deep_wrap(obj,&event)
    expect( Hash(wrapped) ).to eq obj
  end
  it 'works with String()' do
    obj = 'string'
    wrapped = ObservableObject.deep_wrap(obj,&event)
    expect( String(wrapped) ).to eq obj
  end
  it 'works with Complex()' do
    obj = 1+2i
    wrapped = ObservableObject.deep_wrap(obj,&event)
    expect( Complex(wrapped) ).to eq obj
  end
  it 'works with Float()' do
    obj = 22.73
    wrapped = ObservableObject.deep_wrap(obj,&event)
    expect( Float(wrapped) ).to eq obj
  end
  it 'works with Integer()' do
    obj = 18
    wrapped = ObservableObject.deep_wrap(obj,&event)
    expect( Integer(wrapped) ).to eq obj
  end
  it 'works with Rational()' do
    obj = 2/3.to_r
    wrapped = ObservableObject.deep_wrap(obj,&event)
    expect( Rational(wrapped) ).to eq obj
  end
  
  # TODO: fix the case below, if there is an efficient solution. Not a bug, annoyance.
  # it 'does not call event handler after an already deleted sub-object is modified' do
  #   obj = [[1,2],[3,4]]
  #   wrapped = ObservableObject.deep_wrap(obj,&event)
  #   a = wrapped[0]
  #   a.compact!
  #   wrapped.delete_at(0)
  #   a[0] = 100
  #   expect(event_obj_list.count).to eq(2)
  #   expect(event_obj_list.all? { |x| x == wrapped }).to be true
  # end
end