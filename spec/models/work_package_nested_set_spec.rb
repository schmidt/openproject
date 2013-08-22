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

# TODO: this spec is for now targeting each WorkPackage subclass
# independently. Once only WorkPackage exist, this can safely be consolidated.
describe WorkPackage do
  let(:project) { FactoryGirl.build(:project_with_types) }
  let(:issue) { FactoryGirl.build(:issue, :project => project, :type => project.types.first) }
  let(:issue2) { FactoryGirl.build(:issue, :project => project, :type => project.types.first) }
  let(:issue3) { FactoryGirl.build(:issue, :project => project, :type => project.types.first) }
  let(:planning_element) { FactoryGirl.build(:planning_element, :project => project) }
  let(:planning_element2) { FactoryGirl.build(:planning_element, :project => project) }
  let(:planning_element3) { FactoryGirl.build(:planning_element, :project => project) }

  [:issue, :planning_element].each do |subclass|

    describe "(#{subclass})" do
      let(:instance) { send(subclass) }
      let(:parent) { send(:"#{subclass}2") }
      let(:parent2) { send(:"#{subclass}3") }

      shared_examples_for "root" do
        it "should set root_id to the id of the #{subclass}" do
          instance.root_id.should == instance.id
        end

        it "should set lft to 1" do
          instance.lft.should == 1
        end

        it "should set rgt to 2" do
          instance.rgt.should == 2
        end
      end

      shared_examples_for "first child" do
        it "should set root_id to the id of the parent #{subclass}" do
          instance.root_id.should == parent.id
        end

        it "should set lft to 2" do
          instance.lft.should == 2
        end

        it "should set rgt to 3" do
          instance.rgt.should == 3
        end
      end

      describe "creating a new instance without a parent" do

        before do
          instance.save!
        end

        it_should_behave_like "root"
      end

      describe "creating a new instance with a parent" do

        before do
          parent.save!
          instance.parent = parent

          instance.save!
        end

        it_should_behave_like "first child"
      end

      describe "an existant instance receives a parent" do

        before do
          parent.save!
          instance.save!
          instance.parent = parent
          instance.save!
        end

        it_should_behave_like "first child"
      end

      describe "an existant instance becomes a root" do

        before do
          parent.save!
          instance.parent = parent
          instance.save!
          instance.parent_id = nil
          instance.save!
        end

        it_should_behave_like "root"

        it "should set parent_id to nil" do
          instance.parent_id.should == nil
        end
      end

      describe "an existant instance receives a new parent (new tree)" do

        before do
          parent.save!
          parent2.save!
          instance.parent_id = parent2.id
          instance.save!

          instance.parent = parent
          instance.save!
        end

        it_should_behave_like "first child"

        it "should set parent_id to new parent" do
          instance.parent_id.should == parent.id
        end
      end

      describe "an existant instance
                with a right sibling receives a new parent" do

        let(:other_child) { send(:"#{subclass}3") }

        before do
          parent.save!
          instance.parent = parent
          instance.save!
          other_child.parent = parent
          other_child.save!

          instance.parent_id = nil
          instance.save!
        end

        it "former roots's root_id should be unchanged" do
          parent.reload
          parent.root_id.should == parent.id
        end

        it "former roots's lft should be 1" do
          parent.reload
          parent.lft.should == 1
        end

        it "former roots's rgt should be 4" do
          parent.reload
          parent.rgt.should == 4
        end

        it "former right siblings's root_id should be unchanged" do
          other_child.reload
          other_child.root_id.should == parent.id
        end

        it "former right siblings's left should be 2" do
          other_child.reload
          other_child.lft.should == 2
        end

        it "former right siblings's rgt should be 3" do
          other_child.reload
          other_child.rgt.should == 3
        end
      end

      describe "an existant instance receives a new parent (same tree)" do

        before do
          parent.save!
          parent2.save!
          instance.parent_id = parent2.id
          instance.save!

          instance.parent = parent
          instance.save!
        end

        it_should_behave_like "first child"
      end

      describe "an existant instance with children receives a new parent (itself)" do
        let(:child) { send(:"#{subclass}3") }

        before do
          parent.save!
          instance.parent = parent
          instance.save!
          child.parent_id = instance.id
          child.save!

          # reloading as instance's nested set attributes (lft, rgt) where
          # updated by adding child to the set
          instance.reload
          instance.parent_id = nil
          instance.save!
        end

        it "former parent's root_id should be unchanged" do
          parent.reload
          parent.root_id.should == parent.id
        end

        it "former parent's left should be 1" do
          parent.reload
          parent.lft.should == 1
        end

        it "former parent's right should be 2" do
          parent.reload
          parent.rgt.should == 2
        end

        it "the child should have the root_id of the parent #{subclass}" do
          child.reload
          child.root_id.should == instance.id
        end

        it "the child should have a lft of 2" do
          child.reload
          child.lft.should == 2
        end

        it "the child should have a rgt of 3" do
          child.reload
          child.rgt.should == 3
        end
      end
    end
  end
end
