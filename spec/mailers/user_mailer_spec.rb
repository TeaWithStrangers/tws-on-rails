describe UserMailer do
  context 'User Mails' do

    it 'renders the subject' do
      expect(mail.subject).to eql('Instructions')
    end
 
    it 'renders the receiver email' do
      expect(mail.to).to eql([user.email])
    end
 
    it 'renders the sender email' do
      expect(mail.from).to eql(['noreply@company.com'])
    end
 
    it 'assigns @name' do
      expect(mail.body.encoded).to match(user.name)
    end
 
    it 'assigns @confirmation_url' do
      expect(mail.body.encoded).to match("http://aplication_url/#{user.id}/confirmation")
    end
  end
end
