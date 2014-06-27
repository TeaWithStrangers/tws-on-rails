class Validators::FacebookUrlValidator < ActiveModel::Validator
  def validate(record)
    facebook_url = record.facebook
    if facebook_url.present?

      if facebook_url.match(/[http?s]/)
        record.errors[:facebook] << 'should not include http(s)'
      end

      if facebook_url.match(/facebook\.com/)
        record.errors[:facebook] << 'should not include facebook.com'
      end
    end
  end
end