require "spec_helper"

describe "Sort dropdown in results toolbar", js: true, feature: true do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end
  it "should display default correctly" do
    within "#sortAndPerPage" do
      expect(page).to have_css("button.btn.btn-sul-toolbar", text: "SORT BY RELEVANCE", visible: true)
    end
  end
  it "should change to current sort" do
    within "#sortAndPerPage" do
      expect(page).to_not have_css("button.btn.btn-sul-toolbar", text: "SORT BY AUTHOR", visible: true)
      page.find("button.btn.btn-sul-toolbar", text:"SORT BY RELEVANCE").click
      click_link "author"
      expect(page).to have_css("button.btn.btn-sul-toolbar", text: "SORT BY AUTHOR", visible: true)
    end
  end
end