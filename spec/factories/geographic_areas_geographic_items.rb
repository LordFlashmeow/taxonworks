# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :geographic_areas_geographic_item do
    geographic_area nil
    geographic_item nil
    data_origin "MyString"
    origin_gid 1
    date_valid_from "MyString"
    date_valid_to "MyString"
    date_valid_origin "MyString"
  end
end
