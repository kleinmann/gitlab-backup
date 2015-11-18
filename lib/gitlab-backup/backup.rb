require "net/https"
require "json"
require "pp"

module Gitlab
  module Backup
    # Begins the backup process.
    #
    # @param [String] host
    #     the host (and maybe port) of the GitLab instance to backup from.
    #
    # @param [String] token
    #     the private token of the user to backup repositories for.
    #
    # @param [String] backup_root
    #     the absolute or relative path of the directory to backup the repositories to.
    def self.backup(host, token, backup_root)
      backup_root = File.expand_path(backup_root)

      puts
      puts "Backing up repositories to #{backup_root}"
      puts

      repos = get_repo_list(host, token)

      repos.each do |repo|
        Gitlab::Backup::Repository.new(repo, token, backup_root).backup
      end
    end

    # Checks if the specified SCM tool exists on the PATH
    # and is executable.
    #
    # @return [Boolean]
    #     true if the SCM tool exists and is executable, false otherwise.
    def self.have_git?
      # From: http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
      exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]

      ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          bin = "#{path}/git#{ext}"

          return bin if File.executable?(bin)
        end
      end

      return nil
    end

    private
    # Gets a list of the repositories the user has access to.
    #
    # @param [String] host
    #     the host (and maybe port) of the GitLab instance to backup from.
    #
    # @param [String] token
    #     the private token of the user to get repositories for.
    #
    # @return [Array<String>]
    #     the repositories the user has access to.
    #
    def self.get_repo_list(host, token)
      uri = URI.parse("#{host}/api/v3/projects")

      http = Net::HTTP.new(uri.host, uri.port)

      if host =~ /\Ahttps/
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field("PRIVATE-TOKEN", token)

      response = http.request(request)

      if response.code == "401"
        puts "Invalid token."
        exit
      end

      JSON.parse(response.body)
    end
  end
end
