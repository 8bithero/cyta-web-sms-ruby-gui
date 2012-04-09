require 'rubygems'
require 'mechanize'
require 'fox16'
include Fox

class TheMainWindow < FXMainWindow
  def initialize(app, title, w, h)

    def loginAndSend
      agent = Mechanize.new

      # Login Page
      login_page = agent.get('https://www.cytamobile-vodafone.com/miPortal/HeaderLoginBar.aspx')

      # Get login form
      login_form = login_page.form('frmHeaderLogin')

      # Set Username
      login_form.field_with(:name => "HeaderLogin1$CybeeUserName1$txtUserName").value = @username

      # Set Password
      login_form.field_with(:name => "HeaderLogin1$CybeePassword1$txtPassword").value = @password

      # Submit form
      page = login_form.click_button

      # Get web SMS page
      web_sms_page = agent.get('http://www.cytamobile-vodafone.com/misms/sendsms.aspx')

      # Get SMS Form
      sms_form = web_sms_page.form('smsform')

      # Enter recipient
      sms_form.field_with(:name => "txtPhonebook").value = @recipient

      # Enter message
      sms_form.field_with(:name => "txtSMSText").value = @message

      # Add field for form Target
      sms_form.add_field!('__EVENTTARGET', 'lbtnSendSmsPreview')

      # Submit SMS and go to preview page
      web_sms_page2 = agent.submit(sms_form)

      # Get form again from 'preview' page
      sms_form2 = web_sms_page2.form('smsform')

      # Add field for new form Target
      sms_form2.add_field!('__EVENTTARGET', 'lbtnSendSMS')

      # Submit SMS
      gooo = agent.submit(sms_form2)
    end

    super(app, title, :width => w, :height => h)
    
    @username  = FXDataTarget.new("")
    @password  = FXDataTarget.new("")
    @recipient = FXDataTarget.new("")
    @message   = FXDataTarget.new("")

    loginFrame = FXVerticalFrame.new(self, LAYOUT_CENTER_X|LAYOUT_CENTER_Y)

    FXLabel.new(loginFrame, "Username:" )
    FXTextField.new(loginFrame, 20, @username, FXDataTarget::ID_VALUE, TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)

    FXLabel.new(loginFrame, "Password:" )
    FXTextField.new(loginFrame, 20, @password, FXDataTarget::ID_VALUE, TEXTFIELD_PASSWD|FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)

    FXLabel.new(loginFrame, "Recipient:" )
    FXTextField.new(loginFrame, 20, @recipient, FXDataTarget::ID_VALUE, TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)

    FXLabel.new(loginFrame, "Message")
    sunkenFrame = FXHorizontalFrame.new(loginFrame, FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    @message = FXText.new(sunkenFrame, :opts => LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)

    loginBtn = FXButton.new(loginFrame, "Send SMS", :opts => BUTTON_NORMAL|LAYOUT_CENTER_X|LAYOUT_CENTER_Y)
    loginBtn.connect(SEL_COMMAND) do
      loginAndSend()
    end
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

app = FXApp.new
myWindow = TheMainWindow.new(app, "Cyta web SMS", 300, 300)
app.create
app.run

