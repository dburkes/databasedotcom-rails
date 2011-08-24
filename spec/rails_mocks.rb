class ApplicationController
end

module Rails
  def self.root
    File.dirname(__FILE__)
  end
end