require 'spec_helper'

include OwnTestHelper

describe "beerlist page" do
  let!(:user) { FactoryGirl.create :user }

  before :all do
    self.use_transactional_fixtures = false
    WebMock.disable_net_connect!(allow_localhost:true)
  end

  before :each do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start

    @brewery1 = FactoryGirl.create(:brewery, name: "Koff")
    @brewery2 = FactoryGirl.create(:brewery, name: "Schlenkerla")
    @brewery3 = FactoryGirl.create(:brewery, name: "Ayinger")
    @style1 = Style.create name: "Lager"
    @style2 = Style.create name: "Rauchbier"
    @style3 = Style.create name: "Weizen"
    @beer1 = FactoryGirl.create(:beer, name: "Nikolai", brewery: @brewery1, style: @style1)
    @beer2 = FactoryGirl.create(:beer, name: "Fastenbier", brewery: @brewery2, style: @style2)
    @beer3 = FactoryGirl.create(:beer, name: "Lechte Weisse", brewery: @brewery3, style: @style3)

    sign_in(username:"Pekka", password:"Foobar1")
  end

  after :each do
    DatabaseCleaner.clean
  end

  after :all do
    self.use_transactional_fixtures = true
  end

  it "shows all beers in order", js: true do
    visit beerlist_path
    find('table').find('tr:nth-child(2)')

    @beers = Beer.all
    @beers.sort! { |a,b| a.name.downcase <=> b.name.downcase }

    @beers.each_index {|i| find('table').find("tr:nth-child(#{i+2})").should have_content(@beers[i].name) }
  end

  it "shows all styles in order if style is clicked", js: true do
    visit beerlist_path
    find('table').find('tr:nth-child(2)')

    page.first('a', text:'Style').click

    @beers = Beer.all
    @beers.sort! { |a,b| a.style.name.downcase <=> b.style.name.downcase }

    @beers.each_index {|i| find('table').find("tr:nth-child(#{i+2})").should have_content(@beers[i].name) }
  end

  it "shows all breweries in order if brewery is clicked", js: true do
    visit beerlist_path
    find('table').find('tr:nth-child(2)')

    page.first('a', text:'Brewery').click

    @beers = Beer.all
    @beers.sort! { |a,b| a.brewery.name.downcase <=> b.brewery.name.downcase }

    @beers.each_index {|i| find('table').find("tr:nth-child(#{i+2})").should have_content(@beers[i].name) }
  end

  it "shows one known beer", js: true do
    visit beerlist_path
    find('table').find('tr:nth-child(2)')
    expect(page).to have_content "Nikolai"
  end

  #find('table').find('tr:nth-child(2)').should have_content('Fastenbier')
end