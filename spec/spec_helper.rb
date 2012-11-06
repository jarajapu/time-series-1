require 'spec'
require 'time_series/ascii'
require 'fixture_dependencies'
require 'fixture_dependencies/rspec/sequel'

#Connect to local db
dao_report = OPower::DaoCore::ReportDao.new :db_tier => 'local-test'
OPower::DaoCore::ReportDao.setup_models(dao_report.db)

#Set path for fixture files
FixtureDependencies.fixture_path = 'spec/fixtures'

#Debug logging
#FixtureDependencies.verbose = 3