class String

  def remove_tag(tag)
    tag = tag.strip

    self_array = self.split('~').map{|s| s.strip}

    if self_array.include? tag
      # return self.gsub(tag, '').gsub(/~\s*~/, '~').gsub(/(\A\s*~\s*|\s*~\s*\z)/, '')
      new_array = self_array - [tag]
      return new_array.join('~')
    end

    self
  end

  def add_tag(tag)
    new_string = self.strip

    old_tag_remote = tag.split('}{').first
    if new_string.length == 0
      new_string = tag
    else
      new_array = new_string.split('~').map{|s| s.strip}

      # puts old_tag_remote
      # puts self
      new_array = new_array.map { |s| if s.include? "#{old_tag_remote}}{" then "" else s end }
      new_array = new_array - [""]

      new_array << '~ ' << tag unless new_array.include? tag.strip
      new_array.uniq!

      if tag.include? "}{"
        old_tag_version = tag.split('}{').first.strip
        new_array = new_array - [old_tag_version]
      end

      new_string = new_array.join('~')
    end

    new_string
  end

end