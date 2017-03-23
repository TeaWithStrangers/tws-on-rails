require 'spec_helper.rb'

describe RefreshHostActivityStatus do
  let!(:host) { create(:user, :host) }

  it 'is active if future tea time posted' do
    create(:tea_time, :host => host, :start_time => Time.now + 1.day)
    RefreshHostActivityStatus.run
    expect(host.host_detail.reload.activity_status).to eql 'active'
  end

  it 'is inactive with no tea times' do
    RefreshHostActivityStatus.run
    expect(host.host_detail.reload.activity_status).to eql 'inactive'
  end

  context 'with past tea time' do
    let!(:tea_time) { create(:tea_time, :completed, :host => host, :start_time => Time.now - 1.day) }

    it 'is inactive with inactive commitment' do
      hd = host.host_detail
      hd.commitment = HostDetail::INACTIVE_COMMITMENT
      hd.save!
      RefreshHostActivityStatus.run
      expect(host.host_detail.reload.activity_status).to eql 'inactive'
    end

    context 'with active commitment' do
      before(:each) do
        hd = host.host_detail
        hd.commitment = HostDetail::NO_COMMITMENT
        hd.save!
      end

      it 'is active with recent tea_time' do
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'active'
      end

      it 'is inactive when tea time was too long ago' do
        tea_time.start_time = Time.now - 5.years
        tea_time.save!
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'inactive'
      end

      it 'is legacy when host has enough tea times' do
        tea_time.start_time = Time.now - 5.years
        tea_time.save!
        RefreshHostActivityStatus::PROLIFIC_HOST_CUTOFF.times do
          create(:tea_time, :completed, :host => host, :start_time => Time.now - 5.years)
        end
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'legacy'
      end
    end
  end
end
