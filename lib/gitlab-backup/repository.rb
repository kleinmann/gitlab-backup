equire "fileutils"
require "cgi"

module Gitlab
  module Backup
    # The repository to back up.
    #
    class Repository
      # @return [Hash]
      #     the hash of repository data from the Gitlab API.
      #
      attr_reader :repo

      # @return [String]
      #     the private token for the user with which to backup the repository with.
      #
      attr_reader :token

      # @return [String]
      #     the absolute path of the directory to backup the repository to.
      #
      attr_reader :backup_root

      # Creates a new repository.
      #
      # @param [Hash] repo
      #     the hash of repository data from the Gitlab API.
      #
      # @param [String] token
      #     the private token for the user with which to backup the repository with.
      #
      # @param [String] backup_root
      #     the absolute path of the directory to backup the repository to.
      #
      def initialize(repo, token, backup_root)
        @repo        = repo
        @token       = token
        @backup_root = backup_root
      end

      # Performs a backup of the repository.
      #
      def backup
        puts "Backing up: #{repo["slug"]}."

        unless Gitlab::Backup.have_git?
          puts "Warning: git not found on PATH. Skipping..."

          return
        end

        backup_src
        backup_wiki
      end

      private
      # Backs up the repository's source code.
      #
      def backup_src
        clone_or_update(:type => :src)
      end

      # Backs up the repository's wiki if the wiki exists.
      #
      def backup_wiki
        clone_or_update(:type => :wiki) if repo["has_wiki"]
      end

      # Performs a full backup of the repository's source code
      # or wiki if the directory to which the backup would occur does not
      # exist. Performs an incremental update (pull) otherwise.
      #
      # @param [Hash] options
      # @option options [Symbol] :type the type of repository to backup.
      #     Either :src or :wiki.
      #
      def clone_or_update(options)
        path = dir_for_repo(options)
        uri  = uri_for_repo(options)

        if File.exist?(path)
          run_incremental_backup(path, uri)
        else
          run_full_backup(uri, path)
        end
      end

      # Checks whether the specified path is a repository or not.
      #
      # @param [String] path
      #     the path to check.
      #
      # @return [Boolean]
      #     true if the path is the same type of repository
      #     that we got from the Gitlab API, false otherwise.
      def repo?(path)
        FileUtils.cd(path)

        system "git status -s"

        return $? == 0
      end

      def run_incremental_backup(path, uri)
        return unless repo?(path)

        FileUtils.cd(path)

        system("git", "pull", uri)
      end

      def run_full_backup(uri, dest)
        system("git", "clone", uri, dest)
      end

      def dir_for_repo(options)
        if options.nil? || options[:type].nil?
          raise RuntimeError
        end

        path = nil

        case options[:type]
        when :src
          path = File.expand_path("#{backup_root}/#{repo["owner"]}/#{repo["slug"]}/src")
        when :wiki
          path = File.expand_path("#{backup_root}/#{repo["owner"]}/#{repo["slug"]}/wiki")
        end

        return path
      end

      def uri_for_repo(options)
        base_uri = nil
        uri      = nil
        ext      = ".git"

        if repo["is_private"]
          base_uri = "https://#{username}:#{CGI.escape(password)}@bitbucket.org/#{repo["owner"]}/#{repo["slug"]}#{ext}"
        else
          base_uri = "https://bitbucket.org/#{repo["owner"]}/#{repo["slug"]}#{ext}"
        end

        case options[:type]
        when :src
          uri = base_uri
        when :wiki
          uri = "#{base_uri}/wiki"
        end

        return uri
      end
    end
  end
end
