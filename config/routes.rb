Chiliproject::Application.routes.draw do
  match '' => 'welcome#index', :as => :home
  match 'login' => 'account#login', :as => :signin
  match 'logout' => 'account#logout', :as => :signout
  match 'roles/workflow/:id/:role_id/:tracker_id' => 'roles#workflow'
  match 'help/:ctrl/:page' => 'help#index'
  match 'actionreportconditionsmethodgetcontrollertime_entry_reports' => '#index', :as => :with_options
  resources :time_entries
  match 'projects/:id/wiki' => 'wikis#edit', :via => post
  match 'projects/:id/wiki/destroy' => 'wikis#destroy', :via => get
  match 'projects/:id/wiki/destroy' => 'wikis#destroy', :via => post
  match 'controllermessages' => '#index', :as => :with_options
  match 'controllerboards' => '#index', :as => :with_options
  match 'controllerdocuments' => '#index', :as => :with_options
  resources :issue_moves
  match '/issues/auto_complete' => 'auto_completes#issues', :as => :auto_complete_issues
  match '/issues/preview/:id' => 'previews#issue', :as => :preview_issue
  match '/issues/context_menu' => 'context_menus#issues', :as => :issues_context_menu
  match '/issues/changes' => 'journals#index', :as => :issue_changes
  match 'issues/bulk_edit' => 'issues#bulk_edit', :as => :bulk_edit_issue, :via => get
  match 'issues/bulk_edit' => 'issues#bulk_update', :as => :bulk_update_issue, :via => post
  match '/issues/:id/quoted' => 'journals#new', :as => :quoted_issue, :via => post, :id => /\d+/
  match '/issues/:id/destroy' => 'issues#destroy', :via => post
  resource :gantt
  resource :gantt
  resource :calendar
  resource :calendar
  match 'conditionsmethodgetcontrollerreports' => '#index', :as => :with_options
  match '/issues' => 'issues#index', :via => post
  match '/issues/create' => 'issues#index', :via => post
  resources :issues do
  
  
      resources :time_entries
  end

  resources :issues do
  
  
      resources :time_entries
  end

  match 'conditionsmethodpostcontrollerissue_relations' => '#index', :as => :with_options
  match 'projects/:id/members/new' => 'members#new'
  match 'controllerusers' => '#index', :as => :with_options
  resources :users do
  
    member do
  post :edit_membership
  post :destroy_membership
  end
  
  end

  match 'projects/:project_id/roadmap' => 'versions#index'
  match 'news' => 'news#index', :as => :all_news
  match 'news.:format' => 'news#index', :as => :formatted_all_news
  match '/news/preview' => 'previews#news', :as => :preview_news
  match 'news/:id/comments' => 'comments#create', :via => post
  match 'news/:id/comments/:comment_id' => 'comments#destroy', :via => delete
  resources :projects do
  
  
      resource :project_enumerations
    resources :files
    resources :versions do
        collection do
    put :close_completed
    end
        member do
    post :status_by
    end
    
    end

    resources :news
    resources :time_entries
    match 'wiki' => 'wiki#show', :as => :wiki_start_page, :via => get
    match 'wiki/index' => 'wiki#index', :as => :wiki_index, :via => get
    match 'wiki/:id/diff/:version' => 'wiki#diff', :as => :wiki_diff, :version => 
    match 'wiki/:id/diff/:version/vs/:version_from' => 'wiki#diff', :as => :wiki_diff
    match 'wiki/:id/annotate/:version' => 'wiki#annotate', :as => :wiki_annotate
    resources :wiki do
        collection do
    get :date_index
    get :export
    end
        member do
    get :history
    any :preview
    getpost :rename
    post :protect
    post :add_attachment
    end
    
    end
  end

  match 'projects/:id/destroy' => 'projects#destroy', :as => :project_destroy_confirm, :via => get
  match 'controllerprojects' => '#index', :as => :with_options
  match 'actionindexconditionsmethodgetcontrolleractivities' => '#index', :as => :with_options
  match 'controllerissue_categories' => '#index', :as => :with_options
  match 'controllerrepositories' => '#index', :as => :with_options
  match 'attachments/:id' => 'attachments#show', :id => /\d+/
  match 'attachments/:id/:filename' => 'attachments#show', :filename => /.*/, :id => /\d+/
  match 'attachments/download/:id/:filename' => 'attachments#download', :filename => /.*/, :id => /\d+/
  resources :groups
  match 'projects/:project_id/issues/:action' => 'issues#index'
  match 'projects/:project_id/documents/:action' => 'documents#index'
  match 'projects/:project_id/boards/:action/:id' => 'boards#index'
  match 'boards/:board_id/topics/:action/:id' => 'messages#index'
  match 'wiki/:id/:page/:action' => 'wiki#index', :page => 
  match 'issues/:issue_id/relations/:action/:id' => 'issue_relations#index'
  match 'projects/:project_id/news/:action' => 'news#index'
  match 'projects/:project_id/timelog/:action/:id' => 'timelog#index', :project_id => /.+/
  match 'controllerrepositories' => '#index', :as => :with_options
  match 'controllersys' => '#index', :as => :with_options
  match '/:controller(/:action(/:id))'
  match 'robots.txt' => 'welcome#robots'
  match '/' => 'account#login'
end
