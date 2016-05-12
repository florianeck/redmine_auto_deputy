module RedmineAutoDeputy
end

lib_path = File.expand_path("../redmine_auto_deputy/*.rb", __FILE__)
Dir.glob(lib_path).each {|p| require p }