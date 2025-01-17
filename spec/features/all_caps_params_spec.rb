require "spec_helper"

describe "Search parameters in all caps", type: :feature do
  it "should be downcased" do
    visit root_path
    fill_in 'q', with: "HELLO WORLD"
    click_button 'search'

    within('.breadcrumb') do
      expect(page).not_to have_content("HELLO WORLD")
      expect(page).to have_content("hello world")
    end

    text_field = find('#q')
    expect(text_field.value).not_to eq 'HELLO WORLD'
    expect(text_field.value).to eq 'hello world'
  end
end
