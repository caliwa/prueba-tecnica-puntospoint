require "rails_helper"

RSpec.describe AdminNotificationMailer, type: :mailer do
  describe "first_purchase_notification" do
    let(:mail) { AdminNotificationMailer.first_purchase_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("First purchase notification")
      expect(mail.to).to eq([ "to@example.org" ])
      expect(mail.from).to eq([ "from@example.com" ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end
end
