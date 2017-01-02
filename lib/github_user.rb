require 'octokit'

class GithubUser
  def initialize(username)
    @user = Octokit.user username
  end

  def favourite_languages
    @favourite_languages ||= find_favourite_languages
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

  def find_favourite_languages
    language_counts = languages_with_counts
    return [] if language_counts.empty?

    highest_count = language_counts.first.last
    top_langs = language_counts.select { |_, v| v == highest_count }
    top_langs.keys
  end

  def languages
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
