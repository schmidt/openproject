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

module Redmine
  module Themes
    describe DefaultTheme do
      let(:theme) { DefaultTheme.instance }

      describe '#stylesheet_manifest' do
        it 'it is default with a css extension' do
          expect(theme.stylesheet_manifest).to eq 'default.css'
        end
      end

      describe '#assets_prefix' do
        it 'is empty' do
          expect(theme.assets_prefix).to be_empty
        end
      end

      describe '#assets_path' do
        it "should be the assets path of the rails app" do
          rails_root = File.expand_path('../../../../..', __FILE__)
          expect(theme.assets_path).to eq File.join(rails_root, 'app/assets')
        end
      end

      describe '#overridden_images' do
        it 'is empty' do
          expect(theme.overridden_images).to be_empty
        end
      end

      describe '#path_to_image' do
        before do
          # set a list of overridden images, which default theme should ignore
          theme.stub(:overridden_images).and_return(['add.png'])
        end

        it "doesn't prepend the theme path for the default theme" do
          expect(theme.path_to_image('add.png')).to eq 'add.png'
        end

        it "doesn't prepend the theme path if the file is not overridden" do
          expect(theme.path_to_image('missing.png')).to eq 'missing.png'
        end

        it "doesn't change anything if the path is absolute" do
          expect(theme.path_to_image('/add.png')).to eq '/add.png'
        end

        it "doesn't change anything if the source is a url" do
          expect(theme.path_to_image('http://some_host/add.png')).to eq 'http://some_host/add.png'
        end
      end

      describe '#overridden_images_path' do
        it 'should be nil' do
          expect(theme.overridden_images_path).to be_nil
        end
      end

      describe '#image_overridden?' do
        before do
          # set the dir of this file as the images folder
          # default theme should ignore all files in it
          theme.stub(:overridden_images_path).and_return(File.dirname(__FILE__))
        end

        it 'is false' do
          expect(theme.image_overridden?('theme_spec.rb')).to be_false
        end
      end

      describe '#default?' do
        it "returns true" do
          expect(DefaultTheme.instance).to be_default
        end
      end
    end

    describe ViewHelpers do
      let(:theme)   { DefaultTheme.instance }
      let(:helpers) { ApplicationController.helpers }

      before do
        # set a list of overridden images
        theme.stub(:overridden_images).and_return(['add.png'])

        # set the theme as current
        helpers.stub(:current_theme).and_return(theme)
      end

      it 'overridden images are on root level' do
        expect(helpers.image_tag('add.png')).to include 'src="/assets/add.png"'
      end

      it 'not overridden images are on root level' do
        expect(helpers.image_tag('missing.png')).to include 'src="/assets/missing.png"'
      end

      it 'overridden favicon is on root level' do
        expect(helpers.favicon_link_tag('add.png')).to include 'href="/assets/add.png"'
      end

      it 'not overridden favicon is on root level' do
        expect(helpers.favicon_link_tag('missing.png')).to include 'href="/assets/missing.png"'
      end
    end
  end
end
