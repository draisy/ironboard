require 'mechanize'
require 'highline/import'
class Ironboard

  def initialize
   @agent = Mechanize.new
   @page = @agent.get('http://learn.flatironschool.com')
   login(@page)
   display
   call
  end

  def call
    get_input
  end

  def get_input
    input = 0
    while !valid?(input)  
      puts "\nWhat would you like to work on? Please enter a number selection"
      input = gets.strip.to_i
      get_link(input) if valid?(input)
    end
  end

  def valid?(input)
    input.between?(1, @logged_in.links_with(:href =>/lessons/).count)
  end

  def login(page)
    page = @agent.page.link_with(:text => 'Login').click
    login = page.form_with(:action => "/session")

    username_field = login.field_with(:name => "login")
    username = ask("Please enter your (github) username:  ") { |x| x.echo = true }
    username_field.value = username

    password_field = login.field_with(:name => "password")
    password = ask("Enter password:  ") { |x| x.echo = false }
    password_field.value = password

    puts "Thank you. Please wait a moment while we download the latest schedule.\n"
    @logged_in = login.submit login.button
  end

  def display
    get_schedule
    display_plan
    display_labs
    get_titles
  end

  def get_schedule
    @schedule = @logged_in.links_with(:href =>/daily-schedules/).last.click
    puts @schedule.search('div#daily-schedule h1').first.text 
  end

  def display_plan
    puts "\n******THE PLAN******"
    @rows = @schedule.search('tbody tr')
    @rows.each {|row| puts "#{row.text}"}
  end

  def display_labs
    @labs_title = @schedule.search('div#daily-schedule h1')[1]
    @labs_title = @schedule.search('div#daily-schedule h2').first if !@labs_title
    puts "\n******THE #{@labs_title.text.upcase}******"
    @labs_title.next_sibling.next.search('li a').each {|l| puts l.text}
    puts "*********************"
  end

  def get_titles
    puts "\nLabs available for download"
    @schedule.search('div#daily-schedule a').each_with_index do |title, index| 
      puts "#{index+1}. #{title.text}"
    end
  end

  def get_link(input)
    lesson = @logged_in.links_with(:href =>/lessons/)[input -1].click
    get_github_page(lesson)
  end

  def get_github_page(lesson)
    github = lesson.links_with(:href => /github.com\/flatiron-school-ironboard/).first.href
    `open "#{github}"`
  end
end

i = Ironboard.new