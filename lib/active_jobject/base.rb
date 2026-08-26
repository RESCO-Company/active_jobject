class ActiveJobject::Base
  include ActiveJobject::Request

  class << self
    attr_accessor :_site

    def site
      _site
    end

    def site=(site)
      self._site = site
    end
  end

  def uri
    self.class._site.is_a?(URI) ? self.class._site : URI(self.class._site)
  end
end
