# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

User.create(:email => "Jillyh0@gmail.com",
            :password => "jek339",
            :first_name => "Jillian",
            :last_name => "Kozyra",
            :user_type => "admin",
            :who => "adfsf",
            :how => "sdjfdf",
            :approved => 1)