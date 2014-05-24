require 'spec_helper'

feature "Library Location Access Panel" do

  scenario "should have 1 library location" do
    visit '/catalog/1'
    expect(page).to have_css('div.panel-library-location', count:1)
    within "div.panel-library-location" do
      within "div.library-location-heading" do
        expect(page).to have_css('img[src="/assets/EARTH-SCI.jpg"]')
        expect(page).to have_css('div.library-location-heading-text a', text: 'Earth Sciences Library (Branner)')
      end
    end
  end

  scenario "should have 3 library locations" do
    visit '/catalog/10'
    expect(page).to have_css('div.panel-library-location', count:3)
  end
end