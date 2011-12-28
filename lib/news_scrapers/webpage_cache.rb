require 'rubygems'
require 'digest/md5'

module NewsScrapers

  # Simple file-based caching of webpage contents, key_fored by the url
  class WebpageCache
  
    def initialize(dir)
      @base_dir = dir
      Dir.mkdir @base_dir unless File.directory? @base_dir
    end
    
    def put url, page_contents, overwrite=true
      return if (!overwrite && exists?(url) )
      File.open(path_for(url), 'w') {|f| f.write(page_contents) }
    end
    
    def get url
      return nil if !exists?(url)
      IO.read(path_for(url))
    end
    
    def exists? url
      File.exists? path_for(url)
    end
      
    def path_for url
      File.join(@base_dir,key_for(url))
    end
  
    def key_for url
      Digest::MD5.hexdigest(url)
    end
      
  end

end