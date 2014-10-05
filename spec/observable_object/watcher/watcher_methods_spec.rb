require 'spec_helper'

describe ObservableObject::Watcher::WatcherMethods do
  class TestWatcherMethodsObject
    # safe methods
    def safe; false; end
    def safe!; false; end
    def delete_at; false; end
    def sort!; false; end
    
    # changing methods
    def changing1; true; end
    def changing2; true; end
    def delete; true; end
    def collect!; true; end
  end
  
  test_methods = (TestWatcherMethodsObject.instance_methods - Object.instance_methods).map do |name|
    [name, TestWatcherMethodsObject.new.send(name)]
  end.to_h
  safe_methods = test_methods.select { |k,v| v == false }.map(&:first)
  changing_methods = test_methods.select { |k,v| v == true }.map(&:first)
  
  let(:obj) { TestWatcherMethodsObject.new }
  let(:watcher) { ObservableObject::Watcher::WatcherMethods.new(changing_methods) }
  
  it 'ignores the block passed to remember' do
    called = false
    watcher.remember { called = true }
    expect(called).to be false
  end
  it 'returns true when called with methods from the list' do
    changing_methods.each do |mname|
      expect(watcher.is_state_changing(obj,mname)).to be_truthy
    end
  end
  it 'returns false when called with methods not from the list' do
    safe_methods.each do |mname|
      expect(watcher.is_state_changing(obj,mname)).to be_falsy
    end
  end
end