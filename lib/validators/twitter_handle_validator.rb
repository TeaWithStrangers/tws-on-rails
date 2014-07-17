class Validators::TwitterHandleValidator < ActiveModel::Validator
  def validate(record)
    twitter_handle = record.twitter
    if twitter_handle.present? # checks empty strings
      unless twitter_handle.match(/^([A-Za-z0-9_]+{1,15}$)/)
        record.errors[:twitter] << 'not a valid twitter handle'
      end
    end
  end

end