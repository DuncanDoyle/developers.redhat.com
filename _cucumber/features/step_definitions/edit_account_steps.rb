And(/^the following newly registered details should be added to my profile:$/) do |table|
  on EditAccountPage do |page|
    table.raw.each do |row|
      element = row.first
      keycloak_admin = KeyCloak.new
      case element
        when 'Username'
          expect(page.username_field.value).to eq $site_user[:email].gsub('@redhat.com', '').gsub('+', '-').gsub('_', '')
        when 'Email'
          expect(page.email_field.value).to eq $site_user[:email]
        when 'First Name'
          expect(page.first_name_field.value.downcase).to eq $site_user[:first_name].downcase
        when 'Last name'
          expect(page.last_name_field.value.downcase).to eq $site_user[:last_name].downcase
        when 'Company'
          expect(page.company_field.value.downcase).to eq $site_user[:company_name].downcase
        when 'Country'
          expect(page.country).to eq $site_user[:country]
        when 'Red Hat Developer Program subscription date'
          reg_date = keycloak_admin.get_registration_date($site_user[:email])
          expect(page.agreement_date.value).to eq reg_date
        when 'Privacy & Subscriptions status'
          status = keycloak_admin.get_subscription_status($site_user[:email])
          expect(page.receive_newsletter.set?).to be status
        else
          raise("#{element} was not a recognised field")
      end
    end
  end
end

And(/^the following additional information should be added to my profile:$/) do |table|
  on EditAccountPage do |page|
    table.raw.each do |row|
      element = row.first
      keycloak_admin = KeyCloak.new
      case element
        when 'Username'
          expect(page.username_field.attribute('value')).to eq $site_user[:email]
        when 'Email'
          expect(page.email_field.attribute('value')).to eq $site_user[:email]
        when 'First Name'
          expect(page.first_name_field.attribute('value')).to eq $site_user[:first_name]
        when 'Last name'
          expect(page.last_name_field.attribute('value')).to eq $site_user[:last_name]
        when 'Company'
          expect(page.company_field.attribute('value')).to eq $site_user[:company_name]
        when 'Country'
          expect(page.country).to eq $site_user[:country]
        when 'Red Hat Developer Program subscription date'
          reg_date = keycloak_admin.get_registration_date($site_user[:email])
          expect(page.agreement_date.attribute('value')).to eq reg_date
        when 'Privacy & Subscriptions status'
          status = keycloak_admin.get_subscription_status($site_user[:email])
          expect(page.receive_newsletter.selected?).to be status
        else
          raise("#{element} was not a recognised field")
      end
    end
  end
end

When(/^I change my email address$/) do
  puts "Initial email address was #{$site_user[:email]}"
  @updated_email = $site_user[:email].gsub($session_id, Faker::Lorem.characters(5))
  $site_user[:email] = @updated_email
  puts "Updated email email address was #{$site_user[:email]}}"
  on EditAccountPage do |page|
    page.edit_profile(@updated_email, nil, nil, nil, nil)
    page.click_save_btn
    expect(page.alert_box_message).to eq('Your account has been updated.')
  end
end

When(/^I change my details/) do
  $site_user[:first_name] = Faker::Name.first_name
  $site_user[:last_name] = Faker::Name.last_name
  $site_user[:company_name] = Faker::Company.name

  on EditAccountPage do |page|
    page.edit_profile($site_user[:first_name], $site_user[:last_name], $site_user[:company_name])
    page.click_save_btn
    expect(page.alert_box_message).to eq('Your account has been updated.')
  end
end


Then(/^on my next log in I can successfully use the recently added email$/) do
  @current_page.click_logout
  @current_page.logged_out?
  on LoginPage do |page|
    page.login_with(@updated_email, $site_user[:password])
    expect(page.logged_in?).to be true
  end
end

And(/^the email field should be be updated on my profile$/) do
  visit EditAccountPage do |page|
    expect(page.email_field_value).to eq $site_user[:email]
  end
end

Then(/^I should see a (success|error) message "([^"]*)"$/) do |negate, message|
  expect(@current_page.alert_box_message).to eq message
end

And(/^my logged in name should be updated to reflect this change$/) do
  name = "#{$site_user[:first_name]} #{$site_user[:last_name]}".upcase
  expect(@current_page.profile_name_updated?(name)).to be true
end

And(/^the customer portal should be updated$/) do
  it_admin = ItAdmin.new
  user = it_admin.find_user_by_email($site_user[:email])
  expect(user[0]['personalInfo']['firstName']).to eq($site_user[:first_name])
  expect(user[0]['personalInfo']['lastName']).to eq($site_user[:last_name])
  expect(user[0]['personalInfo']['company']).to eq($site_user[:company_name])
  expect(user[0]['personalSite']['address']['countryCode']).to eq('GB')
end

And(/^my details are changed on the customer portal$/) do
  it_admin = ItAdmin.new
  it_admin.update_user($site_user[:email], 'Just Testing Inc', 'Ian', 'Hamilton')
end

Then(/^the changes from the Customer Portal are propagated to my RHD user profile$/) do
  visit EditAccountPage do |page|
    expect(page.first_name_field.value.downcase).to eq 'ian'
    expect(page.last_name_field.value.downcase).to eq 'hamilton'
    expect(page.company_field.value.downcase).to eq 'just testing inc'
  end
end

And(/^I unlink my social account$/) do
  on SocialLoginPage do |page|
    page.click_remove_github_btn
    wait_for { page.remove_github_btn_present? == false }
  end
end

Then(/^I should not have any social accounts associated with me$/) do
  keycloak_admin = KeyCloak.new
  logins = keycloak_admin.get_social_logins($site_user[:email])
  expect(logins.none?).to eq true
end

When(/^I click to link my github account$/) do
  on SocialLoginPage do |page|
    page.click_add_github_btn
  end
end

And(/^log into GitHub$/) do
  @github_admin = GitHubAdmin.new('rhdScenarioOne', 'P@$$word01')
  on GitHubPage do |page|
    page.login_with('rhdScenarioOne', 'P@$$word01')
    page.authorize_app
  end
end

Then(/^my account should be linked$/) do
  on SocialLoginPage do |page|
    expect(page.remove_github_btn_present?).to be true
  end
  keycloak_admin = KeyCloak.new
  logins = keycloak_admin.get_social_logins($site_user[:email])
  expect(logins.none?).to eq false
end

When(/^I change my password$/) do
  on ChangePasswordPage do |page|
    page.change_password($site_user[:password], 'NewPa$$word', 'NewPa$$word')
    wait_for { page.alert_box_message == 'Your password has been updated.' }
  end
end

Then(/^the username field should be disabled$/) do
  on EditAccountPage do |page|
    expect(page.username_field_disabled?).to be true
  end
end

Then(/^the email field should be readonly$/) do
  on EditAccountPage do |page|
    page.email_field.attribute_value('readOnly').should == 'true'
  end
end

And(/^I clear all required field$/) do
  on EditAccountPage do |page|
    page.edit_profile('', '', '')
    page.click_save_btn
  end
end

Then(/^I should see the following validation errors:$/) do |table|
  on EditAccountPage do |page|
    table.hashes.each do |row|
      expect(page.send("#{row['field'].downcase.gsub(' ', '_')}_field_error")).to eq("#{row['message']}")
    end
  end
end

And(/^I enter invalid email address$/) do
  on EditAccountPage do |page|
    page.edit_profile('ian.redhat.com', nil, nil, nil, nil)
    page.click_save_btn
  end
end

Then(/^I should see a "(.*)" validation error "(.*)"$/) do |field, field_error|
  expect(@current_page.send("#{field.downcase.gsub(' ', '_')}_error")).to eq(field_error)
end

And(/^I enter (\d+) characters into the "([^"]*)" field$/) do |characters, field|
  on EditAccountPage do |page|
    type(page.send("#{field.downcase.gsub(' ', '_')}_field"), Faker::Lorem.characters(characters.to_i))
    page.click_save_btn
  end
end

When(/^I enter passwords which don't match$/) do
  on ChangePasswordPage do |page|
    page.change_password($site_user[:password], 'password01', 'P@££word01')
  end
end

When(/^I enter passwords containing less than six characters$/) do
  on ChangePasswordPage do |page|
    page.change_password($site_user[:password], 'pass1', 'pass1')
  end
end

When(/^I enter matching passwords, leaving my previous password empty$/) do
  on ChangePasswordPage do |page|
    page.change_password('', 'password01', 'password01')
  end
end
