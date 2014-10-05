require 'spec_helper'

describe ObservableObject::Wrapper do
  let(:event_obj_list) { Array.new }
  let(:event) { Proc.new { |obj| event_obj_list << obj } }
  let(:notifier) { ObservableObject::Notifier.new("notifier",&event) }
  
  it 'is "equal to" the original object' do
    ObservableObjectTest::AllObjects.each do |obj|
      wrapped = ObservableObject::Wrapper.new(obj,:compare,true,nil) { |p| ; }
      expect(wrapped).to eq(obj)
    end
  end
  it 'can be used as a key in Hashes instead of the original object' do
    hash = Hash.new
    ObservableObjectTest::HashKeyObjects.each do |obj|
      # puts "-> #{obj}"
      wrapped = ObservableObject::Wrapper.new(obj,:compare,true,nil) { |p| ; }
      expect(wrapped.hash).to eq(obj.hash)
      expect(wrapped.eql?(obj)).to be true

      hash[obj] = obj.__id__
      expect(hash[wrapped]).to eq(obj.__id__)
    end
  end
  
  it 'does not call events when the object is not modified' do
    obj = [[1,2,3],[4,5,6]]
    wrapped = ObservableObject::Wrapper.new(obj,:detect,false,nil,&event)
    wrapped.flatten
    expect(event_obj_list.count).to eq(0)
  end
  it 'calls event when the object is modified' do
    obj = [[1,2,3],[4,5,6]]
    wrapped = ObservableObject::Wrapper.new(obj,:detect,false,nil,&event)
    wrapped.flatten!
    expect(event_obj_list.count).to eq(1)
    expect(event_obj_list.all? { |x| x == wrapped }).to be true
  end
  it 'calls notifier when the object is modified if notifier is provided' do
    obj = [[1,2,3],[4,5,6]]
    wrapped = ObservableObject::Wrapper.new(obj,:detect,false,notifier)
    wrapped.flatten!
    expect(event_obj_list.count).to eq(1)
    expect(event_obj_list.all? { |x| x == "notifier" }).to be true
  end
  it 'calls doesn not event when sub-objects are modified (deep=false)' do
    obj = [[1,2,3],[4,5,6]]
    wrapped = ObservableObject::Wrapper.new(obj,:detect,false,nil,&event)
    wrapped[0].sort!
    expect(event_obj_list.count).to eq(0)
  end
  it 'calls event when sub-objects are modified (deep=true)' do
    obj = [[1,2,3],[4,5,6]]
    wrapped = ObservableObject::Wrapper.new(obj,:detect,true,nil,&event)
    wrapped[0].sort!
    expect(event_obj_list.count).to eq(1)
    expect(event_obj_list.all? { |x| x == wrapped }).to be true
  end
  
end