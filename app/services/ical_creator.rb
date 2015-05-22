class IcalCreator
  attr_reader :tt

  def initialize(tt)
    @tt = tt
  end

  def call
    cal = Icalendar::Calendar.new

    cal.add_timezone(TZInfo::Timezone.get(tt.tzid).ical_timezone(tt.start_time))

    cal.event do |e|
      e.uid = tt.id.to_s
      e.dtstart   = Icalendar::Values::DateTime.new tt.start_time, tzid: tt.tzid
      e.dtend     = Icalendar::Values::DateTime.new tt.end_time, tzid: tt.tzid
      e.summary   = "Tea time, hosted by #{tt.host.name}"
      e.location  = tt.location

      #FIXME: Come back to this with fresh eyes
      e.organizer = Icalendar::Values::CalAddress.new("mailto:#{tt.host.email}", 'CN' => tt.host.name)
    end

    cal
  end
end