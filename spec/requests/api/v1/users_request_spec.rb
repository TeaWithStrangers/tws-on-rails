require 'spec_helper'

describe 'Users endpoint: ', type: :request do
    before(:all) do
      @user = create(:user, :waitlist)
      sign_in @user
    end
    describe 'self' do
    end
end
