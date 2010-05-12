require 'test_helper'

class MailManTest < ActionMailer::TestCase
  test "new_user" do
    @expected.subject = 'MailMan#new_user'
    @expected.body    = read_fixture('new_user')
    @expected.date    = Time.now

    assert_equal @expected.encoded, MailMan.create_new_user(@expected.date).encoded
  end

  test "user_approved" do
    @expected.subject = 'MailMan#user_approved'
    @expected.body    = read_fixture('user_approved')
    @expected.date    = Time.now

    assert_equal @expected.encoded, MailMan.create_user_approved(@expected.date).encoded
  end

end
