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

describe ApplicationHelper do
  include ApplicationHelper

  describe "format_activity_description" do
    it "truncates given text" do
      text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lore"
      format_activity_description(text).size.should == 120
    end

    it "replaces escaped line breaks with html line breaks and should be html_safe" do
      text = "Lorem ipsum dolor sit \namet, consetetur sadipscing elitr, sed diam nonumy eirmod\r tempor invidunt"
      text_html = "Lorem ipsum dolor sit <br />amet, consetetur sadipscing elitr, sed diam nonumy eirmod<br /> tempor invidunt"
      format_activity_description(text).should == text_html
      format_activity_description(text).html_safe?.should be_true
    end

    it "escapes potentially harmful code" do
      text = "Lorem ipsum dolor <script>alert('pwnd');</script> tempor invidunt"
      format_activity_description(text).include?("lt;script&gt;alert(&#x27;pwnd&#x27;);&lt;/script&gt;").should be_true
    end
  end

  describe "footer_content" do
    context "no additional footer content" do
      before do
        OpenProject::Footer.content = nil
      end

      it { footer_content.should == I18n.t(:text_powered_by, :link => link_to(Redmine::Info.app_name, Redmine::Info.url)) }
    end

    context "string as additional footer content" do
      before do
        OpenProject::Footer.content = nil
        OpenProject::Footer.add_content("openproject","footer")
      end

      it { footer_content.include?(I18n.t(:text_powered_by, :link => link_to(Redmine::Info.app_name, Redmine::Info.url))).should be_true  }
      it { footer_content.include?("<span class=\"footer_openproject\">footer</span>").should be_true  }
    end

    context "proc as additional footer content" do
      before do
        OpenProject::Footer.content = nil
        OpenProject::Footer.add_content("openproject",Proc.new{Date.parse(Time.now.to_s)})
      end

      it { footer_content.include?("<span class=\"footer_openproject\">#{Date.parse(Time.now.to_s)}</span>").should be_true  }
    end

    context "proc which returns nothing" do
      before do
        OpenProject::Footer.content = nil
        OpenProject::Footer.add_content("openproject",Proc.new{"footer" if false})
      end

      it { footer_content.include?("<span class=\"footer_openproject\">").should be_false }
    end
  end
end
