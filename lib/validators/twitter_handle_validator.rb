class Validators::TwitterHandleValidator < ActiveModel::Validator
  def validate(record)
    twitter_handle = record.twitter
    if twitter_handle
      unless twitter_handle.match(/\A_?[a-z]_?(?:[a-z0-9]_?)*\z/i)
        record.errors[:twitter] << 'not a valid twitter handle'
      end
    end
  end

end