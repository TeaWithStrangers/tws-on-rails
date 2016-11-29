require 'spec_helper.rb'

describe RefreshHostActivityStatus do
  let!(:host) { create(:user, :host) }
  let(:expiration) { RefreshHostActivityStatus::ACTIVE_EXPIRATION }
  let(:mild_expiration) { RefreshHostActivityStatus::MILD_LEGACY[:expiration] }
  let(:strong_expiration) { RefreshHostActivityStatus::STRONG_LEGACY[:expiration] }
  let(:mild_max) { RefreshHostActivityStatus::MILD_LEGACY[:tea_time_max] }
  let(:strong_max) { RefreshHostActivityStatus::STRONG_LEGACY[:tea_time_max] }

  context 'with an active host' do
    let!(:tea_time) { create(:tea_time, :host => host, :start_time => Time.now - 1.day) }
    it 'updates status to active' do
      RefreshHostActivityStatus.run
      expect(host.host_detail.reload.activity_status).to eql "active"
    end
  end

  context 'with an inactive host' do
    it 'updates the status to inactive' do
      host.host_detail.activity_status = :active
      host.host_detail.save!
      RefreshHostActivityStatus.run
      expect(host.host_detail.reload.activity_status).to eql "inactive"
    end
  end

  context 'with a legacy host' do
    let!(:tea_time) do
      create(
        :tea_time,
        :host => host,
        :start_time => Time.now - expiration - 1.day
      )
    end
    it 'updates the status to legacy' do
      RefreshHostActivityStatus.run
      expect(host.host_detail.reload.activity_status).to eql "legacy"
    end
  end

  context 'with a host that has been legacy for a while' do
    context 'and is mild legacy' do
      let!(:tea_time) do
        create(
          :tea_time,
          :host => host,
          :start_time => Time.now - expiration - mild_expiration - 1.day,
        )
      end
      it 'updates to inactive if tea time is long ago' do
        host.host_detail.activity_status = :active
        host.host_detail.save!
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql "inactive"
      end

      it 'does not update to inactive if tea time is too recent' do
        tea_time.start_time = Time.now - expiration - mild_expiration + 1.day
        tea_time.save!
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql "legacy"
      end
    end

    context 'and is strong legacy' do
      it 'updates to inactive if tea times are long ago' do
        (mild_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration - 1.day,
          )
        end
        host.host_detail.activity_status = :active
        host.host_detail.save!
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql "inactive"
      end

      it 'does not update to inactive if tea time is too recent' do
        (mild_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration + 1.day,
          )
        end
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql "legacy"
      end
    end

    context 'and is permanent legacy' do
      it 'does not update with long ago tea times' do
        (strong_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration - 1.day,
          )
        end
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql "legacy"
      end

      it 'does not update with recent tea times' do
        (strong_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration + 1.day,
          )
        end
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql "legacy"
      end
    end
  end
end
