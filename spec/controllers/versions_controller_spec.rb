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

describe VersionsController do
  let(:user) { FactoryGirl.create(:admin) }
  let(:project) { FactoryGirl.create(:public_project) }
  let(:version1) {FactoryGirl.create(:version, :project => project, :effective_date => nil)}
  let(:version2) {FactoryGirl.create(:version, :project => project)}
  let(:version3) {FactoryGirl.create(:version, :project => project, :effective_date => (Date.today - 14.days))}

  describe "#index" do
    render_views

    before do
      version1
      version2
      version3
    end

    context "without additional params" do
      before do
        @controller.stub!(:find_current_user).and_return(user)
        get :index, :project_id => project.id
      end

      it { response.should be_success }
      it { response.should render_template("index") }
      it { assert_select "script", :text => Regexp.new(Regexp.escape("new ContextMenu('/issues/context_menu')")) }

      subject { assigns(:versions) }
      it "shows Version with no date set" do
        subject.include?(version1).should be_true
      end
      it "shows Version with date set" do
        subject.include?(version2).should be_true
      end
      it "not shows Completed version" do
        subject.include?(version3).should be_false
      end
    end

    context "with showing completed versions" do
      before do
        @controller.stub!(:find_current_user).and_return(user)
        get :index, :project_id => project, :completed => '1'
      end

      it { response.should be_success }
      it { response.should render_template("index") }

      subject { assigns(:versions) }
      it "shows Version with no date set" do
        subject.include?(version1).should be_true
      end
      it "shows Version with date set" do
        subject.include?(version2).should be_true
      end
      it "not shows Completed version" do
        subject.include?(version3).should be_true
      end
    end

    context "with showing subprojects versions" do
      let(:sub_project) { FactoryGirl.create(:public_project, :parent_id => project.id) }
      let(:version4) {FactoryGirl.create(:version, :project => sub_project)}

      before do
        @controller.stub!(:find_current_user).and_return(user)
        version4
        get :index, :project_id => project, :with_subprojects => '1'
      end

      it { response.should be_success }
      it { response.should render_template("index") }

      subject { assigns(:versions) }
      it "shows Version with no date set" do
        subject.include?(version1).should be_true
      end
      it "shows Version with date set" do
        subject.include?(version2).should be_true
      end
      it "shows Version from sub project" do
        subject.include?(version4).should be_true
      end
    end
  end

  describe "#show" do
    render_views

    before do
      @controller.stub!(:find_current_user).and_return(user)
      version2
      get :show, :id => version2.id
    end

    it { response.should be_success }
    it { response.should render_template("show") }
    it { assert_tag :tag => 'h2', :content => version2.name }

    subject { assigns(:version) }
    it { should == version2 }
  end

  describe "#create" do
    context "with vaild attributes" do
      before do
        @controller.stub!(:find_current_user).and_return(user)
        post :create, :project_id => project.id, :version => {:name => 'test_add_version'}
      end

      it { response.should redirect_to(settings_project_path(project, :tab => 'versions'))}
      it "generates the new version" do
        version = Version.find_by_name('test_add_version')
        version.should_not be_nil
        version.project.should == project
      end
    end

    context "from issue form" do
      before do
        @controller.stub!(:find_current_user).and_return(user)
        post :create, :project_id => project.id, :version => {:name => 'test_add_version_from_issue_form'}, :format => :js
      end

      it "generates the new version" do
        version = Version.find_by_name('test_add_version_from_issue_form')
        version.should_not be_nil
        version.project.should == project
      end

      it "returns updated select box with new version" do
        version = Version.find_by_name('test_add_version_from_issue_form')

        pattern = "Element.replace\(\"issue_fixed_version_id\","
        # select tag with valid html
        pattern << " \"<select id=\\\"issue_fixed_version_id\\\" name=\\\"issue[fixed_version_id]\\\">"
        # empty option tag with valid html
        pattern << "<option></option>"
        # selected option tag for the new version with valid html
        pattern << "<option value=\\\"#{version.id}\\\" selected=\\\"selected\\\">#{version.name}</option>"
        pattern << "</select>\"\);"

        response.body.should == pattern
      end

      it "escapes potentially harmful html" do
        harmful = "test <script>alert('pwned');</script>"
        post :create, :project_id => project.id, :version => {:name => harmful}, :format => :js
        version = Version.last

        response.body.include?("lt;script&gt;alert(&#x27;pwned&#x27;);&lt;/script&gt;").should be_true
      end
    end
  end

  describe "#edit" do
    render_views

    before do
      @controller.stub!(:find_current_user).and_return(user)
      version2
      get :edit, :id => version2.id
    end

    context "when resource is found" do
      it { response.should be_success }
      it { response.should render_template("edit") }
    end
  end

  describe "#close_completed" do
    before do
      @controller.stub!(:find_current_user).and_return(user)
      version1.update_attribute :status, 'open'
      version2.update_attribute :status, 'open'
      version3.update_attribute :status, 'open'
      put :close_completed, :project_id => project.id
    end

    it { response.should redirect_to(settings_project_path(project, :tab => 'versions')) }
    it { Version.find_by_status('closed').should == version3 }
  end

  describe "#update" do
    context "with valid params" do
      before do
        @controller.stub!(:find_current_user).and_return(user)
        put :update, :id => version1.id,
                     :version => { :name => 'New version name',
                                   :effective_date => Date.today.strftime("%Y-%m-%d")}
      end

      it { response.should redirect_to(settings_project_path(project, :tab => 'versions')) }
      it { Version.find_by_name("New version name").should == version1 }
      it { version1.reload.effective_date.should == Date.today }
    end

    context "with invalid params" do
      before do
        @controller.stub!(:find_current_user).and_return(user)
        put :update, :id => version1.id,
                     :version => { :name => '',
                                   :effective_date => Date.today.strftime("%Y-%m-%d")}
      end

      it { response.should be_success }
      it { response.should render_template("edit") }
    end
  end

  describe "#destroy" do
    before do
      @controller.stub!(:find_current_user).and_return(user)
      @deleted = version3.id
      delete :destroy, :id => @deleted
    end

    it "redirects to projects versions and the version is deleted" do
      response.should redirect_to(settings_project_path(project, :tab => 'versions'))
      expect { Version.find(@deleted) }.to raise_error ActiveRecord::RecordNotFound
    end

  end

  describe "#status_by" do
    render_views

    before do
      @controller.stub!(:find_current_user).and_return(user)
    end

    context "status by version" do
      before do
        get :status_by, :id => version2.id, :format => :js
      end

      it { response.should be_success }
      it { response.should render_template("issue_counts") }
    end

    context "status by version with status_by" do
      before do
        get :status_by, :id => version2.id, :format => :js, :status_by => 'status'
      end

      it { response.should be_success }
      it { response.should render_template("issue_counts") }
    end
  end
end
