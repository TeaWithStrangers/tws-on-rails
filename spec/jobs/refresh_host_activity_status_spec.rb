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

    it 'works with no existing host detail' do
      RefreshHostActivityStatus.run
      expect(host.host_detail.activity_status).to eql HostDetail::statuses[:active]
    end

    it 'works with an existing host detail' do
      create(:host_detail, :inactive, :user => host)
      RefreshHostActivityStatus.run
      expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:active]
    end
  end

  context 'with an inactive host' do
    it 'works with no existing host detail' do
      RefreshHostActivityStatus.run
      expect(host.host_detail.activity_status).to eql HostDetail::statuses[:inactive]
    end

    it 'works with an existing host detail' do
      create(:host_detail, :active, :user => host)
      RefreshHostActivityStatus.run
      expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:inactive]
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

    it 'works with no existing host detail' do
      RefreshHostActivityStatus.run
      expect(host.host_detail.activity_status).to eql HostDetail::statuses[:legacy]
    end

    it 'works with an existing host detail' do
      create(:host_detail, :active, :user => host)
      RefreshHostActivityStatus.run
      expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:legacy]
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
      it 'works with no existing host detail' do
        RefreshHostActivityStatus.run
        expect(host.host_detail.activity_status).to eql HostDetail::statuses[:inactive]
      end

      it 'works with an existing host detail' do
        create(:host_detail, :active, :user => host)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:inactive]
      end

      it 'does not change if tea time is too recent' do
        tea_time.start_time = Time.now - expiration - mild_expiration + 1.day
        tea_time.save!
        create(:host_detail, :legacy, :user => host)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:legacy]
      end
    end

    context 'and is strong legacy' do
      it 'works with no existing host detail' do
        (mild_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration - 1.day,
          )
        end
        RefreshHostActivityStatus.run
        expect(host.host_detail.activity_status).to eql HostDetail::statuses[:inactive]
      end

      it 'works with an existing host detail' do
        (mild_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration - 1.day,
          )
        end
        create(:host_detail, :active, :user => host)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:inactive]
      end

      it 'does not change if tea time is too recent' do
        (mild_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration + 1.day,
          )
        end
        create(:host_detail, :legacy, :user => host)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:legacy]
      end
    end

    context 'and is permanent legacy' do
      it 'does nothing with no existing host detail' do
        (strong_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration - 1.day,
          )
        end
        RefreshHostActivityStatus.run
        expect(host.host_detail.activity_status).to eql HostDetail::statuses[:legacy]
      end

      it 'does nothing with an existing host detail' do
        (strong_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration - 1.day,
          )
        end
        create(:host_detail, :active, :user => host)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:legacy]
      end

      it 'does not change if tea time is recent' do
        (strong_max + 1).times do
          create(
            :tea_time,
            :host => host,
            :start_time => Time.now - expiration - strong_expiration + 1.day,
          )
        end
        create(:host_detail, :legacy, :user => host)
        RefreshHostActivityStatus.run
        expect(host.host_detail.reload.activity_status).to eql HostDetail::statuses[:legacy]
      end
    end
  end
end
