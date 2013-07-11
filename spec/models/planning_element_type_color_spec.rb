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

require File.expand_path('../../spec_helper', __FILE__)

describe PlanningElementTypeColor do
  describe '- Relations ' do
    describe '#planning_element_types' do
      it 'can read planning_element_types w/ the help of the has_many association' do
        color                 = FactoryGirl.create(:color)
        planning_element_type = FactoryGirl.create(:planning_element_type,
                                               :color_id => color.id)

        color.reload

        color.planning_element_types.size.should == 1
        color.planning_element_types.first.should == planning_element_type
      end

      it 'nullifies dependent planning_element_types' do
        color                 = FactoryGirl.create(:color)
        planning_element_type = FactoryGirl.create(:planning_element_type,
                                               :color_id => color.id)

        color.reload
        color.destroy

        planning_element_type.reload
        planning_element_type.color_id.should be_nil
      end
    end
  end

  describe '- Validations ' do
    let(:attributes) {
      {:name    => 'Color No. 1',
       :hexcode => '#FFFFFF'}
    }

    describe 'name' do
      it 'is invalid w/o a name' do
        attributes[:name] = nil
        color = PlanningElementTypeColor.new(attributes)

        color.should_not be_valid

        color.errors[:name].should be_present
        color.errors[:name].should == ["can't be blank"]
      end

      it 'is invalid w/ a name longer than 255 characters' do
        attributes[:name] = "A" * 500
        color = PlanningElementTypeColor.new(attributes)

        color.should_not be_valid

        color.errors[:name].should be_present
        color.errors[:name].should == ["is too long (maximum is 255 characters)"]
      end
    end

    describe 'hexcode' do
      it 'is invalid w/o a hexcode' do
        attributes[:hexcode] = nil
        color = PlanningElementTypeColor.new(attributes)

        color.should_not be_valid

        color.errors[:hexcode].should be_present
        color.errors[:hexcode].should == ["can't be blank"]
      end

      it 'is invalid w/ malformed hexcodes' do
        PlanningElementTypeColor.new(attributes.merge(:hexcode => '0#FFFFFF')).should_not be_valid
        PlanningElementTypeColor.new(attributes.merge(:hexcode => '#FFFFFF0')).should_not be_valid
        PlanningElementTypeColor.new(attributes.merge(:hexcode => 'white')).   should_not be_valid
      end

      it 'fixes some wrong formats of hexcode automatically' do
        color = PlanningElementTypeColor.new(attributes.merge(:hexcode => 'FFCC33'))
        color.should be_valid
        color.hexcode.should == '#FFCC33'

        color = PlanningElementTypeColor.new(attributes.merge(:hexcode => '#ffcc33'))
        color.should be_valid
        color.hexcode.should == '#FFCC33'

        color = PlanningElementTypeColor.new(attributes.merge(:hexcode => 'fc3'))
        color.should be_valid
        color.hexcode.should == '#FFCC33'

        color = PlanningElementTypeColor.new(attributes.merge(:hexcode => '#fc3'))
        color.should be_valid
        color.hexcode.should == '#FFCC33'
      end

      it 'is valid w/ proper hexcodes' do
        PlanningElementTypeColor.new(attributes.merge(:hexcode => '#FFFFFF')). should be_valid
        PlanningElementTypeColor.new(attributes.merge(:hexcode => '#FF00FF')).should be_valid
      end
    end
  end
end
