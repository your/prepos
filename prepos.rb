ENV['OCTOKIT_SILENT'] = 'true' # API reviews are still "preview" as of 05-21-17.
require 'octokit'
require 'optparse'
require 'json'
require 'pry'

#
# prepos \
#   --gh-token TOKEN \
#   --gh-owner author \
#   --gh-repos repo1,repo2,repo3
#
# {
#   "prs": [
#     {
#       "repo": "author/repo1",
#       "number": 1,
#       "title": "Test PR",
#       "body": "Nothing special.\n",
#       "approved": false,
#       "mergeable": true
#     },
#     {
#       "repo": "author/repo3",
#       "number": 1,
#       "title": "Added specs",
#       "body": null,
#       "approved": false,
#       "mergeable": true
#     }
#   ]
# }
#
# OR
#
# {
#   "error": "error description"
# }
#
module PRepos
  MIN_APPROVALS = 2
  SKIP_LABELS = %w(wip).freeze

  # Provide aggregated data from a PR:
  #
  # {
  #   "repo": "author/repo1",
  #   "number": 1,
  #   "title": "Test PR",
  #   "body": "Nothing special.\n",
  #   "approved": false,
  #   "mergeable": true
  # }
  #
  class PRdata
    attr_reader :number, :title, :body, :approved, :mergeable

    def initialize(github, issue, repo)
      @github = github
      @repo = repo
      @number, @title, @body = issue.to_hash.fetch_values(
        :number,
        :title,
        :body
      )
      @approved = approved?
      @mergeable = mergeable?
    end

    def self.from(github, issue, repo)
      new(github, issue, repo).info
    end

    def info
      {
        repo: repo,
        number: number,
        title: title,
        body: body,
        approved: approved,
        mergeable: mergeable
      }
    end

    private

    attr_reader :github, :repo, :error

    def reviews
      @_reviews ||= github.pull_request_reviews(repo, number)
    end

    def pull
      @_pull ||= github.pull(repo, number)
    end

    def approved?
      states_with_count = states_with_count_from_reviews(reviews)

      states_with_count.fetch('CHANGES_REQUESTED', 0).zero? &&
        states_with_count.fetch('APPROVED', 0) >= MIN_APPROVALS
    end

    def mergeable?
      # "The value of the mergeable attribute can be true, false, or null.
      # If the value is null, this means that the mergeability hasn't been
      # computed yet, and a background job was started to compute it."
      # (from Github API doc)
      pull[:mergeable] || false
    end

    def states_with_count_from_reviews(reviews)
      # i.e. {"CHANGES_REQUESTED"=>1, "COMMENTED"=>1}
      reviews
        .map { |review| [review[:user][:id], review[:state]] }
        .reverse.uniq(&:first).map(&:last) # do care about the last state only.
        .each_with_object(Hash.new(0)) { |state, counts| counts[state] += 1 }
    end
  end

  options = {}
  optparse = OptionParser.new do |opts|
    opts.banner = 'Usage: prepos.rb [options]'

    opts.on('-t', '--gh-token TOKEN', 'Set Github token') do |c|
      options[:token] = c
    end

    opts.on('-a', '--gh-author AUTHOR', 'Set Github author') do |c|
      options[:author] = c
    end

    opts.on(
      '-r',
      '--gh-repos COMMA,SEPARATED,REPOS',
      'Set Github author\'s repos'
    ) do |c|
      options[:repos] = c
    end

    opts.on('-p', '--prettify', 'Prettify JSON output (console only)') do |c|
      options[:prettify] = c
    end

    opts.on('-h', '--help', 'Print this help') do |c|
      options[:help] = c
    end
  end

  optparse.parse!

  if options[:help]
    puts optparse
    exit 0
  end

  token = options[:token]
  author = options[:author]
  repos = options[:repos].split(',') if options[:repos]

  if token.nil? || author.nil? || !repos.to_a.any?
    raise OptionParser::MissingArgument
  end

  github = Octokit::Client.new(access_token: token)
  Octokit.auto_paginate = true # TODO?: handle rate limiting and throttling.

  hash = {
    prs: repos.flat_map do |repo|
      repo = "#{author}/#{repo}"
      github.issues(repo).map do |issue|
        if issue[:pull_request] && # Not all issues are PRs.
           (issue[:labels].map(&:name) & SKIP_LABELS).empty?
          PRdata.from(github, issue, repo)
        end
      end.compact
    end.reject(&:empty?)
  }

rescue OptionParser::MissingArgument
  hash = { error: 'Invalid argument(s), please use prepos --help.' }
rescue Faraday::ClientError, Octokit::ClientError => e
  hash = { error: e.message }
ensure
  unless options[:help]
    puts(
      if options[:prettify]
        JSON.pretty_generate(hash)
      else
        hash.to_json
      end
    )
  end
end

# 011101000110100100100000011000010101101011011110010000001110100
