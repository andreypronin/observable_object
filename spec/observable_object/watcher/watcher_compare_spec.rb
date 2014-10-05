require 'spec_helper'

describe ObservableObject::Watcher::WatcherCompare do
  let(:obj) { [10,30,20] }
  let(:watcher) { ObservableObject::Watcher::WatcherCompare.new }
  it 'returns true when object changes' do
    watcher.remember { obj }
    obj[0] = 100
    expect(watcher.is_state_changing(obj,:any_method)).to be_truthy
  end
  it 'works with un-cloneable objects' do
    [nil,true,false,123,3.1415,:symbol].each do |x|
      watcher.remember { x }
      expect(watcher.is_state_changing(x,:any_method)).to be_falsy
    end
  end
  it 'returns false for a different but equal object' do
    watcher.remember { obj }
    expect(watcher.is_state_changing(obj.clone,:any_method)).to be_falsy
  end
  it 'returns false for the same object' do
    watcher.remember { obj }
    expect(watcher.is_state_changing(obj,:sort!)).to be_falsy
  end
end