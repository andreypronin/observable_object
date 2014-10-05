require 'spec_helper'

describe ObservableObject::Watcher do
  it 'creates the right subclass' do
    expect(ObservableObject::Watcher.create(Hash.new,:detect)).to be_instance_of(ObservableObject::Watcher::WatcherDetect)
    expect(ObservableObject::Watcher.create(Hash.new,:compare)).to be_instance_of(ObservableObject::Watcher::WatcherCompare)
    expect(ObservableObject::Watcher.create(Hash.new,[])).to be_instance_of(ObservableObject::Watcher::WatcherMethods)
  end
end

