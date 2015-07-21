require 'spec_helper'

describe EmailReminder do
  it { expect(subject).to belong_to(:remindable) }
end
