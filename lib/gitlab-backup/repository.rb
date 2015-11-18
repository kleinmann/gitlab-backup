require "fileutils"
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
        puts "Backing up: #{repo["name"]}."

        unless Gitlab::Backup.have_git?
          puts "Warning: git not found on PATH. Skipping..."

          return
        end

        clone_or_update
      end

      private
      # Performs a full backup of the repository's source code
      # or wiki if the directory to which the backup would occur does not
      # exist. Performs an incremental update (pull) otherwise.
      #
      def clone_or_update
        path = dir_for_repo
        uri  = repo["ssh_url_to_repo"]

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
        system("git", "clone", "--recursive", uri, dest)
      end

      def dir_for_repo
        File.expand_path("#{backup_root}/#{repo["namespace"]["path"]}/#{repo["path"]}/src")
      end
    end
  end
end
