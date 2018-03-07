class User < ActiveRecord::Base
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :tea_times
  has_many :attendances
  has_one :host_detail
  has_one :email_reminder, as: :remindable
  belongs_to :home_city, class_name: 'City', counter_cache: true
  has_attached_file :avatar, styles: { medium: "300x300", thumb: "100x100", landscape: "500"}, default_url: "/assets/missing.jpg"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  validates_presence_of :nickname

  include ActiveModel::Validations
  validates_with Validators::FacebookUrlValidator
  validates_with Validators::TwitterHandleValidator

  delegate :commitment, to: :host_detail

  before_destroy :flake_future

  bitmask :roles, :as => [:host, :admin], :null => false
  alias_method :role?, :roles?
  scope :hosts, -> { with_roles :host }

  def name(format = nil)
    names = [given_name, nickname, family_name]
    case format
    when :fullest
      names[1] = "\"#{names[1]}\""
    when :full
      names.delete_at(1)
    when nil
      names = [names[1]]
    end

    names.reject(&:nil?).join(' ')
  end

  def name=(name)
    nickname = name
  end

  def commitment_overview
    if commitment.nil? || HostDetail::IRREGULAR_COMMITMENTS.include?(commitment)
      commitment
    else
      HostDetail::REGULAR_COMMITMENT
    end
  end

  def commitment_detail
    commitment
  end

  def commitment_overview=(overview)
    if overview.to_s != HostDetail::REGULAR_COMMITMENT.to_s
      if commitment.nil?
        if overview.to_s == HostDetail::NO_COMMITMENT.to_s
          HostMailer.commitment_intro(id).deliver_later
        elsif overview.to_s == HostDetail::INACTIVE_COMMITMENT.to_s
          HostMailer.pause(id).deliver_later
        end
      end
      host_detail.commitment = overview
      host_detail.save!
    end
  end

  def commitment_detail=(detail)
    if commitment.nil? && detail
      HostMailer.commitment_intro(id).deliver_later
    end
    if detail.to_i > 0
      host_detail.commitment = detail
      host_detail.save!
    end
  end

  def commitment_text
    HostDetail::COMMITMENT_OVERVIEW_TEXT[commitment] ||
        HostDetail::COMMITMENT_OVERVIEW_TEXT[HostDetail::REGULAR_COMMITMENT]
  end

  def custom_commitment
    if commitment_overview == HostDetail::REGULAR_COMMITMENT && !HostDetail::COMMITMENT_DETAILS.include?(commitment)
      commitment
    end
  end

  def twitter_url
    "https://twitter.com/#{twitter}" if twitter
  end

  def facebook_url
    "https://facebook.com/#{facebook}" if facebook
  end

  def future_hosts
    tea_times.future_until Time.now.utc+2.weeks
  end

  def future_attendances
    attendances.where(status: 0).joins(:tea_time).
      merge(TeaTime.future).includes(:tea_time)
  end

  def friendly_email(at_tws: false)
    #Pass at TWS to append 'at Tea With Strangers'; useful for host contexts
    "\"#{self.name}#{at_tws ? ' at Tea With Strangers' : ''}\" <#{self.email}>"
  end

  def admin?
    role? :admin
  end

  def host?
    (admin? || role?(:host))
  end

  def attendances_for(tt_period)
    attendances.joins(:tea_time).
      merge(tt_period).includes(:tea_time)
  end

  def flake_future
    attendances_for(TeaTime.future).each do |a|
      a.flake!(email: false)
    end
  end

  def generate_host_detail
    HostDetail.create(user: self) unless host_detail
  end

  def waitlist
    if !waitlisted?
      write_attribute(:waitlisted, true)
      write_attribute(:waitlisted_at, Time.now)
    end
  end

  def unwaitlist
    if waitlisted?
      write_attribute(:waitlisted, false)
      write_attribute(:unwaitlisted_at, Time.now)
    end
  end

  def tws_interests
    super || {'hosting' => false, 'leading' => false }
  end

  def send_drip_email(tea_time)
    return
  #   return unless commitment
  #   return if commitment == HostDetail::INACTIVE_COMMITMENT
  #   return unless tea_time
  #   tt_time = tea_time.start_time
  #   tt_date = tt_time.to_date
  #   return if tt_date > Date.today
  #   if commitment == HostDetail::NO_COMMITMENT
  #     drip_delay = 3.weeks
  #     reminder_delay = 2.days
  #     recurring_reminder_delay_months = 3
  #     if tt_date + drip_delay == Date.today
  #       HostMailer.no_commitment_drip(tea_time.id, 0).deliver_later
  #     elsif tt_date + drip_delay + reminder_delay == Date.today
  #       HostMailer.no_commitment_drip_reminder(self.id).deliver_later
  #     else # Every 3 months
  #       month_difference = (Date.today.year * 12 + Date.today.month) - (tt_date.year * 12 + tt_date.month)
  #       cycles_mod = month_difference % recurring_reminder_delay_months
  #       if tt_date.day == Date.today.day && (cycles_mod == 0)
  #         HostMailer.no_commitment_drip(tea_time.id, month_difference / recurring_reminder_delay_months).deliver_later
  #       end
  #     end
  #   else
  #     drip_delays = [0.5, 1, 1.5].map{ |n| n * commitment.weeks }
  #     reminder_delays = [2.days, nil, 2.days]
  #     drip_delays.each_with_index do |delay, i|
  #       if (tt_time + delay).to_date == Date.today
  #         return HostMailer.host_drip(tea_time.id, i).deliver_later
  #       elsif reminder_delays[i] && (tt_time + delay + reminder_delays[i]).to_date == Date.today
  #         return HostMailer.host_drip_reminder(tea_time.id, i).deliver_later
  #       end
  #     end
  #     cycles_passed = (Date.today - tt_date).to_f / (commitment * 7) + 1
  #     if cycles_passed % 1 == 0
  #       HostMailer.host_drip(tea_time.id, cycles_passed).deliver_later
  #     end
  #   end
  end

  class << self
    def nil_user
      @@nil_user ||= NilUser.new
    end
  end
end

class NilUser
  alias_method :persisted?, :blank?

  def marked_for_destruction?
    false
  end

  def name
    "A Former Tea Timer"
  end

  def email
    nil
  end

  def waitlisted?
    true
  end

  def blank?
    true
  end

  def id
    nil
  end
end
