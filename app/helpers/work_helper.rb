module WorkHelper
    def render_mod(mod = nil)
        return unless mod
        case mod.type
        when 'Emendation', 'Revision'
            render :partial => "shared/#{mod.type.downcase}", :locals => { :mod => mod }
        when 'Division'
            render :partial => "shared/#{mod.subtype}_division", :locals => { :mod => mod }
        when 'Alternate'
            render :partial => "shared/#{mod.subtype}", :locals => { :mod => mod }
        end
    end

    def render_line(line)
        output = ''
        line.chars.each_with_index do |char, i|
            line.mods_at(i).each do |mod|
                output += render_mod(mod)
            end
            output += char
        end
        line.mods_at(line.chars.count).each do |mod|
            output += render_mod(mod)
        end
        output
    end

    def render_work_result_link(  work )
      raw( "<span class='work-number'>#{work.number} #{work.variant}</span><span class='work-title'>#{work.title}</span>" )
    end
end
