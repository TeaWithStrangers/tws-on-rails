require 'spec_helper.rb'

describe RefreshHostActivityStatus do
  let!(:host) { create(:user, :host) }
  let(:active_expiration) { RefreshHostActivityStatus::ACTIVE_EXPIRATION }
  let(:legacy_expiration) { RefreshHostActivityStatus::LEGACY_EXPIRATION }
  let(:prolific_host_cutoff) { RefreshHostActivityStatus::PROLIFIC_HOST_CUTOFF }


  it 'is active if future tea time posted' do
    create(:tea_time, :host => host, :start_time => Time.now + 1.day)
    RefreshHostActivityStatus.run
    expect(host.host_detail.reload.activity_status).to eql 'active'
  end

  context 'with no future tea times' do
    context 'with inactive host commitment' do
      before(:each) do
        detail = host.host_detail
        detail.commitment = HostDetail::INACTIVE_COMMITMENT
        detail.save!
      end

      it 'is inactive if last tea was within the active_expiration range' do
        create(:tea_time, :completed, :host => host, :start_time => Time.now + 1.day - active_expiration)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'inactive'
      end

      it 'is inactive if last tea was older than the active_expiration range but within legacy expiration' do
        create(:tea_time, :completed, :host => host, :start_time => Time.now + 1.day - legacy_expiration)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'inactive'
      end

      it 'is inactive if last tea is old but host was prolific' do
        prolific_host_cutoff.times do
          create(:tea_time, :completed, :host => host, :start_time => Time.now + 1.day - legacy_expiration)
        end
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'inactive'
      end

      it 'is inactive if last tea was older than the legacy_expiration range' do
        create(:tea_time, :completed, :host => host, :start_time => Time.now - 1.day - legacy_expiration)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'inactive'
      end
    end

    context 'with not inactive host commitment' do
      it 'is active if last tea was within the active_expiration range' do
        create(:tea_time, :completed, :host => host, :start_time => Time.now + 1.day - active_expiration)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'active'
      end

      it 'is legacy if last tea was older than the active_expiration range but within legacy expiration' do
        create(:tea_time, :completed, :host => host, :start_time => Time.now + 1.day - legacy_expiration)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'legacy'
      end

      it 'is legacy if last tea is old but host was prolific' do
        prolific_host_cutoff.times do
          create(:tea_time, :completed, :host => host, :start_time => Time.now + 1.day - legacy_expiration)
        end
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'legacy'
      end

      it 'is inactive if last tea was older than the legacy_expiration range' do
        create(:tea_time, :completed, :host => host, :start_time => Time.now - 1.day - legacy_expiration)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql 'inactive'
      end
    end
  end
end
