module ApplicationHelper
  def body_class( params )
    controller_name = params[:controller].clone
    if controller_name.index '_'
      controller_name[ '_' ] = '-'
    end
    "#{controller_name} #{params[:action]}"
  end

  def link_selected?(link_key)
      link_condition_map = {
          :home_link => ( params[ :action ] == 'home' ),
          :manuscript_link => ( params[ :controller ] == 'works' && params[ :action ] == 'index' ),
          :lexicon_link => ( params[:controller] == 'words' ),
          :about_link => ( params[ :action ] == 'about' || params[ :action ] == 'faq' || params[ :action ] == 'team' || params[ :action ] == 'terms' || params[ :action ] == 'privacy' || params[ :action ] == 'contact' )
      }
      if link_condition_map.include?(link_key)
          return link_condition_map[link_key]
      else
          return false
      end
  end
end
