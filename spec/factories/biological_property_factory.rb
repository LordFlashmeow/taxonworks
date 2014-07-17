FactoryGirl.define do
  factory :controlled_vocabulary_term_biological_property, class: BiologicalProperty, traits: [:housekeeping] do
    factory :valid_controlled_vocabulary_term_biological_property do
      name 'Lunch'
      definition 'Tagged subject is featured as lunch for hungry insects.'
      # name { Faker::Lorem.word }
      # definition { Faker::Lorem.sentence }
    end
  end
end
