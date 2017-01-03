require 'octokit'
require './services/logger'

class GithubUser
  class NotFound < StandardError; end
  class TooManyRequests < StandardError; end
  class InvalidParams < StandardError; end

  def initialize(username)
    raise InvalidParams, "Username can't be blank." if username.nil? || username == ""
    @user = fetch_user(username)
  end

  def favourite_languages
    @favourite_languages ||= find_favourite_languages
  end

  def username
    @user.login
  end

  private

  def build_repos(uri)
    if @repos_collection.nil?
      @repos_collection = uri.get.data
    else
      @repos_collection.concat uri.get.data
    end

    if uri.get.rels[:next]
      build_repos(uri.get.rels[:next])
    end

    @repos_collection
  end

  def fetch_user(username)
    begin
      Octokit.user(username).tap do
        FavLangLogger.log(:info, "Fetched #{username} from api.github.com")
      end
    rescue Octokit::NotFound => e
      raise NotFound, e
    rescue Octokit::TooManyRequests
      raise TooManyRequests, "Oops! The Github API limit has been reached. Please try again in an hour :)"
    end
  end

  def find_favourite_languages
    language_counts = languages_with_counts
    return [] if language_counts.empty?

    highest_count = language_counts.first.last
    top_langs = language_counts.select { |_, v| v == highest_count }
    top_langs.keys
  end

  def languages
    FavLangLogger.log(:info, "Calculating favourite language based on #{repos.count} public repos.")
    repos.map { |repo| repo.language }.compact
  end

  def languages_with_counts
    lang_counts = languages.inject(Hash.new(0)) do |count, language|
      count[language] += 1
      count
    end

    lang_counts.sort_by { |_, count| count }.reverse.to_h
  end

  def repos
    @repos ||= build_repos(@user.rels[:repos])
  end
end
