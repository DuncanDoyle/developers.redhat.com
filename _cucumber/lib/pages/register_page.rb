require_relative 'abstract/site_base'

class RegistrationPage < SiteBase
  expected_element(:div, id: 'kc-register')
  #page_title('Register | Red Hat Developers')

  element(:expand_register_with_email)             { |b| b.link(id: 'register-expand-choice-email') }
  element(:expand_register_with_social)            { |b| b.link(id: 'register-expand-choice-social') }
  element(:email_field)                            { |b| b.text_field(id: 'email') }
  element(:password_field)                         { |b| b.text_field(id: 'password') }
  element(:password_confirm_field)                 { |b| b.text_field(id: 'password-confirm') }
  element(:first_name_field)                       { |b| b.text_field(id: 'firstName') }
  element(:last_name_field)                        { |b| b.text_field(id: 'lastName') }
  element(:company_field)                          { |b| b.text_field(id: 'user.attributes.company') }
  element(:country_dropdown)                       { |b| b.select_list(id: 'user.attributes.country') }
  element(:greeting_field)                         { |b| b.text_field(id: 'user.attributes.greeting') }
  element(:address_line_one_field)                 { |b| b.text_field(id: 'user.attributes.addressLine1') }
  element(:city_field)                             { |b| b.text_field(id: 'user.attributes.addressCity') }
  element(:state_dropdown)                         { |b| b.select_list(id: 'user.attributes.addressState') }
  element(:postcode_field)                         { |b| b.text_field(id: 'user.attributes.addressPostalCode') }
  element(:phone_number_field)                     { |b| b.text_field(id: 'user.attributes.phoneNumber') }
  element(:finish_button)                          { |b| b.button(value: 'Create my account') }
  element(:terms_and_conditions_section)           { |b| b.element(class: 'tac-all-wrapper') }
  element(:all_terms)                              { |b| b.checkbox(id: 'tac-checkall') }
  element(:github_button)                          { |b| b.link(id: 'social-github') }
  element(:rhd_developer_terms)                    { |b| b.link(text: 'Red Hat Developer Program Terms & Conditions') }
  element(:rhd_subscription_terms)                 { |b| b.link(text: 'Red Hat Subscription Agreement') }
  element(:rh_portal_terms)                        { |b| b.link(text: 'Red Hat Portals Terms of Use') }

  value(:thanks_message)                           { |b| b.h2(class: 'divider').text }
  value(:email_field_error)                        { |b| b.span(id: 'email-error').text }
  value(:password_field_error)                     { |b| b.span(id: 'password-error').text }
  value(:password_confirm_field_error)             { |b| b.span(id: 'password-confirm-error').text }
  value(:first_name_field_error)                   { |b| b.span(id: 'firstName-error').text }
  value(:last_name_field_error)                    { |b| b.span(id: 'lastName-error').text }
  value(:company_field_error)                      { |b| b.span(id: 'user.attributes.company-error').text }
  value(:country_field_error)                      { |b| b.span(id: 'user.attributes.country-error').text}
  value(:city_field_error)                         { |b| b.span(id: 'user.attributes.addressCity-error').text}
  value(:state_field_error)                        { |b| b.span(id: 'user.attributes.addressState-error').text}

  action(:accept_all_terms)                        { |p| p.all_terms.click }
  action(:create_account)                          { |p| p.finish_button.click }
  action(:click_github_button)                     { |p| p.github_button.click }
  action(:click_link_social_to_existing_acc)       { |p| p.link_social_to_existing_acc.click }

  def fill_in_form(first_name, last_name, email, company, country=nil, city=nil, state=nil, password, password_confirm)
    expand_register_choice_email
    type(email_field, email)
    type(password_field, password)
    type(password_confirm_field, password_confirm)
    type(first_name_field, first_name)
    type(last_name_field, last_name)
    type(company_field, company)
    select_country(country) unless country.nil?
    type(city_field, city) unless city.nil?
    select_state(state) unless state.nil?
  end

  def select_country(country)
    country_dropdown.select(country)
  end

  def select_state(state)
    state_dropdown.select(state)
  end

  def expand_register_choice_email
    expand_register_with_email.click if expand_register_with_email.visible?
  end

  def click_register_with_github
    expand_register_with_social.click if expand_register_with_social.visible?
    click_github_button
  end

end