//-- copyright
// OpenProject is a project management system.
//
// Copyright (C) 2012-2013 the OpenProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

/*
  The action menu is a menu that usually belongs to an OpenProject entity (like an Issue, WikiPage, Meeting, ..).
  Most likely it looks like this:
    <ul class="action_menu_main">
      <li><a>Menu item text</a></li>
      <li><a>Menu item text</a></li>
      <li class="drop-down">
        <a class="icon icon-more" href="javascript:">More functions</a>
        <ul style="display:none;" class="action_menu_more">
          <li><a>Menu item text</a></li>
        </ul>
      </li>
    </ul>
  The following code is responsible to open and close the "more functions" submenu.
*/

jQuery(function ($) {
  var animationSpeed = 100; // ms

  function menu_top_position(menu) {
    // if an h2 tag follows the submenu should unfold out at the border
    var menu_start_position;
    if (menu.next().get(0) != undefined && (menu.next().get(0).tagName == 'H2')){
      menu_start_position = menu.next().innerHeight() + menu.next().position().top;
    }
    else if(menu.next().hasClass("wiki-content") && menu.next().children().next().first().get(0) != undefined && menu.next().children().next().first().get(0).tagName == 'H1'){
      var wiki_heading = menu.next().children().next().first();
      menu_start_position = wiki_heading.innerHeight() + wiki_heading.position().top;
    }
    return menu_start_position;
  };

  function close_menu(event) {
    var menu = $(event.data.menu);
    // do not close the menu, if the user accidentally clicked next to a menu item (but still within the menu)
    if ( event.target !== menu.find(" > li.drop-down.open > ul").get(0)) {
      menu.find(" > li.drop-down.open").removeClass("open").find("> ul").slideUp(animationSpeed);
      // no need to watch for clicks, when the menu is already closed
      $('html').off('click', close_menu);
    };
  };

  function open_menu(menu) {
    var drop_down = menu.find(" > li.drop-down")
    // do not open a menu, which is already open
    if ( !drop_down.hasClass('open') ) {
      drop_down.find('> ul').slideDown(animationSpeed, function(){
        drop_down.find('li > a:first').focus();
        // when clicking on something, which is not the menu, close the menu
        $('html').on('click', {menu: menu.get(0)}, close_menu);
      });
      drop_down.addClass('open');
    };
  };

  // open the given submenu when clicking on it
  function install_menu_logic(menu) {
    menu.find(" > li.drop-down").click(function(event) {
      $(this).find("ul.action_menu_more").css({ top: menu_top_position(menu) });
      open_menu(menu);
    });
  };

  $('.action_menu_main').each(function(idx, menu){
    install_menu_logic($(menu));
  });
});
