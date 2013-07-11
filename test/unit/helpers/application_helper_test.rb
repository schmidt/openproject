#-- encoding: UTF-8
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
require File.expand_path('../../../test_helper', __FILE__)

class ApplicationHelperTest < ActionView::TestCase
  def setup
    super
    # @project variable is used by helper
    @project = FactoryGirl.create :valid_project
    @project.reload # reload references to indirectly created entities (e.g. wiki)

    @admin = FactoryGirl.create :admin
    @anonymous = FactoryGirl.create :anonymous
    @non_member = FactoryGirl.create :user
    @project_member = FactoryGirl.create :user,
      :member_in_project => @project,
      :member_through_role => FactoryGirl.create(:role,
          :permissions => [:view_work_packages, :edit_work_packages, :view_documents,
                           :browse_repository, :view_changesets, :view_wiki_pages])

    @issue = FactoryGirl.create :issue, :project => @project, :author => @project_member, :tracker => @project.trackers.first
    @attachment = FactoryGirl.create :attachment,
        :author => @project_member,
        :content_type => 'image/gif',
        :filename => 'logo.gif',
        :disk_filename => '060719210727_logo.gif',
        :digest => 'b91e08d0cf966d5c6ff411bd8c4cc3a2',
        :container => @issue,
        :filesize => 280,
        :description => 'This is a logo'

    User.current = @project_member
  end

  def request
    @request ||= ActionController::TestRequest.new
  end

  context "#link_to_if_authorized" do
    should "create a link for an authorized user" do
      User.current = @project_member
      response = link_to_if_authorized('link_content', {
          :controller => 'issues',
          :action => 'show',
          :id => @issue },
        :class => 'fancy_css_class')
      assert_match(/href/, response)
      assert_match(/fancy_css_class/, response)
    end

    should "shouldn't create a link for an unauthorized user" do
      User.current = @non_member
      response = link_to_if_authorized 'link_content', {
          :controller => 'issues',
          :action => 'show',
          :id => @issue },
        :class => 'fancy_css_class'
      assert_nil response
    end

    should "allow using the :controller and :action for the target link" do
      User.current = @admin
      response = link_to_if_authorized("By controller/action",
                                       {:controller => 'issues', :action => 'edit', :id => @issue.id})
      assert_match(/href/, response)
    end

  end

  def test_auto_links
    to_test = {
      'http://foo.bar' => '<a class="external" href="http://foo.bar">http://foo.bar</a>',
      'http://foo.bar/~user' => '<a class="external" href="http://foo.bar/~user">http://foo.bar/~user</a>',
      'http://foo.bar.' => '<a class="external" href="http://foo.bar">http://foo.bar</a>.',
      'https://foo.bar.' => '<a class="external" href="https://foo.bar">https://foo.bar</a>.',
      'This is a link: http://foo.bar.' => 'This is a link: <a class="external" href="http://foo.bar">http://foo.bar</a>.',
      'A link (eg. http://foo.bar).' => 'A link (eg. <a class="external" href="http://foo.bar">http://foo.bar</a>).',
      'http://foo.bar/foo.bar#foo.bar.' => '<a class="external" href="http://foo.bar/foo.bar#foo.bar">http://foo.bar/foo.bar#foo.bar</a>.',
      'http://www.foo.bar/Test_(foobar)' => '<a class="external" href="http://www.foo.bar/Test_(foobar)">http://www.foo.bar/Test_(foobar)</a>',
      '(see inline link : http://www.foo.bar/Test_(foobar))' => '(see inline link : <a class="external" href="http://www.foo.bar/Test_(foobar)">http://www.foo.bar/Test_(foobar)</a>)',
      '(see inline link : http://www.foo.bar/Test)' => '(see inline link : <a class="external" href="http://www.foo.bar/Test">http://www.foo.bar/Test</a>)',
      '(see inline link : http://www.foo.bar/Test).' => '(see inline link : <a class="external" href="http://www.foo.bar/Test">http://www.foo.bar/Test</a>).',
      '(see "inline link":http://www.foo.bar/Test_(foobar))' => '(see <a href="http://www.foo.bar/Test_(foobar)" class="external">inline link</a>)',
      '(see "inline link":http://www.foo.bar/Test)' => '(see <a href="http://www.foo.bar/Test" class="external">inline link</a>)',
      '(see "inline link":http://www.foo.bar/Test).' => '(see <a href="http://www.foo.bar/Test" class="external">inline link</a>).',
      'www.foo.bar' => '<a class="external" href="http://www.foo.bar">www.foo.bar</a>',
      'http://foo.bar/page?p=1&t=z&s=' => '<a class="external" href="http://foo.bar/page?p=1&#38;t=z&#38;s=">http://foo.bar/page?p=1&#38;t=z&#38;s=</a>',
      'http://foo.bar/page#125' => '<a class="external" href="http://foo.bar/page#125">http://foo.bar/page#125</a>',
      'http://foo@www.bar.com' => '<a class="external" href="http://foo@www.bar.com">http://foo@www.bar.com</a>',
      'http://foo:bar@www.bar.com' => '<a class="external" href="http://foo:bar@www.bar.com">http://foo:bar@www.bar.com</a>',
      'ftp://foo.bar' => '<a class="external" href="ftp://foo.bar">ftp://foo.bar</a>',
      'ftps://foo.bar' => '<a class="external" href="ftps://foo.bar">ftps://foo.bar</a>',
      'sftp://foo.bar' => '<a class="external" href="sftp://foo.bar">sftp://foo.bar</a>',
      # two exclamation marks
      'http://example.net/path!602815048C7B5C20!302.html' => '<a class="external" href="http://example.net/path!602815048C7B5C20!302.html">http://example.net/path!602815048C7B5C20!302.html</a>',
      # escaping
      'http://foo"bar' => '<a class="external" href="http://foo&quot;bar">http://foo&quot;bar</a>',
      # wrap in angle brackets
      '<http://foo.bar>' => '&lt;<a class="external" href="http://foo.bar">http://foo.bar</a>&gt;'
    }
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text) }
  end

  def test_auto_mailto
    assert_equal '<p><a class="email" href="mailto:test@foo.bar">test@foo.bar</a></p>',
      textilizable('test@foo.bar')
  end

  def test_inline_images
    to_test = {
      '!http://foo.bar/image.jpg!' => '<img src="http://foo.bar/image.jpg" alt="" />',
      'floating !>http://foo.bar/image.jpg!' => 'floating <div style="float:right"><img src="http://foo.bar/image.jpg" alt="" /></div>',
      'with class !(some-class)http://foo.bar/image.jpg!' => 'with class <img src="http://foo.bar/image.jpg" class="some-class" alt="" />',
      # inline styles should be stripped
      'with style !{width:100px;height100px}http://foo.bar/image.jpg!' => 'with style <img src="http://foo.bar/image.jpg" alt="" />',
      'with title !http://foo.bar/image.jpg(This is a title)!' => 'with title <img src="http://foo.bar/image.jpg" title="This is a title" alt="This is a title" />',
      'with title !http://foo.bar/image.jpg(This is a double-quoted "title")!' => 'with title <img src="http://foo.bar/image.jpg" title="This is a double-quoted &quot;title&quot;" alt="This is a double-quoted &quot;title&quot;" />',
    }
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text) }
  end

  def test_inline_images_inside_tags
    raw = <<-RAW
h1. !foo.png! Heading

Centered image:

p=. !bar.gif!
RAW

    assert textilizable(raw).include?('<img src="foo.png" alt="" />')
    assert textilizable(raw).include?('<img src="bar.gif" alt="" />')
  end

  def test_attached_images
    to_test = {
      'Inline image: !logo.gif!' => "Inline image: <img src=\"/attachments/#{@attachment.id}/download\" title=\"This is a logo\" alt=\"This is a logo\" />",
      'Inline image: !logo.GIF!' => "Inline image: <img src=\"/attachments/#{@attachment.id}/download\" title=\"This is a logo\" alt=\"This is a logo\" />",
      'No match: !ogo.gif!' => 'No match: <img src="ogo.gif" alt="" />',
      'No match: !ogo.GIF!' => 'No match: <img src="ogo.GIF" alt="" />',
      # link image
      '!logo.gif!:http://foo.bar/' => "<a href=\"http://foo.bar/\"><img src=\"/attachments/#{@attachment.id}/download\" title=\"This is a logo\" alt=\"This is a logo\" /></a>",
    }
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text, :attachments => [@attachment]) }
  end

  def test_textile_external_links
    to_test = {
      'This is a "link":http://foo.bar' => 'This is a <a href="http://foo.bar" class="external">link</a>',
      'This is an intern "link":/foo/bar' => 'This is an intern <a href="/foo/bar">link</a>',
      '"link (Link title)":http://foo.bar' => '<a href="http://foo.bar" title="Link title" class="external">link</a>',
      '"link (Link title with "double-quotes")":http://foo.bar' => '<a href="http://foo.bar" title="Link title with &quot;double-quotes&quot;" class="external">link</a>',
      "This is not a \"Link\":\n\nAnother paragraph" => "This is not a \"Link\":</p>\n\n\n\t<p>Another paragraph",
      # no multiline link text
      "This is a double quote \"on the first line\nand another on a second line\":test" => "This is a double quote \"on the first line<br />and another on a second line\":test",
      # mailto link
      "\"system administrator\":mailto:sysadmin@example.com?subject=redmine%20permissions" => "<a href=\"mailto:sysadmin@example.com?subject=redmine%20permissions\">system administrator</a>",
      # two exclamation marks
      '"a link":http://example.net/path!602815048C7B5C20!302.html' => '<a href="http://example.net/path!602815048C7B5C20!302.html" class="external">a link</a>',
      # escaping
      '"test":http://foo"bar' => '<a href="http://foo&quot;bar" class="external">test</a>',
    }
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text) }
  end

  def test_textile_relative_to_full_links_in_a_controller
    # we have a request here
    {
      # shouldn't change non-relative links
      'This is a "link":http://foo.bar' => 'This is a <a href="http://foo.bar" class="external">link</a>',
      'This is an intern "link":/foo/bar' => 'This is an intern <a href="http://test.host/foo/bar">link</a>',
      'This is an intern "link":/foo/bar and an extern "link":http://foo.bar' => 'This is an intern <a href="http://test.host/foo/bar">link</a> and an extern <a href="http://foo.bar" class="external">link</a>',
    }.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text, :only_path => false) }
  end

  def test_textile_relative_to_full_links_in_the_mailer
    # we don't a request here
    undef request
    # mimic the mailer default_url_options
    @controller.class.class_eval {
      def self.default_url_options
        ::UserMailer.default_url_options
      end
    }

    {
      # shouldn't change non-relative links
      'This is a "link":http://foo.bar' => 'This is a <a href="http://foo.bar" class="external">link</a>',
      'This is an intern "link":/foo/bar' => 'This is an intern <a href="http://localhost:3000/foo/bar">link</a>',
      'This is an intern "link":/foo/bar and an extern "link":http://foo.bar' => 'This is an intern <a href="http://localhost:3000/foo/bar">link</a> and an extern <a href="http://foo.bar" class="external">link</a>',
    }.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text, :only_path => false) }
  end

  def test_redmine_links
    document = FactoryGirl.create :document,
                 :title => 'Test document',
                 :project => @project
    version = FactoryGirl.create :version,
                 :name => '1.0',
                 :project => @project
    Setting.enabled_scm = Setting.enabled_scm << "Filesystem" unless Setting.enabled_scm.include? "Filesystem"
    repository = FactoryGirl.create :repository,
                 :project => @project
    changeset1 = FactoryGirl.create :changeset,
                 :repository => repository,
                 :comments => 'My very first commit'
    changeset2 = FactoryGirl.create :changeset,
                 :repository => repository,
                 :comments => 'This commit fixes #1, #2 and references #1 & #3'
    board = FactoryGirl.create :board,
                 :project => @project
    message1 = FactoryGirl.create :message,
                 :board => board
    message2 = FactoryGirl.create :message,
                 :board => board,
                 :parent => message1
    message1.reload
    subproject = FactoryGirl.create :valid_project,
                 :parent => @project
    identifier = @project.identifier
    @project.reload

    issue_link = link_to("##{@issue.id}", {:controller => 'issues', :action => 'show', :id => @issue},
                               :class => 'issue status-3 priority-1 created-by-me', :title => "#{@issue.subject} (#{@issue.status})")

    changeset_link = link_to("r#{changeset1.revision}", {:controller => 'repositories', :action => 'revision', :id => identifier, :rev => changeset1.revision},
                                   :class => 'changeset', :title => 'My very first commit')
    changeset_link2 = link_to("r#{changeset2.revision}", {:controller => 'repositories', :action => 'revision', :id => identifier, :rev => changeset2.revision},
                                    :class => 'changeset', :title => 'This commit fixes #1, #2 and references #1 & #3')

    document_link = link_to('Test document', {:controller => 'documents', :action => 'show', :id => document.id},
                                             :class => 'document')

    version_link = link_to('1.0', {:controller => 'versions', :action => 'show', :id => version.id},
                                  :class => 'version')

    message_url = {:controller => 'messages', :action => 'show', :board_id => board.id, :id => message1.id}

    project_url = {:controller => 'projects', :action => 'show', :id => subproject.identifier}

    source_url = {:controller => 'repositories', :action => 'entry', :id => identifier, :path => ['some', 'file']}
    source_url_with_ext = {:controller => 'repositories', :action => 'entry', :id => identifier, :path => ['some', 'file.ext']}

    to_test = {
      # tickets
      "##{@issue.id}, [##{@issue.id}], (##{@issue.id}) and ##{@issue.id}." => "#{issue_link}, [#{issue_link}], (#{issue_link}) and #{issue_link}.",
      # changesets
      "r#{changeset1.revision}"     => changeset_link,
      "r#{changeset1.revision}."    => "#{changeset_link}.",
      "r#{changeset1.revision}, r#{changeset2.revision}" => "#{changeset_link}, #{changeset_link2}",
      "r#{changeset1.revision},r#{changeset2.revision}"  => "#{changeset_link},#{changeset_link2}",
      # documents
      "document##{document.id}"     => document_link,
      'document:"Test document"'    => document_link,
      # versions
      "version##{version.id}"       => version_link,
      'version:1.0'                 => version_link,
      'version:"1.0"'               => version_link,
      # source
      'source:/some/file'           => link_to('source:/some/file', source_url, :class => 'source'),
      'source:/some/file.'          => link_to('source:/some/file', source_url, :class => 'source') + ".",
      'source:/some/file.ext.'      => link_to('source:/some/file.ext', source_url_with_ext, :class => 'source') + ".",
      'source:/some/file. '         => link_to('source:/some/file', source_url, :class => 'source') + ".",
      'source:/some/file.ext. '     => link_to('source:/some/file.ext', source_url_with_ext, :class => 'source') + ".",
      'source:/some/file, '         => link_to('source:/some/file', source_url, :class => 'source') + ",",
      'source:/some/file@52'        => link_to('source:/some/file@52', source_url.merge(:rev => 52), :class => 'source'),
      'source:/some/file.ext@52'    => link_to('source:/some/file.ext@52', source_url_with_ext.merge(:rev => 52), :class => 'source'),
      'source:/some/file#L110'      => link_to('source:/some/file#L110', source_url.merge(:anchor => 'L110'), :class => 'source'),
      'source:/some/file.ext#L110'  => link_to('source:/some/file.ext#L110', source_url_with_ext.merge(:anchor => 'L110'), :class => 'source'),
      'source:/some/file@52#L110'   => link_to('source:/some/file@52#L110', source_url.merge(:rev => 52, :anchor => 'L110'), :class => 'source'),
      'export:/some/file'           => link_to('export:/some/file', source_url.merge(:format => 'raw'), :class => 'source download'),
      # message
      "message##{message1.id}"      => link_to(message1.subject, message_url, :class => 'message'),
      "message##{message2.id}"      => link_to(message2.subject, message_url.merge(:anchor => "message-#{message2.id}", :r => message2.id), :class => 'message'),
      # project
      "project##{subproject.id}"    => link_to(subproject.name, project_url, :class => 'project'),
      "project:#{subproject.identifier}" => link_to(subproject.name, project_url, :class => 'project'),
      "project:\"#{subproject.name}\"" => link_to(subproject.name, project_url, :class => 'project'),
      # escaping
      "!##{@issue.id}."             => "##{@issue.id}.",
      "!r#{changeset1.id}"          => "r#{changeset1.id}",
      "!document##{document.id}"    => "document##{document.id}",
      '!document:"Test document"'   => 'document:"Test document"',
      "!version##{version.id}"      => "version##{version.id}",
      '!version:1.0'                => 'version:1.0',
      '!version:"1.0"'              => 'version:"1.0"',
      '!source:/some/file'          => 'source:/some/file',
      # not found
      '#0123456789'                 => '#0123456789',
      # invalid expressions
      'source:'                     => 'source:',
      # url hash
      "http://foo.bar/FAQ#3"       => '<a class="external" href="http://foo.bar/FAQ#3">http://foo.bar/FAQ#3</a>',
    }
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text), "#{text} failed" }
  end

  def test_cross_project_redmine_links
    document = FactoryGirl.create :document,
                 :title => 'Test document',
                 :project => @project
    version = FactoryGirl.create :version,
                 :name => '1.0',
                 :project => @project
    Setting.enabled_scm = Setting.enabled_scm << "Filesystem" unless Setting.enabled_scm.include? "Filesystem"
    repository = FactoryGirl.create :repository,
                 :project => @project
    changeset = FactoryGirl.create :changeset,
                 :repository => repository,
                 :comments => 'This commit fixes #1, #2 and references #1 & #3'
    identifier = @project.identifier

    source_link = link_to("#{identifier}:source:/some/file", {:controller => 'repositories', :action => 'entry', :id => identifier, :path => ['some', 'file']},
      :class => 'source')
    changeset_link = link_to("#{identifier}:r#{changeset.revision}",
      {:controller => 'repositories', :action => 'revision', :id => identifier, :rev => changeset.revision},
      :class => 'changeset', :title => 'This commit fixes #1, #2 and references #1 & #3')

    # textilizable "sees" the text is parses from the_other_project (and not @project)
    the_other_project = FactoryGirl.create :valid_project

    to_test = {
      # documents
      'document:"Test document"'              => 'document:"Test document"',
      "#{identifier}:document##{document.id}" => "<a href=\"/documents/#{document.id}\" class=\"document\">Test document</a>",
      "#{identifier}:document:\"Test document\"" => "<a href=\"/documents/#{document.id}\" class=\"document\">Test document</a>",
      'invalid:document:"Test document"'      => 'invalid:document:"Test document"',
      # versions
      'version:"1.0"'                         => 'version:"1.0"',
      "#{identifier}:version:\"1.0\""         => "<a href=\"/versions/#{version.id}\" class=\"version\">1.0</a>",
      'invalid:version:"1.0"'                 => 'invalid:version:"1.0"',
      # changeset
      "r#{changeset.revision}"                => "r#{changeset.revision}",
      "#{identifier}:r#{changeset.revision}"  => changeset_link,
      "invalid:r#{changeset.revision}"        => "invalid:r#{changeset.revision}",
      # source
      'source:/some/file'                     => 'source:/some/file',
      "#{identifier}:source:/some/file"       => source_link,
      'invalid:source:/some/file'             => 'invalid:source:/some/file',
    }
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text, :project => the_other_project), "#{text} failed" }
  end

  def test_redmine_links_git_commit
    User.current = @admin
    changeset_link = link_to('abcd',
                               {
                                 :controller => 'repositories',
                                 :action     => 'revision',
                                 :id         => @project.identifier,
                                 :rev        => 'abcd',
                                },
                              :class => 'changeset', :title => 'test commit')
    to_test = {
      'commit:abcd' => changeset_link,
     }
    r = Repository::Git.create!(:project => @project, :url => '/tmp/test/git')
    assert r
    c = Changeset.new(:repository => r,
                      :committed_on => Time.now,
                      :revision => 'abcd',
                      :scmid => 'abcd',
                      :comments => 'test commit')
    assert( c.save )
    @project.reload
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text) }
  end

  def test_attachment_links
    attachment_link = link_to('logo.gif', {:controller => 'attachments', :action => 'download', :id => @attachment}, :class => 'attachment')
    to_test = {
      'attachment:logo.gif' => attachment_link
    }
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text, :attachments => [@attachment]), "#{text} failed" }
  end

  def test_wiki_links
    User.current = @admin
    @project.wiki.start_page = "CookBook documentation"
    @project.wiki.save!
    FactoryGirl.create :wiki_page_with_content, :wiki => @project.wiki, :title => "CookBook_documentation"
    FactoryGirl.create :wiki_page_with_content, :wiki => @project.wiki, :title => "Another page"

    project2 = FactoryGirl.create :valid_project, :identifier => 'onlinestore'
    project2.reload # reload indirectly created references (esp. the wiki)
    project2.wiki.start_page = "Start page"
    project2.wiki.save!
    FactoryGirl.create :wiki_page_with_content, :wiki => project2.wiki, :title => "Start_page"

    to_test = {
      '[[CookBook documentation]]' => "<a href=\"/projects/#{@project.identifier}/wiki/CookBook_documentation\" class=\"wiki-page\">CookBook documentation</a>",
      '[[Another page|Page]]' => "<a href=\"/projects/#{@project.identifier}/wiki/Another_page\" class=\"wiki-page\">Page</a>",
      # link with anchor
      '[[CookBook documentation#One-section]]' => "<a href=\"/projects/#{@project.identifier}/wiki/CookBook_documentation#One-section\" class=\"wiki-page\">CookBook documentation</a>",
      '[[Another page#anchor|Page]]' => "<a href=\"/projects/#{@project.identifier}/wiki/Another_page#anchor\" class=\"wiki-page\">Page</a>",
      # page that doesn't exist
      '[[Unknown page]]' => "<a href=\"/projects/#{@project.identifier}/wiki/Unknown_page\" class=\"wiki-page new\">Unknown page</a>",
      '[[Unknown page|404]]' => "<a href=\"/projects/#{@project.identifier}/wiki/Unknown_page\" class=\"wiki-page new\">404</a>",
      # link to another project wiki
      '[[onlinestore:]]' => "<a href=\"/projects/onlinestore/wiki\" class=\"wiki-page\">onlinestore</a>",
      '[[onlinestore:|Wiki]]' => "<a href=\"/projects/onlinestore/wiki\" class=\"wiki-page\">Wiki</a>",
      '[[onlinestore:Start page]]' => "<a href=\"/projects/onlinestore/wiki/Start_page\" class=\"wiki-page\">Start page</a>",
      '[[onlinestore:Start page|Text]]' => "<a href=\"/projects/onlinestore/wiki/Start_page\" class=\"wiki-page\">Text</a>",
      '[[onlinestore:Unknown page]]' => "<a href=\"/projects/onlinestore/wiki/Unknown_page\" class=\"wiki-page new\">Unknown page</a>",
      # striked through link
      '-[[Another page|Page]]-' => "<del><a href=\"/projects/#{@project.identifier}/wiki/Another_page\" class=\"wiki-page\">Page</a></del>",
      '-[[Another page|Page]] link-' => "<del><a href=\"/projects/#{@project.identifier}/wiki/Another_page\" class=\"wiki-page\">Page</a> link</del>",
      # escaping
      '![[Another page|Page]]' => '[[Another page|Page]]',
      # project does not exist
      '[[unknowproject:Start]]' => '[[unknowproject:Start]]',
      '[[unknowproject:Start|Page title]]' => '[[unknowproject:Start|Page title]]',
    }

    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text) }
  end

  def test_html_tags
    to_test = {
      "<div>content</div>" => "<p>&lt;div&gt;content&lt;/div&gt;</p>",
      "<div class=\"bold\">content</div>" => "<p>&lt;div class=\"bold\"&gt;content&lt;/div&gt;</p>",
      "<script>some script;</script>" => "<p>&lt;script&gt;some script;&lt;/script&gt;</p>",
      # do not escape pre/code tags
      "<pre>\nline 1\nline2</pre>" => "<pre>\nline 1\nline2</pre>",
      "<pre><code>\nline 1\nline2</code></pre>" => "<pre><code>\nline 1\nline2</code></pre>",
      "<pre><div>content</div></pre>" => "<pre>&lt;div&gt;content&lt;/div&gt;</pre>",
      "HTML comment: <!-- no comments -->" => "<p>HTML comment: &lt;!-- no comments --&gt;</p>",
      "<!-- opening comment" => "<p>&lt;!-- opening comment</p>",
      # remove attributes except class
      "<pre class='foo'>some text</pre>" => "<pre class='foo'>some text</pre>",
      '<pre class="foo">some text</pre>' => '<pre class="foo">some text</pre>',
      "<pre class='foo bar'>some text</pre>" => "<pre class='foo bar'>some text</pre>",
      '<pre class="foo bar">some text</pre>' => '<pre class="foo bar">some text</pre>',
      "<pre onmouseover='alert(1)'>some text</pre>" => "<pre>some text</pre>",
      # xss
      '<pre><code class=""onmouseover="alert(1)">text</code></pre>' => '<pre><code>text</code></pre>',
      '<pre class=""onmouseover="alert(1)">text</pre>' => '<pre>text</pre>',
    }
    to_test.each { |text, result| assert_equal result, textilizable(text) }
  end

  def test_allowed_html_tags
    to_test = {
      "<pre>preformatted text</pre>" => "<pre>preformatted text</pre>",
      "<notextile>no *textile* formatting</notextile>" => "no *textile* formatting",
      "<notextile>this is <tag>a tag</tag></notextile>" => "this is &lt;tag&gt;a tag&lt;/tag&gt;"
    }
    to_test.each { |text, result| assert_equal result, textilizable(text) }
  end

  def test_pre_tags
    raw = <<-RAW
Before

<pre>
<prepared-statement-cache-size>32</prepared-statement-cache-size>
</pre>

After
RAW

    expected = <<-EXPECTED
<p>Before</p>
<pre>
&lt;prepared-statement-cache-size&gt;32&lt;/prepared-statement-cache-size&gt;
</pre>
<p>After</p>
EXPECTED

    assert_equal expected.gsub(%r{[\r\n\t]}, ''), textilizable(raw).gsub(%r{[\r\n\t]}, '')
  end

  def test_pre_content_should_not_parse_wiki_and_redmine_links
    @project.wiki.start_page = "CookBook documentation"
    @project.wiki.save!
    FactoryGirl.create :wiki_page_with_content, :wiki => @project.wiki, :title => "CookBook_documentation"

    raw = <<-RAW
[[CookBook documentation]]

##{@issue.id}

<pre>
[[CookBook documentation]]

##{@issue.id}
</pre>
RAW

    expected = <<-EXPECTED
<p><a href="/projects/#{@project.identifier}/wiki/CookBook_documentation" class="wiki-page">CookBook documentation</a></p>
<p><a href="/issues/#{@issue.id}" class="issue status-3 priority-1 created-by-me" title="#{@issue.subject} (#{@issue.status})">##{@issue.id}</a></p>
<pre>
[[CookBook documentation]]

##{@issue.id}
</pre>
EXPECTED

    assert_equal expected.gsub(%r{[\r\n\t]}, ''), textilizable(raw).gsub(%r{[\r\n\t]}, '')
  end

  def test_non_closing_pre_blocks_should_be_closed
    raw = <<-RAW
<pre><code>
RAW

    expected = <<-EXPECTED
<pre><code>
</code></pre>
EXPECTED

    assert_equal expected.gsub(%r{[\r\n\t]}, ''), textilizable(raw).gsub(%r{[\r\n\t]}, '')
  end

  def test_syntax_highlight
    raw = <<-RAW
<pre><code class="ruby">
# Some ruby code here
</code></pre>
RAW

    expected = <<-EXPECTED
<pre><code class="ruby syntaxhl"><span class=\"CodeRay\"><span class="line-numbers"><a href=\"#n1\" name=\"n1\">1</a></span><span class="comment"># Some ruby code here</span></span>
</code></pre>
EXPECTED

    assert_equal expected.gsub(%r{[\r\n\t]}, ''), textilizable(raw).gsub(%r{[\r\n\t]}, '')
  end

  def test_wiki_links_in_tables
    @project.wiki.start_page = "Page"
    @project.wiki.save!
    FactoryGirl.create :wiki_page_with_content, :wiki => @project.wiki, :title => "Other page"
    FactoryGirl.create :wiki_page_with_content, :wiki => @project.wiki, :title => "Last page"

    to_test = {"|[[Page|Link title]]|[[Other Page|Other title]]|\n|Cell 21|[[Last page]]|" =>
                 "<tr><td><a href=\"/projects/#{@project.identifier}/wiki/Page\" class=\"wiki-page new\">Link title</a></td>" +
                 "<td><a href=\"/projects/#{@project.identifier}/wiki/Other_Page\" class=\"wiki-page\">Other title</a></td>" +
                 "</tr><tr><td>Cell 21</td><td><a href=\"/projects/#{@project.identifier}/wiki/Last_page\" class=\"wiki-page\">Last page</a></td></tr>"
    }

    to_test.each { |text, result| assert_equal "<table>#{result}</table>", textilizable(text).gsub(/[\t\n]/, '') }
  end

  def test_text_formatting
    to_test = {'*_+bold, italic and underline+_*' => '<strong><em><ins>bold, italic and underline</ins></em></strong>',
               '(_text within parentheses_)' => '(<em>text within parentheses</em>)',
               'a *Humane Web* Text Generator' => 'a <strong>Humane Web</strong> Text Generator',
               'a H *umane* W *eb* T *ext* G *enerator*' => 'a H <strong>umane</strong> W <strong>eb</strong> T <strong>ext</strong> G <strong>enerator</strong>',
               'a *H* umane *W* eb *T* ext *G* enerator' => 'a <strong>H</strong> umane <strong>W</strong> eb <strong>T</strong> ext <strong>G</strong> enerator',
              }
    to_test.each { |text, result| assert_equal "<p>#{result}</p>", textilizable(text) }
  end

  def test_wiki_horizontal_rule
    assert_equal '<hr />', textilizable('---')
    assert_equal '<p>Dashes: ---</p>', textilizable('Dashes: ---')
  end

  def test_footnotes
    raw = <<-RAW
This is some text[1].

fn1. This is the foot note
RAW

    expected = <<-EXPECTED
<p>This is some text<sup><a href=\"#fn1\">1</a></sup>.</p>
<p id="fn1" class="footnote"><sup>1</sup> This is the foot note</p>
EXPECTED

    assert_equal expected.gsub(%r{[\r\n\t]}, ''), textilizable(raw).gsub(%r{[\r\n\t]}, '')
  end

  def test_headings
    raw = 'h1. Some heading'
    expected = %|<a name="Some-heading"></a>\n<h1 >Some heading<a href="#Some-heading" class="wiki-anchor">&para;</a></h1>|

    assert_equal expected, textilizable(raw)
  end

  def test_table_of_content
    @project.wiki.start_page = "Wiki"
    @project.wiki.save!
    FactoryGirl.create :wiki_page_with_content, :wiki => @project.wiki, :title => "Wiki"
    FactoryGirl.create :wiki_page_with_content, :wiki => @project.wiki, :title => "another Wiki"

    raw = <<-RAW
{{toc}}

h1. Title

Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Maecenas sed libero.

h2. Subtitle with a [[Wiki]] link

Nullam commodo metus accumsan nulla. Curabitur lobortis dui id dolor.

h2. Subtitle with [[Wiki|another Wiki]] link

h2. Subtitle with %{color:red}red text%

<pre>
some code
</pre>

h3. Subtitle with *some* _modifiers_

h1. Another title

h3. An "Internet link":http://www.redmine.org/ inside subtitle

h2. "Project Name !/attachments/#{@attachment.id}/#{@attachment.filename}!":/projects/#{@project.identifier}/issues

RAW

    expected =  '<ul class="toc">' +
                  '<li><a href="#Title">Title</a>' +
                    '<ul>' +
                      '<li><a href="#Subtitle-with-a-Wiki-link">Subtitle with a Wiki link</a></li>' +
                      '<li><a href="#Subtitle-with-another-Wiki-link">Subtitle with another Wiki link</a></li>' +
                      '<li><a href="#Subtitle-with-red-text">Subtitle with red text</a>' +
                        '<ul>' +
                          '<li><a href="#Subtitle-with-some-modifiers">Subtitle with some modifiers</a></li>' +
                        '</ul>' +
                      '</li>' +
                    '</ul>' +
                  '</li>' +
                  '<li><a href="#Another-title">Another title</a>' +
                    '<ul>' +
                      '<li>' +
                        '<ul>' +
                          '<li><a href="#An-Internet-link-inside-subtitle">An Internet link inside subtitle</a></li>' +
                        '</ul>' +
                      '</li>' +
                      '<li><a href="#Project-Name">Project Name</a></li>' +
                    '</ul>' +
                  '</li>' +
               '</ul>'

    assert textilizable(raw).gsub("\n", "").include?(expected), textilizable(raw)
  end

  def test_table_of_content_should_contain_included_page_headings
    @project.wiki.start_page = "Wiki"
    @project.save!
    page  = FactoryGirl.create :wiki_page_with_content, :wiki => @project.wiki, :title => "Wiki"
    child = FactoryGirl.create :wiki_page, :wiki => @project.wiki, :title => "Child_1", :parent => page
    child.content = FactoryGirl.create :wiki_content, :page => child, :text => "h1. Child page 1\n\nThis is a child page"
    child.save!

    raw = <<-RAW
{{toc}}

h1. Included

{{include(Child_1)}}
RAW

    expected = '<ul class="toc">' +
               '<li><a href="#Included">Included</a></li>' +
               '<li><a href="#Child-page-1">Child page 1</a></li>' +
               '</ul>'

    assert textilizable(raw).gsub("\n", "").include?(expected), textilizable(raw)
  end

  def test_default_formatter
    Setting.text_formatting = 'unknown'
    text = 'a *link*: http://www.example.net/'
    assert_equal '<p>a *link*: <a href="http://www.example.net/">http://www.example.net/</a></p>', textilizable(text)
    Setting.text_formatting = 'textile'
  end

  def test_due_date_distance_in_words
    to_test = { Date.today => 'Due in 0 days',
                Date.today + 1 => 'Due in 1 day',
                Date.today + 100 => 'Due in about 3 months',
                Date.today + 20000 => 'Due in over 54 years',
                Date.today - 1 => '1 day late',
                Date.today - 100 => 'about 3 months late',
                Date.today - 20000 => 'over 54 years late',
               }
    ::I18n.locale = :en
    to_test.each do |date, expected|
      assert_equal expected, due_date_distance_in_words(date)
    end
  end

  def test_avatar
    # turn on avatars
    Setting.gravatar_enabled = '1'
    mail = @admin.mail
    assert avatar(@admin).include?(Digest::MD5.hexdigest(mail))
    assert avatar("admin <#{mail}>").include?(Digest::MD5.hexdigest(mail))
    assert_nil avatar('admin')
    assert_nil avatar(nil)

    # turn off avatars
    Setting.gravatar_enabled = '0'
    assert_equal '', avatar(@admin)
  end

  def test_link_to_user
    t = link_to_user(@admin)
    assert_equal "<a href=\"/users/#{ @admin.id }\">#{ @admin.name }</a>", t
  end

  def test_link_to_user_should_not_link_to_locked_user
    user = FactoryGirl.build :user
    user.lock!
    assert user.locked?
    t = link_to_user(user)
    assert_equal user.name, t
  end

  def test_link_to_user_should_not_link_to_anonymous
    user = User.anonymous
    assert user.anonymous?
    t = link_to_user(user)
    assert_equal ::I18n.t(:label_user_anonymous), t
  end

  def test_link_to_project
    p_id = @project.identifier
    p_name = @project.name
    assert_equal %(<a href="/projects/#{p_id}">#{p_name}</a>),
                 link_to_project(@project)
    assert_equal %(<a href="/projects/#{p_id}/settings">#{p_name}</a>),
                 link_to_project(@project, :action => 'settings')
    assert_equal %(<a href="/projects/#{p_id}/settings/members">#{p_name}</a>),
                 link_to_project(@project, :action => 'settings', :tab => 'members')
    assert_equal %(<a href="http://test.host/projects/#{p_id}?jump=blah">#{p_name}</a>),
                 link_to_project(@project, {:only_path => false, :jump => 'blah'})
    assert_equal %(<a href="/projects/#{p_id}/settings" class="project">#{p_name}</a>),
                 link_to_project(@project, {:action => 'settings'}, :class => "project")
  end
end
