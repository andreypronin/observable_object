require 'spec_helper'

describe ObservableObject::Watcher::WatcherDetect do
  let(:obj_str) { "String" }
  let(:obj_arr) { [1,2,3] }
  let(:watcher_str) { ObservableObject::Watcher::WatcherDetect.new(obj_str) }
  let(:watcher_arr) { ObservableObject::Watcher::WatcherDetect.new(obj_arr) }

  it 'ignores the block passed to remember' do
    called = false
    watcher_str.remember { called = true }
    expect(called).to be false
  end
  it 'returns true when delete_at is called for an object' do
    expect(watcher_str.is_state_changing(obj_str,:delete_at)).to be_truthy
    expect(watcher_arr.is_state_changing(obj_arr,:delete_at)).to be_truthy
  end
  it 'returns true when delete is called for non-String objects' do
    expect(watcher_arr.is_state_changing(obj_arr,:delete)).to be_truthy
  end
  it 'returns false when delete is called for String objects' do
    expect(watcher_str.is_state_changing(obj_str,:delete)).to be_falsy
  end
  it 'returns true when a method with a bang is called for an object' do
    expect(watcher_str.is_state_changing(obj_str,:scary!)).to be_truthy
    expect(watcher_arr.is_state_changing(obj_arr,:scary!)).to be_truthy
  end
  it 'returns true when some other method is called for an object' do
    expect(watcher_str.is_state_changing(obj_str,:something)).to be_falsy
    expect(watcher_arr.is_state_changing(obj_arr,:something)).to be_falsy
  end
end