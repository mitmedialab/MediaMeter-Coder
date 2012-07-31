#
# Backup
# Generated Template
#
# For more information:
#
# View the Git repository at https://github.com/meskyanichi/backup
# View the Wiki/Documentation at https://github.com/meskyanichi/backup/wiki
# View the issue log at https://github.com/meskyanichi/backup/issues
#
# When you're finished configuring this configuration file,
# you can run it from the command line by issuing the following command:
#
# $ backup -t my_backup [-c <path_to_configuration_file>]

database_yml = File.expand_path('../../config/database.yml',  __FILE__)
RAILS_ENV    = ENV['RAILS_ENV'] || 'development'

require 'yaml'
config = YAML.load_file(database_yml)


Backup::Model.new(:db_backup, 'Database Backup') do

  database MySQL do |db|
    db.name               = config[RAILS_ENV]["database"]
    db.username           = config[RAILS_ENV]["username"]
    db.password           = config[RAILS_ENV]["password"]
    db.host               = config[RAILS_ENV]["host"]
    db.port               = config[RAILS_ENV]["port"]
    db.skip_tables        = []
  end

  store_with Local do |local|
    local.path = 'tmp/'
    local.keep = 10
  end

#  store_with S3 do |s3|
#    s3.access_key_id      = '<key>'
#    s3.secret_access_key  = '<secret>'
#    s3.region             = 'us-east-1'
#    s3.bucket             = 'media-meter-mst'
#    s3.path               = config[RAILS_ENV]["database"]
#    s3.keep               = 10
#  end

  compress_with Gzip do |compression|
    compression.level = 8
  end

end