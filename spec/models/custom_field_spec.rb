#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe CustomField do
  before { CustomField.destroy_all }

  let(:field)  { FactoryGirl.build :custom_field }
  let(:field2) { FactoryGirl.build :custom_field }

  describe :name do
    describe "uniqueness" do

      describe "WHEN value, locale and type are identical" do
        before do
          field.name = field2.name = "taken name"
          field2.save!
        end

        it { field.should_not be_valid }
      end

      describe "WHEN value and locale are identical and type is different" do
        before do
          field.name = field2.name = "taken name"
          field2.save!
          field.type = "TestCustomField"
        end

        it { field.should be_valid }
      end

      describe "WHEN type and locale are identical and value is different" do
        before do
          field.name = "new name"
          field2.name = "taken name"
          field2.save!
        end

        it { field.should be_valid }
      end

      describe "WHEN value and type are identical and locale is different" do
        before do
          I18n.locale = :de
          field2.name = "taken_name"

          # this fields needs an explicit english translations
          # otherwise it falls back using the german one
          I18n.locale = :en
          field2.name = "unique_name"

          field2.save!

          field.name = "taken_name"
        end

        it { field.should be_valid }
      end
    end

    describe "localization" do
      before do
        I18n.locale = :de
        field.name = "Feld"

        I18n.locale = :en
        field.name = "Field"
      end

      after do
        I18n.locale = :en
      end

      it "should return english name when in locale en" do
        I18n.locale = :en
        field.name.should == "Field"
      end

      it "should return german name when in locale de" do
        I18n.locale = :de
        field.name.should == "Feld"
      end
    end
  end

  describe :translations_attributes do
    describe "WHEN providing a hash with locale and values" do
      before do
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "zwei",
                                            "possible_values" => ["eins", "zwei", "drei"],
                                            "locale" => "de" } ]
      end

      it { field.should have(1).translations }
      it { field.name(:de).should == "Feld" }
      it { field.default_value(:de).should == "zwei" }
      it { field.possible_values(:locale => :de).should == ["eins", "zwei", "drei"] }
    end

    describe "WHEN providing a hash with only a locale" do
      before do
        field.translations_attributes = [ { "locale" => "de" } ]
      end

      it { field.should have(0).translations }
    end

    describe "WHEN providing a hash with a locale and blank values" do
      before do
        field.translations_attributes = [ { "name" => "",
                                            "default_value" => "",
                                            "possible_values" => "",
                                            "locale" => "de" } ]
      end

      it { field.should have(0).translations }
    end

    describe "WHEN providing a hash with a locale and only one values" do
      before do
        field.translations_attributes = [ { "name" => "Feld",
                                            "locale" => "de" } ]
      end

      it { field.should have(1).translations }
      it { field.name(:de).should == "Feld" }
    end

    describe "WHEN providing a hash without a locale but with values" do
      before do
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "zwei",
                                            "possible_values" => ["eins", "zwei", "drei"],
                                            "locale" => "" } ]
      end

      it { field.should have(0).translations }
    end

    describe "WHEN already having a translation and wishing to delete it" do
      before do
        I18n.locale = :de
        field.name = "Feld"

        I18n.locale = :en
        field.name = "Field"

        field.save!
        field.reload

        field.translations_attributes = [ { "id" => field.translations.first.id.to_s,
                                            "_destroy" => "1" } ]

        field.save!
      end

      it { field.should have(1).translations }
    end
  end


  describe :default_value do
    describe "localization" do
      before do
        I18n.locale = :de
        field.default_value = "Standard"

        I18n.locale = :en
        field.default_value = "default"
      end

      it { field.default_value(:en).should == "default" }
      it { field.default_value(:de).should == "Standard" }
    end
  end

  describe :possible_values do
    describe "localization" do
      before do
        I18n.locale = :de
        field.possible_values = ["eins", "zwei", "drei"]

        I18n.locale = :en
        field.possible_values = ["one", "two", "three"]

        I18n.locale = :de
        field.save!
        field.reload
      end

      after do
        I18n.locale = :en
      end

      it { field.possible_values(:locale => :en).should == ["one", "two", "three"] }
      it { field.possible_values(:locale => :de).should == ["eins", "zwei", "drei"] }
    end
  end

  describe :valid? do
    describe "WITH a list field
              WITH two translations
              WITH default_value not included in possible_values in the non current locale translation" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "vier",
                                            "possible_values" => ["eins", "zwei", "drei"],
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "default_value" => "two" } ]
      end

      it { field.should_not be_valid }
    end

    describe "WITH a list field
              WITH two translations
              WITH default_value included in possible_values" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "zwei",
                                            "possible_values" => ["eins", "zwei", "drei"],
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "default_value" => "two" } ]
      end

      it { field.should be_valid }
    end


    describe "WITH a list field
              WITH two translations
              WITH default_value not included in possible_values in the current locale translation" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "zwei",
                                            "possible_values" => ["eins", "zwei", "drei"],
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "default_value" => "four" } ]
      end

      it { field.should_not be_valid }
    end

    describe "WITH a list field
              WITH two translations
              WITH possible_values beeing empty in a fallbacked translation" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "default_value" => "two" } ]
      end

      it { field.should be_valid }
    end

    describe "WITH a list field
              WITH the field beeing required
              WITH two translations
              WITH neither translation defining a default_value" do

      before do
        field.field_format = 'list'
        field.is_required = true
        field.translations_attributes = [ { "name" => "Feld",
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "locale" => "en" } ]
      end

      it { field.should be_valid }
    end

    describe "WITH a boolean field
              WITH the field beeing required
              WITH two translations beeing provided
              WITH only one translation specifying a default value" do

      before do
        field.field_format = 'bool'
        field.translations_attributes = { "0" => { "name" => "name_en",
                                                   "default_value" => "1",
                                                   "locale" => "en" },
                                          "1" => { "name" => "name_es",
                                                   "locale" => "es" } }
        field.is_required = true
      end

      it { field.should be_valid }
    end
  end
end
